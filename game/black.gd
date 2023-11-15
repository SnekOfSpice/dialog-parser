extends CanvasLayer

var hide_characters_on_full_black_reached := false
var new_background_on_full_black_reached := ""
var release_on_full_black_reached := 1.0

signal instruction_completed()
signal request_background_change(background_name: String)

func _ready() -> void:
	$ColorRect.modulate.a = 0.0

func fade_in(duration: float):
	if duration == 0.0:
		$ColorRect.modulate.a = 1.0
		on_full_black_reached()
		return
	var t = get_tree().create_tween()
	t.tween_property($ColorRect, "modulate:a", 1.0, duration)
	t.connect("finished", on_full_black_reached)

func fade_out(duration: float):
	if duration == 0.0:
		$ColorRect.modulate.a = 0.0
		return
	var t = get_tree().create_tween()
	t.tween_property($ColorRect, "modulate:a", 0.0, duration)
	t.connect("finished", on_clear_reached)


func on_full_black_reached():
	if hide_characters_on_full_black_reached:
		for c in get_tree().get_nodes_in_group("Character"):
			c.visible = false
	emit_signal("request_background_change", new_background_on_full_black_reached)
	fade_out(release_on_full_black_reached)
	
	
	
func on_clear_reached():
	print("BLACK IS CLEAR NOW")
	emit_signal("instruction_completed")


func _on_instruction_handler_make_screen_black(hide_characters, new_background, attack, release, sustain) -> void:
	hide_characters_on_full_black_reached = hide_characters
	new_background_on_full_black_reached = new_background
	release_on_full_black_reached = release
	fade_in(attack)
