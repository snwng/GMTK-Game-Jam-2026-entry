class_name Gun extends Weapon

@onready var timer: Timer = $Timer


func _ready() -> void:
	timer.wait_time = cooldown
	timer.one_shot = true
	timer.timeout.connect(func() -> void:
		can_fire = true
	)

func trigger_pressed(origin: Vector2, angle: float) -> void:
	if can_fire:
		can_fire = false
		var offset: Vector2 = Vector2.UP.rotated(angle) * Projectile_Spawn_Offset
		var bullet: Projectile = projectile.instantiate()
		bullet.position = origin + offset
		bullet.rotation = angle
		Global.game_manager.add_2D_node(bullet)
		timer.start()
