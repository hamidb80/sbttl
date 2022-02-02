import std/[unittest, strutils]
import sbttl


suite "srt":
  let
    content = readFile "./samples/sub.srt"
    caps = parseSRT(content)

  test "e2e":
    check content.strip == caps.genSRT.strip


suite "vtt":
  let
    contentWithNumber = readFile "./samples/sub+number.vtt"
    contentWithout = readFile "./samples/sub-number.vtt"

  var caps: seq[Caption]

  test "parse + number":
    caps = parseVTT(contentWithNumber)

  test "gen + number":
    check caps.genVTT("", true).strip == contentWithNumber.strip


  test "parse - number":
    caps = parseVTT(contentWithout)

  test "gen - number":
    check caps.genVTT().strip == contentWithout.strip

  test "parse + number | gen - number":
    check parseVTT(contentWithNumber).genVTT.strip == contentWithout.strip
