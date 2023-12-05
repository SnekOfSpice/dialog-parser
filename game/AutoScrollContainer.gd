extends ScrollContainer

var max_scroll_length = 0
@onready var scrollbar = self.get_v_scroll_bar()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# auto scrolling
	scrollbar.connect("changed",handle_scrollbar_changed)
	max_scroll_length = scrollbar.max_value

func handle_scrollbar_changed():
	if max_scroll_length != scrollbar.max_value:
		max_scroll_length = scrollbar.max_value
		scroll_vertical = max_scroll_length
