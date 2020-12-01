extends PopupPanel


func _ready():
	if g.help_panel == null: g.help_panel = self
	$ScrollContainer/VBoxContainer/version.text = "version " + g.project_version

func show_help():
	rect_size = get_viewport().size
	game_was_paused = get_tree().paused
	g.set_pause(true)
	popup()

func hide_help():
	hide()
	g.set_pause(game_was_paused)

var scrolling_help: bool

var game_was_paused: bool
func _on_help_panel_gui_input(event):
	_on_ScrollContainer_gui_input(event)
	
func _on_ScrollContainer_gui_input(event):
	if event is InputEventScreenDrag:
		scrolling_help = true
		$ScrollContainer.scroll_vertical -= event.relative.y
	
		
	elif event.is_action("scroll_down") or event.is_action("scroll_up"):
		pass
	
	elif event is InputEventScreenTouch:
		if not event.is_pressed():
			if not scrolling_help:
				hide_help()
	
	elif event is InputEventMouseMotion: pass
	
	elif event is InputEventMouseButton:
		if not event.is_pressed():
			if not scrolling_help:
				hide_help()
			scrolling_help = false
		
	else:
		hide_help()
