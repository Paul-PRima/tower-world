extends CanvasLayer

func _ready() -> void:
	$WellDoneScreen.visible = false
	GameState.all_items_collected.connect(_on_all_items_collected)

func _unhandled_input(event: InputEvent) -> void:
	if $WellDoneScreen.visible and event.is_action_pressed("ui_cancel"):
		$WellDoneScreen.visible = false

func _on_all_items_collected() -> void:
	$WellDoneScreen.visible = true
