extends Button

var facts := {}
var do_jump_page := false
var target_page := 0

signal choice_pressed(do_jump_page, target_page)

func _on_pressed() -> void:
	# apply facts
	for f in facts.keys():
		Parser.change_fact(f, facts.get(f))
	
	emit_signal("choice_pressed", do_jump_page, target_page)
	
	visible = false
