#pragma once

#include "render/seriesrenderer.h"
#include "series/dataseries.h"

#include "defs/ENABLE_GRAPHICS.h"
#if ENABLE_GRAPHICS
#include "graphics/glbuffer.h"
#include "graphics/type/element.h"
#include "render/program/linestripprogram.h"
#endif

namespace render {

template <typename ElementType>
class DataSeriesRenderer : public SeriesRenderer {
public:
    DataSeriesRenderer(app::AppContext &context, const std::string &name, series::DataSeries<ElementType> *data, float r, float g, float b, float a)
        : SeriesRenderer(context, name)
        , data(data)
#if ENABLE_GRAPHICS
        , remoteBuffer(GL_ARRAY_BUFFER, GL_STREAM_DRAW)
        , drawStyle(r, g, b, a, true)
#endif
    {
        (void) r;
        (void) g;
        (void) b;
        (void) a;
    }

    void draw(std::size_t begin, std::size_t end, std::size_t stride);

#if ENABLE_GRAPHICS
    typename LineStripProgram<ElementType>::DrawStyle &getDrawStyle() {
        return drawStyle;
    }
#endif

private:
    series::DataSeries<ElementType> *data;

#if ENABLE_GRAPHICS
    graphics::GlVao vao;
    graphics::GlBuffer<ElementType> remoteBuffer;

    typename LineStripProgram<ElementType>::DrawStyle drawStyle;

    struct Actions {
        bool fitX = false;
        bool fitY = false;
    };
    Actions updateDrawStyle();
#endif
};

}
