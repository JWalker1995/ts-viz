﻿#include <iostream>

#include "argparse/include/argparse/argparse.hpp"

#include "log.h"
#include "spdlog/sinks/stdout_color_sinks.h"

#include "app/appcontext.h"
#include "app/options.h"
#include "app/mainloop.h"
#include "app/quitexception.h"

#include "version.h"
#include "stream/filepoller.h"
#include "stream/jsonunwrapper.h"
#include "program/programmanager.h"
#include "stream/inputmanager.h"
#include "util/testrunner.h"

#include "defs/CHUNK_SIZE_LOG2.h"
#include "defs/ENABLE_CONV_MIN_COMPUTE_FLAG.h"
#include "defs/ENABLE_PMUOI_FLAG.h"

int main(int argc, char **argv) {
    // Setup argument parser
    argparse::ArgumentParser program("ts-viz", tsVizVersion);
    program.add_description("A time series visualizer and processor");

    program.add_argument("program-path")
            .help("The path to the program file or stream")
            .required();

    program.add_argument("data-path")
            .help("The path to the data file or stream")
            .required();

    program.add_argument("--log-level")
            .help("Minimum logging level to output")
            .default_value(spdlog::level::info)
            .action(spdlog::level::from_str);

    program.add_argument("--wisdom-dir")
            .help("The directory to load and save wisdom to/from")
            .default_value(std::string("."));

    program.add_argument("--require-existing-wisdom")
            .help("Disable generating fftw's wisdom; exit if they don't exist in filesystem")
            .default_value(false)
            .implicit_value(true);

    program.add_argument("--dont-write-wisdom")
            .help("Disable writing fftw's wisdom files")
            .default_value(false)
            .implicit_value(true);

#if ENABLE_CONV_MIN_COMPUTE_FLAG
    program.add_argument("--conv-min-compute-log2")
            .help("For calculating convolutions, advance in (2 ^ value) element increments")
            .default_value(0u)
            .action([](const std::string& value) -> unsigned int { return std::max(0, std::min(std::stoi(value), CHUNK_SIZE_LOG2)); });
#endif

    program.add_argument("--gc-memory-limit")
            .help("Enable garbage collector above this value")
            .default_value(static_cast<std::size_t>(-1))
            .action([](const std::string& value) -> std::size_t { return std::stoull(value); });

#if ENABLE_PMUOI_FLAG
    program.add_argument("--print-memory-usage-output-index")
            .help("Prints the memory usage required to compute and output the nth record")
            .default_value(static_cast<std::size_t>(-1))
            .action([](const std::string& value) -> std::size_t { return std::stoull(value); });
#endif

    try {
        program.parse_args(argc, argv);
    }
    catch (const std::runtime_error &err) {
        std::cerr << err.what() << std::endl;
        std::cerr << program;
        return 1;
    }

    app::Options::getMutableInstance().wisdomDir = program.get<std::string>("--wisdom-dir");
    app::Options::getMutableInstance().requireExistingWisdom = program.get<bool>("--require-existing-wisdom");
    app::Options::getMutableInstance().writeWisdom = !program.get<bool>("--dont-write-wisdom");
#if ENABLE_CONV_MIN_COMPUTE_FLAG
    app::Options::getMutableInstance().convMinComputeLog2 = program.get<unsigned int>("--conv-min-compute-log2");
#endif
    app::Options::getMutableInstance().gcMemoryLimit = program.get<std::size_t>("--gc-memory-limit");
#if ENABLE_PMUOI_FLAG
    app::Options::getMutableInstance().printMemoryUsageOutputIndex = program.get<std::size_t>("--print-memory-usage-output-index");
#endif

    // Setup logger
    spdlog::set_default_logger(nullptr);
    spdlog::set_default_logger(spdlog::stderr_color_mt(""));

    spdlog::level::level_enum logLevel = program.get<spdlog::level::level_enum>("--log-level");
    if (logLevel >= 0 && logLevel < SPDLOG_ACTIVE_LEVEL) {
        spdlog::critical("Tried to set --log-level flag to {}, which is below (more verbose) than the compile-time SPDLOG_ACTIVE_LEVEL, which is {}", spdlog::level::level_string_views[logLevel], spdlog::level::level_string_views[SPDLOG_ACTIVE_LEVEL]);
        return 1;
    } else {
        spdlog::set_level(logLevel);
    }

    // Setup context
    app::AppContext context;

    // Print some debug info
#ifndef NDEBUG
    SPDLOG_INFO("This is a debug build!");
#else
    SPDLOG_INFO("This is a release build!");
#endif

    SPDLOG_INFO("Version is {}", tsVizVersion);

    SPDLOG_INFO("A pointer is {} bits", sizeof(void*) * CHAR_BIT);
    SPDLOG_INFO("An unsigned int is {} bits", sizeof(unsigned int) * CHAR_BIT);
    SPDLOG_INFO("An unsigned long long is {} bits", sizeof(unsigned long long) * CHAR_BIT);
    SPDLOG_INFO("Chunk size log2 is: {}", CHUNK_SIZE_LOG2);

    SPDLOG_INFO("Running tests...");
    util::TestRunner::getInstance().run();

    SPDLOG_INFO("Starting...");

    context.get<stream::FilePoller>().addFile<stream::JsonUnwrapper<program::ProgramManager>>(program.get<std::string>("program-path"));
    context.get<stream::FilePoller>().addFile<stream::JsonUnwrapper<stream::InputManager>>(program.get<std::string>("data-path"));

    // Run it!!!
    try {
        context.get<app::MainLoop>().run();
    } catch (const app::QuitException &) {
        // Normal exit
    } catch (const std::exception &exception) {
        SPDLOG_CRITICAL("Uncaught exception: {}", exception.what());
        return 1;
    }

    SPDLOG_INFO("Ending...");
    SPDLOG_INFO("AppContext type counts: managed={}, total={}", context.getManagedTypeCount(), context.getTotalTypeCount());
    return 0;
}
