cache =
	_: false
	blockTypes: "ijlotsz".split("")
	blocks:
		srs:
			rotate: (position) ->
				[position[1], -position[0]]
			derotate: (position) ->
				[-position[1], position[0]]
			opposite: (position) ->
				[-position[0], -position[1]]
			initials:
				i: [[0, -1], [0, 0], [0, 1], [0, 2]]
				j: [[-1, -1], [0, -1], [0, 0], [0, 1]]
				l: [[0, -1], [0, 0], [0, 1], [-1, 1]]
				o: [[-1, 0], [0, 0], [-1, 1], [0, 1]]
				s: [[0, -1], [0, 0], [-1, 0], [-1, 1]]
				t: [[-1, 0], [0, -1], [0, 0], [0, 1]]
				z: [[-1, -1], [-1, 0], [0, 0], [0, 1]]
			kickTable:
				right:
					o: [[], [], [], []]
					i: [
						[[-2, 0], [1, 0], [-2, -1], [1, 2]]
						[[-1, 0], [2, 0], [-1, 2], [2, -1]]
						[[2, 0], [-1, 0], [2, 1], [-1, -2]]
						[[1, 0], [-2, 0], [1, -2], [-2, 1]]
					]
					default: [
						[[-1, 0], [-1, 1], [0, -2], [-1, -2]]
						[[1, 0], [1, -1], [0, 2], [1, 2]]
						[[1, 0], [1, 1], [0, -2], [1, -2]]
						[[-1, 0], [-1, -1], [0, 2], [-1, 2]]
					]
				left:
					o: [[], [], [], []]
					i: [
						[[2, 0], [-1, 0], [2, 1], [-1, -2]]
						[[1, 0], [-2, 0], [1, -2], [-2, 1]]
						[[-2, 0], [1, 0], [-2, -1], [1, 2]]
						[[-1, 0], [2, 0], [-1, 2], [2, -1]]
					]
					default: [
						[[1, 0], [1, -1], [0, 2], [1, 2]]
						[[-1, 0], [-1, 1], [0, -2], [-1, 2]]
						[[-1, 0], [-1, -1], [0, 2], [-1, 2]]
						[[1, 0], [1, 1], [0, -2], [1, -2]]
					]
			offsets:
				i: [
					[[0, 0], [-1, 0], [2, 0], [-1, 0], [2, 0]]
					[[-1, 0], [0, 0], [0, 0], [0, 1], [0, -2]]
					[[-1, 2], [1, 1], [-2, 1], [1, 0], [-2, 0]]
					[[0, 1], [0, 1], [0, 1], [0, -1], [0, 2]]
				]
				o: [[[0, 0]], [[0, -1]], [[-1, -1]], [[-1, 0]]]
				default: [
					[[0, 0], [0, 0], [0, 0], [0, 0], [0, 0]]
					[[0, 0], [1, 0], [1, -1], [0, 2], [1, 2]]
					[[0, 0], [0, 0], [0, 0], [0, 0], [0, 0]]
					[[0, 0], [-1, 0], [-1, 1], [0, 2], [-1, 2]]
				]
			color: {
				i: "rgba(0,255,255,.9)"
				j: "rgba(0,0,255,.9)"
				l: "rgba(255,170,0,.9)"
				o: "rgba(255,255,0,.9)"
				s: "rgba(0,255,0,.9)"
				t: "rgba(153,0,255,.9)"
				z: "rgba(255,0,0,.9)"
			}
			blocks: {}
	images:
		cache: {}
		links:
			clown: "http://tweakers.net/ext/f/QiUS8Q3QxzG4yC76TOl0RSHI/full.jpg" # From http://infant.tweakblogs.net/blog/8509/investering.html
			nature: "http://www.finewallpaperss.com/wp-content/uploads/2012/09/green-nature-wallpaper1.jpg"
		offline:
			clown: "img/clown.jpg"
			nature: "img/green-nature-wallpaper.jpg"

init = () ->
	return if cache._

	# Load resources on the background
	getImage("clown")

	# Calculate srs blocks - TODO calculate size
	for i in cache.blockTypes by 1
		l = cache.blocks.srs.initials[i].slice(0)
		cache.blocks.srs.blocks[i] = []

		# Calculate rotations
		for j in [0...4] by 1
			cache.blocks.srs.blocks[i][j] = $.extend(true, [], l)
			for k in [0...cache.blocks.srs.initials[i].length] by 1
				l[k] = cache.blocks.srs.rotate(l[k])

	cache._ = true
	return
