extends Node

const BGM_SLOW_DEEP_BREATHS = "res://game/sound/CØL - Slow, Deep Breaths - 03 Slow, Deep Breaths.ogg"
const BGM_FAILURE_TO_COMPLY = "res://game/sound/CØL - Anoscetia - 02 Failure to Comply Will Result in Death.ogg"
const BGM_WHERE_IS_HEAVEN = "res://game/sound/CØL - Where is Heaven-.ogg"
const BGM_PSYCH = "res://game/sound/Giacomo Forte - Warm 60s (Indie, vintage, psychedelic, rock, acid, synth, dreamy).mp3"

var rampup_time := 1.0

#func _ready() -> void:
#	set_background_music(BGM_SLOW_DEEP_BREATHS)

func set_background_music(key: String, _rampup_time := rampup_time):
	rampup_time = _rampup_time
	var t = get_tree().create_tween()
	t.tween_property($BGMPlayer, "volume_db", -80, _rampup_time)
	t.connect("finished", ramp_up_background_music)
	
	var timer = get_tree().create_timer(_rampup_time)
	await timer.timeout
	$BGMPlayer.stream = load(key)
	$BGMPlayer.playing = true

func ramp_up_background_music():
	var t = get_tree().create_tween()
	t.tween_property($BGMPlayer, "volume_db", 0, rampup_time)

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
