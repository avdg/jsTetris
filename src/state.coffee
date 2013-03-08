class state
	constructor: () ->
		@resetState(true)

	resetState: (updateSettings) ->
		updateSettings ?= false

		# Display

		@activeBlock =
			block: null    # Type of block
			rotation: null # Rotation
			w: null        # Offset
			h: null        # Offset
		@display = []      # Lists color of each block - NOTE: origin is at the right bottom
		@wall = 0          # Height of the wall
		@lineOffsets = []  # Offsets between lines, used to show drop effect

		# Queue system

		@hold = null          # Block in the hold storage
		@holdDisabled = false # Disables the hold feature
		@holdLock = false     # Prevents the active block from being stored
		@queue = []           # Next block list

		# Stats
		@totalLines = 0
		@totalBlocksDropped = 0

		@linesSingle = 0
		@linesDouble = 0
		@linesTriple = 0
		@linesQuadro = 0
		@lastLineType    = null   # TODO implement
		@lastLineIsTSpin = false  # TODO implement

		@combo                 = 0 # TODO implement
		@maxCombo              = 0 # TODO implement
		@backToBackTetrisCombo = 0 # TODO implement
		@backToBackTSpin       = 0 # TODO implement

		# Global settings

		if updateSettings
			@settings = $['extend'](true, {}, settings) # Local settings, starts as a clone of global settings

		# Internals settings

		@rotationStyle = "srs" # Rotation style

		######################

		# Fill display
		for i in [0...24]
			@display[i] = []
			for j in [0...10]
				@display[i][j] = null

		# Fill line offsets array
		for i in [0...20]
			@lineOffsets[i] = 0

		# Fill queue and add first block to the display
		@fillQueue()
		@nextBlock()

		return

	fillQueue: (n) ->
		n ?= 7
		while @queue.length < n
			@queue = @queue.concat shuffle(cache.blockTypes)

		return

	nextBlock: (n, queueLength) ->
		n ?= 1
		queueLength ?= 7
		for i in [0...n] by 1
			@activeBlock.block = @queue.shift()
			@activeBlock.rotation = 0
			@activeBlock.h = 18
			@activeBlock.w = 4

			if @queue.length < queueLength
				@fillQueue(queueLength)

		return

	tryActiveBlockPosition: (x, y, blocks) ->
		for i in [0...blocks.length] by 1
			if (y - blocks[i][0]) < 0 or (y - blocks[i][0]) >= 20
				return false
			if (x + blocks[i][1]) < 0 or (x + blocks[i][1]) >= 10
				return false
			if @display[y - blocks[i][0]][x + blocks[i][1]] != null
				return false
		return true

	storeBlock: () ->
		return if @holdDisabled or @holdLock

		if @hold == null
			@hold = @activeBlock.block
			@nextBlock()
		else
			[@hold, @activeBlock.block] = [@activeBlock.block, @hold]
			@activeBlock.rotation = 0
			@activeBlock.h = 18
			@activeBlock.w = 4

		@holdLock = true

		@updateDisplay()

		return

	moveLeft: () ->
		if @tryActiveBlockPosition(@activeBlock.w - 1, @activeBlock.h, cache.blocks.srs.blocks[@activeBlock.block][@activeBlock.rotation])
			@activeBlock.w -= 1
			@updateDisplay()

		return

	moveRight: () ->
		if @tryActiveBlockPosition(@activeBlock.w + 1, @activeBlock.h, cache.blocks.srs.blocks[@activeBlock.block][@activeBlock.rotation])
			@activeBlock.w += 1
			@updateDisplay()

		return

	moveDown: () ->
		if @tryActiveBlockPosition(@activeBlock.w, @activeBlock.h - 1, cache.blocks.srs.blocks[@activeBlock.block][@activeBlock.rotation])
			@activeBlock.h -= 1
			@updateDisplay()
		else
			@lock() # Also updates display

		return

	doDrop: () ->
		while @tryActiveBlockPosition(@activeBlock.w, @activeBlock.h - 1, cache.blocks.srs.blocks[@activeBlock.block][@activeBlock.rotation])
			@activeBlock.h -= 1

		@lock() # Also updates display

		return

	rotateRight: () ->
		rotation = (@activeBlock.rotation + 1) % 4
		if @tryActiveBlockPosition(@activeBlock.w, @activeBlock.h, cache.blocks.srs.blocks[@activeBlock.block][rotation])
			@activeBlock.rotation = rotation
			@updateDisplay()

		return

	rotateLeft: () ->
		rotation = (@activeBlock.rotation + 3) % 4
		if @tryActiveBlockPosition(@activeBlock.w, @activeBlock.h, cache.blocks.srs.blocks[@activeBlock.block][rotation])
			@activeBlock.rotation = rotation
			@updateDisplay()

		return

	lock: () ->
		@holdLock = false
		@totalBlocksDropped += 1

		# Draw block on the display
		blocks = cache.blocks.srs.blocks[@activeBlock.block][@activeBlock.rotation]
		for i in [0...blocks.length] by 1
			@display[@activeBlock.h - blocks[i][0]][@activeBlock.w + blocks[i][1]] = cache.blocks.srs.color[@activeBlock.block]

		# Remove lines from screen
		@removeLines(@activeBlock.type)

		# Get the next block in the game
		@nextBlock()

		# Try to fit the new block
		if not @tryActiveBlockPosition(@activeBlock.w, @activeBlock.h, cache.blocks.srs.blocks[@activeBlock.block][@activeBlock.rotation])
			@resetState()

		@updateDisplay()

		return

	removeLines: (lockedBlockType) ->
		lines = 0

		# Count full lines, drop blocks above the full lines
		for i in [0...@display.length] by 1
			fullLine = true
			for j in [0...@display[i].length] by 1
				@display[i - lines][j] = @display[i][j]
				if @display[i][j] == null
					fullLine = false

			if fullLine
				lines += 1

		# TODO - CAUSES PROBLEMS - CURRENT WORKAROUND: don't clear more than 4 lines at the same time (this solution is genius btw ;-)
		# Clear the lines above (so far not really needed until we have blocks above row 20)
		#for i in [(@display.length - lines)...@display.length] by 1
		#	console.debug(i)
		#	@display[i] = []
		#	for j in [0...@display[i].length] by 1
		#		@display[i][j] = null

		# Update stats
		@totalLines += lines

		switch lines
			when 1
				@linesSingle += 1
				@lastLineType = "single"
				# TODO test for tspin
				if lockedBlockType == "t"
					"test"
			when 2
				@linesDouble += 1
				@lastLineType = "double"
				# TODO test for tspin
				if lockedBlockType == "t"
					"test"
			when 3
				@linesTriple += 1
				@lastLineType = "triple"
				# TODO test for tspin
				if lockedBlockType == "t"
					"test"
			when 4
				if @lastLineType == "quadro"
					@backToBackTetrisCombo += 1
				else
					@lastLineType = "quadro"

				@linesQuadro += 1
				@lastLineIsTSpin = false

		@updateDisplay()

		return

	# Empty function
	updateDisplay: () ->

	# Empty function
	gameOver: () ->
