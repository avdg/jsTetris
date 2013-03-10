if !window.requestAnimationFrame
	window.requestAnimationFrame = (() ->
		window.webkitRequestAnimationFrame ||
		window.mozRequestAnimationFrame ||
		window.oRequestAnimationFrame ||
		window.msRequestAnimationFrame ||
		(callback) ->
			window.setTimeout(callback, 1000 / 60);
			return
	)()

shuffle = (input) ->
	list = $.extend(true, [], input)
	for i in [1...list.length] by 1
		j = Math.floor(Math.random() * (i + 1))
		t = list[i]
		list[i] = list[j]
		list[j] = t
	list

gcd = (a, b) ->
	while b != 0
		[a, b] = [b, a % b]
	a

solveRatio = (w, h, w2, h2) ->
	if (w / h < w2 / h2) # Too much height
		h2 = (h * w2) / w
	else                 # Too much width
		w2 = (w * h2) / h
	[w2, h2]
