extends Node3D

@export var step_count: int = 40
@export var step_height: float = 0.25
@export var angle_step_deg: float = 15.0
@export var radius: float = 2.6
@export var start_angle_deg: float = 0.0
@export var tread_size := Vector3(1.0, 0.15, 0.9)
@export var tread_material: Material

func _ready() -> void:
	var angle_step := deg_to_rad(angle_step_deg)
	var angle := deg_to_rad(start_angle_deg)
	for i in step_count:
		var body := StaticBody3D.new()
		var mesh_instance := MeshInstance3D.new()
		var box_mesh := BoxMesh.new()
		box_mesh.size = tread_size
		mesh_instance.mesh = box_mesh
		if tread_material:
			mesh_instance.set_surface_override_material(0, tread_material)
		var collision := CollisionShape3D.new()
		var box_shape := BoxShape3D.new()
		box_shape.size = tread_size
		collision.shape = box_shape
		body.add_child(mesh_instance)
		body.add_child(collision)
		add_child(body)
		var y := (i + 1) * step_height
		body.position = Vector3(cos(angle) * radius, y - tread_size.y / 2.0, sin(angle) * radius)
		body.rotation.y = angle
		angle += angle_step
