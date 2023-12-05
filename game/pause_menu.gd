extends CanvasLayer




signal request_main_menu()

func _ready() -> void:
	find_child("TextSpeedSlider").min_value = 1
	find_child("TextSpeedSlider").max_value = Parser.line_reader.MAX_TEXT_SPEED
	find_child("TextSpeedSlider").value = 60
	Parser.line_reader.text_speed = 60
	
	find_child("VolumeLabel").text = str(Options.music_volume + 80)
	find_child("VolumeSlider").value = Options.music_volume + 80
	
	connect("visibility_changed", on_visibility_changed)
	find_child("SaveLabel").modulate.a = 0.0
	
	if Parser.show_demo:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		Options.fullscreen = false
		find_child("FullscreenButton").button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		find_child("WindowedButton").button_pressed = DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN

	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		Options.fullscreen = true
		find_child("FullscreenButton").button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		find_child("WindowedButton").button_pressed = DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN

func _on_fullscreen_button_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	Options.fullscreen = true

func _on_windowed_button_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	Options.fullscreen = false


func _on_text_speed_slider_value_changed(value: float) -> void:
	update_text_speed_slider(value)
	Options.text_speed = value
	

func on_visibility_changed():
	find_child("FullscreenButton").button_pressed = Options.fullscreen
	find_child("TextSpeedSlider").value = Options.text_speed
	update_text_speed_slider(find_child("TextSpeedSlider").value)
	Parser.line_reader.text_speed = Options.text_speed
	find_child("SaveLabel").modulate.a = 0.0


func update_text_speed_slider(value: float):
	if value == Parser.line_reader.MAX_TEXT_SPEED:
		find_child("TextSpeedLabel").text = "Instant"
		#Parser.line_reader.text_speed = 0
	else:
		find_child("TextSpeedLabel").text = str(value)
		Parser.line_reader.text_speed = value


func _on_volume_slider_value_changed(value: float) -> void:
	Options.music_volume = value - 80
	Sound.set_target_volume(value - 80)
	find_child("VolumeLabel").text = str(value)
	


func _on_close_options_button_pressed() -> void:
	visible = false


func _on_main_menu_button_pressed() -> void:
	visible = false
	Options.save_gamestate()
	emit_signal("request_main_menu")

func show_save_text():
	find_child("SaveLabel").modulate.a = 1.0

func hide_save_text():
	find_child("SaveLabel").modulate.a = 0.0

func _on_quit_button_pressed() -> void:
	Options.save_gamestate()
	get_tree().quit()
