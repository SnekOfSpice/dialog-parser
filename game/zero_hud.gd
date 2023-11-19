extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false

func parser_init():
	Parser.connect("read_new_page", on_page_changed)

func on_page_changed(page_index: int):
	if page_index == 12: # hide for end
		visible = false


func fact_changed(fact_name: String, new_value: bool):
	match fact_name:
		"transplanted_eye":
			visible = new_value
