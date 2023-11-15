extends CanvasLayer


const MAX_TEXT_SPEED := 201

func _ready() -> void:
	find_child("TextSpeedSlider").min_value = 1
	find_child("TextSpeedSlider").max_value = MAX_TEXT_SPEED
	find_child("TextSpeedSlider").value = 60
	Parser.line_reader.text_speed = 60
	
	connect("visibility_changed", on_visibility_changed)

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


func update_text_speed_slider(value: float):
	if value == MAX_TEXT_SPEED:
		find_child("TextSpeedLabel").text = "Instant"
		Parser.line_reader.text_speed = 0
	else:
		find_child("TextSpeedLabel").text = str(value)
		Parser.line_reader.text_speed = value
