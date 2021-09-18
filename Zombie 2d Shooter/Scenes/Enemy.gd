extends KinematicBody2D


enum _States {
	IDLE,
	ATTACK,
	DEAD,
}

export(int) var _speed := 100
export(int) var _health := 60

var _velocity := Vector2()
var _state = _States.IDLE
var _player: KinematicBody2D

onready var _timer = $Timer
onready var _ap = $AnimationPlayer


func _physics_process(delta):
	match _state:
		_States.IDLE:
			pass
		_States.ATTACK:
			var dir := global_position.direction_to(_player.global_position)
			_velocity = move_and_slide(dir * _speed)
			look_at(_player.global_position)
		_States.DEAD:
			pass


func _on_sight_body_entered(body: Node) -> void:
	_player = body


func _on_sight_body_exited(_body: Node) -> void:
	_player = null
	_state = _States.IDLE
	_ap.stop()


func _on_attack_body_entered(body: Node) -> void:
	_state = _States.ATTACK
	_ap.play("walk")
