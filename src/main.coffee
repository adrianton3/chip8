'use strict'

{ setupCanvas, loadRom, draw } = window.Chip8Common

{ initContext, draw, setVideoData } = Chip8Renderer()

initContext document.getElementById 'can'

keyboard = Chip8Keyboard()
(document.getElementById 'container').appendChild keyboard.getHtml()

chip8 = Chip8()
chip8.setKeyboard keyboard

(loadRom 'MAZE').then (romData) ->
  chip8.load romData

  TICKS_PER_FRAME = 1

  mainLoop = ->
    for i in [0...TICKS_PER_FRAME]
      chip8.tick()

    setVideoData chip8.getVideo()
    draw()

    requestAnimationFrame mainLoop
    return

  mainLoop()
  return