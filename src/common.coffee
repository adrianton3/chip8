'use strict'

setupCanvas = ->
  canvas = document.getElementById 'can'
  con2d = canvas.getContext '2d'

  videoBuffer = con2d.createImageData 64, 32

  { con2d, videoBuffer }


loadRom = (romFile) ->
  request = new XMLHttpRequest()
  request.open 'GET', "../roms/#{romFile}", true
  request.responseType = 'arraybuffer'

  promise = new Promise (resolve, reject) ->
    request.onload = ->
      resolve new Uint8Array request.response
      return
    return

  request.send()
  promise


draw = (video, videoBuffer, con2d) ->
  i4 = 0
  for i in [0...video.length]
    if video[i]
      videoBuffer.data[i4 + 0] = 255
      videoBuffer.data[i4 + 1] = 255
      videoBuffer.data[i4 + 2] = 255
    else
      videoBuffer.data[i4 + 0] = 0
      videoBuffer.data[i4 + 1] = 0
      videoBuffer.data[i4 + 2] = 0

    videoBuffer.data[i4 + 3] = 255

    i4 += 4

  con2d.putImageData videoBuffer, 0, 0
  return


window.Chip8Common = { setupCanvas, loadRom, draw }