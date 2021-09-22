extends Control

onready var MainMenu := "res://Scenes/Menu/MainMenu.tscn"

onready var TestLevel := "res://Scenes/World/MainWorld.tscn"

func _on_BackButton_pressed():
	get_tree().change_scene(MainMenu)


func _on_Level1_pressed():
	get_tree().change_scene(TestLevel)
