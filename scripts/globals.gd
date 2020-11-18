extends Node

var pole
var editor
var cam

var mute_audio: bool

func _ready():
	pass


func reparent_cam():
	var ball
	for child in pole.get_children():
		if child.has_method("disappear"):
			ball = child
			break
	if ball != null:
		cam.reparent(ball)


func mute():
	mute_audio = not mute_audio
	AudioServer.set_bus_mute(0, mute_audio)
	if editor != null:
		if mute_audio:
			editor.mute.normal = load("res://images/mute.png")
		else:
			editor.mute.normal = load("res://images/speaker.png")

func pause():
	if get_tree().paused:
		pole.modulate = Color.from_hsv(0, 0, 1)
		get_tree().paused = false
		if editor != null:
			editor.pause.normal = load("res://images/play.png")
	else:
		pole.modulate = Color.from_hsv(0, 0, 0.5)
		get_tree().paused = true
		if editor != null:
			editor.pause.normal = load("res://images/pause.png")



func quicksave():
	save_to_file("user://quicksave.tres", save_to_res())

func quickload():
	var data = load_from_file("user://quicksave.tres")
	if data:
		load_from_res(data)
		return
	
	data = load_from_file("res://quicksave.tres")
	if data:
		load_from_res(data)
		return

#ресурс-сейвер мне нравится больше, чем JSON, так как нативно работает с
#типами ГОДОТа. Меньше костылей.
func save_to_file(filename: String, data: pole_save):
	ResourceSaver.save(filename, data)

func load_from_file(filename: String) -> pole_save:
	var TMP = ResourceLoader.load(filename)
	if TMP is pole_save: return TMP
	return null


#Эта функция сохраняет все игровые данные в один ресурс,
#нужно для скармливания его функции сохранения в файл
func save_to_res() -> pole_save:
	var res : pole_save = pole_save.new() #собсно ресурс
	
	#сначала сохраним тайлы
	var cells = pole.get_used_cells() #таблица векторов с занятыми клетками
	var cell_types = {} #сюда будем писать данные
	#используем таблицу векторов как ключи и пишем им значения содержимого.
	#я не нашёл функцию, чтобы просто получить эти данные из тайлмапа
	for one_cell in cells:
		cell_types[one_cell] = pole.get_cell_type(one_cell)
	res.cell_array = cell_types #и пишем эти данные в ресурсный файл
	
	#теперь находим и сохраняем потомков
	for child in get_children():
		#Сначала эмиттеры
		if child.has_method("emit_ball"):
			var my_emitter = {
				"position"   : child.position,
				"direction"  : child.direction,
				"autostart"  : child.autostart,
				"autoshoot"  : false,
				"autoshoot_time" : 1}
			#у эмиттера внутри может быть таймер-автозапускаймер, запомним и его
			for t in child.get_children():
				if t is Timer:
					if t.autostart and not t.one_shot:
						my_emitter["autoshoot"] = true
						my_emitter["autoshoot_time"] = t.wait_time
			res.ball_emitters.append(my_emitter)
		#Потом поедатели
		if child.has_method("eat_ball"):
			var my_eater = {
				"position" : child.position}
			res.ball_eaters.append(my_eater)
	#готово!
	return res


#Эта функция восстанавливает игровое поле из ресурса,
#который мы обычно получаем из файла сохранения
func load_from_res(res: pole_save):
	#для начала удалим всё с поля.
	pole.clear_pole()
	
	#восстанавливаем тайлы
	for cell_coord in res.cell_array.keys():
		pole.set_cell_type(cell_coord, res.cell_array[cell_coord])
	
	#восстанавливаем поедателей
	for child in res.ball_eaters:
		var my_eater = load("res://scenes/ball_eater.scn").instance()
		pole.call_deferred("add_child", my_eater) #потокобезопасненько!
		my_eater.position = child["position"]
	
	#восстанавливаем эмиттеры
	for child in res.ball_emitters:
		var my_emitter = load("res://scenes/ball_emitter.scn").instance()
		my_emitter.autostart = child["autostart"]
		#не забыть про таймеры-автозапускаймеры
		if child["autoshoot"]:
			var T = Timer.new()
			my_emitter.add_child(T) #Этот эмиттер ещё не вошёл в дерево, так что потомка ему добавляем без деферреда
			T.autostart = true
			T.one_shot = false
			T.wait_time = child["autoshoot_time"]
		pole.call_deferred("add_child", my_emitter)
		my_emitter.position = child["position"]
		my_emitter.set_dir(child["direction"])
	#а шары мы не сохраняли, так что и восстанавливать не будем
