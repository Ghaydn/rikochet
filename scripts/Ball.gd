extends KinematicBody2D
#Наш шарик, который движется.
#Он кинематик из соображений расширяемости

export(float, 10, 10000) var speed
export(int, 0, 3) var direction setget set_dir
var past_direction: int
onready var pole = get_parent()
var velocity
var current_cell: Vector2 = Vector2(-1, -1)
var current_cell_center: Vector2
var past_position: Vector2
var cell_visited: bool


onready var triangle_sound   = $sounds/triangle
onready var flag_sound       = $sounds/flag
onready var pass_sound       = $sounds/pass

#если шарик исчезает, ему надо сначала избавиться от камеры
func disappear():
	for cam in get_children():
		if cam.has_method("reparent"):
			cam.reparent(self)
	queue_free()

func set_dir(dir: int):
	dir = wrapi(dir, 0, 4)
	direction = dir

#У шарика есть физикс-процес! Ещё он есть у камеры и больше ни у кого.
func _physics_process(delta):
	#Скорость движения постоянна, выбираем только направление
	match direction:
		0: velocity = Vector2(speed, 0)
		1: velocity = Vector2(0, speed)
		2: velocity = Vector2(-speed, 0)
		3: velocity = Vector2(0, -speed)
	
	
	var cell_coord
	var cell
	
	#добываем свои координаты и тип клетки под ними
	if pole.has_method("get_cell_coord"):
		cell_coord = pole.get_cell_coord(global_position)
	if pole.has_method("get_cell_type"):
		cell = pole.get_cell_type(cell_coord)
	
	if cell_coord != current_cell:
		cell_visited = false
		current_cell = cell_coord
		if pole.has_method("to_center"):
			current_cell_center = pole.to_center(current_cell)
	
	move_and_collide(velocity * delta)
	
	if not pole.get_rect().has_point(pole.get_cell_coord(global_position)):
		print("ball ", self, " out of bounds, disappear. Position: ", position)
		disappear()
	
	if past_position.distance_to(current_cell_center) < global_position.distance_to(current_cell_center) and not cell_visited:
		if pole.has_method("has_something"):
			if pole.has_something(current_cell):
				past_direction = direction
				#тут сначала было просто изменение направления,
				#но потом добавились ещё звуки.
				direction = pole.hit_cell(cell_coord, direction)
				match int(abs(direction - past_direction)):
					0:
						pass_sound.pitch_scale = f.random(0.9, 1.1)
						pass_sound.play()
					2:
						flag_sound.pitch_scale = f.random(0.9, 1.1)
						flag_sound.play()
					_:
						triangle_sound.pitch_scale = f.random(0.9, 1.1)
						triangle_sound.play()
					
				
				global_position = current_cell_center
				cell_visited = true
	past_position = global_position
