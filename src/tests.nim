# NiCalc - test cases to verify the calculation

import utils

var failedTests = 0

proc assert(term: string, expectedResult: float, expectedError = NoError) =
  var exception: CalcException
  var res: float
  try:
    res = calculate(term)
  except CalcException:
    exception = cast[CalcException](getCurrentException())
  if expectedError == NoError and exception != nil:
    echo "TEST FAILED: ", term, " = ", expectedResult.formatFloat, "  result: ", exception.errorCode
    failedTests.inc()
  elif expectedError != NoError and exception == nil:
    echo "TEST FAILED: ", term, "  expectedError: ", expectedError, "  result: NoError"
    failedTests.inc()
  elif expectedError != NoError and expectedError != exception.errorCode:
    echo "TEST FAILED: ", term, "  expectedError: ", expectedError, "  result: ", exception.errorCode
    failedTests.inc()
  elif expectedError == NoError and res.formatFloat != expectedResult.formatFloat:
    echo "TEST FAILED: ", term, " = ", expectedResult.formatFloat, "  result: ", res.formatFloat
    failedTests.inc()

assert("1", 1)
assert("1+2", 3)
assert(" 1 +\t2 ", 3)
assert("((1)+(2))", 3)
assert("1+2-3", 0)
assert("1-2+3", 2)
assert("1-2-3", -4)
assert("1-(2+3)", -4)
assert("(1-2)+3", 2)
assert("1-(2+3)+1", -3)
assert("(1+2)*3", 9)
assert("1+2*3", 7)
assert("4/2", 2)
assert("4/2/2", 1)
assert("-1", -1)
assert("-(1)", -1)
assert("-(1-1)", 0)
assert("2^3", 8)
assert("1,500", 1500)

assert("sin(0+0)", 0)
assert("-sin(0)", 0)
assert("1+sin(0+0)", 1)
assert("sin(sin(0+0))", 0)
assert("sin ( pi / 2 )", 1)
assert("cos (0)", 1)
assert("tan (0)", 0)
assert(" pi ", 3.141593)
assert("e / e", 1)
assert("sqrt(9)", 3)
assert("sqrt(2.345)^2", 2.345)
assert("ln(e)", 1)
assert("floor(1.9)", 1)
assert("ceil(1.1)", 2)
assert("round(1.5)", 2)
assert("(2^16+2*3-sin(pi/2))/2", 32770.5)

assert("1++1", 0, Error1)
assert("((-))", 0, Error1)
assert("*1", 0, Error1)
assert(" ", 0, Error1)
assert("1-(2+3", 0, Error2)
assert("(1-2+3", 0, Error2)
assert("1-2+3)", 0, Error3)
assert("1abc", 0, Error4)
assert("inf", 0, Error4)
assert("sqrt(-1)", 0, Error5)
assert("1/(2-1-1)", 0, Error6)
assert("ln(0)", 0, Error8)
assert("-ln(0)", 0, Error8)
assert("2^9999", 0, Error9)

if failedTests == 0:
  echo "All tests PASSED"
