extends Node3D

@export var grid_size: int = 6
@export var cell_size: float = 4.0
@export var wall_thickness: float = 0.3
@export var wall_height: float = 3.0
@export var base_y: float = -60.0
@export var cobweb_scene: PackedScene
@export var cobweb_chance: float = 0.35
@export var random_seed: int = 1

var _rng := RandomNumberGenerator.new()
var _visited := []
var _open_east := []
var _open_north := []

func _ready() -> void:
	_rng.seed = random_seed
	_generate()
	_build()

func _generate() -> void:
	_visited.clear()
	_open_east.clear()
	_open_north.clear()
	for x in grid_size:
		_visited.append([])
		_open_east.append([])
		_open_north.append([])
		for y in grid_size:
			_visited[x].append(false)
			_open_east[x].append(false)
			_open_north[x].append(false)

	var stack: Array[Vector2i] = []
	var start := Vector2i(0, 0)
	_visited[start.x][start.y] = true
	stack.append(start)

	while stack.size() > 0:
		var current: Vector2i = stack[-1]
		var neighbors := _unvisited_neighbors(current)
		if neighbors.is_empty():
			stack.pop_back()
			continue
		var next: Vector2i = neighbors[_rng.randi_range(0, neighbors.size() - 1)]
		_carve(current, next)
		_visited[next.x][next.y] = true
		stack.append(next)

func _unvisited_neighbors(cell: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	var candidates := [
		Vector2i(cell.x + 1, cell.y), Vector2i(cell.x - 1, cell.y),
		Vector2i(cell.x, cell.y + 1), Vector2i(cell.x, cell.y - 1),
	]
	for c in candidates:
		if c.x >= 0 and c.x < grid_size and c.y >= 0 and c.y < grid_size and not _visited[c.x][c.y]:
			result.append(c)
	return result

func _carve(a: Vector2i, b: Vector2i) -> void:
	if b.x == a.x + 1:
		_open_east[a.x][a.y] = true
	elif b.x == a.x - 1:
		_open_east[b.x][b.y] = true
	elif b.y == a.y + 1:
		_open_north[a.x][a.y] = true
	elif b.y == a.y - 1:
		_open_north[b.x][b.y] = true

func _cell_center(x: int, y: int) -> Vector3:
	var offset := (grid_size * cell_size) / 2.0 - cell_size / 2.0
	return Vector3(x * cell_size - offset, base_y, y * cell_size - offset)

func _build() -> void:
	for x in grid_size:
		for y in grid_size:
			var center := _cell_center(x, y)
			if x == 0:
				_add_wall(center + Vector3(-cell_size / 2.0, 0, 0), Vector3(wall_thickness, wall_height, cell_size))
			if y == 0:
				_add_wall(center + Vector3(0, 0, -cell_size / 2.0), Vector3(cell_size, wall_height, wall_thickness))
			if not _open_east[x][y]:
				_add_wall(center + Vector3(cell_size / 2.0, 0, 0), Vector3(wall_thickness, wall_height, cell_size))
			elif _rng.randf() < cobweb_chance:
				_add_cobweb(center + Vector3(cell_size / 2.0, 0, 0), true)
			if not _open_north[x][y]:
				_add_wall(center + Vector3(0, 0, cell_size / 2.0), Vector3(cell_size, wall_height, wall_thickness))
			elif _rng.randf() < cobweb_chance:
				_add_cobweb(center + Vector3(0, 0, cell_size / 2.0), false)

func _add_wall(pos: Vector3, size: Vector3) -> void:
	var body := StaticBody3D.new()
	var mesh_instance := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = size
	mesh_instance.mesh = box_mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.32, 0.3, 0.34)
	mesh_instance.set_surface_override_material(0, material)
	var collision := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = size
	collision.shape = box_shape
	body.add_child(mesh_instance)
	body.add_child(collision)
	body.position = pos + Vector3(0, wall_height / 2.0, 0)
	add_child(body)

func _add_cobweb(pos: Vector3, rotated: bool) -> void:
	if not cobweb_scene:
		return
	var cobweb := cobweb_scene.instantiate()
	add_child(cobweb)
	cobweb.position = pos + Vector3(0, wall_height / 2.0, 0)
	if rotated:
		cobweb.rotation.y = PI / 2.0
