extends InstructionHandler

func execute(instruction_name, args):
	prints("EXECUTING ", instruction_name, " WITH ARGS ", args)
	match instruction_name:
		"play-sfx":
			pass
