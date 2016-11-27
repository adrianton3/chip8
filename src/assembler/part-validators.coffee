'use strict'

{ partLabels } = Assembler

{ LABEL, REGISTER, WORD, BYTE, BYTE3 } = partLabels


raise = (message, coords) ->
	error = Error message
	error.coords = coords
	throw error
	return


partValidators = {}


partValidators[LABEL] = (token, labels) ->
	unless token.type == 'identifier'
		raise "Expected a label", token.coords

	unless labels.has token.value
		raise "Label #{token.value} has not been declared", token.coords


registerRegex = /^v[0-9A-F]$/
partValidators[REGISTER] = (token) ->
	unless token.type == 'identifier' and registerRegex.test token.value
		raise "Expected a register", token.coords


partValidators[WORD] = (token) ->
	unless token.type == 'number' and +token.value < 256 * 256
		raise "Expected a word", token.coords


partValidators[BYTE] = (token) ->
	unless token.type == 'number' and +token.value < 256
		raise "Expected a byte", token.coords


partValidators[BYTE3] = (token) ->
	unless token.type == 'number' and +token.value < 8
		raise "Expected a number between 0 and 7", token.coords


window.Assembler ?= {}
Object.assign(window.Assembler, {
	partValidators
})