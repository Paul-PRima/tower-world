extends CharacterBody3D

@export var max_health: int = 10
@export var attack_interval: float = 2.0
@export var parkour_reset_position := Vector3(5, -19, 5)
@export var move_speed: float = 3.0
@export var detection_range: float = 15.0
@export var attack_range: float = 3.0
@export var maze_entrance := Vector3(-10, -59, -10)

var health: int
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var attack_area: Area3D = $AttackArea
@onready var attack_timer: Timer = $AttackTimer
@onready var weapon: Node3D = $Weapon

func _ready() -> void:
	health = max_health
	attack_timer.wait_time = attack_interval
	attack_timer.timeout.connect(_on_attack_timer_timeout)

func _physics_process(_float) -> void:
	var player := get_tree().get_first_node_in_group("player")
	velocity.x = 0.0
	velocity.z = 0.0

	if player:
		var to_player: Vector3 = player.global_position - global_position
		to_player.y = 0.0
		var distance := to_player.length()

		if distance > 0.1:
			var flat_target := Vector3(player.global_position.x, global_position.y, player.global_position.z)
			look_at(flat_target, Vector3.UP)

		if distance < detection_range and distance > attack_range * 0.7:
			var dir := to_player.normalized()
			velocity.x = dir.x * move_speed
			velocity.z = dir.z * move_speed

	move_and_slide()

func take_damage(amount: int) -> void:
	if health <= 0:
		return
	health -= amount
	if $HitSound.stream:
		$HitSound.play()
	if health <= 0:
		var player := get_tree().get_first_node_in_group("player")
		if player:
			player.global_position = maze_entrance
		queue_free()

func _on_attack_timer_timeout() -> void:
	for body in attack_area.get_overlapping_bodies():
		if body is CharacterBody3D and body != self:
			_swing_weapon()
			body.global_position = parkour_reset_position
			break

func _swing_weapon() -> void:
	var tween := create_tween()
	tween.tween_property(weapon, "rotation:x", weapon.rotation.x - 0.8, 0.15)
	tween.tween_property(weapon, "rotation:x", weapon.rotation.x, 0.15)
