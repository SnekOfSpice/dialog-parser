extends CanvasLayer

@export var property_for_name := ""
@export var name_for_blank_name := ""
@export var text_speed := 100.0

signal line_finished(line_index)
signal jump_to_page(page_index)

var line_data := {}

var line_index

var is_input_locked := false : set = set_is_input_locked
var showing_text := false

func _ready() -> void:
	Parser.connect("read_new_line", read_new_line)
	Parser.connect("terminate_page", close)
	Parser.open_connection()
	
	find_child("InstructionHandler").connect("set_input_lock", set_is_input_locked)



func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if is_input_locked: return
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if showing_text:
				if find_child("TextContent").visible_ratio >= 1.0:
					if chunk_index >= line_chunks.size() - 1:
						emit_signal("line_finished", line_index)
					else:
						read_next_chunk()
				else:
					find_child("TextContent").visible_ratio = 1.0
			else:
				emit_signal("line_finished", line_index)

func set_is_input_locked(value: bool):
	is_input_locked = value
	find_child("NextPromptContainer").visible = not is_input_locked

func close(_terminating_page):
	prints("closing page ", _terminating_page)

func read_new_line(new_line: Dictionary):
	line_data = new_line
	line_index = new_line.get("meta.line_index")
	
	var eval = evaluate_conditionals(line_data.get("conditionals"))
	var conditional_is_true = eval[0]
	var behavior = eval[1]
	if behavior == "Show" or behavior == "Enable":
		if not conditional_is_true:
			emit_signal("line_finished", line_index)
			return
	if behavior == "Hide" or behavior == "Disable":
		if conditional_is_true:
			emit_signal("line_finished", line_index)
			return
	
	handle_header(line_data.get("header"))
	
	var line_type = int(line_data.get("line_type"))
	var content = line_data.get("content").get("content")
	if line_type == Parser.LineType.Choice:
		content = line_data.get("content").get("choices")
	var content_name = line_data.get("content").get("name") # wtf is this
	
	find_child("TextContainer").visible = line_type == Parser.LineType.Text
	showing_text = line_type == Parser.LineType.Text
	find_child("ChoiceContainer").visible = line_type == Parser.LineType.Choice
	match line_type:
		Parser.LineType.Text:
			start_showing_text(content)
		Parser.LineType.Choice:
			build_choices(content)
		Parser.LineType.Instruction:
			if not find_child("InstructionHandler").has_method("execute"):
				push_error("InsutrctionHandler doesn't have execute method.")
				return
			
			var instruction_name = content_name
			var args = {}
			
			# transform content to more friendly args
			for c in content:
				args[c.get("name")] = c.get("value")
			
			var delay_before = new_line.get("content").get("delay.before")
			var delay_after = new_line.get("content").get("delay.after")
			
			find_child("InstructionHandler").wrapper_execute(instruction_name, args, delay_before, delay_after)
	
	# register facts
	line_data.get("facts")

func _process(delta: float) -> void:
	if find_child("TextContent").visible_ratio < 1.0:
		find_child("TextContent").visible_characters += text_speed * delta


# TODO: different pause types and chunking. for now only line clears that are manually placed.
#var chunks_to_show := []
#var chunk_break_types := [] # defined for the one after the chunk
#enum BreakTypes {ManualPause, AutoPause}


# split by mp and ap, then a single part of that gets fed into the split code
# and that actually displays it
var line_chunks := []
var chunk_index := 0
var max_chunk_length := 50
func start_showing_text(content: String):
	line_chunks = content.split("<lc>")
	
	chunk_index = 0
	
	if text_speed > 0:
		find_child("TextContent").visible_characters = 0
	else:
		find_child("TextContent").visible_ratio = 1.0
	
	find_child("TextContent").text = line_chunks[chunk_index]
	
