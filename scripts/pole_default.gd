extends TileMap
#In fact, this is not a pole, but a field,
#it's just that I'm used to calling it in all my programs

onready var s1 = $sounds/sound1
onready var s2 = $sounds/sound2

func _ready():
	g.pole = self
	g.cs = cell_size

func hit_cell(cell_coord: Vector2, dir: int):
	var cell = get_cell_type(cell_coord)
	if get_cellv(cell_coord) == INVALID_CELL: return
	if not(cell is Vector2): return
	s1.global_position = to_center(cell_coord)
	s2.global_position = to_center(cell_coord)
	set_cell_type(cell_coord, change_cell(cell, dir))
	return change_direction(cell, dir)

#this function answers in which direction the ball will fly
#when it hits a given figure in a given direction
func change_direction(cell: Vector2, dir: int) -> int:
	if dir < 0 or dir >= 4: dir = wrapi(dir, 0, 4) #cutout
	
	var shift = int(cell.x) % 4 #clockwise direction shift
	var dir_matrix: PoolIntArray #4-way offset matrix
	#a limited number of these matrices.
	var matrix_1_triangle = f.array4x(-1, 1, 0, 0)
	var matrix_1_flag = f.array4x(2, 0, 0, 0)
	var matrix_1b_triangle = f.array4x(1, 0, 0, -1)
	var matrix_2_1 = f.array4x(2, 1, 0, -1)
	var matrix_2_2 = f.array4x(2, 1, 0, 0)
	var matrix_2_3 = f.array4x(2, 0, 0, -1)
	
	#now we look at the position of the figure in the tileset and select the matrix
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
		elif cell.x >= 32 and cell.x < 36:
			if int(cell.y) == 1:
				return dir
			else:
				dir_matrix = matrix_1_triangle
		elif cell.x >= 36 and cell.x < 40:
			if int(cell.y) == 1:
				return dir
			else:
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
	
	#and apply a matrix to the direction value by adding an offset
	dir = wrapi(dir + dir_matrix[(dir + shift) % 4], 0, 4)
	return dir

#This function answers how the shape will change after interacting
#with a ball that has flown in a given direction. Due to the fact
#that I did not find a way to easily and clearly arrange the figures
#in the tileset, I arranged them as logically as I could, and then
#there was a choice: to load individually the parameters of each
#figure from a table file or to register them by branching in the
#code. The choice fell on the second option. It will be possible to
#convert to the first one only if the picture is also stored in the
#table
func change_cell(cell: Vector2, dir: int) -> Vector2:
	if dir < 0 or dir >= 4: dir = wrapi(dir, 0, 4)#cutout
	
	var shift = int(cell.x) % 4 #shift the direction of the shape clockwise
	var change: Vector2 #most often it is enough to specify only one change
	var change_matrix: PoolVector2Array #but actually a whole matrix is needed,
	#since the change depends on the direction
	
	var template: PoolIntArray #The template shows which directions change the shape
	#we have it int, not boolean, because it is clearer
	var template_triangle = f.array4x(1, 1, 0, 0)
	var template_flag = f.array4x(1, 0, 0, 0)
	var template_second = f.array4x(1, 0, 0, 1)
	var template_special = f.array4x(1, 1, 0, 1)
	
	#I had to cram the sounds into a ready-made system.
	var sound_1: String
	var sound_2: String
	
	#Choosing a color change. For complex shapes, select the matrix immediately.
	#Here we also set the type of sound, if any.
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
			2: #Swiveling triangles are an exception
				s1.stream = r.turn_right_sound
				s1.pitch_scale = f.random(0.95, 1.05)
				s2.stream = null
				if cell.x < 36:
					match shift:
						0: if dir == 0 or dir == 1:
							s1.play()
							return cell + Vector2(3, 0)
						1: if dir == 3 or dir == 0:
							s1.play()
							return cell + Vector2(-1, 0)
						2: if dir == 2 or dir == 3:
							s1.play()
							return cell + Vector2(-1, 0)
						3: if dir == 1 or dir == 2:
							s1.play()
							return cell + Vector2(-1, 0)
				else:
					match shift:
						0: if dir == 0:
							s1.play()
							return cell + Vector2(3, 0)
						1: if dir == 3:
							s1.play()
							return cell + Vector2(-1, 0)
						2: if dir == 2:
							s1.play()
							return cell + Vector2(-1, 0)
						3: if dir == 1:
							s1.play()
							return cell + Vector2(-1, 0)
				s1.stream = null
				s2.stream = null
				return cell
			3:
				s1.stream = r.turn_left_sound
				s1.pitch_scale = f.random(0.95, 1.05)
				s2.stream = null
				#s1.play()
				if cell.x < 36:
					match shift:
						0: if dir == 0 or dir == 1:
							s1.play()
							return cell + Vector2(1, 0)
						1: if dir == 3 or dir == 0:
							s1.play()
							return cell + Vector2(1, 0)
						2: if dir == 2 or dir == 3:
							s1.play()
							return cell + Vector2(1, 0)
						3: if dir == 1 or dir == 2:
							s1.play()
							return cell + Vector2(-3, 0)
				else:
					match shift:
						0: if dir == 0:
							s1.play()
							return cell + Vector2(1, 0)
						1: if dir == 3:
							s1.play()
							return cell + Vector2(1, 0)
						2: if dir == 2:
							s1.play()
							return cell + Vector2(1, 0)
						3: if dir == 1:
							s1.play()
							return cell + Vector2(-3, 0)
				
				s1.stream = null
				s2.stream = null
				return cell
	else: return cell
	
	#We choose a template according to which we will later erase values from the matrix
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
		elif int(cell.y == 2) or int(cell.y == 3):
			template = template_special
		else: return cell

	#check that the matrix is not special, according to a special template
	#The special matrices are already filled in. But we fill in the usual ones here.
	if template != template_special:
		change_matrix = f.array4vect(change, change, change, change)
	
	#and apply the template
	for i in range(4):
		change_matrix[i] *= template[i]
	change_matrix = f.shift_array(change_matrix, shift)
	
	#now we fill in the sound matrices. They are easier to distribute.
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
		
	#now we load the necessary sounds, but only if they should sound.
	#If not, we unload, despite the protests.
	if sound_1 == "activate":
		s1.stream = r.activate_sound
	elif sound_1 == "deactivate":
		s1.stream = r.deactivate_sound
	else:
		if sound_matrix[dir] == 1 or sound_matrix[dir] == 2:
			s1.stream = null
	if sound_2 == "activate":
		s2.stream = r.activate_sound
	elif sound_2 == "deactivate":
		s2.stream = r.deactivate_sound
	else:
		if sound_matrix[dir] == 3 or sound_matrix[dir] == 2:
			s2.stream = null
	
	#random pitch will give liveliness
	s1.pitch_scale = f.random(0.95, 1.05)
	s2.pitch_scale = f.random(0.95, 1.05)

	#and reproduce the set of sounds indicated in the matrix in this direction
	match sound_matrix[dir]:
		1: s1.play()
		2:
			s1.play()
			s2.play()
		3: s2.play()
	
	#yes, now we can return the result.
	#We changed the figure there after the collision
	return cell + change_matrix[dir]
	#TODO: separate sound from shape change

