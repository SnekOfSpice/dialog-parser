extends InstructionHandler

signal request_background_change(background_name: String)
signal make_screen_black(hide_characters: bool, new_background: String, attack: float, release: float, sustain: float)

func execute(instruction_name, args):
	prints("EXECUTING ", instruction_name, " WITH ARGS ", args)
	match instruction_name:
		"play-sfx":
			Sound.play(args.get("key", ""))
			
		"hide-all-characters":
			for c in get_tree().get_nodes_in_group("Character"):
				c.visible = false
		"black-fade-in-out":
			var hide_characters : bool = args.get("hide-characters", "") == "true"
			
			var new_background : String = args.get("new-background", "")
			#emit_signal("request_background_change", new_background)
			
			var attack = 5.0
			if not args.get("attack", "").is_empty():
				attack = float(args.get("attack"))
			var release = 5.0
			if not args.get("release", "").is_empty():
				release = float(args.get("release"))
			var sustain = 5.0
			if not args.get("sustain", "").is_empty():
				sustain = float(args.get("sustain"))
			
			emit_signal("make_screen_black", hide_characters, new_background, attack, release, sustain)
			return true
			
			
		"set-background":
			emit_signal("request_background_change", args.get("background-name", ""))
		"set-background-music":
			match args.get("key", ""):
				"Failure to Comply Will Result in Death":
					Sound.set_background_music(Sound.BGM_FAILURE_TO_COMPLY)
				"Where is Heaven?":
					Sound.set_background_music(Sound.BGM_WHERE_IS_HEAVEN)
				"Warm 60s":
					Sound.set_background_music(Sound.BGM_PSYCH)
				"Winds":
					Sound.set_background_music(Sound.BGM_WINDS)
	



func _on_black_instruction_completed() -> void:
	emit_signal("instruction_completed")
