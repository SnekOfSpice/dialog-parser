extends Node

const BGM_SLOW_DEEP_BREATHS = "res://game/sound/CØL - Slow, Deep Breaths - 03 Slow, Deep Breaths.ogg"
const BGM_FAILURE_TO_COMPLY = "res://game/sound/CØL - Anoscetia - 02 Failure to Comply Will Result in Death.ogg"
const BGM_WHERE_IS_HEAVEN = "res://game/sound/CØL - Where is Heaven-.ogg"
const BGM_PSYCH = "res://game/sound/Giacomo Forte - Warm 60s (Indie, vintage, psychedelic, rock, acid, synth, dreamy).mp3"
const BGM_WINDS = "res://game/sound/610365__klankbeeld__snow-city-nl-0009pm-210206_0243.ogg"
const BGM_TOO_MUCH_FOR_ME = "res://game/sound/CØL - Golden Twilight (Rarities) - 07 This Is All Too Much For Me (Piano Only).ogg"
const BGM_MELANCHOLY = "res://game/sound/Serge-Quadrado-Melancholy.ogg"
const BGM_JEREMIAH = "res://game/sound/CØL - Unmedicated IV - 01 Jeremiah I (Intro).ogg"
const BGM_MAIN_MENU_LOST_PIANO = "res://game/sound/650013__logicmoon__lost-piano-recording.ogg"
const BGM_UNSTEADY_WORK = "res://game/sound/661484__jim-bretherick__piano-chord-stretched-distorted-echphoned1.ogg"
const BGM_ZERO_DRAGGING_NAILS = "res://game/sound/425945__timbre__fb-loop-excerpt-of-erokias-freesound-401743.ogg"
const BGM_WEDDING = "res://game/sound/wedding.ogg"
const BGM_AFTERCARE = "res://game/sound/478318__tri-tachyon__soundscape-dust-ambient-guitar.ogg"
const BGM_SEX = "res://game/sound/511277__doctor_dreamchip__2020-03-29-downtempo-doctor-dreamchip.ogg"
const BGM_LYING_TO_ME = "res://game/sound/CØL - Unmedicated IV - 01 Jeremiah I (Intro).ogg"

var gauge_out_eye = preload("res://game/sound/gauge-out-eye.ogg")

var rampup_time := 1.0
var target_volume := 0

var current_bgm := ""
var current_bgm_key := ""

func set_background_music_by_key(key:String):
	current_bgm_key = key
	match key:
		"Failure to Comply Will Result in Death":
			set_background_music(BGM_FAILURE_TO_COMPLY)
		"Where is Heaven?":
			set_background_music(BGM_WHERE_IS_HEAVEN)
		"Warm 60s":
			set_background_music(BGM_PSYCH)
		"Winds":
			set_background_music(BGM_WINDS)
		"Slow, Deep Breaths":
			set_background_music(BGM_SLOW_DEEP_BREATHS)
		"This Is All Too Much For Me":
			set_background_music(BGM_TOO_MUCH_FOR_ME)
		"Melancholy":
			set_background_music(BGM_MELANCHOLY)
		"Jeremiah":
			set_background_music(BGM_JEREMIAH)
		"Unsteady Work":
			set_background_music(BGM_UNSTEADY_WORK)
		"Zero Dragging Nails":
			set_background_music(BGM_ZERO_DRAGGING_NAILS)
		"Wedding":
			set_background_music(BGM_WEDDING)
		"BDSM Aftercare":
			set_background_music(BGM_AFTERCARE)
		"Sex":
			set_background_music(BGM_SEX)
		"Lying to Me":
			set_background_music(BGM_LYING_TO_ME)
		"":
			set_background_music("")

func set_background_music(key: String, _rampup_time := rampup_time):
	rampup_time = _rampup_time
	current_bgm = key
	var t = get_tree().create_tween()
	t.tween_property($BGMPlayer, "volume_db", -80, rampup_time)
	
	if key == "":
		return
	
	t.connect("finished", ramp_up_background_music)
	
	
	
	var timer = get_tree().create_timer(rampup_time)
	await timer.timeout
	$BGMPlayer.stream = load(key)
	$BGMPlayer.playing = true
	
	set_target_volume(Options.music_volume)
	
func set_target_volume(value: float):
	if current_bgm == BGM_WINDS:
		target_volume = value + 12
	else:
		target_volume = value
	$BGMPlayer.volume_db = target_volume

func ramp_up_background_music():
	var t = get_tree().create_tween()
	t.tween_property($BGMPlayer, "volume_db", target_volume, rampup_time)
	rampup_time = 1.0

# idk TODO ig
func play(soundName:String, randomPitch := true) -> AudioStreamPlayer:
	var s = get(soundName)
	if s is Array:
		if s.size() == 0:
			prints("no sounds in array ", soundName)
			return null
		randomize()
		s = s[randi_range(0, s.size() - 1)]
	if s:
		var p = AudioStreamPlayer.new()
		add_child(p)
		p.volume_db = 4 + Options.music_volume
		p.connect("finished", p.queue_free)
		p.stream = s
		p.play()
		if randomPitch:
			randomize()
			p.pitch_scale = randf_range(0.8, 1 / 0.8)
		return p
	else:
		print("Sound \"" + soundName + "\" is not defined") 
		return null
