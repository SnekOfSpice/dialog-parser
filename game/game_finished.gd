extends CanvasLayer


func _ready() -> void:
	visible = false
	Parser.connect("terminate_page", handle_page_terminated)
	# debug only
	Parser.connect("page_finished", handle_page_terminated) 

func handle_page_terminated(page_index: int):
	print(page_index)
	if page_index < Parser.page_data.keys().size() - 1:
		return
	
	visible = true
