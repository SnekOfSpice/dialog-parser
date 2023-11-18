extends Node

const BGM_SLOW_DEEP_BREATHS = "res://game/sound/CØL - Slow, Deep Breaths - 03 Slow, Deep Breaths.ogg"
const BGM_FAILURE_TO_COMPLY = "res://game/sound/CØL - Anoscetia - 02 Failure to Comply Will Result in Death.ogg"
const BGM_WHERE_IS_HEAVEN = "res://game/sound/CØL - Where is Heaven-.ogg"
const BGM_PSYCH = "res://game/sound/Giacomo Forte - Warm 60s (Indie, vintage, psychedelic, rock, acid, synth, dreamy).mp3"
const BGM_WINDS = "res://game/sound/610365__klankbeeld__snow-city-nl-0009pm-210206_0243.ogg"
const BGM_TOO_MUCH_FOR_ME = "res://game/sound/CØL - Golden Twilight (Rarities) - 07 This Is All Too Much For Me (Piano Only).ogg"
const BGM_MELANCHOLY = "res://game/sound/Serge-Quadrado-Melancholy.ogg"
const BGM_JEREMIAH = "res://game/sound/CØL - Unmedicated IV - 01 Jeremiah I (Intro).ogg"

var gauge_out_eye = preload("res://game/sound/gauge-out-eye.ogg")

var rampup_time := 1.0
var target_volume := 0

func set_background_music(key: String, _rampup_time := rampup_time):
	rampup_time = _rampup_time
	var t = get_tree().create_tween()
	t.tween_property($BGMPlayer, "volume_db", -80, _rampup_time)
	
	if key == "":
		return
	
	t.connect("finished", ramp_up_background_music)
	
	
	
	var timer = get_tree().create_timer(_rampup_time)
	await timer.timeout
	$BGMPlayer.stream = load(key)
	$BGMPlayer.playing = true
	
	if key == BGM_WINDS:
		target_volume = Options.music_volume + 12
	else:
		target_volume = Options.music_volume

func ramp_up_background_music():
	var t = get_tree().create_tween()
	t.tween_property($BGMPlayer, "volume_db", target_volume, rampup_time)

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
		p.volume_db = 4
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
