'use strict'

partLabels =
	LABEL: 'label'
	REGISTER: 'register'
	WORD: 'word'
	BYTE: 'byte'
	TRIAD: 'triad'


window.Assembler ?= {}
Object.assign(window.Assembler, {
	partLabels
})