import std/[unittest]
import sbttl

echo parseSRT(readFile "./samples/sub.srt").genSRT
