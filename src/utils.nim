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


type
  NodeKind = enum
    NK_Literal
    NK_Identifier
    NK_Operator
    NK_OpeningBracket
    NK_ClosingBracket
    NK_InBrackets
  Operator = enum
    Op_Power
    Op_Div
    Op_Mult
    Op_Minus
    Op_Plus
  Node = ref object
    case kind: NodeKind
    of NK_Literal:
      value: float
    of NK_Operator:
      operator: Operator
      left, right: Node
    of NK_InBrackets:
      node: Node
    of NK_Identifier:
      name: string
      nameLower: string
      param: Node
    else:
      discard

const
  Whitespace = {' ', '\t', '\v', '\c', '\n', '\f'}
  Digits = {'0'..'9'}
  DigitsWithSep = Digits + {'.', ',', '_'}
  OpChars = ['^', '/', '*', '-', '+']

proc debugPrint(node: Node, level, i = 0) =
  if level == 0 and i == 0:
    echo "---"
  var indent = ""
  for j in 0..level - 1:
    indent.add("  ")
  var s = ""
  s.add($i)
  s.add(": ")
  s.add($node.kind)
  case node.kind:
  of NK_Literal:
    s.add(' ')
    s.add($node.value)
  of NK_Operator:
    s.add(' ')
    s.add($node.operator)
  of NK_Identifier:
    s.add(' ')
    s.add($node.name)
  else:
    discard
  echo indent, s
  case node.kind:
  of NK_Operator:
    echo indent, "  left:"
    if node.left != nil:
      debugPrint(node.left, level + 1, 0)
    echo indent, "  right:"
    if node.right != nil:
      debugPrint(node.right, level + 1, 0)
  of NK_InBrackets:
    if node.node != nil:
      debugPrint(node.node, level + 1, 0)
  of NK_Identifier:
    if node.param != nil:
      debugPrint(node.param, level + 1, 0)
  else:
    discard

proc debugPrint(nodes: seq[Node], level = 0) =
  for i in 0..nodes.len - 1:
    debugPrint(nodes[i], level, i)

proc newNode(k: NodeKind): Node =
  result = Node(kind: k)

proc tokenize(term: string): seq[Node] =
  var i = 0
  while i < term.len:
    let c = term[i]
    if c in Whitespace:
      i.inc
      continue
    if c in Digits:
      # float literal
      var j = i + 1
      while j < term.len and term[j] in DigitsWithSep:
        j.inc
      var str = term.substr(i, j - 1)
      try:
        var node = newNode(NK_Literal)
        node.value = str.replace(",").parseFloat.checkNumber
        result.add(node)
      except:
        raise newCalcException(Error4, "Invalid term '" & str & "'")
      i = j
      continue
    # string literal
    if c in IdentStartChars:
      var j = i + 1
      while j < term.len and term[j] in IdentChars:
        j.inc
      let str = term.substr(i, j - 1)
      var node = newNode(NK_Identifier)
      node.name = str
      node.nameLower = str.toLower()
      result.add(node)
      i = j
      continue
    if c == '(':
      var node = newNode(NK_OpeningBracket)
      result.add(node)
      i.inc
      continue
    if c == ')':
      var node = newNode(NK_ClosingBracket)
      result.add(node)
      i.inc
      continue
    let op = OpChars.find(c)
    if op != -1:
      var node = newNode(NK_Operator)
      node.operator = cast[Operator](op)
      result.add(node)
      i.inc
      continue
    raise newCalcException(Error7, "Invalid character '" & c & "'")

proc transformToTree(nodes: seq[Node]): Node

proc transformToTree_operator(nodes: seq[Node]): Node =
  # looking for operator with lowest precedence (highest value)
  for i in 0..nodes.len - 1:
    let node = nodes[i]
    if node.kind == NK_Operator:
      if result == nil or node.operator.int >= result.operator.int:
        result = node
  if result == nil:
    raise newCalcException(Error10, "Operator expected")
  var
    before = true
    leftNodes, rightNodes: seq[Node]
  for i in 0..nodes.len - 1:
    let node = nodes[i]
    if node == result:
      before = false
      continue
    if before:
      leftNodes.add(node)
    else:
      rightNodes.add(node)
  if leftNodes.len > 0:
    result.left = transformToTree(leftNodes)
  elif result.operator != Op_Minus:
    raise newCalcException(Error10, "Operand before '" & OpChars[result.operator.int] & "' expected")
  if rightNodes.len > 0:
    result.right = transformToTree(rightNodes)
  else:
    raise newCalcException(Error10, "Operand after '" & OpChars[result.operator.int] & "' expected")

