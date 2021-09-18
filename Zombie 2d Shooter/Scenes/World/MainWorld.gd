extends Node2D


onready var _bullet_manager = $BulletManager
onready var _player = $Player


func _ready() -> void:
	_player.connect("player_fired", _bullet_manager, "handle_bullet_spawned")


func _input(event):
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()
