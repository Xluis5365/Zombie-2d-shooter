extends KinematicBody2D

signal player_fired(uzi_bullet, position, direction)

signal weapon_out_of_ammo

var max_ammo = 30
var current_ammo = max_ammo

onready var ap = $AnimationPlayer

onready var cooldown = $Cooldown

onready var uzi = $Hand/Uzi
onready var ak = $Hand/Ak
onready var m4 = $Hand/M4A14
onready var sniper = $Hand/Sniper

onready var uzi_gun_direction = $Uzi_gun_direction
onready var uzi_end_of_gun = $Hand/bulletpoints/uziendofgun

export (PackedScene) var uzi_bullet

onready var Health_stat = $Health

onready var muzzleflash = $Particles2D

var speed = 10
var max_speed = 200
var ACCELERATION = 1000

var current_weapon = 1

var velocity = Vector2()

func _physics_process(delta):
	look_at(get_global_mouse_position())
	var axis = get_input_axis()
	if axis == Vector2.ZERO:
		apply_friction(ACCELERATION * delta)
	else:
		apply_movement(axis * ACCELERATION * delta)
	velocity = move_and_slide(velocity)
	if velocity > Vector2.ZERO:
		ap.play("Walking")
	elif velocity < Vector2.ZERO:
		ap.play("Walking")
	
	
	
	
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

func _unhandled_input(event):
	if event.is_action_pressed("Shoot"):
		shoot()
	elif event.is_action_released("Shoot"):
		shoot()
	elif event.is_action_released("reload"):
		start_reload()

func start_reload():
	ap.play("reload")

func _stop_reload():
	current_ammo = max_ammo

func shoot():
	if current_ammo != 0 and cooldown.is_stopped():
		muzzleflash.emitting = true
		var uzi_bullet_instance = uzi_bullet.instance()
		var direction = (uzi_gun_direction.global_position - uzi_end_of_gun.global_position).normalized()
		emit_signal("player_fired", uzi_bullet_instance, uzi_end_of_gun.global_position, direction)
		cooldown.start()
		current_ammo -= 1
		if current_ammo == 0:
			emit_signal("weapon_out_of_ammo")
		print(current_ammo)
	else:
		pass

func handle_hit_by_enemy():
	Health_stat.health -= 10
	print("player hit", Health_stat.health)


func _ready():
	connect("weapon_out_of_ammo", self, "handle_reload")

func handle_reload():
	pass
