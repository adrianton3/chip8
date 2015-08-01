'use strict'

app = angular.module 'Disassembler', []

app.controller 'DisassemblerController', [
	'$scope'
	'$http'
	(
		$scope
		$http
	) ->
		{ disassemble, serialize } = Chip8Disassembler()

		@selectedRomName = 'MAZE'
		@romNames = [
			'15PUZZLE', 'BLINKY', 'BLITZ', 'BRIX', 'CONNECT4', 'GUESS', 'HIDDEN', 'INVADERS',
			'KALEID', 'MAZE', 'MERLIN', 'MISSILE', 'PONG', 'PONG2', 'PUZZLE', 'SYZYGY',
			'TANK', 'TETRIS', 'TICTAC', 'UFO', 'VBRIX', 'VERS', 'WIPEOFF', 'ZERO'
		]

		editor = null

		setupEditor = ->
			editor = ace.edit 'editor'
			editor.getSession().setMode 'ace/mode/chip8'
			editor.setTheme 'ace/theme/monokai'
			return

		setupEditor()


		@changeRom = ->
			$http.get "../../roms/#{@selectedRomName}", { responseType: 'arraybuffer' }
			.success (data) ->
				{ instructions, jumpAddresses } = disassemble (new Uint8Array data), 0x0200
				str = serialize instructions, jumpAddresses, 0x0200
				editor.setValue str, -1
				return

		@changeRom()

		return
	]