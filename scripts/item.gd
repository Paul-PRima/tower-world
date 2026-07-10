extends Area3D

@export var challenge_id: int = 0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	rotate_y(delta)

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		GameState.collect_item(challenge_id)
		if $PickupSound.stream:
			$PickupSound.play()
		$MeshInstance3D.visible = false
		$CollisionShape3D.set_deferred("disabled", true)
