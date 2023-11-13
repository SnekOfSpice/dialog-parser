extends Node
class_name InstructionHandler

signal set_input_lock(value)
signal instruction_completed()
signal execute_instruction(args)


func wrapper_execute(instruction_name, args, delay_before := 0.0, delay_after := 0.0):
	emit_signal("set_input_lock", true)
	if delay_before > 0.0:
		await get_tree().create_timer(delay_before).timeout
	
	emit_signal("execute_instruction", args)
	execute(instruction_name, args)
	
	if delay_after > 0.0:
		await get_tree().create_timer(delay_after).timeout
	
	emit_signal("set_input_lock", false)
	emit_signal("instruction_completed")

func execute(instruction_name, args):
	pass
