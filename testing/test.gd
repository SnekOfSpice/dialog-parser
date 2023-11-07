extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer/HSlider.min_value = 0
	var highest = 0
	for i in Parser.page_data.keys():
		if i > highest:
			highest = i
	$VBoxContainer/HSlider.max_value = highest


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_h_slider_value_changed(value: float) -> void:
	$VBoxContainer/Label.text = str($VBoxContainer/HSlider.value)


func _on_button_pressed() -> void:
	Parser.read_page($VBoxContainer/HSlider.value)
