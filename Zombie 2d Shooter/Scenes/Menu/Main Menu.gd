extends Control

const test = preload("res://Scenes/World/MainWorld.tscn")




func _on_Play_Button_pressed():
	get_parent().add_child(test.instance())
	queue_free()
