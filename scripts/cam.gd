extends Camera2D
#Камера 

var velocity: Vector2
var target_zoom: float = 1.0
onready var pole = get_parent()
#onready var ball = pole.get_node("Ball")
var ball

const SPEED = 800.0
#const BASE_ZOOM = 1.0
const ZOOM_MAX = 2.5
const ZOOM_MIN = 0.25
const ZOOM_SPEED = 10.0
const ZOOM_STEP = 0.125

var mute_master: bool

func _ready():
	g.cam = self

func _input(event):
	if Input.is_action_pressed("ctrl"):
		if Input.is_action_just_pressed("scroll_up"):
			target_zoom -= ZOOM_STEP
		elif Input.is_action_just_pressed("scroll_down"):
			target_zoom += ZOOM_STEP
		target_zoom = clamp(target_zoom, ZOOM_MIN, ZOOM_MAX)
	
	if Input.is_action_just_pressed("reparent_cam"):
		g.reparent_cam()
	
	
	if Input.is_action_just_pressed("mute"):
		g.mute()
	
	if Input.is_action_just_pressed("pause"):
		g.pause()

#Эта функция прикрепляет камеру к шарику. Или открепляет обратно.
func reparent(reball):
	if get_parent() == pole:
		pole.remove_child(self)
		reball.add_child(self)
		drag_margin_h_enabled = true
		drag_margin_v_enabled = true
		position = Vector2.ZERO
	else:
		var globalpos = global_position
		reball.remove_child(self)
		pole.add_child(self)
		global_position = globalpos
		drag_margin_h_enabled = false
		drag_margin_v_enabled = false
	print("cam parent: ", get_parent())
	
#Камера - одна из двух нод, имеющих физикс-процесс.
#Он тут нужен для перемещения и для плавного зума.
func _physics_process(delta):
	if get_parent() == pole:
		if not Input.is_action_pressed("shift"):
			velocity = Vector2(float(Input.is_action_pressed("move_right")) - float(Input.is_action_pressed("move_left")), \
												 float(Input.is_action_pressed("move_down")) - float(Input.is_action_pressed("move_up")))
			velocity *= SPEED * zoom
			position += velocity * delta
			
		if Input.is_action_pressed("center_cam"):
			position = get_global_mouse_position()
	
	if zoom != Vector2(target_zoom, target_zoom):
		zoom = lerp(zoom, Vector2(target_zoom, target_zoom), ZOOM_SPEED * delta)
