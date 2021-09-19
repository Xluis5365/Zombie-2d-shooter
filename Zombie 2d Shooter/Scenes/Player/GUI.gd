extends CanvasLayer


var _player: KinematicBody2D
var slots := []

onready var _health_bar = $Marg/Rows/BottomRow/Center/HealthBar
onready var _health_tween = $Marg/Rows/BottomRow/Center/Tween
onready var _cur_ammo = $Marg/Rows/BottomRow/AmmoSection/CurAmmo
onready var _max_ammo = $Marg/Rows/BottomRow/AmmoSection/MaxAmmo


func _ready() -> void:
	for slot in $Marg/Rows/Inventory.get_children():
		slots.append("")
		slot.connect("pressed", self, "_on_inv_item_pressed", [slot.get_index()])
		

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_pause_pressed()
		get_tree().set_input_as_handled()


func set_info(p: KinematicBody2D):
	_player = p

	_health_bar.value = p.health
	_set_current_ammo(p.cur_ammo)
	_set_max_ammo(p.max_ammo)
	
	_player.connect("player_health_changed", self, "_set_new_health_value")
	_player.connect("weapon_ammo_changed", self, "_set_current_ammo")
	_player.connect("item_picked_up", self, "_on_item_picked_up")
	
	
func remove_item(i) -> void:
	slots[i] = ""
	$Marg/Rows/Inventory.get_child(i).get_child(0).texture = null
	
	
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
		if slots[i] == "":
			slots[i] = item.id
			$Marg/Rows/Inventory.get_child(i).get_child(0).texture = item.get_node("Sprite").texture
			item.queue_free()
			break

func _on_inv_item_pressed(i: int) -> void:
	match slots[i]:
		"Health":
			_player.health = 100
			_set_new_health_value(100)
			remove_item(i)

	
func _on_pause_pressed() -> void:
	$PausePop.popup_centered()
	get_tree().paused = true


func _on_pause_pop_popup_hide() -> void:
	get_tree().paused = false


func _on_resume_pressed() -> void:
	$PausePop.hide()


func _on_quit_pressed() -> void:
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)
