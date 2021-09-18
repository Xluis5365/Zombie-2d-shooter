extends Area2D
class_name UziBullet


export var _speed = 800

var _dir := Vector2.ZERO


func _physics_process(delta: float) -> void:
	global_position += _dir * _speed * delta


func set_direction(dir: Vector2):
	_dir = dir
	rotation += _dir.angle()


func _on_Vanish_Timer_timeout() -> void:
	queue_free()


func _on_Uzi_Bullet_body_entered(body):
	if body.has_method("handle_hit_by_enemy"):
		body.handle_hit_by_enemy()
		queue_free()
