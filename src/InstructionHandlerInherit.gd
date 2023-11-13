extends InstructionHandler

func execute(instruction_name, args):
	prints("EXECUTING ", instruction_name, " WITH ARGS ", args)
	match instruction_name:
		"play-sfx":
			pass
		"hide-all-characters":
			for c in get_tree().get_nodes_in_group("Character"):
				c.visible = false
