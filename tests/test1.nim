import unittest
import isbalanced
import nre

test "single pattern - Delimiter":
  proc isBalancedParens(s: string): bool =
    s.isBalanced(newDelim("("), newDelim(")"))

  check "()".isBalancedParens == true
  check ")".isBalancedParens == false
  check "())(".isBalancedParens == false
  check "((()())((())))".isBalancedParens == true

test "single pattern - Regex":
  proc isBalancedParens(s: string): bool =
    s.isBalanced(re"\(", re"\)")

  check "()".isBalancedParens == true
  check ")".isBalancedParens == false
  check "())(".isBalancedParens == false
  check "((()())((())))".isBalancedParens == true

test "single pattern - string":
  proc isBalancedParens(s: string): bool =
    s.isBalanced("(", ")")

  check "()".isBalancedParens == true
  check ")".isBalancedParens == false
  check "())(".isBalancedParens == false
  check "((()())((())))".isBalancedParens == true

test "multiple patterns - Delimiter":
  let
    opens = @[newDelim("["), newDelim("(")]
    closes = @[newDelim("#")]

  check "[(##".isBalanced(opens, closes) == true
  check "[(#".isBalanced(opens, closes) == false

test "multiple patterns - Regex":
  let
    opens = @[re"\[", re"\("]
    closes = @[re"#"]

  check "[(##".isBalanced(opens, closes) == true
  check "[(#".isBalanced(opens, closes) == false

test "multiple patterns - string":
  let
    opens = @["[", "("]
    closes = @["#"]

  check "[(##".isBalanced(opens, closes) == true
  check "[(#".isBalanced(opens, closes) == false
