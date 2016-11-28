'use strict'

{ instructionTypes } = Assembler


formatters = new Map


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


findSimilarLabels = (labels, candidate) ->
	matches = []

	labels.forEach (address, label) ->
		if label.startsWith candidate
			matches.push label
		return

	labels.forEach (address, label) ->
		if label.endsWith candidate
			matches.push label
		return

	matches.slice 0, 3


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