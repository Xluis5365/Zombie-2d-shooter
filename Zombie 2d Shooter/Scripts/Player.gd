extends KinematicBody2D

onready var ap = $AnimationPlayer

var speed = 10
var max_speed = 200
var ACCELERATION = 1000

var velocity = Vector2()

func _physics_process(delta):
	look_at(get_global_mouse_position())
	var axis = get_input_axis()
	if axis == Vector2.ZERO:
		apply_friction(ACCELERATION * delta)
	else:
		apply_movement(axis * ACCELERATION * delta)
	velocity = move_and_slide(velocity)
	
func get_input_axis():
	var axis = Vector2.ZERO
	axis.x = int(Input.is_action_pressed("Right")) - int(Input.is_action_pressed("Left"))
	axis.y = int(Input.is_action_pressed("Down")) - int(Input.is_action_pressed("Up"))
	return axis.normalized()



func apply_friction(amount):
	if velocity.length() > amount:
		velocity -= velocity.normalized() * amount
	else:
		velocity = Vector2.ZERO

func apply_movement(acceleration):
	velocity += acceleration
	velocity = velocity.clamped(max_speed)
	if velocity.length() > max_speed:
		velocity =  velocity.normalized() * max_speed
