extends CanvasLayer

signal request_main_menu()

func _ready() -> void:
	visible = false
	ParserEvents.listen(self, "terminate_page")

func handle_page_terminated(page_index: int):
	if page_index < Parser.page_data.keys().size() - 1:
		return
	
	visible = true
	
	if Options.ending_chosen == Options.ENDING_NEVER_REACHED:
		Options.ending_chosen = Options.ENDING_UNDECIDED


func _on_ily_button_pressed() -> void:
	if Options.ending_chosen == Options.ENDING_UNDECIDED:
		Options.ending_chosen = Options.ENDING_BACK_TO_MAIN_MENU
	Options.save_prefs()
	visible = false
	emit_signal("request_main_menu")


func _on_fade_button_pressed() -> void:
	if Options.ending_chosen == Options.ENDING_UNDECIDED:
		Options.ending_chosen = Options.ENDING_QUIT_GAME
	Options.save_prefs()
	get_tree().quit()
