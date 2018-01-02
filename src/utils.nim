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
    Error10

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
  let bracketStart = t.find("(")
  var i = bracketStart
  var bracketEnd = -1
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
    bracketEnd = j
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
    if bracketStart != -1:
      var middleValue = t.substr(bracketStart + 1, bracketEnd - 1).calculate
      let rightValue = t.substr(bracketEnd + 1).strip
      if rightValue.len > 0 and not(rightValue[0] in ['+', '-', '*', '/', '^']):
        raise newCalcException(Error10, "Missing operator after '" & t.substr(0, bracketEnd) & "'")
      while i > 1 and t[i - 1] == ' ':
        i.dec
      if t.continuesWithSafe("round", i - 5):
        middleValue = round(middleValue)
        i.dec(5)
      elif t.continuesWithSafe("floor", i - 5):
        middleValue = floor(middleValue)
        i.dec(5)
      elif t.continuesWithSafe("ceil", i - 4):
        middleValue = ceil(middleValue)
        i.dec(4)
      elif t.continuesWithSafe("sqrt", i - 4):
        middleValue = sqrt(middleValue).checkNumber
        i.dec(4)
      elif t.continuesWithSafe("abs", i - 3):
        middleValue = abs(middleValue).checkNumber
        i.dec(3)
      elif t.continuesWithSafe("sin", i - 3):
        # echo "sin found"
        middleValue = sin(middleValue).checkNumber
        i.dec(3)
      elif t.continuesWithSafe("cos", i - 3):
        middleValue = cos(middleValue).checkNumber
        i.dec(3)
      elif t.continuesWithSafe("tan", i - 3):
        middleValue = tan(middleValue).checkNumber
        i.dec(3)
      elif t.continuesWithSafe("ln", i - 2):
        middleValue = ln(middleValue).checkNumber
        i.dec(2)
      let leftValue = t.substr(0, i - 1)
      return calculate(leftValue & $middleValue & rightValue).checkNumber
    var rightValue = t.substr(i + 1).calculate
    while i > 0 and t[i] == ' ':
      i.dec
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
