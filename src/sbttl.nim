import std/[times, strscans, strutils, strformat]


type
    TimeRange* = HSlice[Duration, Duration]

    Caption* = object
        timeRange*: TimeRange
        content*: string

# helper ------------------------------------

func toDuration(t: seq[int]): Duration =
    assert t.len == 4
    initDuration(hours = t[0], minutes = t[1], seconds = t[2], milliseconds = t[3])

func toTimeRange(timeArr: array[8, int]): TimeRange =
    toDuration(timeArr[0..3]) .. toDuration(timeArr[4..7])

func isInt(s: string): bool =
    for c in s:
        if c notin '0' .. '9':
            return false
    true

# SRT ----------------------------------------

func tryParseُُSRTTimeRange(line: string): tuple[can: bool, res: TimeRange] =
    var n: array[8, int]

    result.can = line.scanf("$i:$i:$i,$i --> $i:$i:$i,$i",
        n[0], n[1], n[2], n[3], n[4], n[5], n[6], n[7])

    if result.can:
        result.res = toTimeRange n

func parseSRT*(content: string): seq[Caption] =
    var
        lastLineIsAnumber = false
        acc: seq[string]

    template resolveContents():untyped =
        if result.len != 0:
            result[^1].content = acc.join "\n"

    for l in content.splitLines:
        if lastLineIsAnumber and (let p = tryParseُُSRTTimeRange(l); p.can):
            if result.len != 0:
                discard acc.pop

            resolveContents()
            lastLineIsAnumber = false
            result.add Caption(timeRange: p.res)
            acc.setLen 0

        elif result.len != 0:
            acc.add l

        if l.isInt:
            lastLineIsAnumber = true

    resolveContents()

func toSRT(d: Duration): string =
    let t = d.toParts
    fmt"{t[Hours]:02}:{t[Minutes]:02}:{t[Seconds]:02},{t[Milliseconds]:03}"

func toSRT(c: Caption): string =
    fmt "{toSRT c.timeRange.a} --> {toSRT c.timeRange.b}\n{c.content}"

func genSRT*(cs: seq[Caption]): string =
    for i, c in cs.pairs:
        result &= $(i+1) & "\n" & c.toSRT & "\n"

# VTT ----------------------------------------

# FIXME follow spec