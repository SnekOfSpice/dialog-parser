extends CanvasLayer


const MAX_TEXT_SPEED := 201

func _ready() -> void:
	find_child("TextSpeedSlider").min_value = 1
	find_child("TextSpeedSlider").max_value = MAX_TEXT_SPEED
	find_child("TextSpeedSlider").value = 80

func _on_fullscreen_button_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_windowed_button_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_text_speed_slider_value_changed(value: float) -> void:
	if value == MAX_TEXT_SPEED:
		find_child("TextSpeedLabel").text = "Instant"
		Parser.line_reader.text_speed = 0
	else:
		find_child("TextSpeedLabel").text = str(value)
		Parser.line_reader.text_speed = value
	
