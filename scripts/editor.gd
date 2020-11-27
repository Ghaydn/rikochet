extends Node2D
#Эта нода, будучи добавленной к полю, позволяет его редактировать.
#Без редактора невозможно ни крутить треугольники на поле, ни даже вручную запускать шары.

var mouse_pos: Vector2
var mouse_on_pole: Vector2
onready var painter = $painter

var fig_cell: Vector2 = Vector2.ZERO
var painter_mode: String
var emitter_dir: int
var emitter_speed: int = 5
var press_pos: Vector2
var touch_drag: bool

func _ready():
	if g.editor == null: g.editor = self

#В инпуте у нас только инпуты и вызовы соответствующих функций
func _unhandled_input(event):
	#print(event.as_text())
	mouse_pos = get_global_mouse_position()
	mouse_on_pole = g.pole.get_cell_coord(mouse_pos)
	
	if event is InputEventScreenDrag:
		touch_drag = true

	if Input.is_action_just_pressed("quicksave"):
		g.quicksave()
	
	if Input.is_action_just_pressed("quickload"):
		g.quickload()
		
	if Input.is_action_just_pressed("clear"):
		g.pole.clear_pole()
	
	if event is InputEventMouseMotion:
		painter.position = g.pole.to_center(mouse_on_pole)
	
	#if painter.visible:
	if not Input.is_action_pressed("ctrl"):
		if Input.is_action_just_pressed("scroll_up"):
			if Input.is_action_pressed("shift"):
				if painter.visible:
					button_next_fig()
			else:
				if painter.visible:
					button_rotate_right()
		if Input.is_action_just_pressed("scroll_down"):
			if Input.is_action_pressed("shift"):
				if painter.visible:
					button_prev_fig()
			else:
				if painter.visible:
					button_rotate_left()
	
		if event.is_action_pressed("place"):
			press_pos = g.pole.to_center(mouse_on_pole)
			if not event is InputEventScreenTouch: touch_drag = false
			
		if event.is_action_released("place"):
			if not touch_drag:
				painter.position = g.pole.to_center(mouse_on_pole)
				if painter.visible: use_painter()
				else:
					var emitt = g.pole.find_emitter(mouse_on_pole)
					if emitt != null: emitt.emit_ball()
			if event is InputEventScreenTouch: touch_drag = false

		if Input.is_action_pressed("erase"):
			painter.position = g.pole.to_center(mouse_on_pole)
			if painter.visible: use_eraser()
		

	#if not Input.is_action_pressed("ctrl"):
		#if g.pole.has_something(mouse_on_pole):
		if Input.is_action_just_pressed("scroll_up"):
			if Input.is_action_pressed("shift"):
				if not painter.visible:
					g.pole.shift_selected_cell(mouse_on_pole, true)
			else:
				if not painter.visible:
					g.pole.rotate_selected_cell(mouse_on_pole, false)
				
		if Input.is_action_just_pressed("scroll_down"):
			if Input.is_action_pressed("shift"):
				if not painter.visible:
					g.pole.shift_selected_cell(mouse_on_pole, false)
			else:
				if not painter.visible:
					g.pole.rotate_selected_cell(mouse_on_pole, true)
	
	if event.is_action_pressed("ui_cancel"):
		if g.help_panel.visible: g.help_panel.hide_help()
		elif painter.visible: painter.visible = false
		else: g.quit()
	
	if event.is_action_pressed("eraser_tool"):
		button_erase()
	
	if event.is_action_pressed("pencil_tool"):
		button_placer()
	
	if event.is_action_pressed("emitter_tool"):
		button_emitter()
	
	if event.is_action_pressed("launch_all"):
		button_go()
	
	if event.is_action_pressed("help"):
		g.interface.button_help()
	
	if event.is_action_pressed("killballs"):
		button_killballs()
	
	if event.is_action_pressed("erase_all"):
		button_clear()

#если у нас активен какой-то инструмент, то мы используем его.
#Если никакой не активен, то никакой не используем.
func use_painter():
	if not painter.visible: return
	match painter_mode:
		"eraser": use_eraser()
		"eater": place_eater()
		"emitter": place_emitter()
		"placer": place_fig()

#Вот тут мы используем стёрку.
#Наверное, стоило бы передавать координаты в аргументе, а не считать их каждый раз...
func use_eraser():
	if not painter.visible: return
	var paint_pos = g.pole.get_cell_coord(painter.position)
	g.pole.erase_cell(paint_pos)
	
	var eater = g.pole.find_eater(paint_pos)
	if eater != null: eater.queue_free()
	var emitter = g.pole.find_emitter(paint_pos)
	if emitter != null: emitter.queue_free()

