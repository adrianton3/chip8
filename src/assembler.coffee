'use strict'

Chip8Assembler = ->
  LABEL = 'label'
  REGISTER = 'register'
  BYTE = 'byte'
  BYTE3 = 'byte3'


  setupPartValidators = ->
    ret = {}

    ret[LABEL] = (part, labels) -> labels.has part

    registerRegex = /^v[0-9A-F]$/
    ret[REGISTER] = (part) -> registerRegex.test part

    ret[BYTE] = (part) -> (not isNaN part) and (0 <= +part <= 255)

    ret[BYTE3] = (part) -> (not isNaN part) and (0 <= +part <= 8)

    ret


  setupInstructions = ->
    ret = new Map()

    add = (name, expectedParts, encoder) ->
      ret.set name, { expectedParts, encoder }

    add 'cls', [], ->
      0x0000

    add 'return', [], ->
      0x000E

    add 'jump', [LABEL], (parts, labels) ->
      0x1000 | (labels.get parts[1])

    add 'call', [LABEL], (parts, labels) ->
      0x2000 | (labels.get parts[1])

    add 'sei', [REGISTER, BYTE], (parts) ->
      0x3000 | ((parseInt parts[1][1], 16) << 8) | (parseInt parts[2], 10)

    add 'snei', [REGISTER, BYTE], (parts) ->
      0x4000 | ((parseInt parts[1][1], 16) << 8) | (parseInt parts[2], 10)

    add 'ser', [REGISTER, REGISTER], (parts) ->
      0x5000 | ((parseInt parts[1][1], 16) << 8) | (parseInt parts[2][1], 16)

    add 'sprite', [REGISTER, REGISTER, BYTE], (parts) ->
      0xD000 | ((parseInt parts[1][1], 16) << 8) | ((parseInt parts[2][1], 16) << 4) | (parseInt parts[3])

    add 'digit', [REGISTER], (parts) ->
      0xF000 | ((parseInt parts[1][1], 16) << 8) | 0x0033

    ret


  instructions = setupInstructions()
  partValidators = setupPartValidators()


  validate = (parts, expectedParts, labels) ->
    if parts.length - 1 != expectedParts.length
      throw Error "instruction #{parts[0]} takes #{expectedParts.length} parameters"

    expectedParts.forEach (expectedPart, index) ->
      partValidator = partValidators[expectedParts[index]]
      if not partValidator parts[index + 1], labels
        throw Error "instruction #{parts[0]} takes #{expectedParts.join ', '}; parameter #{parts[index + 1]} failed validation"
      return
    return


  assemble = (string) ->
    trimmed1 = string.trim().replace /[ \t]{2,}/g, ' '
    trimmed2 = trimmed1.replace /(?: ?\n ?)+/g, '\n'
    lines = trimmed2.split '\n'

    program = []

    addressCounter = 0x0200
    labels = new Map()

    # traverse once to get the address of labels
    lines.forEach (line) ->
      if line[line.length - 1] == ':'
        label = line.slice 0, line.length - 1
        if labels.has label
          throw Error "label '#{label}' declared twice"
        labels.set label, addressCounter
      else
        addressCounter += 2

    # traverse another time to encode instructions
    lines.forEach (line) ->
      parts = line.split ' '

      if instructions.has parts[0]
        entry = instructions.get parts[0]
        validate parts, entry.expectedParts, labels
        encodedInstruction = entry.encoder parts, labels
        program.push (encodedInstruction >> 8), (encodedInstruction & 0x00FF)
      else if line[line.length - 1] != ':'
        throw Error "unrecognised instruction '#{parts[0]}' in line '#{line}'"

    program


  {
    assemble
  }


window.Chip8Assembler = Chip8Assembler