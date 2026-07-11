extends Control

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = false
	$VBoxContainer/ContinueButton.disabled = not GameState.has_save()
	$VBoxContainer/ContinueButton.pressed.connect(_on_continue_pressed)
	$VBoxContainer/NewGameButton.pressed.connect(_on_new_game_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)

func _on_continue_pressed() -> void:
	GameState.load_save_data()
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_new_game_pressed() -> void:
	GameState.reset_progress()
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
