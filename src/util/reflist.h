#pragma once

#include <cassert>
#include <vector>

namespace util {

template <typename Type, typename ContainerType = std::vector<Type *>>
class RefList {
public:
    typedef typename ContainerType::iterator iterator;
    typedef typename ContainerType::const_iterator const_iterator;

    RefList() {}

    void add(Type *inst) {
        data.push_back(inst);
    }

    void remove(Type *inst) {
        typename ContainerType::const_iterator found = std::find(data.cbegin(), data.cend(), inst);
        assert(found != data.cend());
        data.erase(found);
    }

    iterator begin() { return data.begin(); }
    iterator end() { return data.end(); }
    const_iterator cbegin() const { return data.cbegin(); }
    const_iterator cend() const { return data.cend(); }

    template <typename... ArgTypes>
    class Invoker {
    public:
        Invoker() = delete;

        template <void (Type::*Method)(ArgTypes...)>
        static void call(const RefList &refList, ArgTypes... args) {
            typename ContainerType::const_iterator i = refList.data.cbegin();
            while (i != refList.data.cend()) {
                ((*i)->*Method)(std::forward<ArgTypes>(args)...);
                i++;
            }
        }
    };

private:
    ContainerType data;
};

}
