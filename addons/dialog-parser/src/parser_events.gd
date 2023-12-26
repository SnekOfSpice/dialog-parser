extends Node


## List of all events:

# "choice_pressed"
#		args:
#			"do_jump_page": bool,
#			"target_page": int,
#			"choice_text": String,
#	
# "choices_presented"
#		args:
#			"choices": Array
#				where every item is {
#					"disabled": bool,
#					"option_text": String,
#					"facts": Dictionary (dictionary of fact String and the value of the fact if the choice is pressed),
#					"do_jump_page": bool,
#					"target_page": int,
#				}
#"dialog_line_args_passed", e
#e = {
#			"actual_name": actual_name,
#			"dialog_line_arg_dict": dialog_line_arg_dict
#		}
#"fact_changed",  {"old_value" : facts[fact_name],"fact_name": fact_name, "new_value": new_value}
#"name_label_updated", {"actor_name": display_name, "is_name_container_visible": name_container.visible}
## uses the actual string that ends up in the label
#"new_actor_speaking", {"actor_name": actor_name, "is_name_container_visible": name_container.visible}
## uses internal key
#"new_header", {"header":header}
#header: Array where every item is {"data_type": int, "property_name": String, "values": Array of size 2}
#"page_finished", {"page_index": page_index}
#"read_new_page", {"number":number}
#"terminate_page", {"page_index": page_index}
#"text_content_text_changed", {"old_text": text_content.text, "new_text": cleaned_text}
#"word_read", {"word": word}


var event_listeners := {}

func listen(listener: Node, event_name: String):
	var listeners: Array = event_listeners.get(event_name, [])
	if not listeners.has(listener):
		listeners.append(listener)
		if not listener.tree_exiting.is_connected(remove_listener):
			listener.tree_exiting.connect(remove_listener.bind(listener))
	event_listeners[event_name] = listeners

## removes the listener from all events by iterating over all values of event_listeners
func remove_listener(listener: Node):
	for key in event_listeners.keys():
		unlisten(listener, key)

func unlisten(listener: Node, event_name: String):
	var listeners: Array = event_listeners.get(event_name, [])
	if listeners.has(listener):
		listeners.erase(listener)
		listener.tree_exiting.disconnect(remove_listener.bind(listener))
	event_listeners[event_name] = listeners

func start(event_name: String, event_args: Dictionary):
	for l in event_listeners.get(event_name, []):
		if not l.has_method("handle_event"):
			push_warning(str("Listener ", l, " doesn't have method handle_event"))
			continue
		l.handle_event(event_name, event_args)
