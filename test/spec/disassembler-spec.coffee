'use strict'

describe 'disassembler', ->
  disassembler = window.Chip8Disassembler()
  { disassemble, serialize } = disassembler


  splitWords = (words) ->
    bytes = []
    words.forEach (word) ->
      bytes.push (word >> 8), (word & 0xFF)
      return
    bytes


  PROGRAM_OFFSET = 0x0123
  decode = (words) ->
    { instructions, jumpAddresses } = disassemble (splitWords words), PROGRAM_OFFSET
    serialize instructions, jumpAddresses, PROGRAM_OFFSET


  beforeEach ->
    jasmine.addMatchers CustomMatchers


  describe 'jump (_NNN)', ->
    it 'decodes one jump', ->
      expect decode [0x1000 | PROGRAM_OFFSET | 0]
      .toEqual 'label-1:\njump label-1'

    it 'decodes more jumps', ->
      expect decode [0x1000 | (PROGRAM_OFFSET + 0), 0x1000 | (PROGRAM_OFFSET + 2)]
      .toEqual 'label-1:\njump label-1\nlabel-2:\njump label-2'

    it 'decodes jumps to labels not yet declared', ->
      expect decode [0x1000 | (PROGRAM_OFFSET + 2), 0x1000 | (PROGRAM_OFFSET + 0)]
      .toEqual 'label-1:\njump label-2\nlabel-2:\njump label-1'

    it 'decodes jumps to the same addres', ->
      expect decode [0x1000 | (PROGRAM_OFFSET + 0), 0x1000 | (PROGRAM_OFFSET + 0)]
      .toEqual 'label-1:\njump label-1\njump label-1'


  describe 'sei (_XNN)', ->
    it 'decodes', ->
      expect decode [0x3000 | 0x0A00 | 31]
      .toEqual 'sei vA 31'

  describe 'sprite (_XYN)', ->
    it 'decodes', ->
      expect decode [0xD000 | 0x0500 | 0x00D0 | 3]
      .toEqual 'sprite v5 vD 3'

  describe 'cls (____)', ->
    it 'decodes', ->
      expect decode [0x00E0]
      .toEqual 'cls'