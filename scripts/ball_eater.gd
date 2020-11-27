extends Area2D
#the ball eater eats the balls that it gets

func _on_ball_eater_body_entered(body):
	if body.has_method("disappear"):
		eat_ball(body)

func eat_ball(body):
	print("Eating ball at position: ", position, ", velocity: ", body.velocity)
	body.disappear()
	$eat_sound.play()
