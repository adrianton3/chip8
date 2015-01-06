'use strict'

{ setupCanvas, loadRom, draw } = window.Chip8Common

{ con2d, videoBuffer } = setupCanvas()

keyboard = Chip8Keyboard()
(document.getElementById 'container').appendChild keyboard.getHtml()

chip8 = Chip8()
chip8.setKeyboard keyboard

(loadRom 'WIPEOFF').then (romData) ->
  chip8.load romData

  TICKS_PER_FRAME = 1

  mainLoop = ->
    for i in [0...TICKS_PER_FRAME]
      chip8.tick()

    draw chip8.getVideo(), videoBuffer, con2d

    requestAnimationFrame mainLoop
    return

  mainLoop()
  return