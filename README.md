# What's this?

This scanKeyValue.rb will scan the file and output the scan result which is matches with rule file description, as markdown manner.

You can specify the interested condition and what's expected to get as value by ```@```

```
Usage: 
    -s, --scanDir=                   Specify scan target dir
    -e, --extension=                 Specify target file extension \.c$, etc.
    -r, --ruleFile=                  Specify rule file (mandatory)
        --recursive
                                     Specify if you want to search recursively
        --robust
                                     Specify if you want to robust match (experimental)
        --outputFormat=
                                     Specify markdown or csv or json (default:markdown)
        --disableFilenameOutput
                                     Specify if you don't want to output filename as 1st col.
```

# How to use and example output

```
$ ruby scanKeyValue.rb -r samplerule.txt -s ./sample -e \.c$ --recursive
| /Users/.../scanKeyValueToMd/sample.c | Sample | MAX_INPUT | 1 | 1, 2 | 8000, 11025, 12000, 16000, 22050, 24000,32000, 44100, 48000,64000, 88200, 96000 | 8, 16, 24, 32 | 2 | 8000, 11025, 12000, 16000, 22050, 24000,32000, 44100, 48000,64000, 88200, 96000 | 16 | 
```

## samplerule.txt

```samplerule.txt
Handler_t
    .HandlerName = "@",
    .HandlerCapability = {
        .MaxInput = @,
        .MaxOutput = @,
        .InputCapability = {
            .Channel = {@},
            .SampleRate = {@},
            .BitWidth = {@},
        .OutputCapability = {
            .Channel = {@},
            .SampleRate = {@},
            .BitWidth = {@},
```

## sample/sample.c

```sample/sample.c
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
```
