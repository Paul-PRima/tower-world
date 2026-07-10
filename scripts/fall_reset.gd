extends Area3D

@export var start_positions: Array[Vector3] = []

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D and start_positions.size() >= 4:
		var pos := body.global_position
		var index := 0
		if pos.x >= 0 and pos.z >= 0:
			index = 0
		elif pos.x < 0 and pos.z >= 0:
			index = 1
		elif pos.x < 0 and pos.z < 0:
			index = 2
		else:
			index = 3
		body.global_position = start_positions[index]
		body.velocity = Vector3.ZERO
