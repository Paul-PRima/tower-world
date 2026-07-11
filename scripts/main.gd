extends Node3D

func _ready() -> void:
	var player := get_tree().get_first_node_in_group("player")
	GameState.apply_pending_load(player)
