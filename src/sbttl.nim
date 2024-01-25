import std/[times, strscans, strutils, strformat, options]


type
    TimeRange* = Slice[Duration]

    Caption* = object
        timeRange*: TimeRange
        content*: string

# helper ------------------------------------

func toDuration(t: seq[int]): Duration =
    initDuration(
        hours = t[0], 
        minutes = t[1], 
        seconds = t[2], 
        milliseconds = t[3])

func toTimeRange(timeArr: array[8, int]): TimeRange =
    toDuration(timeArr[0..3]) .. toDuration(timeArr[4..7])

func isInt(s: string): bool =
    for c in s:
        if c notin '0' .. '9':
            return false
    true

# SRT ----------------------------------------

func tryParseSrtTimeRange(line: string): Option[TimeRange] =
    var n: array[8, int]

    if scanf(line, "$i:$i:$i,$i --> $i:$i:$i,$i",
        n[0], n[1], n[2], n[3], n[4], n[5], n[6], n[7]):

        result = some toTimeRange n

func parseSRT*(content: string): seq[Caption] =
    var
        lastLineIsAnumber = false
        acc: seq[string]

    template resolveContents: untyped =
        if result.len != 0:
            result[^1].content = strip join(acc, "\n")

    for l in content.splitLines:
        if lastLineIsAnumber and (let p = tryParseSrtTimeRange(l); p.issome):
            if acc.len != 0:
                del acc, acc.high

            resolveContents()
            add result, Caption(timeRange: get p)
            setLen acc, 0

        elif result.len != 0:
            add acc, l

        lastLineIsAnumber = isInt l

    resolveContents()

func toSRT(d: Duration): string =
    let t = d.toParts
    fmt"{t[Hours]:02}:{t[Minutes]:02}:{t[Seconds]:02},{t[Milliseconds]:03}"

func toSRT(c: Caption): string =
    fmt "{toSRT c.timeRange.a} --> {toSRT c.timeRange.b}\n{c.content}"

func genSRT*(cs: seq[Caption]): string =
    for i, c in cs.pairs:
        result &= $(i+1) & "\n" & c.toSRT & "\n\n"

# VTT ----------------------------------------

func tryParseVttTimeRange(line: string): Option[TimeRange] =
    var n: array[8, int]

    if scanf(line, "$i:$i:$i.$i --> $i:$i:$i.$i",
        n[0], n[1], n[2], n[3], n[4], n[5], n[6], n[7]):

        result = some toTimeRange n

func toVTT(d: Duration): string =
    let t = toParts d
    fmt"{t[Hours]:02}:{t[Minutes]:02}:{t[Seconds]:02}.{t[Milliseconds]:03}"

func toVTT(c: Caption): string =
    fmt "{toVTT c.timeRange.a} --> {toVTT c.timeRange.b}\n{c.content}"

func parseVTT*(content: string): seq[Caption] =
    var
        lastLineIsAnumber = false
        acc: seq[string]

    template resolveContents(): untyped =
        if result.len != 0:
            result[^1].content = strip join(acc, "\n")

    for l in content.splitLines:
        if (let p = tryParseVttTimeRange(l); p.issome):
            if acc.len != 0 and lastLineIsAnumber:
                del acc, acc.high

            resolveContents()
            add result, Caption(timeRange: p.get)
            setLen acc, 0

        elif result.len != 0:
            add acc, l

        lastLineIsAnumber = isInt l

    resolveContents()

func genVTT*(captions: seq[Caption],
    meta = "", includeCaptionNumber = false): string =

    result = "WEBVTT\n" & meta & "\n"

    for i, c in captions:
        result &= (
            if includeCaptionNumber: $(i+1) & "\n"
            else: ""
        ) & toVTT(c) & "\n\n"
