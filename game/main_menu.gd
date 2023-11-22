extends CanvasLayer

signal request_show_options()
signal start_game(page: int)

func _ready() -> void:
	find_child("ConfirmAge").visible = not Options.confirmed_age
	
	find_child("CWContainer").visible = false
	find_child("CreditsContainer").visible = false
	
	connect("visibility_changed", on_visibility_changed)
	
	Sound.set_background_music(Sound.BGM_MAIN_MENU_LOST_PIANO, 0.0)

func on_visibility_changed():
	if visible:
		Sound.set_background_music(Sound.BGM_MAIN_MENU_LOST_PIANO, 0.0)

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


func _on_quit_button_pressed() -> void:
	Options.save()
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
