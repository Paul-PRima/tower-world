extends RigidBody3D

@export var launch_force: float = 30.0
@export var despawn_delay: float = 15.0

var player_in_range := false
var launched := false

func _ready() -> void:
	$InteractArea.body_entered.connect(_on_body_entered)
	$InteractArea.body_exited.connect(_on_body_exited)

func _unhandled_input(event: InputEvent) -> void:
	if player_in_range and not launched and event.is_action_pressed("interact"):
		_launch()

func _launch() -> void:
	launched = true
	freeze = false
	apply_central_impulse(Vector3(randf_range(-2.0, 2.0), launch_force, randf_range(-2.0, 2.0)))
	apply_torque_impulse(Vector3(randf_range(-5.0, 5.0), randf_range(-5.0, 5.0), randf_range(-5.0, 5.0)))
	if $InteractSound.stream:
		$InteractSound.play()
	get_tree().create_timer(despawn_delay).timeout.connect(queue_free)

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		player_in_range = true

func _on_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D:
		player_in_range = false
