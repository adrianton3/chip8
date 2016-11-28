'use strict'

{ LABEL, REGISTER, WORD, BYTE, TRIAD } = Assembler.partLabels

instructionTypes = new Map


add = (name, expectedParts, encoder) ->
	instructionTypes.set name, { expectedParts, encoder }

add_NNN = (name, code0) ->
	add name, [LABEL], (parts, labels) ->
		code0 | (labels.get parts[1].value)

add_XNN = (name, code0) ->
	add name, [REGISTER, BYTE], (parts) ->
		code0 | ((parseInt parts[1].value[1], 16) << 8) | (parseInt parts[2].value, 10)

add_XY_ = (name, code0, code3) ->
	add name, [REGISTER, REGISTER], (parts) ->
		code0 | ((parseInt parts[1].value[1], 16) << 8) | ((parseInt parts[2].value[1], 16) << 4) | code3

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
add 'sprite', [REGISTER, REGISTER, TRIAD], (parts) ->
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

add 'dw', [WORD], (parts) -> parts[1].value


window.Assembler ?= {}
Object.assign(window.Assembler, {
	instructionTypes
})