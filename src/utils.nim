# NiCalc - utils

import strutils
import math

proc formatFloat*(f: float, decimals: range[-1 .. 32] = -1): string =
  if decimals == -1:
    result = f.formatFloat(ffDecimal, 6)
    result.trimZeros
  elif decimals == 0:
    result = $f.round.int
  else:
    result = f.formatFloat(ffDecimal, decimals)
  if result == "-0":
    result = "0"
  var i = result.find('.')
  if i == -1:
    i = result.len
  if i > 4:
    var groups: seq[string] = @[]
    groups.add(result.substr(i))
    while i > 3:
      groups.add(result.substr(i - 3, i - 1))
      i = i - 3
    groups.add(result.substr(0, i - 1))
    result = ""
    i = 0
    for g in groups:
      if i > 1:
        result = ',' & result
      result = g & result
      i.inc

proc continuesWithSafe(s, substr: string, start: int): bool =
  if start < 0: return false
  result = continuesWith(s, substr, start)


type
  ErrorCode* = enum
    NoError
    Error1
    Error2
    Error3
    Error4
    Error5
    Error6
    Error7
    Error8
    Error9

  CalcException* = ref object of Exception
    errorCode*: ErrorCode

proc newCalcException(errorCode: ErrorCode, msg: string): CalcException =
  result = new CalcException
  result.errorCode = errorCode
  result.msg = msg

proc checkNumber(number: float): float =
  if number.classify == fcNan:
    raise newCalcException(Error5, "Result is not a number")
  if number.classify == fcNegInf:
    raise newCalcException(Error8, "Result is negative infinity")
  if number.classify == fcInf:
    raise newCalcException(Error9, "Result is infinity")
  result = number

proc calculate*(term: string): float =
  let t = term.toLower.strip
  if t.len == 0:
    raise newCalcException(Error1, "Missing operand")
  if t == "pi":
    return 3.14159265358979323846
  if t == "e":
    return 2.71828182845904523536
  var i = t.find("(")
  if i != -1:
    var depth = 0
    var j = i + 1
    while j < t.len:
      if t[j] == '(':
        depth.inc
      elif t[j] == ')':
        if depth == 0:
          break
        depth.dec
      j.inc
    if j >= t.len or t[j] != ')':
      raise newCalcException(Error2, "Missing ')'")
    if i == 0 and j == t.high:
      return t.substr(1, t.len - 2).calculate
    if j == t.high:
      i.dec
    else:
      let left = t.substr(0, j)
      let right = t.substr(j + 1).strip
      if right[0] in ['+', '-', '*', '/', '^']:
        return calculate($left.calculate & right)
      i = j + 1
  else:
    if t.contains(')'):
      raise newCalcException(Error3, "Unexpected ')'")
  if i == -1:
    i = t.find("+")
  if i == -1:
    i = t.rfind("-")
  if i == -1:
    i = t.find("*")
  if i == -1:
    i = t.rfind("/")
  if i == -1:
    i = t.rfind("^")
  if i == -1:
    try:
      result = t.replace(",").parseFloat.checkNumber
    except:
      raise newCalcException(Error4, "Invalid term '" & t & "'")
  else:
    var rightValue = t.substr(i + 1).calculate
    while i > 0 and t[i] == ' ':
      i.dec
    if t.continuesWithSafe("round", i - 4):
      rightValue = round(rightValue)
      i.dec(5)
    if t.continuesWithSafe("floor", i - 4):
      rightValue = floor(rightValue)
      i.dec(5)
    if t.continuesWithSafe("ceil", i - 3):
      rightValue = ceil(rightValue)
      i.dec(4)
    if t.continuesWithSafe("sqrt", i - 3):
      rightValue = sqrt(rightValue).checkNumber
      i.dec(4)
    if t.continuesWithSafe("abs", i - 2):
      rightValue = abs(rightValue).checkNumber
      i.dec(3)
    if t.continuesWithSafe("sin", i - 2):
      rightValue = sin(rightValue).checkNumber
      i.dec(3)
    if t.continuesWithSafe("cos", i - 2):
      rightValue = cos(rightValue).checkNumber
      i.dec(3)
    if t.continuesWithSafe("tan", i - 2):
      rightValue = tan(rightValue).checkNumber
      i.dec(3)
    if t.continuesWithSafe("ln", i - 1):
      rightValue = ln(rightValue).checkNumber
      i.dec(2)
    if i == -1:
      return rightValue
    let op = t[i]
    let left = t.substr(0, i - 1)
    if op == '+':
      return (left.calculate + rightValue).checkNumber
    if op == '-':
      if left.len == 0:
        return -rightValue
      return (left.calculate - rightValue).checkNumber
    if op == '*':
      return (left.calculate * rightValue).checkNumber
    if op == '/':
      if rightValue == 0:
        raise newCalcException(Error6, "Division by zero")
      return (left.calculate / rightValue).checkNumber
    if op == '^':
      return pow(left.calculate, rightValue).checkNumber
    raise newCalcException(Error7, "Invalid term '" & t.substr(0, i) & "'")
