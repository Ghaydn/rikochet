extends Camera2D 

var velocity: Vector2
var ext_velocity: Vector2
var target_zoom: float = 1.25
onready var pole = get_parent()
#onready var ball = pole.get_node("Ball")
var ball

const SPEED = g.MIN_SPEED * 2
#const BASE_ZOOM = 1.0
const ZOOM_MAX = 5.0
const ZOOM_MIN = 0.5
const ZOOM_SPEED = 10.0
const ZOOM_STEP = 0.25

var mute_master: bool

func _ready():
	g.cam = self

func _input(event):
	
	if Input.is_action_pressed("ctrl"):
		if Input.is_action_just_pressed("scroll_up"):
			if get_parent() == pole:
				position = (position + get_global_mouse_position()) / 2
			zoom_in()
		elif Input.is_action_just_pressed("scroll_down"):
			if get_parent() == pole:
				position = (position + get_global_mouse_position()) / 2
			zoom_out()
	
	if Input.is_action_just_pressed("reparent_cam"):
		g.reparent_cam()
	
	
	if Input.is_action_just_pressed("mute"):
		g.mute()
	
	if Input.is_action_just_pressed("pause"):
		g.pause()
	
	if event is InputEventMagnifyGesture:
		var nzoom = clamp(zoom.x * event.factor, ZOOM_MIN, ZOOM_MAX)
		zoom = Vector2(nzoom, nzoom)
	
	if event is InputEventMouseMotion:
		if event.button_mask == BUTTON_MASK_MIDDLE:
			move_cam(event.relative * zoom)
	
	if event is InputEventScreenDrag:
		move_cam(event.relative * zoom)
	
	if event.is_action("move_down") or event.is_action("move_left") \
	or event.is_action("move_right") or event.is_action("move_up"):
		smoothing_enabled = true

func move_cam(distance: Vector2):
	if get_parent() == pole:
		smoothing_enabled = false
		position -= distance


func cam_up_pressed():
	smoothing_enabled = true
	ext_velocity = Vector2.UP

func cam_up_released():
	smoothing_enabled = true
	ext_velocity *= Vector2(1, 0)

func cam_down_pressed():
	smoothing_enabled = true
	ext_velocity = Vector2.DOWN

func cam_down_released():
	smoothing_enabled = true
	ext_velocity *= Vector2(1, 0)

func cam_left_pressed():
	smoothing_enabled = true
	ext_velocity = Vector2.LEFT

func cam_left_released():
	smoothing_enabled = true
	ext_velocity *= Vector2(0, 1)

func cam_right_pressed():
	smoothing_enabled = true
	ext_velocity = Vector2.RIGHT

func cam_right_released():
	smoothing_enabled = true
	ext_velocity *= Vector2(0, 1)


func zoom_in():
	smoothing_enabled = true
	target_zoom -= ZOOM_STEP
	target_zoom = clamp(target_zoom, ZOOM_MIN, ZOOM_MAX)


func zoom_out():
	smoothing_enabled = true
	target_zoom += ZOOM_STEP
	target_zoom = clamp(target_zoom, ZOOM_MIN, ZOOM_MAX)

#This function attaches the camera to the ball. Or detaches back.
func reparent(reball):
	smoothing_enabled = true
	if get_parent() == pole:
		pole.remove_child(self)
		reball.add_child(self)
		drag_margin_h_enabled = true
		drag_margin_v_enabled = true
		position = Vector2.ZERO
		g.interface.cam_to_ball()
	else:
		var globalpos = global_position
		reball.remove_child(self)
		pole.add_child(self)
		global_position = globalpos
		drag_margin_h_enabled = false
		drag_margin_v_enabled = false
		g.interface.cam_to_pole()
	#print("cam parent: ", get_parent())

		

#The camera is one of two nodes with a _physics_process.
#It is needed here for movement and for smooth zoom.
func _physics_process(delta):
	if g.saveload_dialogs.save_dialog.visible or g.saveload_dialogs.load_dialog.visible \
	or g.help_panel.visible: return
	if get_parent() == pole:
		velocity = ext_velocity
		if not Input.is_action_pressed("shift") and not Input.is_action_pressed("ctrl") \
		and velocity == Vector2.ZERO:
			velocity = Vector2(Input.get_action_strength("move_right") - Input.get_action_strength("move_left"), \
												 Input.get_action_strength("move_down") - Input.get_action_strength("move_up"))
			#smoothing_enabled = true
		velocity *= SPEED * zoom
		position += velocity * delta
		velocity = Vector2.ZERO
			
		if Input.is_action_pressed("center_cam"):
			position = get_global_mouse_position()
	
	if zoom != Vector2(target_zoom, target_zoom):
		zoom = lerp(zoom, Vector2(target_zoom, target_zoom), ZOOM_SPEED * delta)
