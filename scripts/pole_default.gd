extends TileMap

onready var s1 = $sounds/sound1
onready var s2 = $sounds/sound2

func _ready():
	g.pole = self

func hit_cell(cell_coord: Vector2, dir: int):
	var cell = get_cell_type(cell_coord)
	if get_cellv(cell_coord) == INVALID_CELL: return
	if not(cell is Vector2): return
	s1.global_position = to_center(cell_coord)
	s2.global_position = to_center(cell_coord)
	set_cell_type(cell_coord, change_cell(cell, dir))
	return change_direction(cell, dir)

#эта функция отвечает, в какую сторону полетит шарик, налетевший
#на заданную фигуру в заданном направлении
func change_direction(cell: Vector2, dir: int) -> int:
	if dir < 0 or dir >= 4: dir = wrapi(dir, 0, 4) #предохранитель
	
	var shift = int(cell.x) % 4 #смещение направления фигуры по часовой стрелке
	var dir_matrix: PoolIntArray #матрица смещения по четырём направлениям
	#этих матриц ограниченное количество.
	var matrix_1_triangle = f.array4x(-1, 1, 0, 0)
	var matrix_1_flag = f.array4x(2, 0, 0, 0)
	var matrix_1b_triangle = f.array4x(1, 0, 0, -1)
	var matrix_2_1 = f.array4x(2, 1, 0, -1)
	var matrix_2_2 = f.array4x(2, 1, 0, 0)
	var matrix_2_3 = f.array4x(2, 0, 0, -1)
	
	#теперь смотрим на положение фигуры в тайлсете и выбираем матрицу
	if cell.y < 4:
		if cell.x < 4 or (cell.x >= 8 and cell.x < 16):
			dir_matrix = matrix_1_triangle
		elif (cell.x >= 4 and cell.x < 8) or (cell.x >= 16 and cell.x < 20):
			dir_matrix = matrix_1_flag
		elif (cell.x >= 20 and cell.x < 24):
			dir_matrix = matrix_2_1
		elif (cell.x >= 24 and cell.x < 28):
			dir_matrix = matrix_2_2
		elif (cell.x >= 28 and cell.x < 32):
			dir_matrix = matrix_2_3
		elif (cell.x >= 32 and cell.x < 36 and int(cell.y) == 0):
			dir_matrix = matrix_1_triangle
		elif (cell.x >= 36 and cell.x < 40 and int(cell.y) == 0):
			dir_matrix = matrix_1_flag
		else:
			return dir
	else:
		if cell.x >= 8 and cell.x < 20:
			if cell.x >= 12 and cell.x < 16:
				dir_matrix = matrix_1_flag
			else:
				dir_matrix = matrix_1b_triangle
		else:
			return dir
	
	#и применяем матрицу к значению направления, прибавив смещение
	dir = wrapi(dir + dir_matrix[(dir + shift) % 4], 0, 4)
	return dir

