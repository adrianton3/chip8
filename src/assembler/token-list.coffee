'use strict'

tokenList = (tokens_) ->
  pointer = 0
  marker = 0
  tokens = tokens_


  hasNext = ->
    pointer < tokens.length


  reset = ->
    pointer = 0
    marker = 0


  advance = ->
    pointer++
    return


  getCurrent = ->
    tokens[pointer]


  setMarker = ->
    marker = pointer


  getMarked = ->
    tokens[marker..pointer]


  {
    hasNext
    reset
    advance
    getCurrent
    setMarker
    getMarked
  }


window.Assembler ?= {}
Object.assign(window.Assembler, {
	tokenList
})