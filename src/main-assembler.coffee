'use strict'

app = angular.module 'Assembler', []

app.controller 'AssemblerController', ($scope) ->
  { setupCanvas, draw } = window.Chip8Common

  TICKS_PER_FRAME = 1

  self = @

  rafId = null

  @running = false

  @state = null

  @assemblerStatus = 'OK'

  assembler = Chip8Assembler()

  chip8 = Chip8()


  onChange = (text) ->
    if text.length == 0
      self.assemblerStatus = 'OK'
      $scope.$apply()
    else
      try
        program = assembler.assemble text
        self.assemblerStatus = 'OK'
        $scope.$apply()
        self.loadProgram program
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


  @start = ->
    mainLoop = ->
      for i in [0...TICKS_PER_FRAME]
        chip8.tick()

      draw chip8.getVideo(), videoBuffer, con2d

      rafId = requestAnimationFrame mainLoop
      return

    mainLoop()
    return


  @stop = ->
    @running = false
    cancelRequestAnimationFrame rafId


  @reset = -> chip8.reset()
  @loadProgram = chip8.load


  getState = ->
    programCounter = chip8.getProgramCounter()
    registers = Array::slice.call chip8.getRegisters(), 0
    stackPointer = chip8.getStackPointer()
    stack = Array::slice.call chip8.getStack(), stackPointer

    {
      programCounter
      registers
      stackPointer
      stack
    }


  @step = ->
    chip8.tick()
    @state = getState()
    draw chip8.getVideo(), videoBuffer, con2d


  { con2d, videoBuffer } = setupCanvas()
  return