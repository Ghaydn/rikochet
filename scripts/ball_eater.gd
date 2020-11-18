extends Area2D
#поедатель шаров ест шары, которые ему попадутся

func _on_ball_eater_body_entered(body):
	if body.has_method("disappear"):
		eat_ball(body)

func eat_ball(body):
	print("Eating ball ", body, ", position: ", position)
	body.disappear()
	$eat_sound.play()
