extends CharacterBody3D

const SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 5
const MOUSE_SENSITIVITY = 0.002
const FOOTSTEP_INTERVAL = 0.4
const SPRINT_FOOTSTEP_INTERVAL = 0.28
const STEP_HEIGHT = 0.3
const STEP_CHECK_DISTANCE = 0.5
const FOOT_OFFSET = 0.15
const SWING_TIME = 0.25
const TOWN_ENTRANCE := Vector3(0, -99, 14)

@onready var head: Node3D = $Head
@onready var footstep_player: AudioStreamPlayer3D = $FootstepPlayer
@onready var sprint_footstep_player: AudioStreamPlayer3D = $SprintFootstepPlayer
@onready var jump_player: AudioStreamPlayer3D = $JumpPlayer
@onready var sword: Node3D = $Head/Camera3D/Sword
@onready var sword_hitbox: Area3D = $Head/Camera3D/Sword/SwordHitbox
@onready var sword_swing_sound: AudioStreamPlayer3D = $SwordSwingSound
@onready var death_sound: AudioStreamPlayer3D = $DeathSound

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var footstep_timer := 0.1
var has_sword := false
var swinging := false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	GameState.all_items_collected.connect(_on_all_items_collected)
	GameState.all_manor_trees_launched.connect(_on_all_manor_trees_launched)

func _on_all_items_collected() -> void:
	grant_sword()

func _on_all_manor_trees_launched() -> void:
	global_position = TOWN_ENTRANCE

func grant_sword() -> void:
	has_sword = true
	sword.visible = true

func play_death_sound() -> void:
	if death_sound.stream:
		death_sound.play()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		head.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		head.rotation.x = clamp(head.rotation.x, -PI / 2, PI / 2)
	if has_sword and not swinging and event.is_action_pressed("attack"):
		_swing_sword()

func _swing_sword() -> void:
	swinging = true
	if sword_swing_sound.stream:
		sword_swing_sound.play()
	var tween := create_tween()
	tween.tween_property(sword, "rotation:x", sword.rotation.x - 1.2, SWING_TIME * 0.5)
	tween.tween_callback(_check_sword_hit)
	tween.tween_property(sword, "rotation:x", sword.rotation.x, SWING_TIME * 0.5)
	tween.tween_callback(func(): swinging = false)

func _check_sword_hit() -> void:
	for area in sword_hitbox.get_overlapping_areas():
		var target := area.get_parent()
		if target.has_method("take_damage"):
			target.take_damage(1)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		if jump_player.stream:
			jump_player.play()

	var is_sprinting := Input.is_action_pressed("sprint")
	var speed := SPRINT_SPEED if is_sprinting else SPEED

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	if is_on_floor() and direction:
		footstep_timer -= delta
		if footstep_timer <= 0.0:
			footstep_timer = SPRINT_FOOTSTEP_INTERVAL if is_sprinting else FOOTSTEP_INTERVAL
			var step_player := sprint_footstep_player if is_sprinting else footstep_player
			if step_player.stream:
				step_player.play()
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
