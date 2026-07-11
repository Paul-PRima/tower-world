extends Area3D

@export var target_position := Vector3.ZERO

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		body.global_position = target_position
		body.velocity = Vector3.ZERO
