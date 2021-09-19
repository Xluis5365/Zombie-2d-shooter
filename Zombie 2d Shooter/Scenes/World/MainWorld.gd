extends Node2D


enum {
	DAY,
	SUNSET,
	NIGHT,
	SUNRISE,
}

const _DAY_TIME := 600.0
const _TRANSITION := 60.0
const _SUNSET_COLOR := Color("ae9050")
const _NIGHT_COLOR := Color("47476a")

var _time := DAY

onready var _player = $Player


func _ready() -> void:
	_player.connect("player_fired", self, "handle_bullet_spawned")
	$GUI.set_info(_player)
	$Timer.wait_time = _DAY_TIME
	$Timer.start()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)


func handle_bullet_spawned(bullet: KinematicBody2D, pos: Vector2, direction: Vector2):
	add_child(bullet)
	bullet.global_position = pos
	bullet.set_direction(direction)


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
		
