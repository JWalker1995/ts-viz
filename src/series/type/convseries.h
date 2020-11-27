#pragma once

#include <complex>

#include "series/dataseries.h"
#include "series/fftwx.h"
#include "series/type/fftseries.h"
#include "series/invalidparameterexception.h"

#include "defs/CONV_CACHE_KERNEL_FFT_ABOVE_SIZE_LOG2.h"
#include "defs/CONV_CACHE_TS_FFT_ABOVE_SIZE_LOG2.h"
#include "defs/CONV_USE_FFT_ABOVE_SIZE_LOG2.h"
#include "defs/CONV_KERNEL_FFT_PADDING_TYPE.h"
#include "defs/CONV_TS_FFT_PADDING_TYPE.h"

namespace {

template <template <unsigned int> typename CreateType, unsigned int count>
class DispatchToTemplate;

template <template <unsigned int> typename ClassType>
class DispatchToTemplate<ClassType, 0> {
public:
    template <typename ReturnType, typename... ArgTypes>
    static ReturnType call(unsigned int value, ArgTypes &&...) {
        (void) value;
        assert(false);
    }
};

template <template <unsigned int> typename ClassType, unsigned int count>
class DispatchToTemplate {
public:
    template <typename ReturnType, typename... ArgTypes>
    static ReturnType call(unsigned int value, ArgTypes &&... args) {
        if (value == count - 1) {
            return ClassType<count - 1>::call(std::forward<ArgTypes>(args)...);
        } else {
            return DispatchToTemplate<ClassType, count - 1>::template call<ReturnType, ArgTypes...>(value, std::forward<ArgTypes>(args)...);
        }
    }
};

}

namespace series {

// Two types of FFT decompositions:
//   1. Persistent - stored in a time series dependency, and always calculated (whether or not it's needed). Only ever calculated once.
//   2. Transient - calculated when needed, and thrown away.


template <typename ElementType>
auto getKernelPartitionFfts(app::AppContext &context, DataSeries<ElementType> &arg, std::size_t chunkIndex) {
    static constexpr unsigned int begin = CONV_CACHE_KERNEL_FFT_ABOVE_SIZE_LOG2;
    static constexpr unsigned int end = CHUNK_SIZE_LOG2 + 1;
    return getKernelPartitionFfts<ElementType, begin, end>(context, arg, chunkIndex, std::make_index_sequence<end - begin>{});
}
template <typename ElementType, std::size_t begin, std::size_t end, std::size_t... is>
auto getKernelPartitionFfts(app::AppContext &context, DataSeries<ElementType> &arg, std::size_t chunkIndex, std::index_sequence<is...>) {
#define NUMS (1u << (begin + is))
    return std::tuple<ChunkPtr<typename fftwx_impl<ElementType>::Complex, NUMS * 2>...>(FftSeries<ElementType, NUMS, CONV_KERNEL_FFT_PADDING_TYPE>::create(context, arg).template getChunk<NUMS * 2>(chunkIndex)...);
#undef NUMS
}

template <typename ElementType>
auto getTsPartitionFfts(app::AppContext &context, DataSeries<ElementType> &arg, std::size_t offset) {
    static constexpr unsigned int begin = CONV_CACHE_TS_FFT_ABOVE_SIZE_LOG2;
    static constexpr unsigned int end = CHUNK_SIZE_LOG2 + 1;
    return getTsPartitionFfts<ElementType, begin, end>(context, arg, offset, std::make_index_sequence<end - begin>{});
}
template <typename ElementType, std::size_t begin, std::size_t end, std::size_t... is>
auto getTsPartitionFfts(app::AppContext &context, DataSeries<ElementType> &arg, std::size_t offset, std::index_sequence<is...>) {
#define NUMS (1u << (begin + is))
    return std::tuple<std::array<ChunkPtr<typename fftwx_impl<ElementType>::Complex, NUMS * 2>, CHUNK_SIZE / NUMS>...>(getTsFftArr(FftSeries<ElementType, NUMS, CONV_TS_FFT_PADDING_TYPE>::create(context, arg), offset)...);
#undef NUMS
}
template <typename ElementType, std::size_t partitionSize>
auto getTsFftArr(FftSeries<ElementType, partitionSize, CONV_TS_FFT_PADDING_TYPE> &tsFft, std::size_t offset) {
    return getTsFftArr(tsFft, offset, std::make_index_sequence<CHUNK_SIZE / partitionSize>{});
}
template <typename ElementType, std::size_t partitionSize, std::size_t... is>
auto getTsFftArr(FftSeries<ElementType, partitionSize, CONV_TS_FFT_PADDING_TYPE> &tsFft, std::size_t offset, std::index_sequence<is...>) {
    assert(offset % partitionSize == 0);

    return std::array<ChunkPtr<typename fftwx_impl<ElementType>::Complex, partitionSize * 2>, sizeof...(is)>{
        tsFft.template getChunk<partitionSize * 2>(offset / partitionSize + is)...
    };
}

template <typename ElementType>
class ConvSeries : public DataSeries<ElementType> {
private:
    typedef fftwx_impl<ElementType> fftwx;
    typedef typename fftwx::Complex ComplexType;

public:
    ConvSeries(app::AppContext &context, DataSeries<ElementType> &kernel, DataSeries<ElementType> &ts, std::int64_t kernelSize, bool backfillZeros)
        : DataSeries<ElementType>(context)
        , kernel(kernel)
        , ts(ts)
        , kernelSize(kernelSize)
        , backfillZeros(backfillZeros)
    {
        if (kernelSize <= 0) {
            throw series::InvalidParameterException("ConvSeries: kernelSize must be greater than zero");
        }

        FftwPlanner<ElementType>::init();
    }

