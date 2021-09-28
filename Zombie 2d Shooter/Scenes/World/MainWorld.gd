extends Node2D


enum {
	DAY,
	SUNSET,
	NIGHT,
	SUNRISE,
}

const _DAY_TIME := 60.0
const _TRANSITION := 6.0
const _SUNSET_COLOR := Color("ae9050")
const _NIGHT_COLOR := Color("47476a")
const _ITEM_PATH := "res://Scenes/Items/%s.tscn"

var _time := DAY
var in_cutscene := false setget set_in_cutscene

onready var _player = $Player


func _ready() -> void:
	_player.connect("player_fired", self, "handle_bullet_spawned")
	$GUI.set_info(_player)
	_player.gui = $GUI
	if not in_cutscene:
		$Timer.wait_time = _DAY_TIME
		$Timer.start()
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.connect("died", self, "_on_enemy_died")


func handle_bullet_spawned(bullet: KinematicBody2D, pos: Vector2, direction: Vector2):
	add_child(bullet)
	bullet.global_position = pos
	bullet.set_direction(direction)


func _on_enemy_died(enemy: KinematicBody2D) -> void:
	$GUI.remove_mini_map_object(enemy)


func _on_timer_timeout() -> void:
	$Tween.interpolate_property($CanvasModulate, "color", $CanvasModulate.color, _SUNSET_COLOR, _TRANSITION)
	$Tween.start()
	if _time == DAY:
		_time = SUNSET
	else:
		_time = SUNRISE


func _on_tween_all_completed() -> void:
	if _time == SUNSET:
		_time = NIGHT
		$Tween.interpolate_property($CanvasModulate, "color", $CanvasModulate.color, _NIGHT_COLOR, _TRANSITION)
		$Tween.start()
	elif _time == SUNRISE:
		$Tween.interpolate_property($CanvasModulate, "color", $CanvasModulate.color, Color.white, _TRANSITION)
		$Tween.start()
		_time = DAY
	else:
		$Timer.start()
		

func _on_item_dropped(id: String) -> void:
	var item: Area2D = load(_ITEM_PATH % id).instance()
	$Items.add_child(item)
	item.position = _player.position
	$GUI.add_mini_map_object(item)
	

func set_in_cutscene(new_value: bool) -> void:
	in_cutscene = new_value
	if in_cutscene:
		$Tween.stop_all()
		$Timer.paused = true
	else:
		$Tween.resume_all()
		$Timer.paused = false
