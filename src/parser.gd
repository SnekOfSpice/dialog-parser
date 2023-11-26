extends Node


@export_file("*.json") var source_file
@export var source_path := ""
@export var source_path_demo := ""
@export var show_demo := false

var page_data := {}
var dropdown_titles := []
var dropdowns := {}

var line_reader : LineReader = null

var page_index := 0
var line_index := 0
var chunk_index := 0
var lines := []
var line_chunks := []

var facts := {}
var starting_facts := {}

var max_line_index_on_page := 0

const MAX_LINE_LENGTH := 10

enum LineType {
	Text, Choice, Instruction
}

enum DataTypes {_String, _Integer, _Float, _Array, _Dictionary, _DropDown, _Boolean}

signal read_new_line(line)
signal terminate_page(page_index: int)
signal page_finished(page_index: int)
signal read_new_page(page_index: int)

func _ready() -> void:
	#var path = source_path_demo if show_demo else source_path
	var file = FileAccess.open(source_file, FileAccess.READ)
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
	starting_facts = facts.duplicate(true)
	dropdown_titles = data.get("dropdown_titles")
	dropdowns = data.get("dropdowns")
	
	if show_demo:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func drop_down_values_to_string_array(values:=[0,0]) -> Array:
	var result = ["", ""]
	var title = dropdown_titles[values[0]]
	#var title_index = dropdown_titles.find(title)
	var value = dropdowns.get(title)[values[1]]
	result[0] = title
	result[1] = value
	return result

func read_page(number: int, starting_line_index := 0):
	if not page_data.keys().has(number):
		push_warning("number not in page data")
		return
	
	emit_signal("read_new_page", number)
	page_index = number
	lines = page_data.get(page_index).get("lines")
	max_line_index_on_page = lines.size() - 1
	
	line_index = starting_line_index
	read_line(line_index)

func get_game_progress() -> float:
	var max_line_index_used_for_calc := 0
	var calc_lines = page_data.get(page_index).get("lines")
	max_line_index_used_for_calc = calc_lines.size() - 1
	if max_line_index_used_for_calc <= 0:
		return 0.0
	var max_page_index :int= max(page_data.keys().size(), 1)
	
	if max_page_index <= 0:
		return 0.0
	
	var page_progress = (int(page_index) / float(max_page_index))
	var line_progress = float(line_index) / float(max_line_index_used_for_calc)
	
	return page_progress + (line_progress / float(max_page_index))

func read_line(index: int):
	if lines.size() == 0:
		push_warning(str("No lines defined for page ", page_index))
		return
	line_index = index
	emit_signal("read_new_line", lines[index])
	

func read_next_line(finished_line_index: int):
	if finished_line_index >= max_line_index_on_page:
		var do_terminate = bool(page_data.get(page_index).get("terminate"))
		if do_terminate:
			emit_signal("terminate_page", page_index)
		else:
			var next = int(page_data.get(page_index).get("next"))
			if page_data.keys().has(next):
				emit_signal("page_finished", page_index)
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
	
	for l in get_tree().get_nodes_in_group("ParserDependent"):
		l.parser_init()
	

func change_fact(fact_name: String, new_value: bool):
	facts[fact_name] = new_value
	for l in get_tree().get_nodes_in_group("FactListener"):
		l.fact_changed(fact_name, new_value)

func apply_facts(f: Dictionary):
	for fact in f.keys():
		change_fact(fact, f.get(fact))

func reset_facts():
	for fact in starting_facts.keys():
		change_fact(fact, starting_facts.get(fact))

func serialize() -> Dictionary:
	var result := {}
	
	result["Parser.facts"] = facts
	result["Parser.page_index"] = page_index
	result["Parser.line_index"] = line_index
	prints("SERIALIZING ", result)
	return result

func deserialize(data: Dictionary):
	facts = data.get("facts")
	read_page(int(data.get("page_index")), int(data.get("line_index")))
