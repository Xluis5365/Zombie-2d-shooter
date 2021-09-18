extends KinematicBody2D


signal player_health_changed(new_health)
signal player_fired(uzi_bullet, position, direction)
signal weapon_ammo_changed(new_ammo_count)
signal weapon_out_of_ammo

export(int) var health := 100
export(int) var max_ammo := 30

export (PackedScene) var _uzi_bullet: PackedScene
export(int) var _max_speed := 200
export(int) var _accel := 1000

var cur_ammo := max_ammo

var _velocity := Vector2()
var _cur_weapon := 0

onready var _ap := $AnimationPlayer
onready var _uzi := $Hand/Uzi
onready var _ak := $Hand/AK
onready var _m4 := $Hand/M4A14
onready var _sniper := $Hand/Sniper
onready var _uzi_end := $Hand/BulletPoints/UziEnd
onready var _cooldown := $Cooldown
onready var _muzzle_flash := $MuzzleFlash


func _ready() -> void:
	$GUI.set_info(self)


func _physics_process(delta):
	look_at(get_global_mouse_position())
	
	var axis = Vector2.ZERO
	axis.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	axis.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	axis = axis.normalized()
	
	if axis == Vector2.ZERO:
		_velocity = _velocity.move_toward(Vector2.ZERO, _accel * delta)
	else:
		_velocity = _velocity.move_toward(axis * _max_speed, _accel * delta)
		_velocity = _velocity.clamped(_max_speed)
	_velocity = move_and_slide(_velocity)

	if not _velocity == Vector2.ZERO:
		_ap.play("walk")
	
	
func _unhandled_input(event):
	if event.is_action_pressed("shoot"):
		_shoot()
	elif event.is_action_released("reload"):
		_start_reload()
		

func _shoot():
	if cur_ammo != 0 and _cooldown.is_stopped():
		_muzzle_flash.emitting = true
		var uzi_bullet_instance = _uzi_bullet.instance()
		var dir: Vector2 = Vector2.RIGHT.rotated(rotation)
		emit_signal("player_fired", uzi_bullet_instance, _uzi_end.global_position, dir)
		_cooldown.start()
		_set_current_ammo(cur_ammo - 1)


func _set_current_ammo(new_ammo: int):
# warning-ignore:narrowing_conversion
	cur_ammo = clamp(new_ammo, 0, max_ammo)
	if cur_ammo == 0:
		emit_signal("weapon_out_of_ammo")
	emit_signal("weapon_ammo_changed", cur_ammo)


func _start_reload():
	_ap.play("reload")


func _stop_reload():
	_set_current_ammo(max_ammo)


func _on_hurt_box_area_entered(area: Area2D) -> void:
	if area.name == "AttackBox":
		health -= 1
		emit_signal("player_health_changed", health)
		$HurtBox/CollisionShape2D.disabled = true
		$HurtBox/Invincibility.start()


func _on_invincibility_timeout() -> void:
	$HurtBox/CollisionShape2D.disabled = false
