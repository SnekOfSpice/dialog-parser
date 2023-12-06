extends Node

const OPTIONS_PATH := "user://preferences.cfg"
const SAVEGAME_PATH := "user://savegame.json"
var music_volume := 0
var fullscreen := true
var confirmed_age := false
var text_speed := 60

const ENDING_NEVER_REACHED := "WTSRTS-never reached the end"
const ENDING_UNDECIDED := "WTSRTS-undecided"
const ENDING_QUIT_GAME := "WTSRTS-quit game"
const ENDING_BACK_TO_MAIN_MENU := "WTSRTS-back to main menu"
var ending_chosen := ENDING_NEVER_REACHED

var loaded_bgm_key := ""
var current_background_image := ""

func _ready() -> void:
	var config = ConfigFile.new()

	# Load data from a file.
	var err = config.load(OPTIONS_PATH)

	# If the file didn't load, ignore it.
	if err != OK:
		return

	music_volume = config.get_value("preferences", "music_volume", 0)
	fullscreen = config.get_value("preferences", "fullscreen", true)
	confirmed_age = config.get_value("preferences", "confirmed_age", false)
	ending_chosen = config.get_value("preferences", "ending_chosen", ENDING_NEVER_REACHED)


func save_prefs():
	# Create new ConfigFile object.
	var config = ConfigFile.new()

	# Store some values.
	config.set_value("preferences", "music_volume", music_volume)
	config.set_value("preferences", "fullscreen", fullscreen)
	config.set_value("preferences", "confirmed_age", confirmed_age)
	config.set_value("preferences", "ending_chosen", ending_chosen)

	# Save it to a file (overwrite if already exists).
	config.save(OPTIONS_PATH)

func save_gamestate():
	var data_to_save := {}
	data_to_save["Sound.current_bgm_key"] = Sound.current_bgm_key
	data_to_save["Game.current_background_image"] = current_background_image
	var character_visibilities := {}
	for c in get_tree().get_nodes_in_group("Character"):
		character_visibilities[c.character_name] = c.serialize()
	data_to_save["Game.character_visibilities"] = character_visibilities
	Parser.save_parser_state_to_file(SAVEGAME_PATH, data_to_save)

func load_gamestate():
	var game_data := Parser.load_parser_state_from_file(SAVEGAME_PATH)
	loaded_bgm_key = game_data.get("Sound.current_bgm_key", "")
	current_background_image = game_data.get("Game.current_background_image", "")
	var character_visibilities : Dictionary= game_data.get("Game.character_visibilities", {})
	for c in get_tree().get_nodes_in_group("Character"):
		c.deserialize(character_visibilities.get(c.character_name, {}))
