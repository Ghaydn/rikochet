extends Node

var pole
var editor
var cam
var interface
var saveload_dialogs
var help_panel

var mute_audio: bool
var current_file

func _ready():
	#load_settings()
	pass

func quit():
	get_tree().quit()

#changes the camera attach state if possible
func reparent_cam():
	var ball
	for child in pole.get_children():
		if child.has_method("disappear"):
			ball = child
			break
	if ball != null:
		cam.reparent(ball)

#exactly turns off or exactly turns on the sound
func set_mute(yes: bool = true):
	if yes != mute_audio: mute()

#toggles the sound
func mute():
	mute_audio = not mute_audio
	AudioServer.set_bus_mute(0, mute_audio)
	if editor != null:
		if mute_audio:
			interface.to_mute()
		else:
			interface.to_unmute()

#same with pause
func set_pause(yes: bool = true):
	if yes != get_tree().paused: pause()

func pause():
	if get_tree().paused:
		pole.modulate = Color.from_hsv(0, 0, 1)
		interface.darken(Color.from_hsv(0, 0, 1))
		get_tree().paused = false
		if editor != null:
			interface.to_unpause()
	else:
		pole.modulate = Color.from_hsv(0, 0, 0.5)
		interface.darken(Color.from_hsv(0, 0, 0.5))
		get_tree().paused = true
		if editor != null:
			interface.to_pause()
	# = editor.pause.normal


func quicksave():
	if current_file != null: save_to_file(current_file, save_to_res())


func quickload():
	if current_file == null: return
	var data = load_from_file(current_file)
	if data:
		load_from_res(data)

#I like the resource-saver more than JSON, since it works
#natively with GODOT types. Less crutches.
func save_to_file(filename: String, data: pole_save):
	if not data is pole_save:
		print("I cannot save THIS")
		return
	var error = ResourceSaver.save(filename, data)
	if error == 0:
		print("File ", filename, " saved")
		current_file = filename
	else:
		print("Cannot load file ", filename, ": error #", error)

func load_from_file(filename: String) -> pole_save:
	var newfile = ResourceLoader.load(filename)
	if newfile == null:
		print("ERROR: file ", filename, " missing or not a resource.")
		return null
	if not (newfile is pole_save):
		print ("ERROR: file ", filename, " is not a saved game.")
		return null
	print("File ", filename, " loaded")
	current_file = filename
	return newfile


#This function saves all game data in one resource,
#we need to feed it to the save function to a file
func save_to_res() -> pole_save:
	var res : pole_save = pole_save.new() #the resource itself
	res.version = "0.1"
	#first save the tiles
	var cells = pole.get_used_cells() #vector table with occupied cells
	var cell_types = {} #we will write data here
	#use the vector table as keys and write content values to them.
	#I have not found a function to simply get this data from the tilemap
	for one_cell in cells:
		cell_types[one_cell] = pole.get_cell_type(one_cell)
	res.cell_array = cell_types #and write this data to a resource file
	
	#now find and save children
	for child in pole.get_children():
		#Emitters first
		if child.has_method("emit_ball"):
			var my_emitter = {
				"position"   : child.position,
				"direction"  : child.direction,
				"ball_speed" : child.ball_speed,
				"autostart"  : child.autostart,
				"autoshoot"  : false,
				"autoshoot_time" : 1}
			#the emitter may have an auto-start timer inside, we will remember it too
			for t in child.get_children():
				if t is Timer:
					if t.autostart and not t.one_shot:
						my_emitter["autoshoot"] = true
						my_emitter["autoshoot_time"] = t.wait_time
			res.ball_emitters.append(my_emitter)
		#Then the eaters
		if child.has_method("eat_ball"):
			var my_eater = {
				"position" : child.position}
			res.ball_eaters.append(my_eater)
	#done!
	return res


#This function restores the game board from a resource
#that we usually get from a save file
func load_from_res(res: pole_save):
	#first, let's delete everything from the field.
	pole.clear_pole()
	
	#restoring tiles
	for cell_coord in res.cell_array.keys():
		pole.set_cell_type(cell_coord, res.cell_array[cell_coord])
	
	#restoring eaters
	for child in res.ball_eaters:
		var my_eater = r.eater.instance()
		pole.call_deferred("add_child", my_eater) #thread safe!
		my_eater.position = child["position"]
	
	#restoring emitters
	for child in res.ball_emitters:
		var my_emitter = r.emitter.instance()
		my_emitter.autostart = child["autostart"]
		#don't forget about auto-start timers
		if child["autoshoot"]:
			var T = Timer.new()
			my_emitter.add_child(T) #This emitter has not yet entered the tree, so we add a child to it without deferred
			T.autostart = true
			T.one_shot = false
			T.wait_time = child["autoshoot_time"]
		pole.call_deferred("add_child", my_emitter)
		my_emitter.position = child["position"]
		my_emitter.set_dir(child["direction"])
		if child.has("ball_speed"): my_emitter.set_speed(child["ball_speed"])
	#and we did not save the balls, so we will not restore them
