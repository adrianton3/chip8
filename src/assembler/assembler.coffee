'use strict'

Chip8Assembler = ->
  LABEL = 'label'
  REGISTER = 'register'
  BYTE = 'byte'
  BYTE3 = 'byte3'


  raise = (message, coords) ->
    error = Error message
    error.coords = coords
    throw error
    return


  setupPartValidators = ->
    ret = {}

    ret[LABEL] = (token, labels) ->
      unless token.type == 'identifier'
        raise "Expected a label", token.coords

      unless labels.has token.value
        raise "Label #{token.value} has not been declared", token.coords


    registerRegex = /^v[0-9A-F]$/
    ret[REGISTER] = (token) ->
      unless token.type == 'identifier' and registerRegex.test token.value
        raise "Expected a register", token.coords

    ret[BYTE] = (token) ->
      unless token.type == 'number' and +token.value < 256
        raise "Expected a byte", token.coords


    ret[BYTE3] = (token) ->
      unless token.type == 'number' and +token.value < 8
        raise "Expected a number between 0 and 7", token.coords

    ret


  setupInstructions = ->
    ret = new Map()

    add = (name, expectedParts, encoder) ->
      ret.set name, { expectedParts, encoder }

    add_NNN = (name, code0) ->
      add name, [LABEL], (parts, labels) ->
        code0 | (labels.get parts[1].value)

    add_XNN = (name, code0) ->
      add name, [REGISTER, BYTE], (parts) ->
        code0 | ((parseInt parts[1].value[1], 16) << 8) | (parseInt parts[2].value, 10)

    add_XY_ = (name, code0, code3) ->
      add name, [REGISTER, REGISTER], (parts) ->
        code1 | ((parseInt parts[1].value[1], 16) << 8) | ((parseInt parts[2].value[1], 16) << 4) | code3

    add_X__ = (name, code0, code23) ->
      add name, [REGISTER], (parts) ->
        code0 | ((parseInt parts[1].value[1], 16) << 8) | code23


    add 'cls', [], -> 0x00E0
    add 'return', [], -> 0x00EE

    add_NNN 'jump', 0x1000
    add_NNN 'call', 0x2000
    add_XNN 'sei', 0x3000
    add_XNN 'snei', 0x4000
    add_XY_ 'ser', 0x5000, 0x0000
    add_XNN 'movi', 0x6000
    add_XNN 'addi', 0x7000

    add_XY_ 'movr', 0x8000, 0x0000
    add_XY_ 'or', 0x8000, 0x0001
    add_XY_ 'and', 0x8000, 0x0002
    add_XY_ 'xor', 0x8000, 0x0003
    add_XY_ 'addr', 0x8000, 0x0004
    add_XY_ 'subr', 0x8000, 0x0005
    add_XY_ 'shr', 0x8000, 0x0006
    add_XY_ 'nsubr', 0x8000, 0x0007
    add_XY_ 'shl', 0x8000, 0x000E
    add_XY_ 'sner', 0x9000, 0x0000

    add_NNN 'imovi', 0xA000
    add_NNN 'jumpoff', 0xB000
    add_XNN 'rnd', 0xC000

    # _XYN
    add 'sprite', [REGISTER, REGISTER, BYTE3], (parts) ->
      0xD000 | ((parseInt parts[1].value[1], 16) << 8) | ((parseInt parts[2].value[1], 16) << 4) | (parseInt parts[3].value)

    add_X__ 'skr', 0xE000, 0x009E
    add_X__ 'snkr', 0xE000, 0x00A1

    add_X__ 'rmovt', 0xF000, 0x0007
    add_X__ 'waitk', 0xF000, 0x000A
    add_X__ 'movt', 0xF000, 0x0015
    add_X__ 'movs', 0xF000, 0x0018
    add_X__ 'iaddr', 0xF000, 0x001E
    add_X__ 'digit', 0xF000, 0x0029
    add_X__ 'bcd', 0xF000, 0x0033
    add_X__ 'store', 0xF000, 0x0055
    add_X__ 'load', 0xF000, 0x0065

    ret


  instructionTypes = setupInstructions()
  partValidators = setupPartValidators()


  parseInstruction = (tokens, labels) ->
    token = tokens.getCurrent()
    tokens.setMarker()
    instruction = token.value
    if not instructionTypes.has instruction
      raise "Unrecognised instruction #{instruction} in line #{token.coords.line}", token.coords

    instructionType = instructionTypes.get instruction
    tokens.advance()

    expectedParts = instructionType.expectedParts
    expectedParts.forEach (expectedPart, index) ->
      partValidator = partValidators[expectedParts[index]]
      partValidator tokens.getCurrent(), labels
      tokens.advance()
      return

    fullInstruction = instructionType.encoder tokens.getMarked(), labels
    [ fullInstruction >> 8, fullInstruction & 0x00FF ]


  expectNewline = (tokens, message) ->
    if tokens.getCurrent().type != 'end'
      tokens.expect 'newline', message


  getLabels = (tokens) ->
    labels = new Map()
    addressCounter = 0x200

    while tokens.hasNext()
      token = tokens.getCurrent()
      if token.type == 'label'
        if labels.has token.value
          raise "label '#{token.value}' already declared", token.coords
        labels.set token.value, addressCounter
        tokens.advance()
        expectNewline tokens, 'Expected new line after label declaration'
      else if token.type == 'identifier'
        while tokens.hasNext() and tokens.getCurrent().type != 'newline'
          tokens.advance()
        addressCounter += 2
      else if token.type == 'end'
        break
      else
        tokens.advance()

    tokens.reset()
    labels


  parse = (rawTokens) ->
    tokens = tokenList rawTokens
    labels = getLabels tokens
    instructions = []

    while tokens.hasNext()
      token = tokens.getCurrent()

      if token.type == 'identifier'
        Array::push.apply instructions, (parseInstruction tokens, labels)
        expectNewline tokens, 'Expected new line after label declaration'
      else if token.type == 'end'
        break
      else if token.type != 'newline' and token.type != 'label'
        raise "Unexpected #{token.type}", token.coords
      else
        tokens.advance()

    instructions


  assemble = (string) ->
    rawTokens = Chip8Tokenizer string
    parse rawTokens


  {
    assemble
    _getLabels: getLabels
  }


window.Chip8Assembler = Chip8Assembler