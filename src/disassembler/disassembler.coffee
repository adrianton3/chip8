'use strict'

Chip8Disassembler = ->
  setupInstructions = ->
    ret = new Map

    decode_NNN = (type) ->
      (instruction) ->
        type: type
        NNN: instruction & 0x0FFF

    decode_XNN = (type) ->
      (instruction) ->
        type: type
        X: (instruction & 0x0F00) >> 8
        NN: instruction & 0x00FF

    decode_XY_ = (type) ->
      (instruction) ->
        type: type
        X: (instruction & 0x0F00) >> 8
        Y: (instruction & 0x00F0) >> 4

    decode_X__ = (type) ->
      (instruction) ->
        type: type
        X: (instruction & 0x0F00) >> 8

    add = Map::set.bind ret

    add_NNN = (pattern, name) ->
      add pattern, decode_NNN name

    add_XNN = (pattern, name) ->
      add pattern, decode_XNN name

    add_XY_ = (pattern, name) ->
      add pattern, decode_XY_ name

    add_X__ = (pattern, name) ->
      add pattern, decode_X__ name


    add 0x00E0, -> type: 'cls'
    add 0x00EE, -> type: 'return'

    add_NNN 0x1000, 'jump'
    add_NNN 0x2000, 'call'
    add_XNN 0x3000, 'sei'
    add_XNN 0x4000, 'snei'
    add_XY_ 0x5000, 'ser'
    add_XNN 0x6000, 'movi'
    add_XNN 0x7000, 'addi'

    add_XY_ 0x8000, 'movr'
    add_XY_ 0x8001, 'and'
    add_XY_ 0x8002, 'xor'
    add_XY_ 0x8003, 'addr'
    add_XY_ 0x8004, 'subr'
    add_XY_ 0x8005, 'shr'
    add_XY_ 0x8006, 'nsubr'
    add_XY_ 0x8007, 'shl'
    add_XY_ 0x800E, 'sner'

    add_XY_ 0x9000, 'or'

    add_NNN 0xA000, 'imovi'
    add_NNN 0xB000, 'jumpoff'

    add_XNN 0xC000, 'rnd'

    add 0xD000, (instruction) ->
      type: 'sprite'
      X: (instruction & 0x0F00) >> 8
      Y: (instruction & 0x00F0) >> 4
      N: instruction & 0x000F

    add_X__ 0xE09E, 'skr'
    add_X__ 0xE0A1, 'snkr'

    add_X__ 0xF007, 'rmovt'
    add_X__ 0xF00A, 'waitk'
    add_X__ 0xF015, 'movt'
    add_X__ 0xF018, 'movs'
    add_X__ 0xF01E, 'iaddr'
    add_X__ 0xF029, 'digit'
    add_X__ 0xF033, 'bcd'
    add_X__ 0xF055, 'store'
    add_X__ 0xF065, 'load'

    ret


  instructionPatterns = setupInstructions()
  registerNames = ("v#{(i.toString 16).toUpperCase()}" for i in [0..0xF])


  serializeInstruction = (instruction, labels) ->
    { type, X, Y, N, NN, NNN, word } = instruction

    if NNN?
      "#{type} #{labels.get NNN}"
    else if NN?
      "#{type} #{registerNames[X]} #{NN}"
    else if N?
      "#{type} #{registerNames[X]} #{registerNames[Y]} #{N}"
    else if Y?
      "#{type} #{registerNames[X]} #{registerNames[Y]}"
    else if X?
      "#{type} #{registerNames[X]}"
    else if type == 'dw'
      "dw 0x#{(word.toString 16).toUpperCase()}"
    else
      type


  decodeInstruction = (high, low) ->
    instruction = (high << 8) | low

    for mask in [0xF000, 0xF00F, 0xF0FF]
      masked = instruction & mask
      if instructionPatterns.has masked
        decoder = instructionPatterns.get masked
        return decoder instruction

    { type: 'dw', word: instruction }


  serialize = (instructions, jumpAddresses) ->
    labels = jumpAddresses.reduce (map, address, index) ->
      map.set address, "label-#{index + 1}"
    , new Map

    pointer = 0
    programCounter = 0

    lines = []
    for instruction in instructions
      while jumpAddresses[pointer] <= programCounter
        pointer++
        lines.push "label-#{pointer}:"

      lines.push serializeInstruction instruction, labels
      programCounter += 2

    lines.join '\n'


  uniqueSorted = (array) ->
    ret = []
    for i in [1...array.length]
      if array[i - 1] != array[i]
        ret.push array[i - 1]
    ret.push array[i - 1]
    ret

  disassemble = (program, startOffset = 0x0200) ->
    decodedInstructions = []
    jumpAddresses = []

    for programCounter in [0x000..0xFFF] by 2
      instructionHi = program[programCounter]
      instructionLo = program[programCounter + 1]
      break unless instructionHi | instructionLo

      decodedInstruction = decodeInstruction instructionHi, instructionLo

      decodedInstructions.push decodedInstruction

      if decodedInstruction.NNN?
        decodedInstruction.NNN -= startOffset
        decodedInstruction.NNN = Math.max 0, decodedInstruction.NNN
        jumpAddresses.push decodedInstruction.NNN

    jumpAddresses.sort()
    jumpAddresses = uniqueSorted jumpAddresses

    {
      instructions: decodedInstructions
      jumpAddresses
    }



  {
    decodeInstruction
    disassemble
    serialize
  }


window.Chip8Disassembler = Chip8Disassembler
