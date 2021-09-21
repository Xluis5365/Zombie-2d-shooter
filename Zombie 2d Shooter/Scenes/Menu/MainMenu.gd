extends Control


onready var test := "res://Scenes/World/MainWorld.tscn"


func _on_Play_Button_pressed():
	get_tree().change_scene(test)
