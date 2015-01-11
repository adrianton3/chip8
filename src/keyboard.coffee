'use strict'

Chip8Keyboard = ->
  layout = [
    ['1', '2', '3', 'C']
    ['4', '5', '6', 'D']
    ['7', '8', '9', 'E']
    ['A', '0', 'B', 'F']
  ]


  state = new Uint8Array 16

  getState = (key) -> state[key]

  waitCallback = null

  waitForKey = (callback) ->
    waitCallback = callback


  setEventListener = (button, key) ->
    button.addEventListener 'mouseup', ->
      state[key] = 0
      return

    button.addEventListener 'mousedown', ->
      state[key] = 1
      if waitCallback?
        waitCallback key
        waitCallback = null
      return

    return


  getHtml = ->
    table = document.createElement 'table'
    table.classList.add 'keyboard'

    layout.forEach (line) ->
      tr = document.createElement 'tr'
      table.appendChild tr

      line.forEach (key) ->
        td = document.createElement 'td'
        tr.appendChild td

        button = document.createElement 'button'
        button.innerText = key
        button.classList.add 'key'
        td.appendChild button

        setEventListener button, (parseInt key, 16)
        return

    table


  {
    getHtml
    getState
    waitForKey
  }

window.Chip8Keyboard = Chip8Keyboard