extends Popup

onready var filename_text = $Panel/filename_text
onready var filelist = $Panel/ItemList
onready var ok_button = $Panel/Ok_button
onready var confirm = $ConfirmationDialog

var game_was_paused: bool
var mode: String = "save"
var selected_file: String

var save_tex

func is_visible():
	return visible

func _ready():
	if g.saveload_dialogs == null or OS.has_touchscreen_ui_hint():
		g.saveload_dialogs = self

func show_save():
	save_tex = get_viewport().get_texture().get_data()
	save_tex.flip_y()
	
	game_was_paused = get_tree().paused
	g.set_pause(true)
	mode = "save"
	ok_button.text = tr("Save")
	popup()
	update_filelist()

func show_load():
	game_was_paused = get_tree().paused
	g.set_pause(true)
	mode = "load"
	ok_button.text = tr("Load")
	popup()
	update_filelist()

func _on_ItemList_item_selected(index):
	filename_text.text = filelist.get_item_text(index)


func update_filelist():
	var dir = Directory.new()
	filelist.clear()
	if dir.open("user://") == OK:
		dir.list_dir_begin()
		var dir_file = dir.get_next()
		while dir_file != "":
			if not dir.current_is_dir():
				if dir_file.get_extension() == "tres":
					var icon_name = "user://" + dir_file.get_basename() + ".png"
					var icon = ImageTexture.new()
					var image = Image.new()
					var err = image.load(icon_name)
					if err == OK:
						icon = ImageTexture.new()
						icon.create_from_image(image, 0)
					else:
						icon = r.triangle_image
					filelist.add_item(dir_file.get_basename(), icon)
			dir_file = dir.get_next()
	else:
		g.answer("Error loading user directory")


func _on_saveload_mobile_popup_hide():
	if not game_was_paused: g.set_pause(false)


func _on_Cancel_button_pressed():
	if not game_was_paused: g.set_pause(false)
	hide()


func _on_Ok_button_pressed():
	selected_file = filename_text.text
	if selected_file == "": return
	var filename = "user://" + selected_file + ".tres"
	
	if mode == "save":
		var checkfile = File.new()
		if checkfile.file_exists(filename):
			confirm.popup()
			return
		else:
			do_save()
		
	elif mode == "load":
		var newfile = g.load_from_file(filename)
		if newfile != null:
			g.load_from_res(newfile)
	else:
		g.answer("Something wrong happened to saveload dialog: incorrect mode")
		if not game_was_paused: g.set_pause(false)
	hide()

func _on_ConfirmationDialog_confirmed():
	do_save()
	hide()
	

func do_save():
	if selected_file == "": return
	var filename = "user://" + selected_file + ".tres"
	g.save_to_file(filename, g.save_to_res(), save_tex)


func _on_ItemList_gui_input(event):
	if event is InputEventMouseButton:
		if event.doubleclick:
			_on_Ok_button_pressed()


func _on_filename_text_gui_input(event):
	if event is InputEventMouseButton and OS.has_touchscreen_ui_hint():
		#OS.show_virtual_keyboard()
		if OS.has_feature('JavaScript'):
			filename_text.text = JavaScript.eval("""
				window.prompt('Filename')
			""")
