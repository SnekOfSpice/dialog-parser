extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	ParserEvents.listen(self, "fact_changed")
	ParserEvents.listen(self, "read_new_page")

func on_page_changed(page_index: int):
	if page_index == 12: # hide for end
		visible = false

func handle_event(event_name: String, event_args: Dictionary):
	match event_name:
		"fact_changed":
			fact_changed(event_args.get("fact_name"), event_args.get("new_value"))
		"read_new_page":
			on_page_changed(event_args.get("number"))

func fact_changed(fact_name: String, new_value: bool):
	match fact_name:
		"transplanted_eye":
			visible = new_value
