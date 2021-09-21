extends CanvasLayer


func popup_centered() -> void:
	$Options.popup_centered()


func _on_FullScreen_toggled(button_pressed: bool) -> void:
	OS.window_fullscreen = button_pressed


func _on_Borderless_toggled(button_pressed: bool) -> void:
	OS.window_borderless = button_pressed


func _on_VSync_toggled(button_pressed: bool) -> void:
	OS.vsync_enabled = button_pressed


func _on_Music_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), value)


func _on_Sound_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound"), value)


func _on_Master_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)
