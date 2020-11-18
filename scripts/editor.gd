extends Node2D
#Эта нода, будучи добавленной к полю, позволяет его редактировать.
#Без редактора невозможно ни крутить треугольники на поле, ни даже вручную запускать шары.

var mouse_pos: Vector2
var mouse_on_pole: Vector2
onready var pole = get_parent()
onready var painter = $painter
onready var palette = $Palette

var palette_size: Vector2 = Vector2(112, 240)
var palette_move_shift: Vector2
var moving_palette: bool

onready var eater = $Palette/place_eater
onready var emitter = $Palette/place_emitter
onready var erase = $Palette/erase
onready var fig = $Palette/fig
onready var pause = $Palette/pause
onready var mute = $Palette/mute

var fig_cell: Vector2 = Vector2.ZERO
var painter_mode: String

func _ready():
	g.editor = self

#В инпуте у нас только инпуты и вызовы соответствующих функций
func _input(event):
	mouse_pos = get_local_mouse_position()
	mouse_on_pole = pole.get_cell_coord(mouse_pos)
	
	if Input.is_action_just_pressed("quicksave"):
		pole.quicksave()
	
	if Input.is_action_just_pressed("quickload"):
		pole.quickload()
		
	if Input.is_action_just_pressed("clear"):
		pole.clear_pole()
		
	if event is InputEventMouseMotion:
		if not mouse_on_palette():
			painter.position = pole.to_center(mouse_on_pole)
	
	if Input.is_action_just_released("place"):
		moving_palette = false
	
	if moving_palette and Input.is_action_pressed("place"):
		palette.position = mouse_pos + palette_move_shift
		return
	
	if mouse_on_palette():
		if mouse_on_header():
			if Input.is_action_just_pressed("place"):
				palette_move_shift = palette.position - mouse_pos 
				moving_palette = true
	else:
		if painter.visible:
			if not Input.is_action_pressed("ctrl"):
				if Input.is_action_just_pressed("scroll_up"):
					if Input.is_action_pressed("shift"):
						button_next_fig()
					else:
						button_rotate_right()
				if Input.is_action_just_pressed("scroll_down"):
					if Input.is_action_pressed("shift"):
						button_prev_fig()
					else:
						button_rotate_left()
			
				if Input.is_action_pressed("place"):
					use_painter()
				if Input.is_action_just_pressed("place"):
					use_painter(true)
				if Input.is_action_pressed("erase"):
					use_eraser()
		
		else:
		
			if not Input.is_action_pressed("ctrl"):
				if pole.has_something(mouse_on_pole):
					if Input.is_action_just_pressed("scroll_up"):
						if Input.is_action_pressed("shift"):
							pole.shift_selected_cell(mouse_on_pole, true)
						else:
							pole.rotate_selected_cell(mouse_on_pole, true)
					if Input.is_action_just_pressed("scroll_down"):
						if Input.is_action_pressed("shift"):
							pole.shift_selected_cell(mouse_on_pole, false)
						else:
							pole.rotate_selected_cell(mouse_on_pole, false)


#если у нас активен какой-то инструмент, то мы используем его.
#Если никакой не активен, то никакой не используем.
func use_painter(once: bool = false):
	if not painter.visible: return
	match painter_mode:
		"eraser": if not once: use_eraser()
		"eater": if once: place_eater()
		"emitter": if once: place_emitter()
		"placer": if not once: place_fig()

#Вот тут мы используем стёрку.
#Наверное, стоило бы передавать координаты в аргументе, а не считать их каждый раз...
func use_eraser():
	if not painter.visible: return
	var paint_pos = pole.get_cell_coord(painter.position)
	pole.erase_cell(paint_pos)
	
	var eater = pole.find_eater(paint_pos)
	if eater != null: eater.queue_free()
	var emitter = pole.find_emitter(paint_pos)
	if emitter != null: emitter.queue_free()

#инструмент расставления поедателя
func place_eater():
	if not painter.visible: return
	var paint_pos = pole.get_cell_coord(painter.position)
	use_eraser()
	var ea = load("res://scenes/ball_eater.scn").instance()
	pole.add_child(ea)
	ea.global_position = pole.to_center(paint_pos)

#инструмент расставления эмиттера
func place_emitter():
	if not painter.visible: return
	var paint_pos = pole.get_cell_coord(painter.position)
	use_eraser()
	var em = load("res://scenes/ball_emitter.scn").instance()
	pole.add_child(em)
	em.global_position = pole.to_center(paint_pos)

#инструмент расставления тайлов
func place_fig():
	if not painter.visible: return
	var paint_pos = pole.get_cell_coord(painter.position)
	use_eraser()
	pole.set_cell_type(paint_pos, fig_cell)

#а дальше пошли обработчики кнопок.
#Я сделал тачевые кнопки, чтобы сразу заложить совместимость.
func button_eater():
	if painter_mode != "eater" or not painter.visible:
		painter_mode = "eater"
		painter.visible = true
	else:
		painter.visible = false
	painter.texture = eater.normal
	painter.region_enabled = false


func button_emitter():
	if painter_mode != "emitter" or not painter.visible:
		painter_mode = "emitter"
		painter.visible = true
	else:
		painter.visible = false
	painter.texture = emitter.normal
	painter.region_enabled = false


func button_placer():
	if painter_mode != "placer" or not painter.visible:
		painter_mode = "placer"
		painter.visible = true
	else:
		painter.visible = false
	painter.texture = fig.texture
	painter.region_enabled = fig.region_enabled
	painter.region_rect = fig.region_rect


func button_erase():
	if painter_mode != "eraser" or not painter.visible:
		painter_mode = "eraser"
		painter.visible = true
	else:
		painter.visible = false
	painter.texture = erase.normal
	painter.region_enabled = false


func button_rotate_right():
	fig_cell = pole.rotate_cell(fig_cell, false)
	fig.region_rect = Rect2(fig_cell * 32, Vector2(32, 32))
	painter.region_rect = fig.region_rect


func button_rotate_left():
	fig_cell = pole.rotate_cell(fig_cell, true)
	fig.region_rect = Rect2(fig_cell * 32, Vector2(32, 32))
	painter.region_rect = fig.region_rect


func button_next_fig():
	fig_cell = pole.shift_cell(fig_cell, true)
	fig.region_rect = Rect2(fig_cell * 32, Vector2(32, 32))
	painter.region_rect = fig.region_rect


func button_prev_fig():
	fig_cell = pole.shift_cell(fig_cell, false)
	fig.region_rect = Rect2(fig_cell * 32, Vector2(32, 32))
	painter.region_rect = fig.region_rect

func mouse_on_palette() -> bool:
	return mouse_pos.x > palette.global_position.x - palette_size.x and \
	mouse_pos.y < palette.global_position.y + palette_size.y and \
	mouse_pos.x < palette.global_position.x + palette_size.x and \
	mouse_pos.y > palette.global_position.y

func mouse_on_header() -> bool:
	return mouse_pos.x > palette.global_position.x - palette_size.x and \
	mouse_pos.y < palette.global_position.y + 16 and \
	mouse_pos.x < palette.global_position.x + palette_size.x and \
	mouse_pos.y > palette.global_position.y

func button_go():
	for child in pole.get_children():
		if child.has_method("emit_ball"): child.emit_ball()


func button_killballs():
	for child in pole.get_children():
		if child.has_method("disappear"): child.disappear()


func button_clear():
	pole.clear_pole()


func button_save():
	pole.quicksave()


func button_load():
	pole.quickload()


func button_mute():
	g.mute()


func button_pause():
	g.pause()
