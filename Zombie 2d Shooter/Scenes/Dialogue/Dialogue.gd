extends CanvasLayer


const SPEECH_DELAY := 0.1

var dialogue := []
var index := -1

onready var speech := $Dialogue/Speech/RichTextLabel
onready var speech_timer := $Dialogue/Speech/RichTextLabel/SpeechTimer


func _ready() -> void:
	speech_timer.wait_time = SPEECH_DELAY
	set_process_input(false)
	$Dialogue.hide()
	
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		get_tree().set_input_as_handled()
		if speech_timer.is_stopped():
			advance_dialogue()
		else:
			speech_timer.stop()
			speech.percent_visible = 1.0


func show_dialogue(path: String) -> void:
	set_process_input(true)
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.in_cutscene = true
	for player in get_tree().get_nodes_in_group("player"):
		player.in_cutscene = true
	for world in get_tree().get_nodes_in_group("worlds"):
		world.in_cutscene = true
	$Dialogue.show()
	index = -1
	dialogue = []
	var file := File.new()
	file.open(path, File.READ)
	while not file.eof_reached():
		dialogue.append(file.get_line())
	advance_dialogue()
	

func advance_dialogue() -> void:
	index += 1
	if index >= dialogue.size():
		$Dialogue.hide()
		set_process_input(false)
		for enemy in get_tree().get_nodes_in_group("enemies"):
			enemy.in_cutscene = false
		for player in get_tree().get_nodes_in_group("player"):
			player.in_cutscene = false
		for world in get_tree().get_nodes_in_group("worlds"):
			world.in_cutscene = false
		return
	var line: Array = dialogue[index].split("|", true, 1)
	if line.size() == 0:
		advance_dialogue()
		return
	$Dialogue/Title/RichTextLabel.bbcode_text = line[0]
	speech.bbcode_text = line[1]
	speech.visible_characters = 0
	speech_timer.start()


func _on_SpeechTimer_timeout() -> void:
	speech.visible_characters += 1
	if not speech.percent_visible == 1.0:
		speech_timer.start()
