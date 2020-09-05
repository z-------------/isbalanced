# This file contains test cases adapted from kaiwood's is-balanced module for JavaScript:
# https://github.com/kaiwood/is-balanced/blob/db7adcd3ff1205a6e30da5cf558c3e2758a9cf70/index.test.js

import unittest
import isbalanced
import nre

proc isBalancedParens(s: string): bool =
  s.isBalanced("(", ")")

test "detect balanced parentheses":
  let balancedData = "(())"
  check balancedData.isBalancedParens == true

test "detect unbalanced parentheses":
  let unbalancedData = "())"
  check unbalancedData.isBalancedParens == false

test "other characters can appear":
  check "((|())x)".isBalancedParens == true
  check "(dsdsadasd((!)xxx)".isBalancedParens == false

test "use tokens that are not the default parentheses":
  let
    balancedData = """
    if true
      # something
    end
    """
    unbalancedData = """
    if false

    def foo
      # something
    end
    """

  check balancedData.isBalanced(@["if", "def"], @["end"]) == true
  check unbalancedData.isBalanced(@["if", "def"], @["end"]) == false

test "differentiate between tokens at the beginning and in the middle of a line":
  let
    balancedData = """
    def foo
    end
    puts "something" if true
    """
    unbalancedData = """
    def foo
    end
    puts "something" if true
    end
    """
    moreUnbalancedData = """
    def foo
      if true
    end
    """

  proc isBalancedWithArgs(s: string): bool =
    s.isBalanced(
      @[newDelim(re"(?m)^\s*?if"), newDelim("def")],
      @[newDelim("end")]
    )

  check balancedData.isBalancedWithArgs == true
  check unbalancedData.isBalancedWithArgs == false
  check moreUnbalancedData.isBalancedWithArgs == false

test "opening/closing args work as a single string too":
  let
    balancedData = "{{}}"
    unbalancedData = "({{})"

  check balancedData.isBalanced("{", "}") == true
  check unbalancedData.isBalanced("{", "}") == false

test "more cases":
  let
    openings = @[
      newDelim(re"(?m)^\s*?if"),
      newDelim(re"(?m)^\s*?unless"),
      newDelim("while"),
      newDelim("for"),
      newDelim("do"),
      newDelim("def"),
      newDelim("class"),
      newDelim("module"),
      newDelim("case"),
    ]
    closings = @[newDelim("end")]

  let
    text = """
    def foo
      if true

      end
    end
    """
    unbalanced = """
    def foo
      if true

      end
    end
    """
    #balanced = """
    #def foo
    #  puts "foo" if true
    #end
    #"""

  check text.isBalanced(openings, closings) == true
  check unbalanced.isBalanced(openings, closings) == true  # am i missing something with this naming?
