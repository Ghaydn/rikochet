extends Control

onready var pause_button = $settings_panel/pause
onready var mute_button = $settings_panel/mute
onready var cam_button = $settings_panel/cam
onready var emitter_button = $placing_panel/emitter
onready var infotext = $Infotext

func _ready():
	if g.interface == null: g.interface = self
	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		$settings_panel/exit.visible = false

func cam_to_ball():
	cam_button.texture_normal = r.cam_ball_image

func cam_to_pole():
	cam_button.texture_normal = r.cam_image

func to_pause():
	pause_button.texture_normal = r.play_image

func to_unpause():
	pause_button.texture_normal = r.pause_image

func to_mute():
	mute_button.texture_normal = r.mute_image

func to_unmute():
	mute_button.texture_normal = r.speaker_image

func set_emitter_rotation(rot: int):
	pass

func set_emitter_color(col: Color):
	emitter_button.modulate = col

func set_fig_rotation(rot: int):
	pass

func set_fig_rect(rect: Rect2):
	pass

func showhide_panels():
	$placing_panel.visible = not $showhide_panels.pressed
	$settings_panel.visible = not $showhide_panels.pressed
	if $showhide_panels.pressed: infotext.margin_top -= $placing_panel.rect_size.y
	else: infotext.margin_top = 0

func showhide_navigation():
	$navigation_panel.visible = not $showhide_navigation.pressed

func darken(col: Color):
	for child in $placing_panel.get_children():
		if child.pause_mode != Node.PAUSE_MODE_PROCESS:
			child.modulate = col
	$placing_panel.self_modulate = col
	$navigation_panel.self_modulate = col
	$settings_panel.self_modulate = col



func button_help():
	g.help_panel.show_help()


func _physics_process(delta):
	if infotext.visible:
		infotext.modulate = lerp(infotext.modulate, Color(1.0, 1.0, 1.0, 0), delta)
		if infotext.modulate.a <= 0.01:
			infotext.visible = false
			infotext.text = ""

func show_infotext(data: String):
	if infotext.modulate.a > 0.1: infotext.text += data
	else: infotext.text = data
	infotext.visible = true
	infotext.modulate.a = 1.0
