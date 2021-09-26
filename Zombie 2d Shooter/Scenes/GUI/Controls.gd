extends CanvasLayer


const _ControlsAction := preload("res://Scenes/GUI/ControlsAction.tscn")

var _actions := {}
var _cur_action: String
var _cur_index: int


func _ready() -> void:
	set_process_input(false)
#	$PopupPanel.popup_centered()
	for action in InputMap.get_actions():
		if "ui_" in action:
			continue
		_actions[action] = InputMap.get_action_list(action)
		var c := _ControlsAction.instance()
		c.get_node("Action").text = action.capitalize()
		for event in InputMap.get_action_list(action):
				c.get_node("Events").text += _event_to_text(event.as_text()) + ", "
		c.get_node("Events").text = c.get_node("Events").text.substr(0, len(c.get_node("Events").text) - 2)
		$PopupPanel/ScrollContainer/Events.add_child(c)
		c.get_node("Add").connect("pressed", self, "_remap", [action, c.get_index()])
		c.get_node("Remove").connect("pressed", self, "_remove", [action, c.get_index()])


func _event_to_text(s: String) -> String:
	if "BUTTON_LEFT" in s:
		return "Left Mouse Button"
	elif "BUTTON_RIGHT" in s:
		return "Right Mouse Button"
	elif "BUTTON_WHEEL_UP" in s:
		return "Mouse Wheel Up"
	elif "BUTTON_WHEEL_DOWN" in s:
		return "Mouse Wheel Down"
	return s


func _remap(action: String, i: int) -> void:
	_cur_action = action
	_cur_index = i
	set_process_input(true)
	$Key.popup_centered()
	

func _input(event: InputEvent) -> void:
	if not event is InputEventMouseMotion:
		get_tree().set_input_as_handled()
		set_process_input(false)
		$Key.hide()
		if not InputMap.action_has_event(_cur_action, event):
			InputMap.action_add_event(_cur_action, event)
			var node := $PopupPanel/ScrollContainer/Events.get_child(_cur_index).get_node("Events")
			if node.text == "":
				node.text = _event_to_text(event.as_text())
			else:
				node.text += ", " + _event_to_text(event.as_text())


func _remove(action: String, i: int) -> void:
	$PopupPanel/ScrollContainer/Events.get_child(i).get_node("Events").text = ""
	InputMap.action_erase_events(action)


func show_controls() -> void:
	$PopupPanel.popup_centered()
