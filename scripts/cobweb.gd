extends StaticBody3D

@export var health: int = 1

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var hurt_collision: CollisionShape3D = $HurtArea/CollisionShape3D

func take_damage(amount: int) -> void:
	if health <= 0:
		return
	health -= amount
	if health <= 0:
		if $DestroySound.stream:
			$DestroySound.play()
		mesh_instance.visible = false
		collision_shape.set_deferred("disabled", true)
		hurt_collision.set_deferred("disabled", true)