proc transformToTree_brackets(nodes: seq[Node]): Node =
  # looking for most outer brackets
  var
    openingBracket: Node
    openingBracketIndex = -1
    closingBracket: Node
    level = 0
  for i in 0..nodes.len - 1:
    let node = nodes[i]
    if node.kind == NK_OpeningBracket:
      if openingBracket == nil:
        openingBracket = node
        openingBracketIndex = i
      else:
        level.inc
    elif node.kind == NK_ClosingBracket:
      if level == 0:
        closingBracket = node
        break
      level.dec
  if openingBracket != nil:
    if closingBracket == nil:
      raise newCalcException(Error2, "')' expected")
    var
      inBrackets = false
      nodesInBrackets: seq[Node]
      newNodeList: seq[Node]
      bracketNode = newNode(NK_InBrackets)
      identifierNode: Node
    for i in 0..nodes.len - 1:
      let node = nodes[i]
      if i == openingBracketIndex - 1 and node.kind == NK_Identifier:
        identifierNode = node
        newNodeList.add(identifierNode)
        continue
      if node == openingBracket:
        inBrackets = true
        if identifierNode == nil:
          newNodeList.add(bracketNode)
        continue
      if node == closingBracket:
        inBrackets = false
        continue
      if inBrackets:
        nodesInBrackets.add(node)
      else:
        newNodeList.add(node)
    if nodesInBrackets.len == 0:
      raise newCalcException(Error10, "Value or identifier expected")
    if identifierNode != nil:
      identifierNode.param = transformToTree(nodesInBrackets)
    else:
      bracketNode.node = transformToTree(nodesInBrackets)
    return transformToTree(newNodeList)

  # checking for invalid ')'
  if closingBracket != nil:
    raise newCalcException(Error10, "Unexpected ')'")

proc transformToTree(nodes: seq[Node]): Node =
  if nodes.len == 1:
    if nodes[0].kind != NK_Literal and nodes[0].kind != NK_InBrackets and nodes[0].kind != NK_Identifier:
      raise newCalcException(Error1, "Value or identifier expected")
    return nodes[0]

  result = transformToTree_brackets(nodes)
  if result == nil:
    result = transformToTree_operator(nodes)

proc calcNodeValue(node: Node): float =
  case node.kind:
  of NK_Literal:
    return node.value
  of NK_InBrackets:
    return calcNodeValue(node.node)
  of NK_Operator:
    case node.operator:
    of Op_Power:
      return pow(calcNodeValue(node.left), calcNodeValue(node.right)).checkNumber
    of Op_Mult:
      return (calcNodeValue(node.left) * calcNodeValue(node.right)).checkNumber
    of Op_Div:
      return (calcNodeValue(node.left) / calcNodeValue(node.right)).checkNumber
    of Op_Plus:
      return (calcNodeValue(node.left) + calcNodeValue(node.right)).checkNumber
    of Op_Minus:
      if node.left == nil:
        return -calcNodeValue(node.right)
      else:
        return calcNodeValue(node.left) - calcNodeValue(node.right)
  of NK_Identifier:
    proc checkConstant() =
      if node.param != nil:
        raise newCalcException(Error1, "'" & node.name & "' is not a function")
    proc getParamValue(): float =
      if node.param == nil:
        raise newCalcException(Error1, "'" & node.name & "' is a function and needs a parameter")
      return calcNodeValue(node.param)
    case node.nameLower:
    of "pi":
      checkConstant()
      return 3.14159265358979323846
    of "e":
      checkConstant()
      return 2.71828182845904523536
    of "round":
      return round(getParamValue()).checkNumber
    of "floor":
      return floor(getParamValue()).checkNumber
    of "ceil":
      return ceil(getParamValue()).checkNumber
    of "sqrt":
      return sqrt(getParamValue()).checkNumber
    of "abs":
      return abs(getParamValue()).checkNumber
    of "sin":
      return sin(getParamValue()).checkNumber
    of "cos":
      return cos(getParamValue()).checkNumber
    of "tan":
      return tan(getParamValue()).checkNumber
    of "ln":
      return ln(getParamValue()).checkNumber
    of "log2":
      return log2(getParamValue()).checkNumber
    raise newCalcException(Error1, "Invalid identifier '" & node.name & "'")
  else:
    discard

proc calculate*(term: string): float =
  var nodes = tokenize(term)

  if nodes.len == 0:
    raise newCalcException(Error1, "Term is empty")

  # debugPrint(nodes)

  let rootNode = transformToTree(nodes)

  # debugPrint(rootNode)

  result = calcNodeValue(rootNode)



