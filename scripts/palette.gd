extends Node2D
#Old version of interface

export(Vector2) var palette_size = Vector2(112, 368)
var moving_palette: bool
var mouse_pos: Vector2
var mouse_on_pole: Vector2
var palette_move_shift: Vector2

func _ready():
	g.interface = self

func _input(event):
	if not visible: return
	mouse_pos = get_local_mouse_position()
	mouse_on_pole = g.pole.get_cell_coord(mouse_pos)
	if Input.is_action_just_released("place"):
		moving_palette = false
	
	if moving_palette and Input.is_action_pressed("place"):
		position = mouse_pos + palette_move_shift
		return
	
	if mouse_on_palette():
		if mouse_on_header():
			if Input.is_action_just_pressed("place"):
				palette_move_shift = position - mouse_pos 
				moving_palette = true


func mouse_on_palette() -> bool:
	return mouse_pos.x > global_position.x - palette_size.x and \
	mouse_pos.y < global_position.y + palette_size.y and \
	mouse_pos.x < global_position.x + palette_size.x and \
	mouse_pos.y > global_position.y

func mouse_on_header() -> bool:
	return mouse_pos.x > global_position.x - palette_size.x and \
	mouse_pos.y < global_position.y + 16 and \
	mouse_pos.x < global_position.x + palette_size.x and \
	mouse_pos.y > global_position.y
