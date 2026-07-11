extends CanvasLayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	$Panel/ContinueButton.pressed.connect(_on_continue_pressed)
	$Panel/SaveButton.pressed.connect(_on_save_pressed)
	$Panel/TitleButton.pressed.connect(_on_title_pressed)
	$Panel/QuitButton.pressed.connect(_on_quit_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if get_tree().paused:
			_resume()
		else:
			_open()

func _open() -> void:
	get_tree().paused = true
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _resume() -> void:
	get_tree().paused = false
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_continue_pressed() -> void:
	_resume()

func _on_save_pressed() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player:
		GameState.save_game(player)

func _on_title_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
