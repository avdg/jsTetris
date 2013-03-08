class achievements
	constructor: () ->
		@achievements = {}

	add: (achievement, msg) ->
		@achievement[achievement] = {msg: msg, unlocked: false}

		return

	unlock: (achievement) ->
		if @achievement[achievement].unlocked = false
			@achievement[achievement].unlocked = true
			return true
		return false

	unlocked: (achievement) ->
		@achievement[achievement].unlocked