#this function rotates a specific cell on the field, by coordinates.
#in fact it just calls the following
func rotate_selected_cell(coord: Vector2, forward: bool = true):
	var emitt = find_emitter(coord)
	if emitt != null:
		if forward: emitt.set_dir(emitt.direction + 1)
		else: emitt.set_dir(emitt.direction - 1)
		return
	if get_cellv(coord) == INVALID_CELL: return
	var cell_type = get_cell_type(coord)
	set_cell_type(coord, rotate_cell(cell_type, forward))

#this function tells what shape will turn out after rotation.
#useful for editing.
func rotate_cell(cell_type: Vector2, forward: bool = true) -> Vector2:
	var cell = cell_type
	
	var shift = int(cell.x) % 4
	var base = int(cell.x) - int(cell.x) % 4
	
	if forward: shift = (shift + 1) % 4
	else: shift = wrapi(shift - 1, 0, 4)
	
	return Vector2(base + shift, cell.y)


#this function changes the type of a specific cell on the field, by coordinates.
#actually just calls the following
func shift_selected_cell(coord: Vector2, forward: bool = true):
	var emitt = find_emitter(coord)
	if emitt != null:
		if forward: emitt.set_speed(emitt.ball_speed + 100)
		else: emitt.set_speed(emitt.ball_speed - 100)
		return
	if get_cellv(coord) == INVALID_CELL: return
	var cell_type = get_cell_type(coord)
	set_cell_type(coord, shift_cell(cell_type, forward))


#this function tells which shape will be the next or previous type.
#Useful for editing.
func shift_cell(cell_type: Vector2, forward: bool = true) -> Vector2:
	var cell = cell_type #alias
	var shift: Vector2 #the actual vector by which the position of the shape inside the tileset will change
	var col: int = floor(cell.x / 4) * 4 #counting a column in a tileset
	#and select the change vector
	match col:
		0:
			if int(cell.y) == 0:
				if forward: shift = Vector2(4, 0)
				else: shift = Vector2(36, 3)
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
			if int(cell.y) == 3:
				if forward: shift = Vector2(-36, -3)
				else: shift = Vector2(-4, 0)
			else:
				if forward: shift = Vector2(-4, 1)
				else: shift = Vector2(-4, 0)
		_: shift = Vector2.ZERO
	
	#that's all, it remains only to add the change vector to the original shape
	return cell + shift

#aliases so that we can replace the field module with a non-tilemap
#In the name of duck-typing!
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
	var R: Rect2 = get_used_rect()
	R.position += Vector2(-10, -10)
	R.size += Vector2(20, 20)
	return R
#that's all aliases


#find the emitter in the specified coordinates using duck typing
func find_emitter(coord: Vector2):
	for child in get_children():
		if child.has_method("emit_ball"):
			if child.position.x >= coord.x * cell_size.x and \
			child.position.y >= coord.y * cell_size.y and \
			child.position.x < (coord.x + 1) * cell_size.x and \
			child.position.y < (coord.y + 1) * cell_size.y:
				return child
	return null

#we also find the eater.
func find_eater(coord: Vector2):
	for child in get_children():
		if child.has_method("eat_ball"):
			if child.position.x >= coord.x * cell_size.x and \
			child.position.y >= coord.y * cell_size.y and \
			child.position.x < (coord.x + 1) * cell_size.x and \
			child.position.y < (coord.y + 1) * cell_size.y:
				return child
	return null

#an alias for clearing a tileset, at the same time deleting other game objects#
func clear_pole():
	clear()
	g.cam.global_position = Vector2.ZERO
	for child in get_children():
		if child.has_method("emit_ball") or \
		child.has_method("eat_ball"):
			child.queue_free()
		if child.has_method("disappear"):
			child.disappear()

func launch_all():
	for child in get_children():
		if child.has_method("emit_ball"):
			child.emit_ball()
#			painter.visible = false