#Эта функция отвечает, как изменится фигура после взаимодействия
#с шариком, налетевшим в заданном направлении.
#Из-за того, что я не нашёл способа легко и понятно расположить
#фигуры в тайлсете, я их расположил максимально логично, как мог,
#а дальше был выбор: подгружать индивидуально параметры каждой фигуры
#из файла-таблицы или прописать ветвлением в коде. Выбор пал на второй
#вариант. Переделать на первый можно будет только если в таблице
#будет также храниться и картинка
func change_cell(cell: Vector2, dir: int) -> Vector2:
	if dir < 0 or dir >= 4: dir = wrapi(dir, 0, 4)#предохранитель
	
	var shift = int(cell.x) % 4 #смещение направления фигуры по часовой стрелке
	var change: Vector2 #чаще всего достаточно указать только одно изменение
	var change_matrix: PoolVector2Array #но вообще-то нужна целая матрица, так как
		#изменение зависит от направления
	
	var template: PoolIntArray #Шаблон показывает, какие направления изменяют фигуру
	#он у нас интовый, а не булевский, потому что так нагляднее
	var template_triangle = f.array4x(1, 1, 0, 0)
	var template_flag = f.array4x(1, 0, 0, 0)
	var template_second = f.array4x(1, 0, 0, 1)
	var template_special = f.array4x(1, 1, 0, 1)
	
	#звуки пришлось впихивать в уже готовую систему.
	var sound_1: String
	var sound_2: String
	
	#Выбираем изменение цвета. Для сложных фигур - сразу матрицу.
	#Здесь же задаём тип звука, если он вообще есть.
	if cell.x < 8:
		match int(cell.y):
			0: change = Vector2(0, 0)
			1:
				sound_1 = "deactivate"
				change = Vector2(0, 6)
			2:
				sound_1 = "deactivate"
				change = Vector2(0, -1)
			3:
				sound_1 = "deactivate"
				change = Vector2(0, -1)
			4:
				sound_1 = "activate"
				change = Vector2(0, -4)
			5:
				sound_1 = "activate"
				change = Vector2(0, -1)
			6:
				sound_1 = "activate"
				change = Vector2(0, -1)
			7: change = Vector2(0, 0)
	elif cell.x >= 8 and cell.x < 20:
		match int(cell.y):
			0:
				sound_2 = "activate"
				change = Vector2(12, 0)
			1: change = Vector2(0, 0)
			2:
				change = Vector2(0, 0)
				sound_1 = "deactivate"
				sound_2 = "activate"
				if cell.x < 12:
					change_matrix = f.array8x(0, 3, 12, 4, 0, 0, 12, 0)
				elif cell.x >= 12 and cell.x < 16:
					change_matrix = f.array8x(0, 3, 12, 4, 0, 0, 0, 0)
				else:
					change_matrix = f.array8x(0, 3, 0, 0, 0, 0, 12, 0)
			3:
				sound_1 = "deactivate"
				change = Vector2(12, 4)
			4:
				sound_1 = "activate"
				change = Vector2(12, -4)
			5: change = Vector2(0, 0)
			6: 
				change = Vector2(0, 0)
				sound_1 = "activate"
				sound_2 = "deactivate"
				if cell.x < 12:
					change_matrix = f.array8x(0, -5, 12, -5, 0, 0, 12, -1)
				elif cell.x >= 12 and cell.x < 16:
					change_matrix = f.array8x(0, -5, 12, -5, 0, 0, 0, 0)
				else:
					change_matrix = f.array8x(0, -5, 0, 0, 0, 0, 12, -1)
			7:
				sound_2 = "deactivate"
				change = Vector2(12, 0)
	elif cell.x >= 20 and cell.x < 32:
		match int(cell.y):
			0: change = Vector2(0, 0)
			1:
				sound_2 = "deactivate"
				change = Vector2(-12, 0)
			2:
				sound_1 = "deactivate"
				change = Vector2(-12, 3)
			3: 
				sound_1 = "deactivate"
				sound_2 = "deactivate"
				change = Vector2(0, 0)
				if cell.x < 24:
					change_matrix = f.array8x(0, 4, -12, 4, 0, 0, -12, 0)
				elif cell.x >= 24 and cell.x < 28:
					change_matrix = f.array8x(0, 4, -12, 4, 0, 0, 0, 0)
				else:
					change_matrix = f.array8x(0, 4, 0, 0, 0, 0, -12, 0)
			4: 
				sound_1 = "activate"
				sound_2 = "activate"
				change = Vector2(0, 0)
				if cell.x < 24:
					change_matrix = f.array8x(0, -4, -12, -5, 0, 0, -12, 0)
				elif cell.x >= 24 and cell.x < 28:
					change_matrix = f.array8x(0, -4, -12, -5, 0, 0, 0, 0)
				else:
					change_matrix = f.array8x(0, -4, 0, 0, 0, 0, -12, 0)
			5:
				sound_1 = "activate"
				change = Vector2(-12, -4)
			6:
				sound_2 = "activate"
				change = Vector2(-12, -1)
			7:
				sound_1 = ""
				sound_2 = ""
				change = Vector2(0, 0)
	elif cell.x >= 32 and cell.x < 40:
		match int(cell.y):
			0:
				sound_1 = "activate"
				change = Vector2(0, 1)
			1:
				sound_1 = "deactivate"
				change = Vector2(0, -1)
	else: return cell
	
	#Выбираем шаблон, согласно которому будем позже стирать значения из матрицы
	if cell.x < 8:
		if cell.y >= 1 and cell.y < 7:
			if cell.x < 4: template = template_triangle
			else: template = template_flag
		else: return cell
	elif cell.x >= 8 and cell.x < 20:
		if int(cell.y) % 4 == 1: return cell
		elif int(cell.y) % 4 == 2: template = template_special
		else:
			if cell.y < 1 or cell.y >= 7:
				if cell.x >= 12 and cell.x < 16: template = template_flag
				else: template = template_second
			else:
				if cell.x >= 16: template = template_flag
				else: template = template_triangle
	elif cell.x >= 20 and cell.x < 32:
		if cell.y >= 1 or cell.y < 7:
			if cell.y >= 3 and cell.y < 5: template = template_special
			elif cell.y < 2 or cell.y >= 6:
				if cell.x < 24 or cell.x >= 28: template = template_second
				else: template = template_flag
			else:
				if cell.x >= 28: template = template_flag
				else: template = template_triangle
		else: return cell
	elif cell.x >= 32:
		if int(cell.y == 0) or int(cell.y == 1):
			if cell.x < 36: template = template_triangle
			else: template = template_flag
		else: return cell

	#проверяем, что матрица не особая, по особому шаблону
	#Особые матрицы уже заполнены. А вот обычные заполняем здесь.
	if template != template_special:
		change_matrix = f.array4vect(change, change, change, change)
	
	#и применяем шаблон
	for i in range(4):
		change_matrix[i] *= template[i]
	change_matrix = f.shift_array(change_matrix, shift)
	
	#теперь заполняем звуковые матрицы. Они проще распределены.
	var sound_matrix = []
	var col: int = floor(cell.x / 4) * 4
	match col:
		0: sound_matrix = f.shift_array(f.array4x(1, 1, 0, 0), shift)
		4: sound_matrix = f.shift_array(f.array4x(1, 0, 0, 0), shift)
		8: sound_matrix = f.shift_array(f.array4x(2, 1, 0, 3), shift)
		12: sound_matrix = f.shift_array(f.array4x(2, 1, 0, 0), shift)
		16: sound_matrix = f.shift_array(f.array4x(2, 0, 0, 3), shift)
		20: sound_matrix = f.shift_array(f.array4x(2, 1, 0, 3), shift)
		24: sound_matrix = f.shift_array(f.array4x(2, 1, 0, 0), shift)
		28: sound_matrix = f.shift_array(f.array4x(2, 0, 0, 3), shift)
		32: sound_matrix = f.shift_array(f.array4x(1, 1, 0, 0), shift)
		36: sound_matrix = f.shift_array(f.array4x(1, 0, 0, 0), shift)
		
	#теперь подгружаем нужные звуки, но только если они должны
	#прозвучать. Если же нет - выгружаем, несмотря на протесты.
	if sound_1 == "activate" or sound_1 == "deactivate":
		s1.stream = load("res://sounds/" + sound_1 + ".wav")
	else:
		if sound_matrix[dir] == 1 or sound_matrix[dir] == 2:
			s1.stream = null
	if sound_2 == "activate" or sound_2 == "deactivate":
		s2.stream = load("res://sounds/" + sound_2 + ".wav")
	else:
		if sound_matrix[dir] == 3 or sound_matrix[dir] == 2:
			s2.stream = null
	
	#случайная высота придаст живости
	s1.pitch_scale = f.random(0.95, 1.05)
	s2.pitch_scale = f.random(0.95, 1.05)

	#и воспроизводим набор звуков, указанный в матрице по данному направлению
	match sound_matrix[dir]:
		1: s1.play()
		2:
			s1.play()
			s2.play()
		3: s2.play()
	
	#да, теперь можно и результат вернуть.
	#Мы же там фигуру после столкновения меняли
	return cell + change_matrix[dir]
	#TODO: отделить звук от изменения фигуры

