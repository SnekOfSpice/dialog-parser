extends Control



func _ready() -> void:
	
	
	# note: this is fucking bad and awful
	find_child("Black").connect("request_background_change", request_background_change)
	find_child("InstructionHandler").connect("request_background_change", request_background_change)
	
	find_child("PauseMenu").visible = false
	
#	Parser.read_page(0)

func request_background_change(new_background):
	find_child("Game").request_background_change(new_background)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		find_child("PauseMenu").visible = not find_child("PauseMenu").visible


func _on_main_menu_request_show_options() -> void:
	find_child("PauseMenu").visible = true


func _on_game_finished_request_main_menu() -> void:
	find_child("MainMenu").visible = true


func _on_pause_menu_request_main_menu() -> void:
	find_child("MainMenu").visible = true
