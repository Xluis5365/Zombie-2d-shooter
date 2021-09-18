extends KinematicBody2D


export var _speed = 800

var _dir := Vector2.ZERO


func _physics_process(_delta: float) -> void:
	move_and_slide(_dir * _speed)


func set_direction(dir: Vector2):
	_dir = dir
	rotation += _dir.angle()


func _on_Vanish_Timer_timeout() -> void:
	queue_free()
