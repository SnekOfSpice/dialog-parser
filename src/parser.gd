extends Node


#@export_file("*.json") var source_file
@export var source_path := ""
@export var source_path_demo := ""
@export var show_demo := false

var page_data := {}
var dropdown_titles := []
var dropdowns := {}

var line_reader = null

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

enum DataTypes {_String, _Integer, _Float, _Array, _Dictionary, _DropDown, _Boolean}

signal read_new_line(line)
signal terminate_page(page_index)
signal read_new_page(page_index)

func _ready() -> void:
	var path = source_path_demo if show_demo else source_path
	var file = FileAccess.open(path, FileAccess.READ)
	var data : Dictionary = JSON.parse_string(file.get_as_text())
	file.close()
	
	
	# all keys are now strings instead of ints
	var int_data = {}
	var loaded_data = data.get("page_data")
	for i in loaded_data.size():
		var where = int(loaded_data.get(str(i)).get("number"))
		int_data[where] = loaded_data.get(str(i)).duplicate()
	
	page_data = int_data.duplicate()
	
	facts = data.get("facts")
	dropdown_titles = data.get("dropdown_titles")
	dropdowns = data.get("dropdowns")

func drop_down_values_to_string_array(values:=[0,0]) -> Array:
	var result = ["", ""]
	var title = dropdown_titles[values[0]]
	var title_index = dropdown_titles.find(title)
	var value = dropdowns.get(title)[values[1]]
	result[0] = title
	result[1] = value
	return result

func read_page(number: int):
	if not page_data.keys().has(number):
		push_warning("number not in page data")
		return
	
	emit_signal("read_new_page", number)
	page_index = number
	lines = page_data.get(page_index).get("lines")
	max_line_index_on_page = lines.size() - 1
	
	line_index = 0
	read_line(line_index)

func read_line(index: int):
	if lines.size() == 0:
		push_warning(str("No lines defined for page ", page_index))
		return
	emit_signal("read_new_line", lines[index])
	

func read_next_line(finished_line_index: int):
	if finished_line_index >= max_line_index_on_page:
		var do_terminate = bool(page_data.get(page_index).get("terminate"))
		if do_terminate:
			emit_signal("terminate_page", page_index)
		else:
			var next = int(page_data.get(page_index).get("next"))
			if page_data.keys().has(next):
				read_page(next)
			else:
				emit_signal("terminate_page", page_index)
				push_warning(str("tried to read non-existent page ", next, " after non-terminating page ", page_index))
		return
	read_line(finished_line_index + 1)



func open_connection():
	for l in get_tree().get_nodes_in_group("LineListener"):
		l.connect("line_finished", read_next_line)
		l.connect("jump_to_page", read_page)
	
