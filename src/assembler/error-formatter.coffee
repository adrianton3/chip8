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
	list = findSimilar instructionTypes, token.value
	help = if list.length > 0
		"similarly named instructions: #{list.join ', '}"
	else
		"no similarly named instructions found"

	message: "Unrecognised instruction #{token.value}"
	help: help
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
	list = findSimilar labels, token.value
	help = if list.length > 0
		"similarly named labels: #{list.join ', '}"
	else
		"no similarly named labels found"

	message: "Label #{token.value} has not been declared"
	help: help
	coords: token.coords


formatError = (type, context) ->
	(formatters.get type) context


window.Assembler ?= {}
Object.assign(window.Assembler, {
	formatError
})