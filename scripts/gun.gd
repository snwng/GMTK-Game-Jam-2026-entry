class_name Gun extends Weapon

@onready var timer: Timer = $Timer
@export var projectile: PackedScene


func _ready() -> void:
	timer.wait_time = cooldown
	timer.one_shot = true
	timer.timeout.connect(func() -> void:
		can_fire = true
	)

func trigger_pressed(origin: Vector2 = global_position, angle: float = rotation) -> void:
	if can_fire:
		can_fire = false
		var offset: Vector2 = Vector2.RIGHT.rotated(angle) * Projectile_Spawn_Offset
		var bullet: Projectile = projectile.instantiate()
		bullet.position = origin + offset
		bullet.rotation = angle
		Global.game_manager.add_2D_node(bullet)
		timer.start()

func _process(_delta: float) -> void:
	orient_weapon()

func orient_weapon() -> void:
	var angle: float = fposmod(rotation, TAU)
	print("Angle: ", angle)
	if angle > PI / 2 and angle < 3 * PI / 2:
		$Sprite2D.flip_v = true
	else:
		$Sprite2D.flip_v = false
