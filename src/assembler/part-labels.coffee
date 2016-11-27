'use strict'

partLabels =
	LABEL: 'label'
	REGISTER: 'register'
	WORD: 'word'
	BYTE: 'byte'
	BYTE3: 'byte3'


window.Assembler ?= {}
Object.assign(window.Assembler, {
	partLabels
})