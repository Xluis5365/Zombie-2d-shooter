extends CanvasLayer


signal item_dropped(id)

const _MAIN_MENU := "res://Scenes/Menu/MainMenu.tscn"

# Array of dictionaries
var slots := []

var _player: KinematicBody2D
var _mini_map_zoom := 1.5
var _mini_map_scale: Vector2
var _markers := {}


onready var _inventory := $TopLeft/Inventory
onready var _mini_map := $MiniMapPop/MiniMap
onready var _mini_map_player := $MiniMapPop/MiniMap/Player
onready var _health_bar = $BottomRow/HealthBar
onready var _health_tween = $BottomRow/HealthBar/Tween
onready var _cur_ammo = $BottomRow/BInv/AmmoSection/CurAmmo
onready var _max_ammo = $BottomRow/BInv/AmmoSection/MaxAmmo
onready var _icons := {
	"enemy": $MiniMapPop/MiniMap/Enemy,
	"item": $MiniMapPop/MiniMap/Item,
}


func _ready() -> void:
	for slot in _inventory.get_children():
		slots.append({"id": "", "stack": 0})
		slot.connect("pressed", self, "_on_inv_item_pressed", [slot.get_index()])
	_mini_map_player.position = _mini_map.rect_size / 2
	_mini_map_scale = _mini_map.rect_size / (get_viewport().get_visible_rect().size * _mini_map_zoom)
	var map_objects = get_tree().get_nodes_in_group("mini_map_objects")
	for object in map_objects:
		add_mini_map_object(object)
		

func _process(_delta: float) -> void:
	if not _player:
		return
	_mini_map_player.rotation = _player.rotation
	for object in _markers:
		var obj_pos = (object.position - _player.position) * _mini_map_scale + _mini_map.rect_size / 2
		if _mini_map.get_rect().has_point(obj_pos + _mini_map.rect_position):
			_markers[object].scale = Vector2(1, 1)
		else:
			_markers[object].scale = Vector2(0.75, 0.75)
		obj_pos.x = clamp(obj_pos.x, 0, _mini_map.rect_size.x)
		obj_pos.y = clamp(obj_pos.y, 0, _mini_map.rect_size.y)
		_markers[object].position = obj_pos
		

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_pause_pressed()
	elif event.is_action_pressed("inv_1"):
		_on_inv_item_pressed(0)
	elif event.is_action_pressed("inv_2"):
		_on_inv_item_pressed(1)
	elif event.is_action_pressed("inv_3"):
		_on_inv_item_pressed(2)
	elif event.is_action_pressed("inv_4"):
		_on_inv_item_pressed(3)
	elif event.is_action_pressed("inv_5"):
		_on_inv_item_pressed(4)
	elif event.is_action_pressed("map"):
		if $MiniMapPop.visible:
			$MiniMapPop.hide()
		else:
			$MiniMapPop.popup_centered()


func set_info(p: KinematicBody2D):
	_player = p

	_health_bar.value = p.health
	_health_bar.max_value = p.max_health
	_set_current_ammo(p.cur_ammo)
	_set_max_ammo(p.max_ammo)
	for i in p.guns.size():
		var slot := $BottomRow/BInv/Top/HBox.get_child(i).get_child(0)
		slot.texture = p.guns[i].texture
		slot.scale = Vector2(9, 9)
		slot.centered = false
		slot.hframes = p.guns[i].hframes
		slot.vframes = p.guns[i].vframes
		slot.frame = p.guns[i].frame
	
	_player.connect("player_health_changed", self, "_set_new_health_value")
	_player.connect("weapon_ammo_changed", self, "_set_current_ammo")
	_player.connect("item_picked_up", self, "_on_item_picked_up")
	_player.connect("gun_picked_up", self, "_on_gun_picked_up")
	

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
	

func add_mini_map_object(object) -> void:
	var new_marker: Sprite
	if object.is_in_group("enemies"):
		new_marker = _icons.enemy.duplicate()
	else:
		new_marker = _icons.item.duplicate()
	_mini_map.add_child(new_marker)
	new_marker.show()
	_markers[object] = new_marker


func remove_mini_map_object(object) -> void:
	_markers[object].queue_free()
	_markers.erase(object)


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
			remove_mini_map_object(item)
			item.queue_free()
			return
	for i in slots.size():
		if slots[i].id == "":
			slots[i].id = item.id
			slots[i].stack += 1
			_inventory.get_child(i).get_node("Icon").texture = item.get_node("Sprite").texture
			_inventory.get_child(i).get_node("Stack").text = "x%d" % slots[i].stack
			remove_mini_map_object(item)
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


func _on_gun_picked_up(gun: Area2D) -> void:
	for slot in $BottomRow/BInv/Top/HBox.get_children():
		if slot.get_child(0).texture == null:
			slot.get_child(0).texture = gun.get_node("Sprite").texture
			slot.get_child(0).scale = Vector2(9, 9)
			slot.get_child(0).centered = false
			slot.get_child(0).hframes = gun.get_node("Sprite").hframes
			slot.get_child(0).vframes = gun.get_node("Sprite").vframes
			slot.get_child(0).frame = gun.get_node("Sprite").frame
			remove_mini_map_object(gun)
			gun.queue_free()
			return
	
	
func _set_mini_map_zoom(value) -> void:
	_mini_map_zoom = clamp(value, 0.5, 5)
	_mini_map_scale = _mini_map.rect_size / (get_viewport().get_visible_rect().size * _mini_map_zoom)
	
	
func _on_pause_pressed() -> void:
	$PausePop.popup_centered()
	get_tree().paused = true


func _on_pause_pop_popup_hide() -> void:
	get_tree().paused = false


func _on_resume_pressed() -> void:
	$PausePop.hide()


#func _on_quit_pressed() -> void:
#	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)


func _on_slot_gui_input(event: InputEvent, i: int) -> void:
	if event.is_action_pressed("right_click"):
		while slots[i].stack != 0:
			emit_signal("item_dropped", slots[i].id)
			remove_item(i)


func _on_TitleScreen_pressed():
	get_tree().change_scene(_MAIN_MENU)


func _on_Options_pressed() -> void:
	Options.popup_centered()


func _on_controls_pressed() -> void:
	Controls.show_controls()
