extends Control

var game_was_paused: bool
onready var load_dialog: FileDialog = $load_dialog
onready var save_dialog: FileDialog = $save_dialog

func _ready():
	if g.saveload_dialogs == null: g.saveload_dialogs = self

func show_save():
	ProjectSettings.set_setting("input_devices/pointing/emulate_mouse_from_touch", true)
	game_was_paused = get_tree().paused
	g.set_pause(true)
	save_dialog.popup()

func show_load():
	ProjectSettings.set_setting("input_devices/pointing/emulate_mouse_from_touch", true)
	game_was_paused = get_tree().paused
	g.set_pause(true)
	load_dialog.popup()

func _on_save_dialog_confirmed():
	if not game_was_paused: g.set_pause(false)
	var filename : String = save_dialog.current_dir + save_dialog.current_file
	if filename == "":
		print("ERROR: filename ", filename, " is not a legal filename.")
		return
	g.save_to_file(filename, g.save_to_res())

func _on_load_dialog_confirmed():
	if not game_was_paused: g.set_pause(false)
	var filename: String = load_dialog.current_dir + load_dialog.current_file
	var newfile = g.load_from_file(filename)
	g.load_from_res(newfile)

func _on_save_dialog_popup_hide():
	ProjectSettings.set_setting("input_devices/pointing/emulate_mouse_from_touch", false)
	if not game_was_paused: g.set_pause(false)

func _on_load_dialog_popup_hide():
	ProjectSettings.set_setting("input_devices/pointing/emulate_mouse_from_touch", false)
	if not game_was_paused: g.set_pause(false)
