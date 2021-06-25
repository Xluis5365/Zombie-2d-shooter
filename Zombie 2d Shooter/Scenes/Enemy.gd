extends KinematicBody2D

enum {
	IDLE,
	ATTACK,
	OUTOFSIGHT
}

var state = IDLE

func _process(delta):
	match state:
		IDLE:
			pass
		ATTACK:
			pass
		OUTOFSIGHT:
			pass
	

func _on_Area2D_body_entered(body):
	if body.is_in_group():
		pass

func match(state):
	pass
