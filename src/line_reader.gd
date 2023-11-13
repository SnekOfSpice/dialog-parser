extends CanvasLayer
class_name LineReader

@export var property_for_name := ""
@export var name_for_blank_name := ""
@export var text_speed := 0.5#100.0
@export var auto_pause_duration := 0.2

signal line_finished(line_index)
signal jump_to_page(page_index)
signal new_header(header)
signal is_input_locked_changed(new_value)

var line_data := {}

var line_index
var remaining_auto_pause_duration := 0.0

var is_input_locked := false : set = set_is_input_locked
var showing_text := false

func _ready() -> void:
	Parser.connect("read_new_line", read_new_line)
	Parser.connect("terminate_page", close)
	
	
	Parser.line_reader = self
	Parser.open_connection()
	
	find_child("InstructionHandler").connect("set_input_lock", set_is_input_locked)
	find_child("InstructionHandler").connect("instruction_completed", instruction_completed)
	
	remaining_auto_pause_duration = auto_pause_duration



func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if is_input_locked: return
		if terminated: return
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if showing_text:
				if find_child("TextContent").visible_ratio >= 1.0:
					if chunk_index >= line_chunks.size() - 1:
						emit_signal("line_finished", line_index)
					else:
						read_next_chunk()
				else:
					find_next_pause()
					if next_pause_position_index >= pause_positions.size():
						find_child("TextContent").visible_ratio = 1.0
					
					elif next_pause_position_index < pause_positions.size():
						find_child("TextContent").visible_characters = pause_positions[next_pause_position_index]
						if next_pause_type == PauseTypes.Manual:
							next_pause_position_index += 1
							remaining_auto_pause_duration = auto_pause_duration
						
					
			else:
				emit_signal("line_finished", line_index)

func instruction_completed():
	emit_signal("line_finished", line_index)

func set_is_input_locked(value: bool):
	is_input_locked = value
	emit_signal("is_input_locked_changed", is_input_locked)

var terminated := false
func close(_terminating_page):
	prints("closing page ", _terminating_page)
	visible = false
	terminated = true

func read_new_line(new_line: Dictionary):
	line_data = new_line
	line_index = new_line.get("meta.line_index")
	terminated = false
	
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
	var facts = line_data.get("facts")
	for f in facts.keys():
		Parser.change_fact(f, facts.get(f))
	
	


func _process(delta: float) -> void:
	if next_pause_position_index < pause_positions.size() and next_pause_position_index != -1:
		
		if find_child("TextContent").visible_characters < pause_positions[next_pause_position_index]:
			#find_child("TextContent").visible_characters += text_speed * delta
			find_child("TextContent").visible_ratio += (text_speed / find_child("TextContent").text.length()) * delta
		elif remaining_auto_pause_duration > 0 and next_pause_type == PauseTypes.Auto:
			var last_dur = remaining_auto_pause_duration
			remaining_auto_pause_duration -= delta
			if last_dur > 0 and remaining_auto_pause_duration <= 0:
				next_pause_position_index += 1
				remaining_auto_pause_duration = auto_pause_duration
	elif find_child("TextContent").visible_ratio < 1.0:
		#find_child("TextContent").visible_characters += text_speed * delta
		find_child("TextContent").visible_ratio += (text_speed / find_child("TextContent").text.length()) * delta
	


var line_chunks := []
var chunk_index := 0
var max_chunk_length := 50
func start_showing_text(content: String):
	line_chunks = content.split("<lc>")
	#if line_chunks.is_empty(): line_chunks = [""] # shouldnt ever happen but idk
	chunk_index = -1
	read_next_chunk()
	
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

var next_pause_position := -1
var next_pause_position_index := -1
var pause_positions := []
var next_pause_type := 0
#var goal_pauses_this_chunk := 0
enum PauseTypes {Manual, Auto}
func read_next_chunk():
	chunk_index += 1
	if text_speed > 0:
		find_child("TextContent").visible_characters = 0
	else:
		find_child("TextContent").visible_ratio = 1.0
	
	pause_positions.clear()
	var new_text : String = line_chunks[chunk_index]
	var current_position = find_child("TextContent").visible_characters
	var total_pauses_this_chunk := 0
	var next_mp = new_text.find("<mp>")
	var next_ap = new_text.find("<ap>")
	while  next_ap !=  -1 or next_mp != -1:
		var next_pause = max(min(next_mp, next_ap), 0)
		next_mp = new_text.find("<mp>", next_pause + 4 * total_pauses_this_chunk)
		next_ap = new_text.find("<ap>", next_pause + 4 * total_pauses_this_chunk)
		if next_mp == -1 and next_ap != -1:
			if not pause_positions.has(next_ap):
				pause_positions.append(next_ap)
		elif next_mp != -1 and next_ap == -1:
			if not pause_positions.has(next_mp):
				pause_positions.append(next_mp)
		elif next_mp != -1 and next_ap != -1:
			if not pause_positions.has(min(next_ap, next_mp)):
				pause_positions.append(min(next_ap, next_mp))
		total_pauses_this_chunk += 1
	
	
	next_pause_position_index = 0
	#goal_pauses_this_chunk = line_chunks[chunk_index].count("<mp>") + line_chunks[chunk_index].count("<ap>")
	find_next_pause()
	
	var cleaned_text : String = line_chunks[chunk_index]
	var i = 0
	for pos in pause_positions:
		cleaned_text = cleaned_text.erase(pos-(i*4), 4)
		i += 1
		
	
	find_child("TextContent").text = cleaned_text

var pause_count_this_chunk := 0
func find_next_pause():
	var new_text : String = line_chunks[chunk_index]
	var current_position = find_child("TextContent").visible_characters
	var next_mp = new_text.find("<mp>", current_position + 4 * pause_count_this_chunk)
	var next_ap = new_text.find("<ap>", current_position + 4 * pause_count_this_chunk)
	if next_ap == -1:
		if next_mp == -1:
			next_pause_position = -1
		else:
			next_pause_position = next_mp
			next_pause_type = PauseTypes.Manual
			pause_count_this_chunk += 1
	elif next_ap != -1:
		next_pause_position = next_ap
		next_pause_type = PauseTypes.Auto
		pause_count_this_chunk += 1


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
	
	emit_signal("new_header", header)



func _on_finished_button_pressed() -> void:
	emit_signal("line_finished", line_index)
