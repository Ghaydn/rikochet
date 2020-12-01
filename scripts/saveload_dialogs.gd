extends Control

var game_was_paused: bool
var save_tex
onready var load_dialog: FileDialog = $load_dialog
onready var save_dialog: FileDialog = $save_dialog

func _ready():
	if g.saveload_dialogs == null or not OS.has_touchscreen_ui_hint():
	#		g.saveload_dialogs = self
			pass

func show_save():
	save_tex = get_viewport().get_texture().get_data()
	save_tex.flip_y()
	game_was_paused = get_tree().paused
	g.set_pause(true)
	save_dialog.popup()

func show_load():
	game_was_paused = get_tree().paused
	g.set_pause(true)
	load_dialog.popup()

func is_visible():
	return save_dialog.visible or load_dialog.visible


func _on_save_dialog_confirmed():
	if not game_was_paused: g.set_pause(false)
	var filename : String = save_dialog.current_dir + save_dialog.current_file
	if filename == "":
		g.answer("ERROR: filename " + filename + " is not a legal filename.")
		return
	if not game_was_paused: g.set_pause(false)
	g.save_to_file(filename, g.save_to_res(), save_tex)

func _on_load_dialog_confirmed():
	if not game_was_paused: g.set_pause(false)
	var filename: String = load_dialog.current_dir + load_dialog.current_file
	var newfile = g.load_from_file(filename)
	g.load_from_res(newfile)

func _on_save_dialog_popup_hide():
	if not game_was_paused: g.set_pause(false)

func _on_load_dialog_popup_hide():
	if not game_was_paused: g.set_pause(false)
