extends CanvasLayer

signal request_show_options()
signal start_game(page: int)

func _ready() -> void:
	find_child("ConfirmAge").visible = not Options.confirmed_age
	#find_child("LoadButtonContainer").visible = false
	find_child("CWContainer").visible = false
	find_child("CreditsContainer").visible = false
	
	connect("visibility_changed", on_visibility_changed)
	
	visible = true
	for c in get_tree().get_nodes_in_group("Character"):
		c.visible = false
	begin()
	
	find_child("QuitButton").visible = not OS.has_feature("web")
	find_child("AbortButton").visible = not OS.has_feature("web")
	
	if Parser.show_demo:
		visible = false
		Parser.line_reader.terminated = false
		Parser.line_reader.visible = true
		Parser.reset_facts()
		Parser.read_page(0)
		Parser.history = []

func begin():
	Sound.set_background_music(Sound.BGM_MAIN_MENU_LOST_PIANO, 0.0)
	Options.load_gamestate()
	var progress_percent := int(Parser.get_game_progress(Options.SAVEGAME_PATH) * 100)
	find_child("LoadButtonContainer").visible = progress_percent > 0 and progress_percent < 100 and FileAccess.file_exists(Options.SAVEGAME_PATH)
	find_child("GameProgressLabel").text = str("(", progress_percent, "%)")

func on_visibility_changed():
	if visible:
		begin()

func _on_confirm_age_button_pressed() -> void:
	find_child("ConfirmAge").visible = false
	Options.confirmed_age = true

func _on_abort_button_pressed() -> void:
	get_tree().quit()


func _on_start_new_button_pressed() -> void:
	visible = false
	Parser.line_reader.terminated = false
	Parser.line_reader.visible = true
	Parser.reset_facts()
	Parser.read_page(0)
	Parser.history = []
	for c in get_tree().get_nodes_in_group("Character"):
		c.visible = false


func _on_load_button_pressed() -> void:
	Options.load_gamestate()
	visible = false
	#Parser.line_reader.terminated = false
	#Parser.line_reader.visible = true
	#Parser.read_page(Parser.page_index, Parser.line_index)
	Sound.set_background_music_by_key(Options.loaded_bgm_key)
	get_parent().find_child("Game").request_background_change(Options.current_background_image)

func _on_quit_button_pressed() -> void:
	Options.save_prefs()
	get_tree().quit()


func _on_close_credits_button_pressed() -> void:
	find_child("CreditsContainer").visible = false


func _on_credits_button_pressed() -> void:
	find_child("CreditsContainer").visible = true


func _on_close_cw_button_pressed() -> void:
	find_child("CWContainer").visible = false


func _on_view_cw_button_pressed() -> void:
	find_child("CWContainer").visible = true


func _on_options_button_pressed() -> void:
	emit_signal("request_show_options")




func _on_credits_label_meta_clicked(meta) -> void:
	OS.shell_open(str(meta))



