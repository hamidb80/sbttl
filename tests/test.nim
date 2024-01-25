import std/[unittest, strutils]
import sbttl


func lined(a: string): auto =
  a.strip.splitLines

template checkLineByLine(a, b): untyped =
  check a.lined == b.lined


suite "srt":
  let
    content = readFile "./samples/sub.srt"
    caps = parseSRT(content)

  test "e2e":
    checkLineByLine content, caps.genSRT


suite "vtt":
  let
    contentWithNumber = readFile "./samples/sub+number.vtt"
    contentWithout = readFile "./samples/sub-number.vtt"

  var caps: seq[Caption]

  test "parse + number":
    caps = parseVTT(contentWithNumber)

  test "gen + number":
    checkLineByLine caps.genVTT("", true), contentWithNumber


  test "parse - number":
    caps = parseVTT(contentWithout)

  test "gen - number":
    checkLineByLine caps.genVTT(), contentWithout

  test "parse + number | gen - number":
    checkLineByLine parseVTT(contentWithNumber).genVTT, contentWithout
