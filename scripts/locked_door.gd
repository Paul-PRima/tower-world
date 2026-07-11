extends StaticBody3D

@export var open_angle_deg: float = 100.0
@export var swing_speed: float = 4.0
@export var required_keys: int = 3

var is_open := false
var target_angle := 0.0
var player_in_range := false

func _ready() -> void:
	$InteractArea.body_entered.connect(_on_body_entered)
	$InteractArea.body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	rotation.y = lerp_angle(rotation.y, deg_to_rad(target_angle), swing_speed * delta)

func _unhandled_input(event: InputEvent) -> void:
	if player_in_range and event.is_action_pressed("interact"):
		if GameState.collected_keys.size() < required_keys:
			if $DeniedSound.stream:
				$DeniedSound.play()
			return
		is_open = not is_open
		target_angle = open_angle_deg if is_open else 0.0
		if $InteractSound.stream:
			$InteractSound.play()

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		player_in_range = true

func _on_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D:
		player_in_range = false
