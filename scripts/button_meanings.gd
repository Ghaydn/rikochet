extends Node


func button_eater():
	g.editor.button_eater()

func button_emitter():
	g.editor.button_emitter()

func button_placer():
	g.editor.button_placer()

func button_eraser():
	g.editor.button_erase()

func button_rotate_right():
	g.editor.button_rotate_right()

func button_rotate_left():
	g.editor.button_rotate_left()

func button_next_fig():
	g.editor.button_next_fig()

func button_prev_fig():
	g.editor.button_prev_fig()

func button_go():
	g.editor.button_go()

func button_killballs():
	g.editor.button_killballs()

func button_clear():
	g.editor.button_clear()

func button_save():
	g.saveload_dialogs.show_save()

func button_load():
	g.saveload_dialogs.show_load()


func button_mute():
	g.mute()

func button_pause():
	g.pause()

func button_zoom_in():
	g.cam.zoom_in()

func button_zoom_out():
	g.cam.zoom_out()

func button_pin_cam():
	g.reparent_cam()

func button_exit():
	g.quit()

func cam_up_pressed():
	g.cam.cam_up_pressed()

func cam_up_released():
	g.cam.cam_up_released()

func cam_down_pressed():
	g.cam.cam_down_pressed()

func cam_down_released():
	g.cam.cam_down_released()

func cam_left_pressed():
	g.cam.cam_left_pressed()

func cam_left_released():
	g.cam.cam_left_released()

func cam_right_pressed():
	g.cam.cam_right_pressed()

func cam_right_released():
	g.cam.cam_right_released()
