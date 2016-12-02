'use strict'

{ instructionTypes } = Assembler


formatters = new Map


findSimilar = (haystack, needle) ->
	matches = []

	haystack.forEach (address, candidate) ->
		if candidate.startsWith needle
			matches.push candidate
		return

	haystack.forEach (address, candidate) ->
		if candidate.endsWith needle
			matches.push candidate
		return

	matches.slice 0, 3


formatters.set 'bad-instruction', ({ token }) ->
	message: "Unrecognised instruction #{token.value}"
	help: "similarly named instruction: #{findSimilar instructionTypes, token.value}"
	coords: token.coords


formatParameters = (instruction) ->
	{ expectedParts } = instructionTypes.get instruction
	expectedParts.join ','


makePartTypeFormatter = (type) ->
	({ token, instruction }) ->
		message: "Expected a #{type}"
		help: "instruction #{instruction} takes #{formatParameters instruction}"
		coords: token.coords


formatters.set 'expect-label', makePartTypeFormatter 'label'

formatters.set 'expect-word', makePartTypeFormatter 'word'

formatters.set 'expect-byte', makePartTypeFormatter 'byte'

formatters.set 'expect-triad', makePartTypeFormatter 'triad (3 bit number)'

formatters.set 'expect-register', makePartTypeFormatter 'register'


formatters.set 'undeclared-label', ({ token, labels }) ->
	message: "Label #{token.value} has not been declared"
	help: "similarly named labels: #{findSimilarLabels labels, token.value}"
	coords: token.coords


formatError = (type, context) ->
	(formatters.get type) context


window.Assembler ?= {}
Object.assign(window.Assembler, {
	formatError
})