#	for c in chunks_to_show:
#		chunk_break_types.append(BreakTypes.LineClear)
	
	
#	# separate by too long
#	var i := 0
#
#	var limited_in_length := []
#	for c in text_lines:
#		#var size = find_child("TextContent").theme_override_fonts.normal_font.get_multiline_string_size(c)
#		var needed_chunks = ceil(float(float(c.length()) / float(max_chunk_length)))
#		prints("NEED ", needed_chunks, " FOR ", c.length())
#		if needed_chunks > 1:
#			for j in needed_chunks:
#				#chunk_break_types.insert(i, BreakTypes.LineClear)
#				i += 1
#				# i think this is also relevant
#				# string.lstrip(string.left(max_legth)
#				limited_in_length.append(c.left(max_chunk_length))
#				c = c.lstrip(c.left(max_chunk_length))
#		else:
#			limited_in_length.append(c)
#
#		i += 1
#	printt(limited_in_length, limited_in_length.size())
#	# separate by manual pause
#
#	# separate by auto pause

func read_next_chunk():
	chunk_index += 1
	if text_speed > 0:
		find_child("TextContent").visible_characters = 0
	else:
		find_child("TextContent").visible_ratio = 1.0
	
	find_child("TextContent").text = line_chunks[chunk_index]


func build_choices(choices):
	for c in find_child("ChoiceOptionContainer").get_children():
		c.queue_free()
	
	for option in choices:
		var conditional_eval = evaluate_conditionals(option.get("conditionals"))
		var cond_true = conditional_eval[0]
		var cond_behavior = conditional_eval[1]
		
		var enable_option := true
		var option_text := ""
		
		if (cond_true and cond_behavior == "Hide") or (not cond_true and cond_behavior == "Show"):
			continue
		
		if (cond_true and cond_behavior == "Show") or (not cond_true and cond_behavior == "Hide"):
			enable_option = option.get("choice_text.enabled_as_default")
		
		if (cond_true and cond_behavior == "Enable") or (not cond_true and cond_behavior == "Disable"):
			enable_option = true
			
		if (cond_true and cond_behavior == "Disable") or (not cond_true and cond_behavior == "Enable"):
			enable_option = false
		
		if enable_option:
			option_text = option.get("choice_text.enabled")
		else:
			option_text = option.get("choice_text.disabled")
		
		# give to option to signal
		var facts = option.get("facts")
		var do_jump_page = option.get("do_jump_page")
		var target_page = option.get("target_page")
		
		var new_option = preload("res://src/choice_option.tscn").instantiate()
		new_option.disabled = not enable_option
		new_option.text = option_text
		
		new_option.facts = facts
		new_option.do_jump_page = do_jump_page
		new_option.target_page = target_page
		
		new_option.connect("choice_pressed", choice_pressed)
		
		find_child("ChoiceOptionContainer").add_child(new_option)

func choice_pressed(do_jump_page, target_page):
	if do_jump_page:
		emit_signal("jump_to_page", target_page)
		return
	emit_signal("line_finished", line_index)
	

# returns an array of size 2.
# index 0 is if the conditionals are satisfied
# index 1 is the behavior if it's true
func evaluate_conditionals(conditionals) -> Array:
	var conditional_is_true := true
	var behavior = line_data.get("conditionals").get("behavior_key")
	var args = conditionals.get("operand_args")
	var facts_to_check = conditionals.get("facts")
	if facts_to_check.keys().size() == 0:
		return [true, "Enable"]
	
	
	var operand_key = conditionals.get("operand_key")
	var true_facts := []
	for fact in facts_to_check:
		if facts_to_check.get(fact) == Parser.facts.get(fact):
			true_facts.append(fact)
	match operand_key:
		"AND":
			conditional_is_true = true_facts.size() == facts_to_check.size()
		"OR":
			conditional_is_true = true_facts.size() > 0
		"nOrMore":
			conditional_is_true = true_facts.size() >= args[0]
		"nOrLess":
			conditional_is_true = true_facts.size() <= args[0]
		"betweenNMincl":
			conditional_is_true = true_facts.size() >= args[0] and true_facts.size() <= args[1]
	
	return [conditional_is_true, behavior]

func handle_header(header: Array):
	#prints("HEADER ", header)
	for prop in header:
		var data_type = prop.get("data_type")
		var property_name = prop.get("property_name")
		var values = prop.get("values")
		if data_type == Parser.DataTypes._DropDown:
			values = Parser.drop_down_values_to_string_array(values)
		
		if property_name == property_for_name:
			find_child("NameLabel").text = values[1]
			find_child("NameContainer").visible = values[1] != name_for_blank_name
			

func chunkify(line) -> Array:
	var line_type = int(line.get("line_type"))
	#print(line)
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
