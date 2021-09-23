extends Node2D

onready var Tentceiling := $Tentceiling
var _player: KinematicBody2D


func _on_Area2D_body_entered(body: KinematicBody2D) -> void:
	if body.is_in_group("Player"):
		Tentceiling.hide()


func _on_Area2D_body_exited(body):
	pass # Replace with function body.
