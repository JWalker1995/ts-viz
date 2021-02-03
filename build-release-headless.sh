#! /bin/sh -e
mkdir -p "src/defs"
cd "src/shaders"
(xxd -i < fill.frag.glsl > fill.frag.glsl.h && echo ",0x00" >> fill.frag.glsl.h)
(xxd -i < fill.vert.glsl > fill.vert.glsl.h && echo ",0x00" >> fill.vert.glsl.h)
(xxd -i < main.frag.glsl > main.frag.glsl.h && echo ",0x00" >> main.frag.glsl.h)
(xxd -i < main.vert.glsl > main.vert.glsl.h && echo ",0x00" >> main.vert.glsl.h)
cd "../.."
(echo "#define SPDLOG_ACTIVE_LEVEL SPDLOG_LEVEL_TRACE" > src/defs/SPDLOG_ACTIVE_LEVEL.h)
(echo "#define ENABLE_GRAPHICS false" > src/defs/ENABLE_GRAPHICS.h)
(echo "#define ENABLE_GUI false" > src/defs/ENABLE_GUI.h)
(echo "#define GLBUFFER_MAX_MERGE_GAP 64" > src/defs/GLBUFFER_MAX_MERGE_GAP.h)
(echo "#define GLBUFFER_FLUSH_EXPLICIT 1" > src/defs/GLBUFFER_FLUSH_EXPLICIT.h)
(echo "#define GLBUFFER_ASSERT_BINDINGS !defined(NDEBUG) && 1" > src/defs/GLBUFFER_ASSERT_BINDINGS.h)
(echo "#define GLVAO_ASSERT_BINDINGS !defined(NDEBUG) && 1" > src/defs/GLVAO_ASSERT_BINDINGS.h)
(echo "#define PRINT_TICK_ORDER !defined(NDEBUG) && 0" > src/defs/PRINT_TICK_ORDER.h)
(echo "#define ENABLE_CHUNK_NAMES !defined(NDEBUG) && 1" > src/defs/ENABLE_CHUNK_NAMES.h)
(echo "#define ENABLE_CHUNK_MULTITHREADING 0" > src/defs/ENABLE_CHUNK_MULTITHREADING.h)
(echo "#define ENABLE_FILEPOLLER_YIELDING 0" > src/defs/ENABLE_FILEPOLLER_YIELDING.h)
(echo "#define ENABLE_PMUOI_FLAG 1" > src/defs/ENABLE_PMUOI_FLAG.h)
(echo "#define INPUT_SERIES_ELEMENT_TYPE double" > src/defs/INPUT_SERIES_ELEMENT_TYPE.h)
(echo "#define CHUNK_SIZE_LOG2 16" > src/defs/CHUNK_SIZE_LOG2.h)
(echo "#define CONV_CACHE_KERNEL_FFT_GTE_SIZE_LOG2 10" > src/defs/CONV_CACHE_KERNEL_FFT_GTE_SIZE_LOG2.h)
(echo "#define CONV_CACHE_TS_FFT_GTE_SIZE_LOG2 16" > src/defs/CONV_CACHE_TS_FFT_GTE_SIZE_LOG2.h)
(echo "#define CONV_USE_FFT_GTE_SIZE_LOG2 0" > src/defs/CONV_USE_FFT_GTE_SIZE_LOG2.h)
(echo "#define ENABLE_CONV_MIN_COMPUTE_FLAG false" > src/defs/ENABLE_CONV_MIN_COMPUTE_FLAG.h)
(echo "#define CONV_VARIANT series::convvariant::ZpTs1" > src/defs/CONV_VARIANT.h)
(echo "#define FFTWX_PLANNING_LEVEL FFTW_MEASURE" > src/defs/FFTWX_PLANNING_LEVEL.h)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/main.cpp -o ./src/main.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/version.cpp -o ./src/version.cpp.o "-DTSVIZ_VERSION=0.1")
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/app/appcontext.cpp -o ./src/app/appcontext.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/app/mainloop.cpp -o ./src/app/mainloop.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/app/signalhandler.cpp -o ./src/app/signalhandler.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/app/tickercontext.cpp -o ./src/app/tickercontext.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/app/window.cpp -o ./src/app/window.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/builder/binary.cpp -o ./src/builder/binary.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/builder/cast.cpp -o ./src/builder/cast.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/builder/check.cpp -o ./src/builder/check.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/builder/conv.double.cpp -o ./src/builder/conv.double.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/builder/conv.float.cpp -o ./src/builder/conv.float.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/builder/delay.cpp -o ./src/builder/delay.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/builder/delta.cpp -o ./src/builder/delta.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/builder/emit.cpp -o ./src/builder/emit.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/builder/inf.cpp -o ./src/builder/inf.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/builder/info.cpp -o ./src/builder/info.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/builder/input.cpp -o ./src/builder/input.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/builder/norm.cpp -o ./src/builder/norm.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/builder/plot.cpp -o ./src/builder/plot.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/builder/random.cpp -o ./src/builder/random.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/builder/scan.cpp -o ./src/builder/scan.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/builder/unary.cpp -o ./src/builder/unary.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/graphics/gl.cpp -o ./src/graphics/gl.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/graphics/glvao.cpp -o ./src/graphics/glvao.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/graphics/gpuprogram.cpp -o ./src/graphics/gpuprogram.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/graphics/type/element.cpp -o ./src/graphics/type/element.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/graphics/type/point.cpp -o ./src/graphics/type/point.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/imgui/imgui.cpp -o ./src/imgui/imgui.cpp.o -I./third_party/imgui/ -I./third_party/imgui/examples/)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/imgui/imgui_demo.cpp -o ./src/imgui/imgui_demo.cpp.o -I./third_party/imgui/ -I./third_party/imgui/examples/)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/imgui/imgui_draw.cpp -o ./src/imgui/imgui_draw.cpp.o -I./third_party/imgui/ -I./third_party/imgui/examples/)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/imgui/imgui_impl_glfw.cpp -o ./src/imgui/imgui_impl_glfw.cpp.o -I./third_party/imgui/ -I./third_party/imgui/examples/)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/imgui/imgui_impl_opengl3.cpp -o ./src/imgui/imgui_impl_opengl3.cpp.o -I./third_party/imgui/ -I./third_party/imgui/examples/)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/imgui/imgui_widgets.cpp -o ./src/imgui/imgui_widgets.cpp.o -I./third_party/imgui/ -I./third_party/imgui/examples/)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/jw_util/thread.cpp -o ./src/jw_util/thread.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/program/programmanager.cpp -o ./src/program/programmanager.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/program/resolver.cpp -o ./src/program/resolver.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/render/axes.cpp -o ./src/render/axes.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/render/camera.cpp -o ./src/render/camera.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/render/dataseriesrenderer.cpp -o ./src/render/dataseriesrenderer.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/render/imguirenderer.cpp -o ./src/render/imguirenderer.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/render/renderer.cpp -o ./src/render/renderer.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/render/seriesrenderer.cpp -o ./src/render/seriesrenderer.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/render/shaders.cpp -o ./src/render/shaders.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/render/program/fillprogram.cpp -o ./src/render/program/fillprogram.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/render/program/linestripprogram.cpp -o ./src/render/program/linestripprogram.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/render/program/program.cpp -o ./src/render/program/program.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/series/chunk.cpp -o ./src/series/chunk.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/series/chunkbase.cpp -o ./src/series/chunkbase.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/series/chunkptr.cpp -o ./src/series/chunkptr.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/series/chunkptrbase.cpp -o ./src/series/chunkptrbase.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/series/dataseries.cpp -o ./src/series/dataseries.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/series/dataseriesbase.cpp -o ./src/series/dataseriesbase.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/series/fftwx.cpp -o ./src/series/fftwx.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/series/garbagecollector.cpp -o ./src/series/garbagecollector.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/stream/dataseriesemitter.cpp -o ./src/stream/dataseriesemitter.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/stream/filepoller.cpp -o ./src/stream/filepoller.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/stream/inputmanager.cpp -o ./src/stream/inputmanager.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/stream/outputmanager.cpp -o ./src/stream/outputmanager.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/util/jsontostring.cpp -o ./src/util/jsontostring.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++  -c ./src/util/testrunner.cpp -o ./src/util/testrunner.cpp.o)
(clang++ -std=c++17 -Wall -Werror -Wno-missing-braces -Wno-unused -Wno-expansion-to-defined -I./src -I./third_party -I./third_party/spdlog/include -I./third_party/rapidjson/include -DIMGUI_IMPL_OPENGL_LOADER_GLEW -O3 -march=native -ffast-math -fno-finite-math-only -fvisibility=hidden -DNDEBUG -stdlib=libc++ -framework OpenGL `pkg-config --static --libs glfw3 glew fftw3 fftw3f fmt` -o ./ts-viz src/main.cpp.o src/version.cpp.o src/app/appcontext.cpp.o src/app/mainloop.cpp.o src/app/signalhandler.cpp.o src/app/tickercontext.cpp.o src/app/window.cpp.o src/builder/binary.cpp.o src/builder/cast.cpp.o src/builder/check.cpp.o src/builder/conv.double.cpp.o src/builder/conv.float.cpp.o src/builder/delay.cpp.o src/builder/delta.cpp.o src/builder/emit.cpp.o src/builder/inf.cpp.o src/builder/info.cpp.o src/builder/input.cpp.o src/builder/norm.cpp.o src/builder/plot.cpp.o src/builder/random.cpp.o src/builder/scan.cpp.o src/builder/unary.cpp.o src/graphics/gl.cpp.o src/graphics/glvao.cpp.o src/graphics/gpuprogram.cpp.o src/graphics/type/element.cpp.o src/graphics/type/point.cpp.o src/imgui/imgui.cpp.o src/imgui/imgui_demo.cpp.o src/imgui/imgui_draw.cpp.o src/imgui/imgui_impl_glfw.cpp.o src/imgui/imgui_impl_opengl3.cpp.o src/imgui/imgui_widgets.cpp.o src/jw_util/thread.cpp.o src/program/programmanager.cpp.o src/program/resolver.cpp.o src/render/axes.cpp.o src/render/camera.cpp.o src/render/dataseriesrenderer.cpp.o src/render/imguirenderer.cpp.o src/render/renderer.cpp.o src/render/seriesrenderer.cpp.o src/render/shaders.cpp.o src/render/program/fillprogram.cpp.o src/render/program/linestripprogram.cpp.o src/render/program/program.cpp.o src/series/chunk.cpp.o src/series/chunkbase.cpp.o src/series/chunkptr.cpp.o src/series/chunkptrbase.cpp.o src/series/dataseries.cpp.o src/series/dataseriesbase.cpp.o src/series/fftwx.cpp.o src/series/garbagecollector.cpp.o src/stream/dataseriesemitter.cpp.o src/stream/filepoller.cpp.o src/stream/inputmanager.cpp.o src/stream/outputmanager.cpp.o src/util/jsontostring.cpp.o src/util/testrunner.cpp.o)
