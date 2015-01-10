'use strict'

app = angular.module 'Assembler', []

app.controller 'AssemblerController', ($scope) ->
  { initContext, draw, setVideoData } = Chip8Renderer()

  initContext document.getElementById 'can'

  TICKS_PER_FRAME = 1

  self = @

  rafId = null

  editor = null

  @running = false

  @state = null

  @assemblerStatus = 'OK'

  assembler = Chip8Assembler()

  keyboard = Chip8Keyboard()
  (document.getElementById 'container').appendChild keyboard.getHtml()

  chip8 = Chip8()
  chip8.setKeyboard keyboard


  onChange = (text) ->
    if text.length == 0
      self.assemblerStatus = 'OK'
      $scope.$apply()
    else
      try
        assembler.assemble text
        self.assemblerStatus = 'OK'
        $scope.$apply()
      catch ex
        self.assemblerStatus = ex.message
        $scope.$apply()
    return


  setupEditor = ->
    editor = ace.edit 'editor'
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


  @reset = ->
    @stop()
    text = editor.getValue()
    if text.length
      try
        program = assembler.assemble text
        self.assemblerStatus = 'OK'
        self.loadProgram program
      catch ex
        self.assemblerStatus = ex.message

    chip8.reset()
    @state = getState()
    setVideoData chip8.getVideo()
    draw()


  @reset()


  @loadProgram = chip8.load


  @step = ->
    chip8.tick()
    @state = getState()
    setVideoData chip8.getVideo()
    draw()
    return


  return