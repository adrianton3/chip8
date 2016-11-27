'use strict'

describe 'tokenizer', ->
  tokenize = (string) ->
    tokens = Assembler.tokenize string
    tokens.pop()
    tokens

  token = (type) ->
    (value, line, column) ->
      { type: type, value, coords: { line, column } }

  number = token 'number'
  label = token 'label'
  identifier = token 'identifier'
  newline = (line, column) -> { type: 'newline', coords: { line, column } }

  error = (message, coords) ->
    error_ = Error message
    error_.coords = coords
    error_


  beforeEach ->
    jasmine.addMatchers CustomMatchers

  it 'tokenizes 0', ->
    expect tokenize '0'
    .toEqual [number 0, 0, 1]

  it 'tokenizes a number', ->
    expect tokenize '123'
    .toEqual [number 123, 0, 3]

  it 'tokenizes a number starting with 0', ->
    expect tokenize '012'
    .toEqual [number 12, 0, 3]

  it 'tokenizes more numbers', ->
    expect tokenize '123 456'
    .toEqual [(number 123, 0, 3), (number 456, 0, 7)]

  it 'throws an exception when parsing a number not followed by a separator', ->
    expect -> tokenize '123a'
    .toThrowWithMessage error "Unexpected character 'a'", { line: 0, column: 3 }

  it 'tokenizes a hexadecimal number', ->
    expect tokenize '0x20'
    .toEqual [number 32, 0, 4]

  it 'throws an exception when parsing a malformed hexadecimal number', ->
    expect -> tokenize '0x'
    .toThrowWithMessage error 'Encountered malformed number', { line: 0, column: 2 }

  it 'throws an exception when parsing a malformed binary number at the right coords', ->
    expect -> tokenize '\n\n\n  0b'
    .toThrowWithMessage error 'Encountered malformed number', { line: 3, column: 4 }

  it 'tokenizes a hexadecimal number', ->
    expect tokenize '0b1101'
    .toEqual [number 13, 0, 6]

  it 'throws an exception when parsing a malformed binary number', ->
    expect -> tokenize '0b'
    .toThrowWithMessage error 'Encountered malformed number', { line: 0, column: 2 }

  it 'throws an exception when parsing a malformed binary number at the right coords', ->
    expect -> tokenize '\n0b'
    .toThrowWithMessage error 'Encountered malformed number', { line: 1, column: 2 }

  it 'tokenizes an identifier', ->
    expect tokenize 'asd'
    .toEqual [identifier 'asd', 0, 3]

  it 'tokenizes more identifiers', ->
    expect tokenize 'asd fgh'
    .toEqual [(identifier 'asd', 0, 3), (identifier 'fgh', 0, 7)]

  it 'tokenizes an label', ->
    expect tokenize 'asd:'
    .toEqual [label 'asd', 0, 4]

  it 'tokenizes newlines', ->
    expect tokenize '\n'
    .toEqual [newline 0, 0]

  it 'ignores a comment', ->
    expect tokenize '; asd'
    .toEqual []

  it 'ignores whitespace', ->
    expect tokenize ' \t\t'
    .toEqual []