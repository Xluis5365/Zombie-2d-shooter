extends Area2D
class_name uzi_bullet

export var speed = 30

onready var vanish_timer = $Vanish_Timer

var direction := Vector2.ZERO

func _ready():
	vanish_timer.start()
func _physics_process(delta: float) -> void:
	if direction !=  Vector2.ZERO:
		var velocity = direction * speed
		
		global_position += velocity

func set_direction(direction: Vector2):
	self.direction = direction
	rotation += direction.angle()


func _on_Vanish_Timer_timeout() -> void:
	queue_free()
