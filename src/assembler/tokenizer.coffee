'use strict'

Chip8Tokenizer = (rawString) ->

  number = (base) ->
    (raw, coords) ->
      type: 'number'
      value: parseInt raw, base
      coords: coords


  numberDec = number 10

  numberHex = number 16

  numberBin = number 2


  identifier = (raw, coords) ->
    type: 'identifier'
    value: raw
    coords: coords


  label = (raw, coords) ->
    type: 'label'
    value: raw
    coords: coords


  newLine = (coords) ->
    type: 'newline'
    coords: coords


  chopNumberDec = (string) ->
    string.setMarker()

    while '0' <= string.getCurrent() <= '9'
      string.advance()

    current = string.getCurrent()
    if current != ' ' and current != '\n'
      throw Error "Unexpected character '#{current}'"

    numberDec string.getMarked(), string.getCoords()


  chopNumberHex = (string) ->
    string.advance()
    string.advance()
    string.setMarker()

    while '0' <= string.getCurrent() <= '9' or 'A' <= string.getCurrent() <= 'F'
      string.advance()

    current = string.getCurrent()
    if current != ' ' and current != '\n'
      throw Error "Unexpected character '#{current}'"

    rawNumber = string.getMarked()
    if rawNumber.length == 0
      throw Error "Encountered malformed number"
    numberHex rawNumber, string.getCoords()


  chopNumberBin = (string) ->
    string.advance()
    string.advance()
    string.setMarker()

    while '0' <= string.getCurrent() <= '1'
      string.advance()

    current = string.getCurrent()
    if current != ' ' and current != '\n'
      throw Error "Unexpected character '#{current}'"

    rawNumber = string.getMarked()
    if rawNumber.length == 0
      throw Error "Encountered malformed number"
    numberBin rawNumber, string.getCoords()


  chopIdentifier = (string) ->
    string.setMarker()

    while 'a' <= string.getCurrent() <= 'z' or 'A' <= string.getCurrent() <= 'Z' or '0' <= string.getCurrent() <= '9'
      string.advance()

    if string.getCurrent() == ':'
      string.advance()
      label (string.getMarked -1), string.getCoords()
    else
      identifier string.getMarked(), string.getCoords()


  chopComment = (string) ->
    while string.getCurrent() != '\n' and string.hasNext()
      string.advance()
    return


  chop = (string) ->
    tokens = []

    while string.hasNext()
      currentChar = string.getCurrent()

      if '1' <= currentChar <= '9'
        tokens.push chopNumberDec string
      else if currentChar == '0'
        next = string.getNext()
        switch next
          when 'x'
            tokens.push chopNumberHex string
          when 'b'
            tokens.push chopNumberBin string
          else
            tokens.push chopNumberDec string
      else if 'a' <= currentChar <= 'z' or 'A' <= currentChar <= 'F'
        tokens.push chopIdentifier string
      else if currentChar == ';'
        chopComment string
      else if currentChar == '\n'
        tokens.push newLine string.getCoords()
        string.advance()
      else
        string.advance()

    tokens


  chop iterableString rawString + ' '


window.Chip8Tokenizer = Chip8Tokenizer