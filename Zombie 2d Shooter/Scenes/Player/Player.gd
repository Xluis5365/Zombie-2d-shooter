extends KinematicBody2D


signal player_health_changed(new_health)
signal player_fired(uzi_bullet, position, direction)
signal weapon_ammo_changed(new_ammo_count)
signal weapon_out_of_ammo
signal item_picked_up(item)
signal gun_picked_up(gun)

const _GUN_PATH := "res://Scenes/Guns/%s.tscn"
const _BULLETS := {
	"Uzi": preload("res://Scenes/Guns/UziBullet.tscn"),
	"AK": preload("res://Scenes/Guns/AKBullet.tscn"),
}

export(int) var max_health := 100
export(int) var health := 100
export(int) var max_ammo := 30

export (PackedScene) var _uzi_bullet: PackedScene
export(int) var _max_speed := 200
export(int) var _accel := 1000

var cur_ammo := max_ammo
var gui: CanvasLayer
var in_cutscene := false
var guns := [null, null]

var _velocity := Vector2()
var _cur_weapon := 0
var _reloading := false
var _hold_to_shoot := true
var _cur_gun := -1

onready var _ap := $AnimationPlayer
onready var _cooldown := $Cooldown
onready var _muzzle_flash := $MuzzleFlash


func _ready() -> void:
	$ItemPickup/PressE.set_as_toplevel(true)
	for gun in $Guns.get_children():
		guns[gun.get_index()] = gun
	_set_gun(0)
	

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
			if item.is_in_group("guns") and null in guns:
				emit_signal("gun_picked_up", item)
				var gun: Sprite = load(_GUN_PATH % item.id).instance()
				$Guns.add_child(gun)
				gun.hide()
				gun.position = gun.gun_offset
				guns[1-_cur_gun] = gun
			elif not item.is_in_group("guns") and (not gui.is_inventory_full() or not gui.find_item(item.id) == -1):
				emit_signal("item_picked_up", item)
			yield(get_tree(), "idle_frame")
			if $ItemPickup.get_overlapping_areas().size() == 0:
				$ItemPickup/PressE.hide()
	elif event.is_action_pressed("switch_hold_to_shoot"):
		_hold_to_shoot = not _hold_to_shoot
	elif event.is_action_pressed("switch_knife"):
		pass
	elif event.is_action_pressed("switch_gun"):
		_set_gun(1-_cur_gun)


func _set_gun(i: int) -> void:
	if guns[_cur_gun]:
		guns[_cur_gun].hide()
	_cur_gun = i
	if guns[i]:
		guns[i].show()
		$GunShot.global_position = guns[i].get_node("End").global_position
		$MuzzleFlash.global_position = guns[i].get_node("End").global_position


func _shoot():
	if guns[_cur_gun] and not cur_ammo == 0 and _cooldown.is_stopped():
		_muzzle_flash.emitting = true
		var bullet = _BULLETS[guns[_cur_gun].id].instance()
		$GunShot.play()
		emit_signal("player_fired", bullet,\
		guns[_cur_gun].get_node("End").global_position, Vector2.RIGHT.rotated(rotation))
		_cooldown.start()
		_set_current_ammo(cur_ammo - 1)


func _set_current_ammo(new_ammo: int):
	cur_ammo = clamp(new_ammo, 0, max_ammo)
	if cur_ammo == 0:
		emit_signal("weapon_out_of_ammo")
	emit_signal("weapon_ammo_changed", cur_ammo)


func start_reload():
	if guns[_cur_gun] and gui.find_item("Bullets") != -1 and not cur_ammo == max_ammo:
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


func _on_cooldown_timeout() -> void:
	if Input.is_action_pressed("shoot") and _hold_to_shoot:
		_shoot()
