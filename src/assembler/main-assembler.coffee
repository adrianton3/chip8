'use strict'

Range = (ace.require 'ace/range').Range

app = angular.module 'Assembler', []

app.controller 'AssemblerController', ($scope) ->
  { initContext, draw, setVideoData } = Chip8Renderer()

  initContext document.getElementById 'can'

  TICKS_PER_FRAME = 1

  self = @

  rafId = null

  editor = null
  errorLine = null

  lineMapping = null
  marker = null

  @running = false

  @state = null

  assembler = Chip8Assembler()

  keyboard = Chip8Keyboard()
  (document.getElementById 'container').appendChild keyboard.getHtml()

  chip8 = Chip8()
  chip8.setKeyboard keyboard


  onChange = (text) ->
    if text.length == 0
      editor.getSession().setAnnotations []
    else
      try
        assembler.assemble text
        if errorLine != null
          editor.getSession().setAnnotations []
          errorLine = null
      catch ex
        if ex.coords?
          errorLine = ex.coords.line
          editor.getSession().setAnnotations([
            row: errorLine
            text: ex.message
            type: 'error'
          ])

    return


  setupEditor = ->
    editor = ace.edit 'editor'
    editor.getSession().setMode 'ace/mode/chip8'
    editor.setTheme 'ace/theme/monokai'
    editor.on 'input', -> onChange editor.getValue()
    return


  setupEditor()


  getState = ->
    programCounter = chip8.getProgramCounter()
    stackPointer = chip8.getStackPointer()
    I = chip8.getI()
    registers = Array::slice.call chip8.getRegisters(), 0
    stack = Array::slice.call chip8.getStack(), stackPointer

    {
      programCounter
      registers
      stackPointer
      I
      stack
    }


  @start = ->
    @reset()
    mainLoop = =>
      for i in [0...TICKS_PER_FRAME]
        chip8.tick()

      setVideoData chip8.getVideo()
      @state = getState()
      $scope.$apply() if not $scope.$$phase
      draw()
      rafId = requestAnimationFrame mainLoop
      return

    mainLoop()
    return


  @stop = ->
    @running = false
    cancelAnimationFrame rafId
    return


  clearMarker = ->
    editor.getSession().removeMarker marker if marker?
    marker = null
    return


  setMarker = (line) ->
    clearMarker()
    if line?
      range = new Range line, 0, line, 100
      marker = editor.getSession().addMarker range, 'active-line', 'fullLine'
    return


  @reset = ->
    @stop()
    text = editor.getValue()
    if text.length
      try
        { instructions, lineMapping } = assembler.assemble text
        self.loadProgram instructions
      catch ex

    chip8.reset()
    @state = getState()
    setVideoData chip8.getVideo()
    draw()
    if lineMapping?
      line = lineMapping.get @state.programCounter
      setMarker line
    return


  @reset()


  @loadProgram = chip8.load


  @step = ->
    return unless lineMapping?
    chip8.tick()
    @state = getState()
    setVideoData chip8.getVideo()
    line = lineMapping.get @state.programCounter
    setMarker line
    draw()
    return


  return