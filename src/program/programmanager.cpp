#include "programmanager.h"

#include "log.h"

#include "defs/ENABLE_GRAPHICS.h"
#if ENABLE_GRAPHICS
#include "render/renderer.h"
#endif

#include "stream/outputmanager.h"
#include "program/resolver.h"
#include "series/invalidparameterexception.h"
#include "util/jsontostring.h"

namespace program {

ProgramManager::ProgramManager(app::AppContext &context)
    : context(context)
{}

void ProgramManager::recvRecord(const rapidjson::Document &row) {
    SPDLOG_DEBUG("Received program {}", util::jsonToStr(row));

#if ENABLE_GRAPHICS
    if (context.has<render::Renderer>()) {
        context.get<render::Renderer>().clearSeries();
    }
#endif

    if (context.has<stream::OutputManager>()) {
        context.get<stream::OutputManager>().clearEmitters();
    }

    if (!row.IsArray()) {
        SPDLOG_WARN("Top-level program node must be an array for line {}", util::jsonToStr(row));
        return;
    }

    std::unordered_map<std::string, ProgObj> cache;

    for (rapidjson::SizeType i = 0; i < row.Size(); i++) {
        try {
            ProgObj obj = makeProgObj("#/" + std::to_string(i), row[i], cache);
#if ENABLE_GRAPHICS
            if (std::holds_alternative<render::SeriesRenderer *>(obj)) {
                context.get<render::Renderer>().addSeries(std::get<render::SeriesRenderer *>(obj));
            } else
#endif
            if (std::holds_alternative<stream::SeriesEmitter *>(obj)) {
                context.get<stream::OutputManager>().addEmitter(std::get<stream::SeriesEmitter *>(obj));
            } else if (std::holds_alternative<std::monostate>(obj)) {
                // Do nothing
            } else {
                throw InvalidProgramException("Value for top-level entry at index " + std::to_string(i) + " is a " + progObjTypeNames[obj.index()] + ", but must be a series renderer or an output emitter");
            }
        } catch (const InvalidProgramException &ex) {
            SPDLOG_WARN("InvalidProgramException: {}", ex.what());
        }
    }

    hasProgram = true;
}

void ProgramManager::end() {
    assert(running);
    running = false;


}

ProgObj ProgramManager::makeProgObj(const std::string &path, const rapidjson::Value &value, std::unordered_map<std::string, ProgObj> &cache) {
    ProgObj res;

    switch (value.GetType()) {
        case rapidjson::Type::kNullType: break;
        case rapidjson::Type::kFalseType: res = false; break;
        case rapidjson::Type::kTrueType: res = true; break;
        case rapidjson::Type::kNumberType: res = UncastNumber(value.GetDouble()); break;
        case rapidjson::Type::kStringType: res = std::string(value.GetString(), value.GetStringLength()); break;
        case rapidjson::Type::kObjectType: {
            const rapidjson::Value::ConstObject &obj = value.GetObject();
            if (obj.MemberCount() == 1) {
                rapidjson::Value::ConstMemberIterator ref = obj.FindMember("$ref");
                if (ref != obj.MemberEnd() && ref->value.IsString()) {
                    std::string refPath(ref->value.GetString(), ref->value.GetStringLength());
                    std::unordered_map<std::string, ProgObj>::const_iterator found = cache.find(refPath);
                    if (found != cache.cend()) {
                        res = found->second;
                        break;
                    } else {
                        throw InvalidProgramException("Path does not exist: " + refPath + " from " + path);
                    }
                }
            }
            throw InvalidProgramException("Cannot parse " + util::jsonToStr(value));
        }
        case rapidjson::Type::kArrayType: {
            const rapidjson::Value::ConstArray &arr = value.GetArray();
            if (arr.Size() < 1 || !arr[0].IsString()) {
                throw InvalidProgramException("Array must have length >= 1 and first item must be a string: " + util::jsonToStr(value));
            }
            std::string name(arr[0].GetString(), arr[0].GetStringLength());
            std::vector<ProgObj> args;
            for (std::size_t i = 1; i < arr.Size(); i++) {
                args.push_back(makeProgObj(path + "/" + std::to_string(i), arr[i], cache));
            }
            try {
                res = context.get<Resolver>().call(name, args);
                break;
            } catch (const Resolver::UnresolvedCallException &ex) {
                throw InvalidProgramException(std::string("UnresolvedCallException: ") + ex.what());
            } catch (const Resolver::AssertionFailureException &ex) {
                throw InvalidProgramException(std::string("AssertionFailureException: ") + ex.what());
            } catch (const series::InvalidParameterException &ex) {
                throw InvalidProgramException(std::string("InvalidParameterException: ") + ex.what());
            }
        }
    }

    bool inserted = cache.emplace(path, res).second;
    assert(inserted);

    return res;
}

}
