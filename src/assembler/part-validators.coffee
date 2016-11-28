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
	return 'expect-label' unless token.type == 'identifier'

	return 'undeclared-label' unless labels.has token.value


registerRegex = /^v[0-9A-F]$/
partValidators[REGISTER] = (token) ->
	return 'expect-register' unless token.type == 'identifier' and registerRegex.test token.value


partValidators[WORD] = (token) ->
	return 'expect-word' unless token.type == 'number' and +token.value < 256 * 256


partValidators[BYTE] = (token) ->
	return 'expect-byte' unless token.type == 'number' and +token.value < 256


partValidators[BYTE3] = (token) ->
	return 'expect-triad' unless token.type == 'number' and +token.value < 8


window.Assembler ?= {}
Object.assign(window.Assembler, {
	partValidators
})