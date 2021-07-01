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
			print("idle")
		ATTACK:
			print("attack")
		OUTOFSIGHT:
			pass
	

func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		state = ATTACK




func match(state):
	pass


func _on_Area2D_body_exited(body):
	if body.is_in_group("Player"):
		state = IDLE
