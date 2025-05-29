#include <iostream>
#include <string>

extern "C"
{
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libavformat/avio.h>
#include <libavutil/audio_fifo.h>
#include <libavutil/avassert.h>
#include <libavutil/avstring.h>
#include <libavutil/channel_layout.h>
#include <libavutil/error.h>
#include <libavutil/frame.h>
#include <libavutil/imgutils.h>
#include <libavutil/log.h>
#include <libavutil/mathematics.h>
#include <libavutil/opt.h>
#include <libavutil/pixdesc.h>
#include <libavutil/samplefmt.h>
#include <libavutil/timestamp.h>
#include <libswscale/swscale.h>
#include <libswresample/swresample.h>
#include <libavutil/hwcontext.h>
#include <libavutil/log.h>
#include <libavutil/display.h>
}

static long CreateEngine(const std::string& videoFilePath) {
    std::cout << "CreateEngine, file path:" << videoFilePath << std::endl;

    av_log_set_level(AV_LOG_DEBUG);

    AVFormatContext* fmtCtx = nullptr;
    int ret = avformat_open_input(&fmtCtx, videoFilePath.c_str(), nullptr, nullptr);
    if (ret < 0) {
        printf("open error: %d\n", ret);
        return -1;
    }

    ret = avformat_find_stream_info(fmtCtx, nullptr);
    if (ret < 0) {
        printf("find_stream_info error: %d\n", ret);
        return -1;
    }

    av_dump_format(fmtCtx, 0, videoFilePath.c_str(), 0);

    avformat_close_input(&fmtCtx);
    avformat_free_context(fmtCtx);

    std::cout << "CreateEngine, end" << std::endl;

    return 0;
}