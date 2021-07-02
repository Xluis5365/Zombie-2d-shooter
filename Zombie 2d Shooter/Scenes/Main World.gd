extends Node2D

onready var bullet_manager = $BulletManager
onready var player = $Player


func _input(event):
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _ready() -> void:
	player.connect("player_fired", bullet_manager, "handle_bullet_spawned")
