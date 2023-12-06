extends Node2D
class_name Character

@export var character_name := ""

func _ready() -> void:
	ParserEvents.listen(self, "fact_changed")
	ParserEvents.listen(self, "page_finished")
	ParserEvents.listen(self, "new_header")
	ParserEvents.listen(self, "new_actor_speaking")
	add_to_group("Character")
	visible = false

func serialize() -> Dictionary:
	var result := {}
	
	result["visible"] = visible
	var expressions := {}
	for expr in find_child("Expressions").get_children():
		expressions[expr.name] = expr.visible
	result["expressions"] = expressions
	
	return result

func deserialize(data: Dictionary):
	visible = data.get("visible", false)
	var expressions_data = data.get("expressions", {})
	for expr in find_child("Expressions").get_children():
		expr.visible = expressions_data.get(expr.name, false)

func handle_event(event_name: String, event_args: Dictionary):
	match event_name:
		"fact_changed":
			fact_changed(event_args.get("fact_name"), event_args.get("new_value"))
		"page_finished":
			handle_page_finished(event_args.get("page_index"))
		"new_header":
			handle_new_header(event_args.get("header"))
		"new_actor_speaking":
			handle_currently_speaking(event_args.get("actor_name"))

func handle_new_header(header: Array):
	var update_emotions := true
	for property in header:
		var prop_name = property.get("property_name")
		if prop_name == "update-emotions":
			update_emotions = bool(property.get("values")[0])
	
	if not update_emotions:
		return
	
	for property in header:
		var prop_name = property.get("property_name")
		if prop_name == str("emotion-", character_name):
			var values = property.get("values")
			var emotion_string = Parser.drop_down_values_to_string_array(values)[1]
			for c in find_child("Expressions").get_children():
				c.visible = c.name.to_lower() == str(character_name, "-", emotion_string)

func handle_currently_speaking(actor_name: String):
	if actor_name == character_name:
		visible = true
		modulate.v = 1.0
	else:
		modulate.v = 0.8

func handle_page_finished(_page_index: int):
	visible = false


func fact_changed(fact_name: String, new_value: bool):
	pass
