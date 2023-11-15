extends Node


signal start_game(page: int)

func _ready() -> void:
	find_child("ConfirmAge").visible = not Options.confirmed_age

func _on_confirm_age_button_pressed() -> void:
	find_child("ConfirmAge").visible = false
	Options.confirmed_age = true

func _on_abort_button_pressed() -> void:
	get_tree().quit()


func _on_start_new_button_pressed() -> void:
	find_child("MenuContainer").visible = false
	Parser.read_page(0)


func _on_quit_button_pressed() -> void:
	Options.save()
	get_tree().quit()
