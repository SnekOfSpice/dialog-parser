extends Control



func _ready() -> void:
	
	# note: this is fucking bad and awful
	find_child("Black").connect("request_background_change", request_background_change)
	find_child("InstructionHandler").connect("request_background_change", request_background_change)
	
	find_child("PauseMenu").visible = false
	$InGameControls.visible = false
	$History.visible = false
	
	ParserEvents.listen(self, "choices_presented")
	ParserEvents.listen(self, "choice_pressed")

func handle_event(event_name: String, event_args: Dictionary):
	match event_name:
		"choices_presented":
			$InGameControls.visible = false
		"choice_pressed":
			$InGameControls.visible = true

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


func _on_pause_button_pressed() -> void:
	$PauseMenu.visible = true


func _on_pause_menu_visibility_changed() -> void:
	$InGameControls.visible = not $PauseMenu.visible


func _on_history_button_pressed() -> void:
	$History.visible = true
	find_child("HistoryLabel").text = Parser.build_history_string()


func _on_history_visibility_changed() -> void:
	$InGameControls.visible = not $History.visible


func _on_close_history_button_pressed() -> void:
	$History.visible = false
