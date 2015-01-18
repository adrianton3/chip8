'use strict'

iterableString = (string_) ->
  string = string_ + ' '
  pointer = 0
  marker = 0

  line = 0
  column = 0


  getCurrent = ->
    string[pointer]


  getNext = ->
    string[pointer + 1]


  hasNext = ->
    pointer < string.length


  advance = ->
    pointer++
    if getCurrent() == '\n'
      line++
      column = 0
    else
      column++


  setMarker = (offset = 0) ->
    marker = pointer + offset


  getMarked = (offset = 0) ->
    string.substring marker, pointer + offset


  getCoords = ->
    { line, column }


  {
    advance
    setMarker
    getCurrent
    getNext
    hasNext
    getMarked
    getCoords
  }

window.iterableString = iterableString