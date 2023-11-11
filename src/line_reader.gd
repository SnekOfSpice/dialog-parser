extends Control


signal line_finished(line_index)

var line_data := {}

var line_index

func _ready() -> void:
	Parser.connect("read_new_line", read_new_line)
	Parser.connect("terminate_page", close)
	Parser.open_connection()

func close(_terminating_page):
	prints("closing page ", _terminating_page)

func read_new_line(new_line: Dictionary):
	line_data = new_line
	line_index = new_line.get("meta.line_index")
	
	# conditionals if it even gets shown etc
	var conditional_behavior = line_data.get("conditionals")
	var args = conditional_behavior.get("operand_args")
	var facts_to_check = conditional_behavior.get("facts")
	if facts_to_check.keys().size() > 0:
		var is_condition_true := true
		var operand_key = conditional_behavior.get("operand_key")
		#match
	
	handle_header(line_data.get("header"))
	
	var line_type = int(line_data.get("line_type"))
	var content = line_data.get("content").get("content")
	var content_name = line_data.get("content").get("name") # wtf is this
	print(line_data)
	match line_type:
		Parser.LineType.Text:
			print("text")
		Parser.LineType.Choice:
			print("choice")
		Parser.LineType.Instruction:
			print("instruction")
	
	# register facts
	line_data.get("facts")

func handle_header(header: Array):
	print(header)

func chunkify(line) -> Array:
	var line_type = int(line.get("line_type"))
	print(line)
	match line_type:
		Parser.LineType.Text:
			print("text")
		Parser.LineType.Choice:
			print("choice")
		Parser.LineType.Instruction:
			print("instruction")
	return []



func _on_finished_button_pressed() -> void:
	emit_signal("line_finished", line_index)
