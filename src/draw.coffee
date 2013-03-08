class draw
	constructor: (x, y, w, h, c, s) ->
		@resetSettings()
		@x = x
		@y = y
		@w = w
		@h = h
		@c = c # Canvas
		@s = s # State

		@c.lineWidth = 0

	resetSettings: () ->
		@options =
			defaultClearColor: "rgb(255, 255, 255)"
			defaultBlockColor: "rgba(0, 0, 0, .5)"
			defaultBgColor: "rgb(0, 0, 0)"
			defaultBlockBgColor: "rgba(255, 255, 255, .3)"
			defaultGridBgColor: "rgba(255, 255, 255, .5)"
			image: "clown"
			rows: 20
			cols: 10

			ghostBlock: true

		return

	clearScreen: (color) ->
		color ?= @options.defaultClearColor
		@c.fillStyle = color
		@c.fillRect(@x, @y, @w, @h)

		return

	drawImageBackground: (x, y, w, h, options) ->
		options ?= {}

		blockSize = 24 # normally 1/24 - Screen is divided in 24x24 imaginary tetris blocks
		bW = w / blockSize
		bH = h / blockSize
		r = bW / 2

		image = getImage(options.image ? @options.image)

		@c.beginPath()
		@c.strokeStyle = @c.fillStyle = options.defaultBgColor ? @options.defaultBgColor
		@c.lineWidth = 1

		@c.moveTo x + bW * 2, y + bH
		@c.arcTo(
			x + bW * 23, y + bH,
			x + bW * 23, y + bH * 2, r
		)
		@c.arcTo(
			x + bW * 23, y + bH * 23,
			x + bW * 22, y + bH * 23, r
		)
		@c.arcTo(
			x + bW, y + bH * 23,
			x + bW, y + bH * 22, r
		)
		@c.arcTo(
			x + bW, y + bH,
			x + bW * 2, y + bH, r
		);
		@c.closePath()
		@c.clip()
		@c.drawImage(image, x + bW, y + bH, w - bW, h - bH)
		@c.restore()
		@c.lineWidth = 0

		return

	drawGameGrid: (x, y, w, h, options) ->
		options ?= {}

		rows = options.rows ? @options.rows
		cols = options.cols ? @options.cols # Shouldn't be changing
		defaultBlockColor = options.defaultBlockColor ? @options.defaultBlockColor
		defaultGridBgColor = options.defaultGridBgColor ? @options.defaultGridBgColor

		bH = h / rows
		bW = w / cols

		# Background color
		@c.fillStyle = defaultGridBgColor
		@c.fillRect(x, y, w, h)

		# Background grid
		@c.fillStyle = defaultBlockColor
		for i in [0...rows] by 1
			for j in [0...cols] by 1
				@c.fillRect(x + bW * j + 1, y + bH * i + 1, bW - 2, bH - 2)

		# Calculate ghost block position - TODO might be moved to state object
		ghostH = @s.activeBlock.h
		while @s.tryActiveBlockPosition(@s.activeBlock.w, ghostH - 1, cache.blocks.srs.blocks[@s.activeBlock.block][@s.activeBlock.rotation])
			ghostH -= 1

		# Grid - build from the bottem up
		offsetBottom = 0
		drawBH = bH
		for i in [0...rows] by 1
			offsetBottom += bH + @s.lineOffsets[i]

			# Check if we are too high - NOTE: floating point precision
			if offsetBottom > h + .05
				break
			else if offsetBottom + bH > h + .05
				drawBH = offsetBottom + bH - h

			for j in [0...cols] by 1
				if @s.display[i][j] != null
					@c.fillStyle = @s.display[i][j]
					@c.fillRect(x + bW * j + 1, y + h - offsetBottom + 1, bW - 2, drawBH - 2)

			# Check for active blocks to draw in this row
			for j in [0...cache.blocks.srs.blocks[@s.activeBlock.block][@s.activeBlock.rotation].length] by 1
				# Active block
				if @s.activeBlock.h - cache.blocks.srs.blocks[@s.activeBlock.block][@s.activeBlock.rotation][j][0] == i
					@c.fillStyle = cache.blocks.srs.color[@s.activeBlock.block]
					@c.fillRect(
						x + bW * (cache.blocks.srs.blocks[@s.activeBlock.block][@s.activeBlock.rotation][j][1] + @s.activeBlock.w) + 1,
						y + h - offsetBottom + 1,
						bW - 2,
						bH - 2
					)
				# Ghost block
				else if ghostH - cache.blocks.srs.blocks[@s.activeBlock.block][@s.activeBlock.rotation][j][0] == i and @options.ghostBlock
					tempX = x + bW * (cache.blocks.srs.blocks[@s.activeBlock.block][@s.activeBlock.rotation][j][1] + @s.activeBlock.w)
					tempY = y + h - offsetBottom
					@c.lineWidth = 2
					@c.strokeStyle = cache.blocks.srs.color[@s.activeBlock.block]
					@c.beginPath()
					@c.moveTo(tempX + 1, tempY + 1)
					@c.lineTo(tempX + bW - 2, tempY + 1)
					@c.lineTo(tempX + bW - 2, tempY + bH - 2)
					@c.lineTo(tempX + 1, tempY + bH - 2)
					@c.closePath()
					@c.stroke()
					@c.lineWdith = 0
		return

	# Currently only supports srs style
	drawBox: (x, y, w, h, typeOrGrid, options) ->
		options ?= {}
		defaultBlockColor = options.defaultBlockBgColor ? @options.defaultBlockBgColor
		blockW = w / 4
		blockH = h / 4

		# Convert blocks
		if typeof typeOrGrid is "string"
			blockColor = options.blockColor ? cache.blocks.srs.color[typeOrGrid] ? @options.defaultBlockColor
			typeOrGrid = cache.blocks.srs.blocks[typeOrGrid][0]
		else
			blockColor = options.blockColor ? @options.defaultBlockColor

		# Draw background
		@c.fillStyle = defaultBlockColor
		@c.fillRect(x, y, w, h)

		if typeOrGrid == null
			return

		# Calculate min/max width/height of block
		minH = maxH = typeOrGrid[0][0]
		minW = maxW = typeOrGrid[0][1]

		for i in [1...typeOrGrid.length] by 1
			if typeOrGrid[i][0] < minH
				minH = typeOrGrid[i][0]
			else if typeOrGrid[i][0] > maxH
				maxH = typeOrGrid[i][0]
			if typeOrGrid[i][1] < minW
				minW = typeOrGrid[i][1]
			else if typeOrGrid[i][1] > maxW
				maxW = typeOrGrid[i][1]

		# Calculate lengths
		wTotal = maxW - minW + 1
		hTotal = maxH - minH + 1

		# Center the figure
		offsetX = ((4 - wTotal) / 2) * blockW
		offsetY = ((4 - hTotal) / 2) * blockH

		# Draw blocks
		@c.fillStyle = blockColor
		for i in [0...typeOrGrid.length] by 1
			@c.fillRect(
				x + offsetX + (typeOrGrid[i][1] - minW) * blockW + 1,
				y + offsetY + (typeOrGrid[i][0] - minH) * blockH + 1,
				blockW - 2,
				blockH - 2
			)

		return

	draw: () ->
		t = (new Date).getDate()

		bW = @w / 24
		bH = @h / 24

		@clearScreen()
		@drawImageBackground(@x, @y, @w, @h)
		@drawGameGrid(@x + bW * 7, @y + bH * 2, bW * 10, bH * 20)

		# Queue
		@drawBox(@x + bW * 18, @y + bH * 2, bW * 4, bH * 4, @s.queue[0])
		@drawBox(@x + bW * 18, @y + bH * 7, bW * 4, bH * 4, @s.queue[1])
		@drawBox(@x + bW * 18, @y + bH * 12, bW * 4, bH * 4, @s.queue[2])
		@drawBox(@x + bW * 18, @y + bH * 17, bW * 4, bH * 4, @s.queue[3])

		# Hold
		@drawBox(@x + bW * 2, @y + bH * 2, bW * 4, bH * 4, @s.hold)

		if settings.debug
			console.debug(((new Date).getDate() - t) + " ms spend drawing")

		return
