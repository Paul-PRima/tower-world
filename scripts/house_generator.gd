extends Node3D

@export var base_y: float = -80.0
@export var key_scene: PackedScene
@export var locked_door_scene: PackedScene

const WALL_COLOR := Color(0.55, 0.5, 0.42)
const STAIR_COLOR := Color(0.4, 0.28, 0.18)

const WALLS := [
	# Ground floor exterior (south wall has a door gap x:-4.3..-2.7)
	[Vector3(-7, 1.5, 0), Vector3(0.3, 3.0, 10)],
	[Vector3(7, 1.5, 0), Vector3(0.3, 3.0, 10)],
	[Vector3(-5.65, 1.5, -5), Vector3(2.7, 3.0, 0.3)],
	[Vector3(2.15, 1.5, -5), Vector3(9.7, 3.0, 0.3)],
	[Vector3(0, 1.5, 5), Vector3(14, 3.0, 0.3)],
	# Ground floor interior dividers (3 rooms), doorway gaps at z:-0.8..0.8
	[Vector3(-2.3, 1.5, -2.9), Vector3(0.3, 3.0, 4.2)],
	[Vector3(-2.3, 1.5, 2.9), Vector3(0.3, 3.0, 4.2)],
	[Vector3(2.3, 1.5, -2.9), Vector3(0.3, 3.0, 4.2)],
	[Vector3(2.3, 1.5, 2.9), Vector3(0.3, 3.0, 4.2)],
	# Floor separator, leaving a stairwell hole at x:-2.3..0.3, z:-1.5..1.5
	[Vector3(-5.65, 3.15, 0), Vector3(4.7, 0.3, 10)],
	[Vector3(0, 3.15, -3.25), Vector3(4.6, 0.3, 3.5)],
	[Vector3(0, 3.15, 3.25), Vector3(4.6, 0.3, 3.5)],
	[Vector3(1.3, 3.15, 0), Vector3(2.0, 0.3, 3.0)],
	[Vector3(4.65, 3.15, 0), Vector3(4.7, 0.3, 10)],
	# Upper floor exterior (fully enclosed)
	[Vector3(-7, 4.8, 0), Vector3(0.3, 3.0, 10)],
	[Vector3(7, 4.8, 0), Vector3(0.3, 3.0, 10)],
	[Vector3(0, 4.8, -5), Vector3(14, 3.0, 0.3)],
	[Vector3(0, 4.8, 5), Vector3(14, 3.0, 0.3)],
	# Upper floor interior dividers (3 rooms), doorway gaps at x:-0.8..0.8
	[Vector3(-3.9, 4.8, -1.7), Vector3(6.2, 3.0, 0.3)],
	[Vector3(3.9, 4.8, -1.7), Vector3(6.2, 3.0, 0.3)],
	[Vector3(-3.9, 4.8, 1.7), Vector3(6.2, 3.0, 0.3)],
	[Vector3(3.9, 4.8, 1.7), Vector3(6.2, 3.0, 0.3)],
	# Roof and ground slab
	[Vector3(0, 6.45, 0), Vector3(14.4, 0.3, 10.4)],
	[Vector3(0, -0.15, 0), Vector3(14, 0.3, 10)],
]

func _ready() -> void:
	for wall in WALLS:
		_add_box(wall[0], wall[1], WALL_COLOR)
	_build_stairs()
	_add_locked_door()
	_add_key(Vector3(4.65, 1.0, 0), 0)
	_add_key(Vector3(0, 4.3, -3.5), 1)
	_add_key(Vector3(0, 4.3, 3.5), 2)

func _build_stairs() -> void:
	var step_count := 15
	var rise := 3.3 / step_count
	var step_x := 2.6 / step_count
	var tread_size := Vector3(0.55, 0.15, 2.6)
	for i in step_count:
		var x := -2.15 + step_x * (i + 0.5)
		var y := rise * (i + 1) - tread_size.y / 2.0
		_add_box(Vector3(x, y, 0), tread_size, STAIR_COLOR)

func _add_box(local_pos: Vector3, size: Vector3, color: Color) -> void:
	var body := StaticBody3D.new()
	var mesh_instance := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = size
	mesh_instance.mesh = box_mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	mesh_instance.set_surface_override_material(0, material)
	var collision := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = size
	collision.shape = box_shape
	body.add_child(mesh_instance)
	body.add_child(collision)
	body.position = local_pos + Vector3(0, base_y, 0)
	add_child(body)

func _add_locked_door() -> void:
	if not locked_door_scene:
		return
	var door := locked_door_scene.instantiate()
	add_child(door)
	door.position = Vector3(-4.3, base_y, -5)

func _add_key(local_pos: Vector3, key_id: int) -> void:
	if not key_scene:
		return
	var key := key_scene.instantiate()
	add_child(key)
	key.position = local_pos + Vector3(0, base_y, 0)
	key.key_id = key_id
