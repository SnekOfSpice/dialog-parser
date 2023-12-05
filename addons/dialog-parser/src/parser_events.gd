extends Node

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
