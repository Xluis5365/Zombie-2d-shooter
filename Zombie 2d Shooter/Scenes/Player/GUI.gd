extends CanvasLayer


var _player: KinematicBody2D

onready var _health_bar = $Marg/Rows/BottomRow/Center/HealthBar
onready var _health_tween = $Marg/Rows/BottomRow/Center/Tween
onready var _cur_ammo = $Marg/Rows/BottomRow/AmmoSection/CurAmmo
onready var _max_ammo = $Marg/Rows/BottomRow/AmmoSection/MaxAmmo


func set_info(p: KinematicBody2D):
	_player = p

	_health_bar.value = p.health
	_set_current_ammo(p.cur_ammo)
	_set_max_ammo(p.max_ammo)
	
	_player.connect("player_health_changed", self, "_set_new_health_value")
	_player.connect("weapon_ammo_changed", self, "_set_current_ammo")
	
	
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
