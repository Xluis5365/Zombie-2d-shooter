extends Node2D


onready var _player = $Player


func _ready() -> void:
	_player.connect("player_fired", self, "handle_bullet_spawned")
	$GUI.set_info(_player)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)


func handle_bullet_spawned(bullet: KinematicBody2D, pos: Vector2, direction: Vector2):
	add_child(bullet)
	bullet.global_position = pos
	bullet.set_direction(direction)
