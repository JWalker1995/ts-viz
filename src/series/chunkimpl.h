#pragma once

#include "series/chunk.h"

namespace series {

template <typename ElementType, std::size_t size, typename ComputerType>
class ChunkImpl final /* final because we want sizeof(this) to be correct */ : public Chunk<ElementType, size> {
public:
    ChunkImpl(DataSeriesBase *ds, ComputerType &&computer)
        : Chunk<ElementType, size>(ds)
        , computer(std::move(computer))
    {
        this->updateMemoryUsage(sizeof(*this));
    }

    ~ChunkImpl() {
#ifndef NDEBUG
        assert(!isRunning);
#endif

        if (!this->isDone()) {
            releaseComputer();
        }

#ifndef NDEBUG
        assert(!hasValue);
#endif

        this->updateMemoryUsage(-sizeof(*this));
    }

    unsigned int compute(ElementType *dst, unsigned int computedCount) override {
#ifndef NDEBUG
        static constexpr std::size_t sizeofThis = sizeof(ChunkImpl<ElementType, size, ComputerType>);
        static constexpr std::size_t sizeofComputer = sizeof(ComputerType);
        assert(hasValue);

        assert(!isRunning);
        isRunning = true;
#endif

        return computer(dst, computedCount);

#ifndef NDEBUG
        assert(isRunning);
        isRunning = false;
#endif
    }

    void releaseComputer() override {
#ifndef NDEBUG
        assert(hasValue);
        hasValue = false;

        assert(!isRunning);
#endif

        computer.~ComputerType();
    }

private:
#ifndef NDEBUG
    bool hasValue = true;
    bool isRunning = false;
#endif

    union {
        ComputerType computer;
        char _; // Prevent destruction of computer
    };
};

}
