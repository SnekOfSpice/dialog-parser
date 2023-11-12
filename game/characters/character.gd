extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("FactListener")

func parser_init():
	Parser.line_reader.connect("new_header", handle_new_header)

func handle_new_header(header):
	print(header)

func fact_changed(fact_name: String, new_value: bool):
	match fact_name:
		"":
			pass
