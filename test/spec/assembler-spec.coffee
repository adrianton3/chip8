'use strict'

describe 'assembler', ->
	assembler = window.Chip8Assembler()
	{ assemble } = assembler

	instructions = (code) -> (assemble code).instructions

	lineMapping = (code) ->
		map = (assemble code).lineMapping

		objMap = {}
		map.forEach (value, key) ->
			objMap[key] = value
		objMap


	splitWords = (words) ->
		bytes = []
		words.forEach (word) ->
			bytes.push (word >> 8), (word & 0xFF)
			return
		bytes

	beforeEach ->
		jasmine.addMatchers CustomMatchers

	describe 'instructions', ->
		describe 'labels', ->
			it 'throws an error if a label is declared twice', ->
				expect -> instructions '''
					label1:
					label1:
				'''
				.toThrow Error "Label 'label1' already declared"

			it 'throws an error if there are tokens following a label on the same line', ->
				expect -> instructions '''
					label1: 123
				'''
				.toThrow Error "Expected new line after label declaration"


		describe 'jump', ->
			it 'encodes one jump', ->
				expect instructions '''
					label1:
					jump label1
				'''
				.toEqual splitWords [0x1000 | 0x0200 | 0]

			it 'encodes more jumps', ->
				expect instructions '''
					label1:
					jump label1
					label2:
					jump label2
				'''
				.toEqual splitWords [0x1000 | (0x0200 + 0), 0x1000 | (0x0200 + 2)]

			it 'encodes jumps to labels not yet declared', ->
				expect instructions '''
					label1:
					jump label2
					label2:
					jump label1
				'''
				.toEqual splitWords [0x1000 | (0x0200 + 2), 0x1000 | (0x0200 + 0)]


		describe 'sei', ->
			it 'encodes', ->
				expect instructions 'sei vA 31'
				.toEqual splitWords [0x3000 | 0x0A00 | 31]

			it 'throws an exception if register is missing', ->
				expect -> instructions 'sei v 31'
				.toThrow Error 'Expected a register'

			it 'throws an exception if value is missing', ->
				expect -> instructions 'sei v0'
				.toThrow Error 'Expected a byte'


		describe 'dw', ->
			it 'encodes', ->
				expect instructions 'dw 0x1234'
				.toEqual splitWords [0x1234]

			it 'throws an exception if value is too high', ->
				expect -> instructions 'dw 0x12345'
				.toThrow Error 'Expected a word'


	describe 'lineMapping', ->
		it 'computes the mapping for 3 instructions', ->
			expect lineMapping '''
				or v1 vA
				and v2 vB
				xor v3 vC
			'''
			.toEqual
				0x0200: 0
				0x0202: 1
				0x0204: 2

		it 'computes the mapping for 3 instructions separated by extra spacing', ->
			expect lineMapping '''


				or v1 vA


				and v2 vB

				xor v3 vC
			'''
			.toEqual
				0x0200: 2
				0x0202: 5
				0x0204: 7

		it 'computes the mapping for 3 instructions separated by labels', ->
			expect lineMapping '''
				label1:
				or v1 vA
				label2:
				label3:
				and v2 vB
				label4:
				xor v3 vC
				label5:
			'''
			.toEqual
				0x0200: 1
				0x0202: 4
				0x0204: 6