#эта функция поворачивает конкретную клетку на поле, по координатам.
#на самом деле просто вызывает следующую
func rotate_selected_cell(coord: Vector2, forward: bool = true):
	var cell_type = get_cell_type(coord)
	set_cell_type(coord, rotate_cell(cell_type, forward))

#эта функция говорит, какая фигура получится после поворота.
#полезно для редактирования.
func rotate_cell(cell_type: Vector2, forward: bool = true) -> Vector2:
	var cell = cell_type
	
	var shift = int(cell.x) % 4
	var base = int(cell.x) - int(cell.x) % 4
	
	if forward: shift = (shift + 1) % 4
	else: shift = wrapi(shift - 1, 0, 4)
	
	return Vector2(base + shift, cell.y)


#эта функция меняет тип конкретной клетки на поле, по координатам.
#на самом деле просто вызывает следующую
func shift_selected_cell(coord: Vector2, forward: bool = true):
	var cell_type = get_cell_type(coord)
	set_cell_type(coord, shift_cell(cell_type, forward))


#эта функция говорит, какая фигура получится следующего или предыдущего
#типа. Полезно для редактирования.
func shift_cell(cell_type: Vector2, forward: bool = true) -> Vector2:
	var cell = cell_type #алиас для короткости.
	var shift: Vector2 #собственно вектор, на который изменится положение фигуры внутри тайлсета
	var col: int = floor(cell.x / 4) * 4 #считаем колонку в тайлсете
	#и выбираем вектор изменения
	match col:
		0:
			if int(cell.y) == 0:
				if forward: shift = Vector2(4, 0)
				else: shift = Vector2(36, 1)
			else:
				if forward: shift = Vector2(4, 0)
				else: shift = Vector2(4, -1)
		4:
			if int(cell.y) == 7:
				if forward: shift = Vector2(4, -7)
				else: shift = Vector2(-4, 0)
			else:
				if forward: shift = Vector2(-4, 1)
				else: shift = Vector2(-4, 0)
		8:
			if int(cell.y) == 0:
				if forward: shift = Vector2(4, 0)
				else: shift = Vector2(-4, 7)
			else:
				if forward: shift = Vector2(4, 0)
				else: shift = Vector2(8, -1)
		12:
			if forward: shift = Vector2(4, 0)
			else: shift = Vector2(-4, 0)
		16:
			if int(cell.y) == 7:
				if forward: shift = Vector2(4, -7)
				else: shift = Vector2(-4, 0)
			else:
				if forward: shift = Vector2(-8, 1)
				else: shift = Vector2(-4, 0)
		20:
			if int(cell.y) == 0:
				if forward: shift = Vector2(4, 0)
				else: shift = Vector2(-4, 7)
			else:
				if forward: shift = Vector2(4, 0)
				else: shift = Vector2(8, -1)
		24:
			if forward: shift = Vector2(4, 0)
			else: shift = Vector2(-4, 0)
		28:
			if int(cell.y) == 7:
				if forward: shift = Vector2(4, -7)
				else: shift = Vector2(-4, 0)
			else:
				if forward: shift = Vector2(-8, 1)
				else: shift = Vector2(-4, 0)
		32:
			if int(cell.y) == 0:
				if forward: shift = Vector2(4, 0)
				else: shift = Vector2(-4, 7)
			else:
				if forward: shift = Vector2(4, 0)
				else: shift = Vector2(4, -1)
		36:
			if int(cell.y) == 1:
				if forward: shift = Vector2(-36, -1)
				else: shift = Vector2(-4, 0)
			else:
				if forward: shift = Vector2(-4, 1)
				else: shift = Vector2(-4, 0)
		_: shift = Vector2.ZERO
	
	#и всё, осталось только прибавить вектор изменения к исходной фигуре
	return cell + shift

