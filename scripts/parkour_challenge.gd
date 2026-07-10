extends Node3D

@export var direction := Vector3(1, 0, 1)
@export var start_radius: float = 32.0
@export var radius_step: float = 5.0
@export var platform_count: int = 5
@export var lateral_amplitude: float = 1.5
@export var start_y: float = -19
@export var height_step: float = 1.0
@export var platform_size := Vector3(3.5, 0.4, 3.5)
@export var item_scene: PackedScene
@export var challenge_id: int = 0

func _ready() -> void:
	var dir := direction.normalized()
	var perp := Vector3(-dir.z, 0, dir.x)
	for i in platform_count:
		var radius := start_radius + i * radius_step
		var is_final := i == platform_count - 1
		var lateral := 0.0 if is_final else (lateral_amplitude if i % 2 == 0 else -lateral_amplitude)
		var pos := dir * radius + perp * lateral
		pos.y = start_y + i * height_step
		_add_platform(pos, is_final)
		if i % 2 == 1:
			_add_light(pos)

func _add_platform(pos: Vector3, is_final: bool) -> void:
	var body := StaticBody3D.new()
	var mesh_instance := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = platform_size
	mesh_instance.mesh = box_mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.9, 0.75, 0.25, 1) if is_final else Color(0.55, 0.55, 0.6, 1)
	mesh_instance.set_surface_override_material(0, material)
	var collision := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = platform_size
	collision.shape = box_shape
	body.add_child(mesh_instance)
	body.add_child(collision)
	body.position = pos
	add_child(body)
	if is_final and item_scene:
		var item := item_scene.instantiate()
		add_child(item)
		item.position = pos + Vector3(0, platform_size.y / 2.0 + 1.0, 0)
		item.challenge_id = challenge_id

func _add_light(pos: Vector3) -> void:
	var light := OmniLight3D.new()
	light.position = pos + Vector3(0, 2.0, 0)
	light.light_energy = 1.2
	light.omni_range = 18.0
	add_child(light)
