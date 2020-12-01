#pragma once

#include <vector>

#include "jw_util/thread.h"

#include "series/dataseries.decl.h"
#include "series/dataseriesbase.h"
#include "series/chunkptr.h"
#include "series/chunk.h"
#include "series/chunkimpl.h"

namespace series {

template <typename ElementType, std::size_t _size>
class DataSeries : public DataSeriesBase {
public:
    static constexpr std::size_t size = _size;

    DataSeries(app::AppContext &context)
        : DataSeriesBase(context)
    {
        jw_util::Thread::set_main_thread();
    }

    template <std::size_t desiredSize = CHUNK_SIZE>
    ChunkPtr<ElementType, size> getChunk(std::size_t chunkIndex) {
        static_assert(size == desiredSize, "DataSeries chunk size doesn't match desired size");

        jw_util::Thread::assert_main_thread();

        while (chunks.size() <= chunkIndex) {
            chunks.emplace_back(ChunkPtr<ElementType, size>::null());
        }
        if (!chunks[chunkIndex].has()) {
            std::size_t depStackSize = getDependencyStack().size();
            chunks[chunkIndex] = ChunkPtr<ElementType, size>::construct(makeChunk(chunkIndex));
            while (getDependencyStack().size() > depStackSize) {
                getDependencyStack().back()->addDependent(chunks[chunkIndex].clone());
                getDependencyStack().pop_back();
            }
            chunks[chunkIndex]->notify();
        }

        getDependencyStack().push_back(chunks[chunkIndex].operator->());

        return chunks[chunkIndex].clone();
    }

    virtual Chunk<ElementType, size> *makeChunk(std::size_t chunkIndex) = 0;

protected:
    template <typename ComputerType>
    Chunk<ElementType, size> *constructChunk(ComputerType &&computer) {
        return new ChunkImpl<ElementType, size, ComputerType>(this, std::move(computer));
    }

private:
//    std::size_t offset = 0;
    std::vector<ChunkPtr<ElementType, size>> chunks;
};

}
