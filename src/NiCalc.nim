# NiCalc - main program

import nigui
import os
import utils

const buttonWidth = 70
const labelWidth = 55
const editFontSize = 22
const editFontFamily = "Consolas"
const historyFontSize = 18
let appConfigDir = getConfigDir() & "NiCalc"
let historyFilePath = appConfigDir / "history.txt"

var lastCalculation = ""
var timer: Timer

app.init()

var window = newWindow("NiCalc")
window.width = 600
window.height = 450

var mainContainer = newLayoutContainer(Layout_Vertical)
mainContainer.padding = 6
window.add(mainContainer)

var inputContainer = newLayoutContainer(Layout_Horizontal)
mainContainer.add(inputContainer)

var inputLabel = newLabel("Input:")
inputContainer.add(inputLabel)
inputLabel.minWidth = labelWidth
inputLabel.heightMode = HeightMode_Fill

var inputTextBox = newTextBox()
inputContainer.add(inputTextBox)
inputTextBox.fontSize = editFontSize
inputTextBox.fontFamily = editFontFamily

var clearButton = newButton("Clear")

clearButton.minWidth = buttonWidth
clearButton.heightMode = HeightMode_Fill
inputContainer.add(clearButton)

var resultContainer = newLayoutContainer(Layout_Horizontal)
mainContainer.add(resultContainer)

var resultLabel = newLabel("Result:")
resultContainer.add(resultLabel)
resultLabel.minWidth = labelWidth
resultLabel.heightMode = HeightMode_Fill

var resultTextBox = newTextBox()
resultContainer.add(resultTextBox)
resultTextBox.fontSize = editFontSize
resultTextBox.fontFamily = editFontFamily

var historyContainer = newLayoutContainer(Layout_Vertical)
mainContainer.add(historyContainer)
historyContainer.frame = newFrame("History")

var historyTextArea = newTextArea()
historyContainer.add(historyTextArea)
historyTextArea.fontSize = historyFontSize
historyTextArea.fontFamily = editFontFamily

if fileExists(historyFilePath):
  historyTextArea.text = readFile(historyFilePath)
if historyTextArea.text.len == 0:
  historyContainer.hide()

proc updateResult(event: TimerEvent) =
  timer.stop()
  var term = inputTextBox.text
  lastCalculation = ""
  resultTextBox.text = ""
  if term.len == 0:
    return
  try:
    let resultStr = term.calculate.formatFloat
    resultTextBox.textColor = app.defaultTextColor
    resultTextBox.text = resultStr
    lastCalculation = term & " = " & resultStr
  except:
    resultTextBox.textColor = rgb(255, 0, 0) # red
    resultTextBox.text = "Error: " & getCurrentExceptionMsg()

inputTextBox.onTextChange = proc(event: TextChangeEvent) =
  lastCalculation = ""
  resultTextBox.text = ""
  timer.stop()
  timer = startTimer(500, updateResult)

inputTextBox.onKeyDown = proc(event: ControlKeyEvent) =
  if event.key == Key_Return:
    when defined(windows):
      event.cancel = true # stops annoying ding sound on windows
    if lastCalculation == "":
      updateResult(nil)
    if lastCalculation != "":
      historyTextArea.addLine(lastCalculation)
      historyTextArea.scrollToBottom()
      historyContainer.show()

window.onKeyDown = proc(event: WindowKeyEvent) =
  if event.key == Key_Escape:
    window.dispose()

window.onDispose = proc(event: WindowDisposeEvent) =
  if historyTextArea.text.len > 0 or fileExists(historyFilePath):
    createDir(appConfigDir)
    writeFile(historyFilePath, historyTextArea.text)

clearButton.onClick = proc(event: ClickEvent) =
  inputTextBox.text = ""
  resultTextBox.text = ""
  inputTextBox.focus()

window.show()
inputTextBox.focus()
app.run()