#инструмент расставления поедателя
func place_eater():
	if not painter.visible: return
	var paint_pos = g.pole.get_cell_coord(painter.position)
	use_eraser()
	var ea = r.eater.instance()
	g.pole.add_child(ea)
	ea.position = g.pole.to_center(paint_pos)

#инструмент расставления эмиттера
func place_emitter():
	if not painter.visible: return
	var paint_pos = g.pole.get_cell_coord(painter.position)
	use_eraser()
	var em = r.emitter.instance()
	g.pole.add_child(em)
	em.position = g.pole.to_center(paint_pos)
	em.set_dir(emitter_dir)
	em.set_speed(emitter_speed * 100)

#инструмент расставления тайлов
func place_fig():
	if not painter.visible: return
	var paint_pos = g.pole.get_cell_coord(painter.position)
	use_eraser()
	g.pole.set_cell_type(paint_pos, fig_cell)

#а дальше пошли обработчики кнопок.
#Я сделал тачевые кнопки, чтобы сразу заложить совместимость.
func button_eater():
	if painter_mode != "eater" or not painter.visible:
		painter_mode = "eater"
		painter.rotation_degrees = 0
		painter.visible = true
	else:
		painter.visible = false
	painter.texture = r.eater_image
	painter.region_enabled = false

func button_emitter():
	if painter_mode != "emitter" or not painter.visible:
		painter_mode = "emitter"
		painter.rotation_degrees = emitter_dir * 90
		painter.visible = true
	else:
		painter.visible = false
	painter.texture = r.emitter_image
	painter.region_enabled = false

func button_placer():
	if painter_mode != "placer" or not painter.visible:
		painter_mode = "placer"
		painter.rotation_degrees = 0
		painter.visible = true
	else:
		painter.visible = false
	painter.texture = r.tilemap_image
	painter.region_enabled = true
	painter.region_rect = Rect2(fig_cell * 32, Vector2(32, 32))

func button_erase():
	if painter_mode != "eraser" or not painter.visible:
		painter_mode = "eraser"
		painter.rotation_degrees = 0
		painter.visible = true
	else:
		painter.visible = false
	painter.texture = r.eraser_image
	painter.region_enabled = false

func button_rotate_right():
	emitter_dir = wrapi(emitter_dir + 1, 0, 4)
	g.interface.set_emitter_rotation(emitter_dir * 90)
	#if painter_mode == "emitter":
	fig_cell = g.pole.rotate_cell(fig_cell, false)
	if painter_mode == "emitter":
		painter.rotation_degrees = emitter_dir * 90
	else:
		painter.region_rect = Rect2(fig_cell * 32, Vector2(32, 32))
	g.interface.set_fig_rect(Rect2(fig_cell * 32, Vector2(32, 32)))

func button_rotate_left():
	emitter_dir = wrapi(emitter_dir - 1, 0, 4)
	g.interface.set_emitter_rotation(emitter_dir * 90)
	#if painter_mode == "emitter":
	fig_cell = g.pole.rotate_cell(fig_cell, true)
	if painter_mode == "emitter":
		painter.rotation_degrees = emitter_dir * 90
	else:
		painter.region_rect = Rect2(fig_cell * 32, Vector2(32, 32))
	g.interface.set_fig_rect(Rect2(fig_cell * 32, Vector2(32, 32)))

func button_next_fig():
	fig_cell = g.pole.shift_cell(fig_cell, true)
	g.interface.set_fig_rect(Rect2(fig_cell * 32, Vector2(32, 32)))
	painter.region_rect = Rect2(fig_cell * 32, Vector2(32, 32))
	emitter_speed = clamp(emitter_speed + 1, 1, 10)
	g.interface.set_emitter_color(Color.from_hsv(0, float(emitter_speed) / 10, 1.0))

func button_prev_fig():
	fig_cell = g.pole.shift_cell(fig_cell, false)
	g.interface.set_fig_rect(Rect2(fig_cell * 32, Vector2(32, 32)))
	painter.region_rect = Rect2(fig_cell * 32, Vector2(32, 32))
	emitter_speed = clamp(emitter_speed - 1, 1, 10)
	g.interface.set_emitter_color(Color.from_hsv(0, float(emitter_speed) / 10, 1.0))

func button_go():
	g.pole.launch_all()

func button_killballs():
	for child in g.pole.get_children():
		if child.has_method("disappear"): child.disappear()

func button_clear():
	g.pole.clear_pole()
