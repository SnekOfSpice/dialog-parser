extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	find_child("PageIndexSlider").min_value = 0
	var highest = 0
	for i in Parser.page_data.keys():
		if i > highest:
			highest = i
	find_child("PageIndexSlider").max_value = highest




func _on_h_slider_value_changed(value: float) -> void:
	find_child("PageIndexLabel").text = str(find_child("PageIndexSlider").value)


func _on_button_pressed() -> void:
	Parser.read_page(find_child("PageIndexSlider").value)
