extends Node

signal request_show_options()
signal start_game(page: int)

func _ready() -> void:
	find_child("ConfirmAge").visible = not Options.confirmed_age
	
	find_child("CWContainer").visible = false
	find_child("CreditsContainer").visible = false

func _on_confirm_age_button_pressed() -> void:
	find_child("ConfirmAge").visible = false
	Options.confirmed_age = true

func _on_abort_button_pressed() -> void:
	get_tree().quit()


func _on_start_new_button_pressed() -> void:
	find_child("MenuContainer").visible = false
	Parser.read_page(5)


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
