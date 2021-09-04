#include "handler_def.h"

// this is target source code example
// you can specify interested condition and what you'd like to get by @
// see samplerule.txt

Handler_t _stSampleHandler = { // point is you can specify match condition by what you'd like to interest
    .HandlerName = "Sample",
    .HandlerOps = {
        .Init = HANDLER_PROCESING_Init,
        .DeInit = HANDLER_PROCESING_DeInit,
    },
    .HandlerCapability = {
        .MaxInput = MAX_INPUT,
        .MaxOutput = 1,
        .InputType = PCM,
        .OutputType = PCM,
        .InputCapability = {
            .Channel = {1, 2},
            .SampleRate = {8000, 11025, 12000, 16000, 22050, 24000, 
                32000, 44100, 48000,
                64000, 88200, 96000}, // point is multiline supported
            .BitWidth = {8, 16, 24, 32},
            .Endian = ENDIAN_LITTLE
        },
        .OutputCapability = {
            .Channel = {2},
            .SampleRate = {8000, 11025, 12000, 16000, 22050, 24000, 
                32000, 44100, 48000,
                64000, 88200, 96000},
            .BitWidth = {16},
            .Endian = ENDIAN_LITTLE
        },
    }
};
