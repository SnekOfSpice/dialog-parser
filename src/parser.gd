extends Node


@export_file("*.json") var source_file
@export var source_path := ""

var page_data := {}


var page_index := 0
var line_index := 0
var chunk_index := 0
var lines := []
var line_chunks := []

const MAX_LINE_LENGTH := 10

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
	line_index = 0
	read_line(line_index)

func read_line(index: int):
	line_chunks = chunkify(lines[index])
	chunk_index = 0

func chunkify(line: String) -> Array:
	print(line)
	return []
