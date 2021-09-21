extends CanvasLayer


signal item_dropped(id)

var _player: KinematicBody2D
# Array of dictionaries
var slots := []

onready var _inventory := $Inventory
onready var _health_bar = $BottomRow/Center/HealthBar
onready var _health_tween = $BottomRow/Center/Tween
onready var _cur_ammo = $BottomRow/AmmoSection/CurAmmo
onready var _max_ammo = $BottomRow/AmmoSection/MaxAmmo


func _ready() -> void:
	for slot in _inventory.get_children():
		slots.append({"id": "", "stack": 0})
		slot.connect("pressed", self, "_on_inv_item_pressed", [slot.get_index()])
		

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_pause_pressed()
		get_tree().set_input_as_handled()
	elif event.is_action_pressed("1"):
		_on_inv_item_pressed(0)
	elif event.is_action_pressed("2"):
		_on_inv_item_pressed(1)
	elif event.is_action_pressed("3"):
		_on_inv_item_pressed(2)
	elif event.is_action_pressed("4"):
		_on_inv_item_pressed(3)
	elif event.is_action_pressed("5"):
		_on_inv_item_pressed(4)


func set_info(p: KinematicBody2D):
	_player = p

	_health_bar.value = p.health
	_set_current_ammo(p.cur_ammo)
	_set_max_ammo(p.max_ammo)
	
	_player.connect("player_health_changed", self, "_set_new_health_value")
	_player.connect("weapon_ammo_changed", self, "_set_current_ammo")
	_player.connect("item_picked_up", self, "_on_item_picked_up")
	

# Removes one item from the stack
func remove_item(i) -> void:
	slots[i].stack -= 1
	if slots[i].stack == 0:
		slots[i].id = ""
		_inventory.get_child(i).get_node("Icon").texture = null
		_inventory.get_child(i).get_node("Stack").text = ""
	else:
		_inventory.get_child(i).get_node("Stack").text = "x%d" % slots[i].stack
	
	
func find_item(item: String) -> int:
	for i in slots.size():
		if slots[i].id == item:
			return i
	return -1
	
	
func _set_new_health_value(new_health: int):
	var original_color = Color("#830000")
	var highlight_color = Color("#ce0000")
	var bar_style = _health_bar.get("custom_styles/fg")
	_health_tween.interpolate_property(_health_bar, "value", _health_bar.value, new_health, 0.4,Tween.TRANS_LINEAR, Tween.EASE_IN)
	_health_tween.interpolate_property(bar_style, "bg_color", original_color, highlight_color, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	_health_tween.interpolate_property(bar_style, "bg_color", highlight_color, original_color, 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.2)
	_health_tween.start()


func _set_current_ammo(new_ammo: int):
	_cur_ammo.text = str(new_ammo)
	
	
func _set_max_ammo(new_max_ammo: int):
	_max_ammo.text = str(new_max_ammo)
	

func _on_item_picked_up(item: Area2D) -> void:
	for i in slots.size():
		if slots[i].id == item.id:
			slots[i].stack += 1
			_inventory.get_child(i).get_node("Stack").text = "x%d" % slots[i].stack
			item.queue_free()
			return
	for i in slots.size():
		if slots[i].id == "":
			slots[i].id = item.id
			slots[i].stack += 1
			_inventory.get_child(i).get_node("Icon").texture = item.get_node("Sprite").texture
			_inventory.get_child(i).get_node("Stack").text = "x%d" % slots[i].stack
			item.queue_free()
			return

func _on_inv_item_pressed(i: int) -> void:
	match slots[i].id:
		"Health":
			if _player.health != 100:
				_player.health = 100
				_set_new_health_value(100)
				remove_item(i)
		"Bullets":
			_player.start_reload()

	
func _on_pause_pressed() -> void:
	$PausePop.popup_centered()
	get_tree().paused = true


func _on_pause_pop_popup_hide() -> void:
	get_tree().paused = false


func _on_resume_pressed() -> void:
	$PausePop.hide()


func _on_quit_pressed() -> void:
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)


func _on_slot_gui_input(event: InputEvent, i: int) -> void:
	if event.is_action_pressed("right_click"):
		while slots[i].stack != 0:
			emit_signal("item_dropped", slots[i].id)
			remove_item(i)
