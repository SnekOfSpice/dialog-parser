extends Node


signal set_input_lock(value)


func execute(instruction_name, args, delay_before := 0.0, delay_after := 0.0):
	emit_signal("set_input_lock", true)
	if delay_before > 0.0:
		prints("DELAY BEFRE", delay_before)
		await get_tree().create_timer(delay_before).timeout
		#t.connect("timeout", execute, [instruction_name, args, 0.0, delay_after])
		
		#return
	
	prints("EXECUTING ", instruction_name, " WITH ARGS ", args)
	match instruction_name:
		"play-sfx":
			pass
	
	
	if delay_after > 0.0:
		await get_tree().create_timer(delay_after).timeout
	
	emit_signal("set_input_lock", false)
