extends Node


@export_file("*.json") var source_file
@export var source_path := ""

var page_data := {}


var page_index := 0
var line_index := 0
var chunk_index := 0
var lines := []
var line_chunks := []

var facts := {}

var max_line_index_on_page := 0

const MAX_LINE_LENGTH := 10

enum LineType {
	Text, Choice, Instruction
}

signal read_new_line(line)
signal terminate_page(page_index)

func _ready() -> void:
	var file = FileAccess.open(source_path, FileAccess.READ)
	var data : Dictionary = JSON.parse_string(file.get_as_text())
	file.close()
	
	
	# all keys are now strings instead of ints
	var int_data = {}
	var loaded_data = data.get("page_data")
	for i in loaded_data.size():
		var where = int(loaded_data.get(str(i)).get("number"))
		int_data[where] = loaded_data.get(str(i)).duplicate()
	
	page_data = int_data.duplicate()


func read_page(number: int):
	if not page_data.keys().has(number):
		push_warning("number not in page data")
		return
	
	page_index = number
	lines = page_data.get(page_index).get("lines")
	max_line_index_on_page = lines.size() - 1
	
	line_index = 0
	read_line(line_index)

func read_line(index: int):
	emit_signal("read_new_line", lines[index])

func read_next_line(finished_line_index: int):
	if finished_line_index > max_line_index_on_page:
		var do_terminate = bool(page_data.get(page_index).get("terminate"))
		if do_terminate:
			emit_signal("terminate_page", page_index)
		else:
			if page_data.keys().has(page_index + 1):
				read_page(page_index + 1)
			else:
				emit_signal("terminate_page", page_index)
				push_warning(str("tried to read non-existent page ", page_index + 1, " after non-terminating page ", page_index))
		return
	read_line(finished_line_index + 1)



func open_connection():
	for l in get_tree().get_nodes_in_group("LineListener"):
		l.connect("line_finished", read_next_line)
	
