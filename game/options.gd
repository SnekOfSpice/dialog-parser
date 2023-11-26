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
	

	var score_data = {}
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
	var file = FileAccess.open(SAVEGAME_PATH, FileAccess.WRITE)
	var data_to_save = Parser.serialize()
	data_to_save["Sound.current_bgm_key"] = Sound.current_bgm_key
	data_to_save["Game.current_background_image"] = current_background_image
	file.store_string(JSON.stringify(data_to_save, "\t"))
	file.close()

func load_gamestate():
	var file = FileAccess.open(SAVEGAME_PATH, FileAccess.READ)
	if not file:
		Parser.page_index = 0
		Parser.line_index = 0
		return
	
	var data : Dictionary = JSON.parse_string(file.get_as_text())
	file.close()
	
	Parser.page_index = int(data.get("Parser.page_index", 0))
	Parser.line_index = int(data.get("Parser.line_index", 0))
	Parser.apply_facts(data.get("Parser.facts", {}))
	loaded_bgm_key = data.get("Sound.current_bgm_key", "")
	current_background_image = data.get("Game.current_background_image", "")
