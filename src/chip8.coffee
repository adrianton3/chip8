'use strict'

Chip8 = ->
  WIDTH = 64
  HEIGHT = 32

  video = new Uint8Array WIDTH * HEIGHT
  memory = new Uint8Array 0x1000
  V = new Uint8Array 16
  stack = new Uint16Array 16

  soundTimer = 0
  delayTimer = 0

  programCounter = 0x200
  I = 0
  stackPointer = 0

  waitingForKey = false


  load = (romData) ->
    for i in [0...romData.length]
      memory[i + 0x0200] = romData[i]

    # calling it here for now
    initChars()
    return


  reset = ->
    soundTimer = 0
    delayTimer = 0

    programCounter = 0x200
    I = 0
    stackPointer = 0

    video[i] = 0 for i in [0...WIDTH * HEIGHT]
    V[i] = 0 for i in [0...16]
    stack[i] = 0 for i in [0...16]
    return


  initChars = ->
    # 5 lines per char
    memory.set [
      0xF0, 0x90, 0x90, 0x90, 0xF0 # 0
      0x20, 0x60, 0x20, 0x20, 0x70 # 1
      0xF0, 0x10, 0xF0, 0x80, 0xF0 # 2
      0xF0, 0x10, 0xF0, 0x10, 0xF0 # 3
      0x90, 0x90, 0xF0, 0x10, 0x10 # 4
      0xF0, 0x80, 0xF0, 0x10, 0xF0 # 5
      0xF0, 0x80, 0xF0, 0x90, 0xF0 # 6
      0xF0, 0x10, 0x20, 0x40, 0x40 # 7
      0xF0, 0x90, 0xF0, 0x90, 0xF0 # 8
      0xF0, 0x90, 0xF0, 0x10, 0xF0 # 9
      0xF0, 0x90, 0xF0, 0x90, 0x90 # A
      0xE0, 0x90, 0xE0, 0x90, 0xE0 # B
      0xF0, 0x80, 0x80, 0x80, 0xF0 # C
      0xE0, 0x90, 0x90, 0x90, 0xE0 # D
      0xF0, 0x80, 0xF0, 0x80, 0xF0 # E
      0xF0, 0x80, 0xF0, 0x80, 0x80 # F
    ]
    return


  getVideo = -> video
  getRegisters = -> V
  getProgramCounter = -> programCounter
  getStackPointer = -> stackPointer
  getStack = -> stack
  getI = -> I

  keyboard = null

  setKeyboard = (keyboard_) ->
    keyboard = keyboard_
    return


  clearScreen = ->
    for i in [0...video.length]
      video[i] = 0
    return


  setPixel = (i, j) ->
    if i > HEIGHT
      i -= HEIGHT
    else if i < 0
      i += HEIGHT

    if j > WIDTH
      j -= WIDTH
    else if j < 0
      j += WIDTH

    address = (i * WIDTH) + j

    video[address] ^= 1

    not video[address]


  tick = ->
    return if waitingForKey

    instructionHi = memory[programCounter]
    instructionLo = memory[programCounter + 1]
    X = instructionHi & 0x0F
    Y = instructionLo >> 4
    instruction = (instructionHi << 8) | instructionLo

    delayTimer-- if delayTimer > 0
    soundTimer-- if soundTimer > 0

    programCounter += 2
    switch 0xF0 & instructionHi
      when 0x00
        switch instructionLo
          # clear screen
          when 0xE0
            clearScreen()

          # return from subroutine
          when 0xEE
            stackPointer--
            programCounter = stack[stackPointer]

      # jump to NNN
      when 0x10
        programCounter = instruction & 0x0FFF

      # call subroutine
      when 0x20
        stack[stackPointer] = programCounter
        stackPointer++
        programCounter = instruction & 0x0FFF

      # skip if vX == NN
      when 0x30
        if instructionLo == V[X]
          programCounter += 2

      # skip if vX != NN
      when 0x40
        if instructionLo != V[X]
          programCounter += 2

      # skip if vX == vY
      when 0x50
        if V[X] == V[Y]
          programCounter += 2

      # vX = NN
      when 0x60
        V[X] = instructionLo

      # vX += NN
      when 0x70
        V[X] += instructionLo

      when 0x80
        switch 0x08 & instructionLo

          # vX = vY
          when 0x00
            V[X] = V[Y]

          # vX |= vY
          when 0x01
            V[X] |= V[Y]

          # vX &= vY
          when 0x02
            V[X] &= V[Y]

          # vX ^= vY
          when 0x03
            V[X] ^= V[Y]

          # vX += vY; vF = 1 if overflow
          when 0x04
            V[X] += V[Y]
            V[0xF] = +(V[X] < V[Y])

          # vX -= vY; vF = 1 if not borrow
          when 0x05
            V[0xF] = +(V[X] > V[Y])
            V[X] -= V[Y]

          # shr (does not use vY)
          when 0x06
            V[0xF] = V[X] & 0x01
            V[X] >>= 1

          # vX = vY - vX; vF = 1 if not borrow
          when 0x07
            V[0xF] = +(V[Y] > V[X])
            V[X] = V[Y] - V[X]

          # shl (does not use vY)
          when 0x0E
            V[0xF] = V[X] & 0x80
            V[X] <<= 1

      # skip if vX != vY
      when 0x90
        if V[X] != V[Y]
          programCounter += 2

      # I = NNN
      when 0xA0
        I = instruction & 0x0FFF

      # jump to NNN + v0
      when 0xB0
        programCounter = (instruction & 0x0FFF) + V[0]

      # rnd
      when 0xC0
        V[X] = ((Math.random() * 256) | 0) & instructionLo

      # print sprite
      when 0xD0
        V[0xF] = 0
        height = instructionLo & 0x0F
        for i in [0...height]
          line = memory[I + i]
          for j in [0...8]
            if line & 0x80
              if setPixel V[Y] + i, V[X] + j
                V[0xF] = 1
            line <<= 1

      when 0xE0
        switch instructionLo
          when 0x9E
            keyState = keyboard.getState V[X]
            if keyState == 1
              programCounter += 2

          when 0xA1
            keyState = keyboard.getState V[X]
            if keyState == 0
              programCounter += 2

      when 0xF0
        switch instructionLo
          when 0x07
            V[X] = delayTimer

          when 0x0A
            waitingForKey = true
            keyboard.waitForKey (key) ->
              waitingForKey = false
              V[X] = key

          when 0x15
            delayTimer = V[X]

          when 0x18
            soundTimer = V[X]

          when 0x1E
            I += V[X]

          # I = vX char sprite
          when 0x29
            I = V[X] * 5

          # bcd
          when 0x33
            value = V[X]
            memory[I + 2] = value % 10

            value = (value / 10) | 0
            memory[I + 1] = value % 10

            value = (value / 10) | 0
            memory[I + 0] = value % 10

          # save registers
          when 0x55
            for i in [0..X]
              memory[I + i] = V[i]

          # restore registers
          when 0x65
            for i in [0..X]
              V[i] = memory[I + i]

      else
        console.log 'unsupported'
    return


  {
    tick
    load
    reset
    clearScreen
    getVideo
    getRegisters
    getProgramCounter
    getStackPointer
    getStack
    getI
    setKeyboard
  }

window.Chip8 = Chip8