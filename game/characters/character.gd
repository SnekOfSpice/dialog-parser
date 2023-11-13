extends Node2D

@export var character_name := ""

func _ready() -> void:
	add_to_group("FactListener")
	add_to_group("Character")
	visible = false

func parser_init():
	Parser.line_reader.connect("new_header", handle_new_header)
	Parser.line_reader.connect("currently_speaking", handle_currently_speaking)
	Parser.line_reader.connect("page_finished", handle_page_finished)

func handle_new_header(header: Array):
	#prints("EUPHORIA GOT NEW HEADER", header)
	for property in header:
		var prop_name = property.get("property_name")
		if prop_name == str("emotion-", character_name):
			var values = property.get("values")
			var emotion_string = Parser.drop_down_values_to_string_array(values)[1]
			print(emotion_string)

func handle_currently_speaking(actor_name: String):
	if actor_name == character_name:
		visible = true

func handle_page_finished(page_index: int):
	visible = false

func fact_changed(fact_name: String, new_value: bool):
	match fact_name:
		"":
			pass
