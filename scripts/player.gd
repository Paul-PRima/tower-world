extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.002
const FOOTSTEP_INTERVAL = 0.4
const STEP_HEIGHT = 0.3
const STEP_CHECK_DISTANCE = 0.5
const FOOT_OFFSET = 0.15

@onready var head: Node3D = $Head
@onready var footstep_player: AudioStreamPlayer3D = $FootstepPlayer
@onready var jump_player: AudioStreamPlayer3D = $JumpPlayer

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var footstep_timer := 0.1

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		head.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		head.rotation.x = clamp(head.rotation.x, -PI / 2, PI / 2)
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		if jump_player.stream:
			jump_player.play()

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	if is_on_floor() and direction:
		footstep_timer -= delta
		if footstep_timer <= 0.0:
			footstep_timer = FOOTSTEP_INTERVAL
			if footstep_player.stream:
				footstep_player.play()
	else:
		footstep_timer = 0.0

	_apply_step_up()
	move_and_slide()

func _apply_step_up() -> void:
	if not is_on_floor():
		return
	var horizontal := Vector3(velocity.x, 0, velocity.z)
	if horizontal.length() < 0.1:
		return
	var motion_dir := horizontal.normalized()
	var space_state := get_world_3d().direct_space_state

	var from_low := global_position + Vector3(0, -0.9 + FOOT_OFFSET, 0)
	var query_low := PhysicsRayQueryParameters3D.create(from_low, from_low + motion_dir * STEP_CHECK_DISTANCE)
	query_low.exclude = [self]
	if space_state.intersect_ray(query_low).is_empty():
		return

	var from_high := global_position + Vector3(0, -0.9 + STEP_HEIGHT, 0)
	var query_high := PhysicsRayQueryParameters3D.create(from_high, from_high + motion_dir * STEP_CHECK_DISTANCE)
	query_high.exclude = [self]
	if space_state.intersect_ray(query_high).is_empty():
		global_position.y += STEP_HEIGHT
