extends Node2D


func handle_bullet_spawned(bullet: UziBullet, pos: Vector2, direction: Vector2):
	add_child(bullet)
	bullet.global_position = pos
	bullet.set_direction(direction)
