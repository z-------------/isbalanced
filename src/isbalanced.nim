import nre
import sequtils
import strutils
import sugar

type
  DelimiterKind* = enum
    dkString
    dkRegex
  Delimiter* = object
    # To be used as a container for heterogenous string pattern / regex seqs.
    case kind: DelimiterKind
    of dkString:
      strVal: string
    of dkRegex:
      reVal: Regex

proc toRegex(s: string): Regex =
  re(s.escapeRe)

proc toRegex(d: Delimiter): Regex =
  case d.kind
  of dkString:
    d.strVal.toRegex
  of dkRegex:
    d.reVal

proc combine(regexes: seq[Regex]): Regex =
  re(
    "(" &
    regexes
      .map(r => r.pattern)
      .join(")|(") &
    ")"
  )

proc getNextPos(m: RegexMatch): int =
  m.captureBounds[-1].b + 1

proc matchStart(m: RegexMatch): int =
  m.captureBounds[-1].a

proc isBalanced*(s: string; open, close: Regex): bool =
  ## Not optimal (a lot of wasted/duplicated computation),
  ## but it works.
  var
    level = 0
    pos = 0

  while true:
    var
      openPos = int.high
      closePos = int.high
      needFindCloseMatch = true

    let openMatch = s.find(open, start = pos)
    var closeMatch = none(RegexMatch)

    if openMatch.isSome:
      openPos = openMatch.get.matchStart
      if openPos == pos:
        needFindCloseMatch = false

    if needFindCloseMatch:
      closeMatch = s.find(close, start = pos)
    if closeMatch.isSome:
      closePos = closeMatch.get.matchStart

    if openPos < closePos:
      level.inc
      pos = getNextPos(openMatch.get)
    elif closePos < openPos:
      level.dec
      pos = getNextPos(closeMatch.get)

    if level < 0:
      return false

    if (openPos == int.high and openPos == closePos) or pos == s.len:
      break

  return level == 0

proc isBalanced*(s: string; open, close: Delimiter): bool =
  return isBalanced(s, open.toRegex, close.toRegex)

proc isBalanced*(s: string; open, close: string): bool =
  return isBalanced(s, open.toRegex, close.toRegex)

proc isBalanced*(s: string; opens, closes: seq[string]): bool =
  return isBalanced(
    s,
    opens.map(toRegex).combine,
    closes.map(toRegex).combine,
  )

proc isBalanced*(s: string; opens, closes: seq[Regex]): bool =
  return isBalanced(
    s,
    opens.combine,
    closes.combine,
  )

proc isBalanced*(s: string; opens, closes: seq[Delimiter]): bool =
  let
    openCombined: Regex = opens.map(toRegex).combine
    closeCombined: Regex  = closes.map(toRegex).combine
  return isBalanced(s, openCombined, closeCombined)

proc newDelim*(pattern: string): Delimiter =
  Delimiter(
    kind: dkString,
    strVal: pattern,
  )

proc newDelim*(regex: Regex): Delimiter =
  Delimiter(
    kind: dkRegex,
    reVal: regex,
  )
