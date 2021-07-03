extends KinematicBody2D

onready var timer = $Timer
onready var ap = $AnimationPlayer

onready var Health_stat = $Health

onready var player = get_parent().get_node("Player")

export var speed = 500
var velocity = Vector2()


enum {
	IDLE,
	ATTACK,
	OUTOFSIGHT
}

var target :Vector2 = player.global_position

var state = IDLE

func _physics_process(delta):
	
	
	
	
	
	
	move_and_slide(velocity)
	
	match state:
		IDLE:
			print("idle")
		ATTACK:
			transform = player.global_position
			print("attack")
	

func _on_attack_body_entered(body):
	if body.is_in_group("Player"):
		state = ATTACK



func _on_Sight_body_exited(body):
	if body.is_in_group("Player"):
		state = IDLE

func handle_hit_by_enemy():
	Health_stat.health -= 20
	print("enemy hit", Health_stat.health)
	if Health_stat.health <= 0:
		queue_free()
