extends Control



func _ready() -> void:
	Parser.read_page(0)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		find_child("PauseMenu").visible = not find_child("PauseMenu").visible