#алиасы, чтобы можно было заменить модуль поля на не-тайлмап
#Во имя duck-typing!
func get_cell_coord(pos: Vector2) -> Vector2:
	return world_to_map(pos)

func get_cell_type(coord: Vector2) -> Vector2:
	return get_cell_autotile_coord(coord.x, coord.y)
	

func set_cell_type(coord: Vector2, type: Vector2):
	set_cell(coord.x, coord.y, 0, false, false, false, type)

func erase_cell(coord: Vector2):
	set_cellv(coord, -1)

func to_center(pos: Vector2) -> Vector2:
	return map_to_world(pos) + cell_size / 2

func has_something(coord: Vector2) -> bool:
	return get_cellv(coord) != INVALID_CELL

func get_rect():
	return get_used_rect()
#вот и все алиасы


#находим эмиттер в указанных координатах с использованием утиной типизации
func find_emitter(coord: Vector2):
	for child in get_children():
		if child.has_method("emit_ball"):
			if child.position.x >= coord.x * cell_size.x and \
			child.position.y >= coord.y * cell_size.y and \
			child.position.x < (coord.x + 1) * cell_size.x and \
			child.position.y < (coord.y + 1) * cell_size.y:
				return child
	return null

#так же находим поедатель.
func find_eater(coord: Vector2):
	for child in get_children():
		if child.has_method("eat_ball"):
			if child.position.x >= coord.x * cell_size.x and \
			child.position.y >= coord.y * cell_size.y and \
			child.position.x < (coord.x + 1) * cell_size.x and \
			child.position.y < (coord.y + 1) * cell_size.y:
				return child
	return null

#алиас для очистки тайлсета, заодно удаляющий остальные игровые объекты
func clear_pole():
	clear()
	for child in get_children():
		if child.has_method("emit_ball") or \
		child.has_method("eat_ball"):
			child.queue_free()
		if child.has_method("disappear"):
			child.disappear()
