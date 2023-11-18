extends InstructionHandler

signal request_background_change(background_name: String)
signal make_screen_black(hide_characters: bool, new_background: String, attack: float, release: float, sustain: float, new_bgm: String)

func execute(instruction_name, args):
	prints("EXECUTING ", instruction_name, " WITH ARGS ", args)
	match instruction_name:
		"play-sfx":
			var rand_pitch := true
			if args.get("random-pitch") == "false":
				rand_pitch = false
			Sound.play(args.get("key", ""), rand_pitch)
			
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
			
			var new_bgm = args.get("new-background-music", "")
			
			emit_signal("make_screen_black", hide_characters, new_background, attack, release, sustain, new_bgm)
			return true
			
			
		"set-background":
			emit_signal("request_background_change", args.get("background-name", ""))
		"set-background-music":
			Sound.set_background_music_by_key(args.get("key", ""))
	



func _on_black_instruction_completed() -> void:
	emit_signal("instruction_completed")
