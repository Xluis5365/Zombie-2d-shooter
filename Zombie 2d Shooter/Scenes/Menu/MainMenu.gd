extends Control


onready var test := "res://Scenes/World/MainWorld.tscn"


func _on_Play_Button_pressed():
	get_tree().change_scene(test)


func _on_OptionButton_pressed() -> void:
	Options.popup_centered()


func _on_QuitButton_pressed():
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)
