'use strict'

app = angular.module 'Chip8', []

app.controller 'Chip8Controller', [
	'$scope'
	'$http'
	(
		$scope
		$http
	) ->
		{ initContext, draw, setVideoData } = Chip8Renderer()

		@selectedRomName = 'MAZE'
		@romNames = [
			'15PUZZLE', 'BLINKY', 'BLITZ', 'BRIX', 'CONNECT4', 'GUESS', 'HIDDEN', 'INVADERS',
			'KALEID', 'MAZE', 'MERLIN', 'MISSILE', 'PONG', 'PONG2', 'PUZZLE', 'SYZYGY',
			'TANK', 'TETRIS', 'TICTAC', 'UFO', 'VBRIX', 'VERS', 'WIPEOFF', 'ZERO'
		]


		@changeRom = ->
			($http.get "../roms/#{@selectedRomName}", { responseType: 'arraybuffer' })
				.success (data) =>
					@chip8.load new Uint8Array data
					@chip8.reset()


		@init = ->
			initContext document.getElementById 'can'

			keyboard = Chip8Keyboard()
			(document.getElementById 'container').appendChild keyboard.getHtml()

			@chip8 = Chip8()
			@chip8.setKeyboard keyboard

		@init()


		@changeRom()
			.then =>
				TICKS_PER_FRAME = 10

				mainLoop = =>
					for i in [0...TICKS_PER_FRAME]
						@chip8.tick()

					setVideoData @chip8.getVideo()
					draw()

					requestAnimationFrame mainLoop
					return

				mainLoop()
				return
	]