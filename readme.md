# SuBTiTLe
subtile reader & writer for nimmers :D

## Supported Formats
* [x] `.srt`
* [x] `.vtt`

## Usage
see `tests/test.nim` for now

## API

### types
```nim
TimeRange* = HSlice[Duration, Duration]

Caption* = object
    timeRange*: TimeRange
    content*: string
```

### functions
```nim
func parseVTT(content: string): seq[Caption]
func genVTT(captions: seq[Caption], meta = "", includeCaptionNumber = false): string
func parseSRT(content: string): seq[Caption]
func genSRT(cs: seq[Caption]): string
```