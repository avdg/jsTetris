class keyHandler
	constructor: (register) ->
		register ?= true

		@keys = {keyUp:{}, keyDown:{}, keyPress:{}}
		@keyDownFunction = (e) => @onKeyDown(e)
		@keyUpFunction = (e) => @onKeyUp(e)
		@keyPressFunction = (e) => @onKeyPress(e)

		@registerEventHandlers() if register

		return

	registerEventHandlers: () ->
		document.addEventListener("keydown", @keyDownFunction, false)
		document.addEventListener("keyup", @keyUpFunction, false)
		document.addEventListener("keypress", @keyPressFunction, false)

		return

	unregisterEventHandlers: () ->
		document.removeEventListener("keydown", @keyDownFunction, false)
		document.removeEventListener("keyup", @keyUpFunction, false)
		document.removeEventListener("keypress", @keyPressFunction, false)

		return

	registerKeyDown: (keyCode, f) ->
		@keys.keyDown[keyCode] = f

		return

	registerKeyUp: (keyCode, f) ->
		@keys.keyUp[keyCode] = f

		return

	registerKeyPress: (keyCode, f) ->
		@keys.keyPress[keyCode] = f

		return

	onKeyDown: (e) ->
		keyCode = e.which

		if typeof @keys.keyDown[keyCode] == "function"
			return @keys.keyDown[keyCode](e)
		else if typeof @keys.keyDown.default == "function"
			return @keys.keyDown.default

		return

	onKeyUp: (e) ->
		keyCode = e.which

		if typeof @keys.keyUp[keyCode] == "function"
			return @keys.keyUp[keyCode](e)
		else if typeof @keys.keyUp.default == "function"
			return @keys.keyUp.default

		return

	onKeyPress: (e) ->
		keyCode = e.which

		if typeof @keys.keyPress[keyCode] == "function"
			return @keys.keyPress[keyCode](e)
		else if typeof @keys.keyPress.default == "function"
			return @keys.keyPress.default

		return

	#getKeyCode: (key) ->
