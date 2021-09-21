extends KinematicBody2D


signal player_health_changed(new_health)
signal player_fired(uzi_bullet, position, direction)
signal weapon_ammo_changed(new_ammo_count)
signal weapon_out_of_ammo
signal item_picked_up(item)

onready var gun_shot := $gun_shot

export(int) var health := 100
export(int) var max_ammo := 30

export (PackedScene) var _uzi_bullet: PackedScene
export(int) var _max_speed := 200
export(int) var _accel := 1000

var cur_ammo := max_ammo
var gui: CanvasLayer
var in_cutscene := false

var _velocity := Vector2()
var _cur_weapon := 0
var _reloading := false

onready var _ap := $AnimationPlayer
onready var _uzi := $Hand/Uzi
onready var _ak := $Hand/AK
onready var _m4 := $Hand/M4A14
onready var _sniper := $Hand/Sniper
onready var _uzi_end := $Hand/BulletPoints/UziEnd
onready var _cooldown := $Cooldown
onready var _muzzle_flash := $MuzzleFlash


func _ready() -> void:
	$ItemPickup/PressE.set_as_toplevel(true)


func _physics_process(delta):
	if not in_cutscene:
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
		
		if not _reloading:
			if not _velocity == Vector2.ZERO:
				_ap.play("walk")
			else:
				_ap.stop()
	
	$ItemPickup/PressE.rect_position = position + Vector2(-101, -103)
	
	
func _unhandled_input(event):
	if event.is_action_pressed("shoot"):
		_shoot()
	elif event.is_action_released("reload"):
		start_reload()
	elif event.is_action_pressed("pickup"):
		for item in $ItemPickup.get_overlapping_areas():
			emit_signal("item_picked_up", item)
			yield(get_tree(), "idle_frame")
			if $ItemPickup.get_overlapping_areas().size() == 0:
				$ItemPickup/PressE.hide()
		

func _shoot():
	if not cur_ammo == 0 and _cooldown.is_stopped():
		_muzzle_flash.emitting = true
		var uzi_bullet_instance = _uzi_bullet.instance()
		var dir: Vector2 = Vector2.RIGHT.rotated(rotation)
		gun_shot.playing = true
		emit_signal("player_fired", uzi_bullet_instance, _uzi_end.global_position, dir)
		_cooldown.start()
		_set_current_ammo(cur_ammo - 1)


func _set_current_ammo(new_ammo: int):
# warning-ignore:narrowing_conversion
	cur_ammo = clamp(new_ammo, 0, max_ammo)
	if cur_ammo == 0:
		emit_signal("weapon_out_of_ammo")
	emit_signal("weapon_ammo_changed", cur_ammo)


func start_reload():
	if gui.find_item("Bullets") != 1 and not cur_ammo == max_ammo:
		_ap.play("reload")
		gui.remove_item(gui.find_item("Bullets"))
		_reloading = true


func _stop_reload():
	_set_current_ammo(max_ammo)
	_reloading = false


func _on_hurt_box_area_entered(area: Area2D) -> void:
	if area.name == "AttackBox":
		health -= 10
		emit_signal("player_health_changed", health)
		$HurtBox/CollisionShape2D.disabled = true
		$HurtBox/Invincibility.start()


func _on_invincibility_timeout() -> void:
	$HurtBox/CollisionShape2D.disabled = false


func _on_item_pickup_area_entered(_area: Area2D) -> void:
	$ItemPickup/PressE.show()


func _on_item_pickup_area_exited(_area: Area2D) -> void:
	if $ItemPickup.get_overlapping_areas().size() == 0:
		$ItemPickup/PressE.hide()