    ~ConvSeries() {}

    Chunk<ElementType> *makeChunk(std::size_t chunkIndex) override {
        FftSeries<ElementType, CHUNK_SIZE, CONV_KERNEL_FFT_PADDING_TYPE> &kernelFft = FftSeries<ElementType, CHUNK_SIZE, CONV_KERNEL_FFT_PADDING_TYPE>::create(this->context, kernel);
        FftSeries<ElementType, CHUNK_SIZE, CONV_TS_FFT_PADDING_TYPE> &tsFft = FftSeries<ElementType, CHUNK_SIZE, CONV_TS_FFT_PADDING_TYPE>::create(this->context, ts);

        // 1 -> 1
        // 2 -> 1
        std::size_t numKernelChunks = (kernelSize + CHUNK_SIZE - 1) / CHUNK_SIZE;
        std::vector<std::pair<ChunkPtr<ElementType>, ChunkPtr<ComplexType, CHUNK_SIZE * 2>>> kernelChunks;
        kernelChunks.reserve(numKernelChunks);
        for (std::size_t i = 0; i < numKernelChunks; i++) {
            kernelChunks.emplace_back(kernel.getChunk(i), kernelFft.template getChunk<CHUNK_SIZE * 2>(i));
        }

        // 1 -> 1
        // 2 -> 2
        std::size_t numTsChunks = std::min((kernelSize + CHUNK_SIZE - 2) / CHUNK_SIZE, chunkIndex) + 1;
        std::vector<std::pair<ChunkPtr<ElementType>, ChunkPtr<ComplexType, CHUNK_SIZE * 2>>> tsChunks;
        tsChunks.reserve(numTsChunks);
        for (std::size_t i = 0; i < numTsChunks; i++) {
            tsChunks.emplace_back(ts.getChunk(chunkIndex - i), tsFft.template getChunk<CHUNK_SIZE * 2>(chunkIndex - i));
        }

        auto kernelPartitionFfts0 = getKernelPartitionFfts<ElementType>(this->context, kernel, 0);
        auto kernelPartitionFfts1 = getKernelPartitionFfts<ElementType>(this->context, kernel, 1);

        auto tsPartitionedFfts = getTsPartitionFfts<ElementType>(this->context, ts, chunkIndex * CHUNK_SIZE);

        return this->constructChunk([
            this,
            kernelChunks = std::move(kernelChunks),
            tsChunks = std::move(tsChunks),
            kernelPartitionFfts0 = std::move(kernelPartitionFfts0),
            kernelPartitionFfts1 = std::move(kernelPartitionFfts1),
            tsPartitionedFfts = std::move(tsPartitionedFfts)
        ](ElementType *dst, unsigned int computedCount) -> unsigned int {
            for (std::size_t i = 1; i < tsChunks.size(); i++) {
                if (tsChunks[i].first->getComputedCount() != CHUNK_SIZE) {
                    return 0;
                }
            }

            unsigned int endCount = tsChunks[0].first->getComputedCount();
            if (endCount == computedCount) {
                return endCount;
            }

            if (computedCount == 0) {
                // TODO: See if this segfaults?
                typename fftwx::Complex test[CHUNK_SIZE * 2];

                const typename FftwPlanner<ElementType>::IO planIO = FftwPlanner<ElementType>::request();

                std::size_t len = std::min(kernelChunks.size(), tsChunks.size());
                for (std::size_t i = 1; i < len; i++) {
                    // Elementwise multiply
                    for (std::size_t i = 0; i < CHUNK_SIZE * 2; i++) {
                        planIO.fft[i] = kernelChunks[1].second->getElement(i) * tsChunks[1].second->getElement(i);
                    }

                    typename fftwx::Plan planBwd = FftwPlanner<ElementType>::template getPlanBwd<CHUNK_SIZE * 2>();
                    fftwx::execute_dft_c2r(planBwd, planIO.fft, planIO.out);

                    if (i == 1) {
                        std::copy_n(planIO.out + CHUNK_SIZE, CHUNK_SIZE, dst);
                    } else {
                        for (std::size_t i = 0; i < CHUNK_SIZE; i++) {
                            dst[i] += planIO.out[CHUNK_SIZE + i];
                        }
                    }
                }

                assert(len > 0);
                if (len <= 1) {
                    std::fill_n(dst, CHUNK_SIZE, static_cast<ElementType>(0.0));
                }

                FftwPlanner<ElementType>::release(planIO);
            }

            while (computedCount < endCount) {
                // Divide kernel into sections: [0:1, 1:2, 2:4, 4:8, 8:16, ...]
                // Result is the convolution of each section with TS, added together
                // [K x T -> R]
                // For dst[0], we add [0:1 x 0:1 -> 0:1]
                // For dst[1], we add [0:1 x 1:2 -> 1:2], [1:2 x 0:1 -> 1:2]
                // For dst[2], we add [0:1 x 2:3 -> 2:3], [1:2 x 1:2 -> 2:3], [2:4 x 0:2 -> 2:4]
                // For dst[3], we add [0:1 x 3:4 -> 3:4], [1:2 x 2:3 -> 3:4]

                // We can jump. We could have processed dst[2:4] as:
                // For dst[2:4], we add [0:2 x 2:4 -> 2:4], [2:4 x 0:2 -> 2:4]

                /*
                10010100 <- prev
                10110110 <- targ
                00000100 <- step

                10011000 <- prev
                10110110 <- targ
                00001000 <- step

                10100000 <- prev
                10110110 <- targ
                00010000 <- step

                10110000 <- prev
                10110110 <- targ
                00000100 <- step

                10110100 <- prev
                10110110 <- targ
                00000010 <- step
                */

                unsigned int countLsz = sizeof(unsigned int) * CHAR_BIT - 1 - __builtin_clz(computedCount ^ (computedCount - 1));
                if (countLsz > CHUNK_SIZE_LOG2) { countLsz = CHUNK_SIZE_LOG2; }
                unsigned int maxStep = sizeof(unsigned int) * CHAR_BIT - 1 - __builtin_clz(endCount - computedCount);
                unsigned int stepLog2 = std::min(countLsz, maxStep);

                for (unsigned int i = stepLog2; i <= countLsz; i++) {        
                    DispatchToTemplate<KernelPartitionFiller, CHUNK_SIZE_LOG2 + 1>::template call<void>(i, dst, computedCount, kernelChunks[0].first, tsChunks[0].first, kernelPartitionFfts1, tsPartitionedFfts, 1);
                }

                DispatchToTemplate<KernelPartitionFiller, CHUNK_SIZE_LOG2 + 1>::template call<void>(stepLog2, dst, computedCount, kernelChunks[0].first, tsChunks[0].first, kernelPartitionFfts0, tsPartitionedFfts, 0);

                computedCount += 1u << stepLog2;
            }

            return CHUNK_SIZE;
        });
    }

