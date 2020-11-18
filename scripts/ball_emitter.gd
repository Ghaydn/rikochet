tool #нужен, чтобы корректно работал поворот через direction
extends Sprite
#Эмиттер выпускает шарики.

export(int, 0, 3) var direction setget set_dir 
export(float, 0, 10000) var ball_speed #запускает шары с разной скоростью.
export(bool) var autostart #запустит шар сразу после входа в дерево
onready var pole = get_parent()

#Сердце и самая суть.
func emit_ball():
	if Engine.editor_hint: return #не надо нам этого в редакторе
	var ball = load("res://scenes/ball.scn").instance() #это не юзерский файл, так что без него пусть падает с ошибкой
	pole.call_deferred("add_child", ball) #потокобезопасно
	ball.direction = direction
	ball.position = position
	ball.speed = ball_speed
	ball.modulate = Color.from_hsv(randf(), 0.5, 1.0)#случайные цвета шариков для красоты
	$emit_sound.play()

#при задании направления поворачивает сам объект
func set_dir(dir: int):
	#pole.get_node("ball").queue_free()
	dir = wrapi(dir, 0, 4)
	rotation_degrees = dir * 90
	direction = dir

func _ready():
	if Engine.editor_hint: return
	if autostart: emit_ball()
