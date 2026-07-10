extends Node

const TOTAL_ITEMS := 4

signal all_items_collected

var pending_spawn_index: int = 0
var collected_items := {}

func enter_tower(spawn_index: int) -> void:
	pending_spawn_index = spawn_index
	get_tree().change_scene_to_file("res://scenes/platformer_2d.tscn")

func return_to_village() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func collect_item(challenge_id: int) -> void:
	if collected_items.has(challenge_id):
		return
	collected_items[challenge_id] = true
	if collected_items.size() >= TOTAL_ITEMS:
		all_items_collected.emit()