    template <unsigned int fillSizeLog2>
    struct KernelPartitionFiller {
        static void call(
                ElementType *dst,
                unsigned int computedCount,
                const ChunkPtr<ElementType> &kernelChunk,
                const ChunkPtr<ElementType> &tsChunk,
                const typename std::result_of<decltype(&getKernelPartitionFfts<ElementType>)(app::AppContext &, DataSeries<ElementType> &, std::size_t)>::type &kernelPartitionFfts,
                const typename std::result_of<decltype(&getTsPartitionFfts<ElementType>)(app::AppContext &, DataSeries<ElementType> &, std::size_t)>::type &tsPartitionedFfts,
                bool kernelPartitionIndex // Either the first or second partition
        ) {
            static_assert(fillSizeLog2 <= CHUNK_SIZE_LOG2, "We should not be generating code to handle larger-than-chunk-size fills");

            static_assert((sizeof(ElementType) << CONV_USE_FFT_ABOVE_SIZE_LOG2) >= 16, "Data subscripts won't be aligned to 16-byte boundaries");

            static constexpr unsigned int fillSize = 1u << fillSizeLog2;
            assert(computedCount % fillSize == 0);

            unsigned int kernelOffset = fillSize * kernelPartitionIndex;
            unsigned int tsOffset = computedCount - fillSize * kernelPartitionIndex;

            if (fillSizeLog2 >= CONV_USE_FFT_ABOVE_SIZE_LOG2) {
                typename fftwx::Plan planFwd = FftwPlanner<ElementType>::template getPlanFwd<fillSize>();
                typename fftwx::Plan planBwd = FftwPlanner<ElementType>::template getPlanBwd<fillSize>();

                const typename FftwPlanner<ElementType>::IO kernelPlanIO = fillSizeLog2 < CONV_CACHE_KERNEL_FFT_ABOVE_SIZE_LOG2
                        ? FftwPlanner<ElementType>::request() : typename FftwPlanner<ElementType>::IO();
                const typename FftwPlanner<ElementType>::IO tsPlanIO = fillSizeLog2 < CONV_CACHE_TS_FFT_ABOVE_SIZE_LOG2
                        ? FftwPlanner<ElementType>::request() : typename FftwPlanner<ElementType>::IO();
                const typename FftwPlanner<ElementType>::IO eitherPlanIO =
                        fillSizeLog2 < CONV_CACHE_KERNEL_FFT_ABOVE_SIZE_LOG2 ? kernelPlanIO : fillSizeLog2 < CONV_CACHE_TS_FFT_ABOVE_SIZE_LOG2 ? tsPlanIO : FftwPlanner<ElementType>::request();

                const typename fftwx::Complex *kernelFft;
                if constexpr (fillSizeLog2 >= CONV_CACHE_KERNEL_FFT_ABOVE_SIZE_LOG2) {
                    kernelFft = std::get<ChunkPtr<typename fftwx::Complex, 2u << fillSizeLog2>>(kernelPartitionFfts)->getData();
                } else {
                    std::copy_n(kernelChunk->getData() + kernelOffset, fillSize, kernelPlanIO.in);
                    std::fill_n(kernelPlanIO.in, fillSize, static_cast<ElementType>(0.0));
                    fftwx::execute_dft_r2c(planFwd, kernelPlanIO.in, kernelPlanIO.fft);
                    kernelFft = kernelPlanIO.fft;
                }

                const typename fftwx::Complex *tsFft;
                if constexpr (fillSizeLog2 >= CONV_CACHE_TS_FFT_ABOVE_SIZE_LOG2) {
                    tsFft = std::get<std::array<ChunkPtr<typename fftwx::Complex, 2u << fillSizeLog2>, CHUNK_SIZE / fillSize>>(tsPartitionedFfts)[tsOffset / fillSize]->getData();
                } else {
                    std::copy_n(tsChunk->getData() + tsOffset, fillSize, tsPlanIO.in);
                    std::fill_n(tsPlanIO.in, fillSize, static_cast<ElementType>(0.0));
                    fftwx::execute_dft_r2c(planFwd, tsPlanIO.in, tsPlanIO.fft);
                    tsFft = tsPlanIO.fft;
                }

                // Elementwise multiply
                for (std::size_t i = 0; i < fillSize; i++) {
                    eitherPlanIO.fft[i] = kernelFft[i] * tsFft[i];
                }

                // Backward fft
                FftwPlanner<ElementType>::checkAlignment(kernelPlanIO.fft);
                FftwPlanner<ElementType>::checkAlignment(dst + computedCount);
                fftwx::execute_dft_c2r(planBwd, kernelPlanIO.fft, dst + computedCount);

                // Release stuff
                if (fillSizeLog2 < CONV_CACHE_KERNEL_FFT_ABOVE_SIZE_LOG2) {
                    FftwPlanner<ElementType>::release(kernelPlanIO);
                }
                if (fillSizeLog2 < CONV_CACHE_TS_FFT_ABOVE_SIZE_LOG2) {
                    FftwPlanner<ElementType>::release(tsPlanIO);
                }
                if (fillSizeLog2 >= CONV_CACHE_KERNEL_FFT_ABOVE_SIZE_LOG2 && fillSizeLog2 >= CONV_CACHE_TS_FFT_ABOVE_SIZE_LOG2) {
                    FftwPlanner<ElementType>::release(eitherPlanIO);
                }
            } else {
                assert(fillSizeLog2 < CHUNK_SIZE_LOG2);
                assert(computedCount + 1 >= fillSize);

                for (unsigned int i = 0; i < fillSize; i++) {
                    for (unsigned int j = 0; j < fillSize; j++) {
                        dst[computedCount] += kernelChunk->getElement(kernelOffset + j) * tsChunk->getElement(tsOffset + j);
                    }
                    computedCount++;
                }
            }
        }
    };

private:
    DataSeries<ElementType> &kernel;
    DataSeries<ElementType> &ts;

    std::size_t kernelSize;
    bool backfillZeros;
};

}
