tool #is needed for the rotation through direction to work correctly
extends Sprite
#The emitter launches balls.

export(int, 0, 3) var direction setget set_dir 
export(float, 0, 1000) var ball_speed setget set_speed #launches balls at different speeds.
export(bool) var autostart #will launch the ball immediately after entering the tree
onready var pole = get_parent()
#onready var labl = $Label

#The heart and the very essence.
func emit_ball():
	if Engine.editor_hint: return #we don't need this in the editor
	var ball = r.ball.instance() #this is not a user file, so without it let it fall with an error
	pole.call_deferred("add_child", ball) #thread safe
	ball.direction = direction
	ball.position = position
	ball.speed = ball_speed
	ball.modulate = Color.from_hsv(randf(), 0.5, 1.0)#random balls colors for fancy
	$emit_sound.play()

#when specifying the direction, rotates the object itself
func set_dir(dir: int):
	#pole.get_node("ball").queue_free()
	dir = wrapi(dir, 0, 4)
	rotation_degrees = dir * 90
	direction = dir

func set_speed(spd: float):
	spd = clamp(spd, 100, 1000)
	modulate = Color.from_hsv(0, float(spd) / 1000, 1.0)
	#if labl != null:
	#	labl.text = String(int(spd / 100))
	ball_speed = spd

func _ready():
	#labl.text =  String(int(ball_speed / 100))
	if Engine.editor_hint: return
	if autostart: emit_ball()
