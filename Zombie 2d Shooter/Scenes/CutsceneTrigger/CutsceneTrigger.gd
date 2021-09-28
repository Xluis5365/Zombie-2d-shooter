extends Area2D


export(String, FILE, ".txt") var dialogue


func _on_CutsceneTrigger_body_entered(_body: Node) -> void:
	Dialogue.show_dialogue(dialogue)
