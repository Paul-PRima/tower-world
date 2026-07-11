extends Node3D

@export var tree_scene: PackedScene
@export var tree_count: int = 90
@export var inner_radius: float = 18.0
@export var outer_radius: float = 35.0
@export var random_seed: int = 1
@export var center: Vector3 = Vector3.ZERO
@export var assign_tree_ids: bool = false

func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = random_seed
	if assign_tree_ids:
		GameState.set_manor_tree_total(tree_count)
	for i in tree_count:
		var angle := rng.randf_range(0, TAU)
		var radius := rng.randf_range(inner_radius, outer_radius)
		var tree := tree_scene.instantiate()
		add_child(tree)
		tree.position = center + Vector3(cos(angle) * radius, 0, sin(angle) * radius)
		tree.rotate_y(rng.randf_range(0, TAU))
		var s := rng.randf_range(0.8, 1.3)
		tree.scale = Vector3(s, s, s)
		if assign_tree_ids:
			tree.tree_id = i
