extends Node2D

func handle_bullet_spawned(uzi_bullet: uzi_bullet, position: Vector2, direction: Vector2):
	add_child(uzi_bullet)
	uzi_bullet.global_position = position
	uzi_bullet.set_direction(direction)
