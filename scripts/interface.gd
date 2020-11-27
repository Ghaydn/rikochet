extends Control

onready var pause_button = $settings_panel/pause
onready var mute_button = $settings_panel/mute
onready var cam_button = $settings_panel/cam
onready var emitter_button = $placing_panel/emitter

func _ready():
	if g.interface == null: g.interface = self

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


