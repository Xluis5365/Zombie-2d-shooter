extends KinematicBody2D

onready var timer = $Timer
onready var ap = $AnimationPlayer

var health = 100

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
	

func _on_attack_body_entered(body):
	if body.is_in_group("Player"):
		state = ATTACK



func _on_Sight_body_exited(body):
	if body.is_in_group("Player"):
		state = IDLE

func handle_hit_by_enemy():
	health -= 20
	print("enemy hit", health)
	if health <= 0:
		ap.play("pre enemy death")
		queue_free()
