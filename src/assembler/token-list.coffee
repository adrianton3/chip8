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


  expect = (type, message) ->
    token = getCurrent()
    advance()
    if token.type != type
      throw Error "#{message}, line #{token.coords.line}, column #{token.coords.column}"
    return


  setMarker = ->
    marker = pointer


  getMarked = ->
    tokens[marker..pointer]


  {
    hasNext
    reset
    advance
    getCurrent
    expect
    setMarker
    getMarked
  }

window.tokenList = tokenList