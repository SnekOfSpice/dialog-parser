extends CanvasLayer

var hide_characters_on_full_black_reached := false
var new_background_on_full_black_reached := ""
var release_on_full_black_reached := 1.0
var sustain_on_full_black_reached := 1.0
var new_bgm_on_full_black_reached := ""

signal instruction_completed()
signal request_background_change(background_name: String)

func _ready() -> void:
	$ColorRect.modulate.a = 0.0
	visible = true

func fade_in(duration: float):
	if duration == 0.0:
		$ColorRect.modulate.a = 1.0
		on_full_black_reached()
		return
	var t = get_tree().create_tween()
	t.tween_property($ColorRect, "modulate:a", 1.0, duration)
	t.connect("finished", on_full_black_reached)

func fade_out(duration:= release_on_full_black_reached):
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
	
	if not new_bgm_on_full_black_reached.is_empty():
		Sound.set_background_music_by_key(new_bgm_on_full_black_reached)
		
	if sustain_on_full_black_reached > 0:
		var t = get_tree().create_timer(sustain_on_full_black_reached)
		t.connect("timeout", fade_out)
		return
	
	fade_out()
		
	
	
	
	
	
func on_clear_reached():
	print("BLACK IS CLEAR NOW")
	emit_signal("instruction_completed")


func _on_instruction_handler_make_screen_black(hide_characters, new_background, attack, release, sustain, new_bgm) -> void:
	hide_characters_on_full_black_reached = hide_characters
	new_background_on_full_black_reached = new_background
	release_on_full_black_reached = release
	sustain_on_full_black_reached = sustain
	new_bgm_on_full_black_reached = new_bgm
	fade_in(attack)
