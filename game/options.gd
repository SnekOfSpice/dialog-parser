extends Node

const OPTIONS_PATH := "user://preferences.cfg"
var music_volume := 0
var fullscreen := true
var confirmed_age := false
var text_speed := 60

const ENDING_NEVER_REACHED := "WTSRTS-never reached the end"
const ENDING_UNDECIDED := "WTSRTS-undecided"
const ENDING_QUIT_GAME := "WTSRTS-quit game"
const ENDING_BACK_TO_MAIN_MENU := "WTSRTS-back to main menu"
var ending_chosen := ENDING_NEVER_REACHED

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


func save():
	# Create new ConfigFile object.
	var config = ConfigFile.new()

	# Store some values.
	config.set_value("preferences", "music_volume", music_volume)
	config.set_value("preferences", "fullscreen", fullscreen)
	config.set_value("preferences", "confirmed_age", confirmed_age)
	config.set_value("preferences", "ending_chosen", ending_chosen)

	# Save it to a file (overwrite if already exists).
	config.save(OPTIONS_PATH)

