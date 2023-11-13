extends InstructionHandler

signal request_background_change(background_name: String)
signal make_screen_black(hide_characters: bool, new_background: String, attack: float, release: float)

func execute(instruction_name, args):
	prints("EXECUTING ", instruction_name, " WITH ARGS ", args)
	match instruction_name:
		"play-sfx":
			pass
		"hide-all-characters":
			for c in get_tree().get_nodes_in_group("Character"):
				c.visible = false
			
		"black-fade-in-out":
			var hide_characters : bool = args.get("hide-characters", "") == "true"
#			if hide_characters:
#				for c in get_tree().get_nodes_in_group("Character"):
#					c.visible = false
			
			var new_background : String = args.get("new-background", "")
			#emit_signal("request_background_change", new_background)
			
			var attack = 5.0
			if not args.get("attack", "").is_empty():
				attack = float(args.get("attack"))
			var release = 5.0
			if not args.get("release", "").is_empty():
				release = float(args.get("release"))
			
			emit_signal("make_screen_black", hide_characters, new_background, attack, release)
			
		"set-background":
			emit_signal("request_background_change", args.get("background-name", ""))
