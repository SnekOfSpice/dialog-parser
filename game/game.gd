extends Node2D

@export var backgrounds: Array[Texture] = []


func request_background_change(new_background: String):
	prints("NEW BG ", new_background)
	if new_background.is_empty():
		return
	
	for b in backgrounds:
		if b.resource_path.ends_with(str("/", new_background, ".png")):
			$Background.texture = b
			return
	
	push_warning(str("Couldn't find texture for ", new_background))
