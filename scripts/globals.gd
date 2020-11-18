extends Node

var pole
var editor
var cam

var mute_audio: bool

func _ready():
	pass


func reparent_cam():
	var ball
	for child in pole.get_children():
		if child.has_method("disappear"):
			ball = child
			break
	if ball != null:
		cam.reparent(ball)


func mute():
	mute_audio = not mute_audio
	AudioServer.set_bus_mute(0, mute_audio)
	if editor != null:
		if mute_audio:
			editor.mute.normal = load("res://images/mute.png")
		else:
			editor.mute.normal = load("res://images/speaker.png")

func pause():
	if get_tree().paused:
		pole.modulate = Color.from_hsv(0, 0, 1)
		get_tree().paused = false
		if editor != null:
			editor.pause.normal = load("res://images/play.png")
	else:
		pole.modulate = Color.from_hsv(0, 0, 0.5)
		get_tree().paused = true
		if editor != null:
			editor.pause.normal = load("res://images/pause.png")
