'use strict'

describe 'assembler', ->
  assembler = window.Chip8Assembler()
  { assemble } = assembler


  splitWords = (words) ->
    bytes = []
    words.forEach (word) ->
      bytes.push (word >> 8), (word & 0xFF)
      return
    bytes

  beforeEach ->
    jasmine.addMatchers CustomMatchers

  describe 'labels', ->
    it 'throws an error if a label is declared twice', ->
      expect -> assemble 'label1:\nlabel1:'
      .toThrow Error "label 'label1' already declared"


  describe 'jump', ->
    it 'encodes one jump', ->
      expect assemble 'label1:\njump label1'
      .toEqual splitWords [0x1000 | 0x0200 | 0]

    it 'encodes more jumps', ->
      expect assemble 'label1:\njump label1\nlabel2:\njump label2'
      .toEqual splitWords [0x1000 | (0x0200 + 0), 0x1000 | (0x0200 + 2)]

    it 'encodes jumps to labels not yet declared', ->
      expect assemble 'label1:\njump label2\nlabel2:\njump label1'
      .toEqual splitWords [0x1000 | (0x0200 + 2), 0x1000 | (0x0200 + 0)]


  describe 'sei', ->
    it 'encodes', ->
      expect assemble 'sei vA 31'
      .toEqual splitWords [0x3000 | 0x0A00 | 31]

    it 'throws an exception if register is missing', ->
      expect -> assemble 'sei v 31'
      .toThrow Error 'Expected a register'

    it 'throws an exception if value is missing', ->
      expect -> assemble 'sei v0'
      .toThrow Error 'Expected a byte'


  describe 'dw', ->
    it 'encodes', ->
      expect assemble 'dw 0x1234'
      .toEqual splitWords [0x1234]

    it 'throws an exception if value is too high', ->
      expect -> assemble 'dw 0x12345'
      .toThrow Error 'Expected a word'