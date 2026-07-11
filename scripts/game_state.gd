extends Node

const SAVE_PATH := "user://savegame.json"

const TOTAL_ITEMS := 4
const TOTAL_KEYS := 3

signal all_items_collected
signal all_manor_trees_launched

var pending_spawn_index: int = 0
var collected_items := {}
var collected_keys := {}
var boss_defeated := false
var manor_trees_launched := {}
var manor_tree_total: int = 0

var pending_player_position := Vector3.ZERO
var pending_has_sword := false
var has_pending_load := false

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

func collect_key(key_id: int) -> void:
	if collected_keys.has(key_id):
		return
	collected_keys[key_id] = true

func set_manor_tree_total(total: int) -> void:
	manor_tree_total = total

func collect_manor_tree(tree_id: int) -> void:
	if manor_trees_launched.has(tree_id):
		return
	manor_trees_launched[tree_id] = true
	if manor_tree_total > 0 and manor_trees_launched.size() >= manor_tree_total:
		all_manor_trees_launched.emit()

func show_ending() -> void:
	get_tree().change_scene_to_file("res://scenes/ending_screen.tscn")

func reset_progress() -> void:
	collected_items.clear()
	collected_keys.clear()
	manor_trees_launched.clear()
	boss_defeated = false
	has_pending_load = false

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func save_game(player: Node3D) -> void:
	var data := {
		"player_position": [player.global_position.x, player.global_position.y, player.global_position.z],
		"collected_items": collected_items.keys(),
		"collected_keys": collected_keys.keys(),
		"manor_trees_launched": manor_trees_launched.keys(),
		"has_sword": player.has_sword,
		"boss_defeated": boss_defeated,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))

func load_save_data() -> void:
	has_pending_load = false
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return
	var data = JSON.parse_string(file.get_as_text())
	if typeof(data) != TYPE_DICTIONARY:
		return

	collected_items.clear()
	for id in data.get("collected_items", []):
		collected_items[id] = true

	collected_keys.clear()
	for id in data.get("collected_keys", []):
		collected_keys[id] = true

	manor_trees_launched.clear()
	for id in data.get("manor_trees_launched", []):
		manor_trees_launched[id] = true

	boss_defeated = data.get("boss_defeated", false)

	var pos: Array = data.get("player_position", [0.0, 1.0, 0.0])
	pending_player_position = Vector3(pos[0], pos[1], pos[2])
	pending_has_sword = data.get("has_sword", false)
	has_pending_load = true

func apply_pending_load(player: Node3D) -> void:
	if not has_pending_load or not player:
		return
	has_pending_load = false
	player.global_position = pending_player_position
	if pending_has_sword and player.has_method("grant_sword"):
		player.grant_sword()
