'use strict'

{
	instructionTypes
	partValidators
	tokenize
	tokenList
	formatError
} = Assembler


raise = (message, coords) ->
	if typeof message == 'string'
		error = Error message
		error.coords = coords
		throw error
	else
		error = Error """
			#{message.message}
			Hint: #{message.help}
		"""
		error.coords = message.coords
		throw error

	return


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
		token = tokens.getCurrent()
		result = partValidator token, labels
		if result?
			pretty = formatError result, { labels, instruction, token }
			raise pretty

		tokens.advance()
		return

	fullInstruction = instructionType.encoder tokens.getMarked(), labels
	[ fullInstruction >> 8, fullInstruction & 0x00FF ]


expectNewline = (tokens, message) ->
	token = tokens.getCurrent()

	if token.type != 'newline' and token.type != 'end'
		raise message, token.coords

	tokens.advance()
	return


getLabels = (tokens) ->
	labels = new Map
	addressCounter = 0x0200

	while tokens.hasNext()
		token = tokens.getCurrent()
		if token.type == 'label'
			if labels.has token.value
				raise "Label '#{token.value}' already declared", token.coords
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
	lineMapping = new Map
	addressCounter = 0x0200

	while tokens.hasNext()
		token = tokens.getCurrent()

		if token.type == 'identifier'
			lineMapping.set addressCounter, tokens.getCurrent().coords.line
			addressCounter += 2
			Array::push.apply instructions, (parseInstruction tokens, labels)
			expectNewline tokens, 'Expected new line after instruction'
		else if token.type == 'end'
			break
		else if token.type != 'newline' and token.type != 'label'
			raise "Unexpected #{token.type}", token.coords
		else
			tokens.advance()

	{ instructions, lineMapping }


assemble = (string) ->
	rawTokens = tokenize string
	parse rawTokens


window.Assembler ?= {}
Object.assign(window.Assembler, {
	assemble
	_getLabels: getLabels
})