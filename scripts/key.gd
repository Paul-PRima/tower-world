extends Area3D

@export var key_id: int = 0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if GameState.collected_keys.has(key_id):
		_hide_pickup()

func _process(delta: float) -> void:
	rotate_y(delta)

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		GameState.collect_key(key_id)
		if $PickupSound.stream:
			$PickupSound.play()
		_hide_pickup()

func _hide_pickup() -> void:
	$MeshInstance3D.visible = false
	$Bow.visible = false
	$CollisionShape3D.set_deferred("disabled", true)
