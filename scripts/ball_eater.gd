extends Area2D
#the ball eater eats the balls that it gets

func _on_ball_eater_body_entered(body):
	if body.has_method("disappear"):
		eat_ball(body)

func eat_ball(body):
	g.answer("Eating ball at position: " + String(position))
	body.disappear()
	$particl.restart()
	$particl.emitting = true
	$eat_sound.play()
