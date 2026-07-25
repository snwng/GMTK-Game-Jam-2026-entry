# This script defines the behavior of a witch's projectile in the game. It handles movement, collision detection, and damage application to entities.
class_name SpellProjectile extends Node2D
const SPEED: float = 250.0
const LIFETIME: float = 3.0
const DAMAGE: int = 15
var timer: Timer
var hitbox: Area2D
var direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	hitbox = $Area2D
	timer = $Timer
	hitbox.body_entered.connect(_on_collision)
	timer.timeout.connect(_on_timeout)
	

func _physics_process(delta: float) -> void:
	position += direction * SPEED * delta

func _on_timeout() -> void:
	queue_free()

func _on_collision(body: Node2D) -> void:
	if body is Player:
		body.take_damage(DAMAGE)
		queue_free()
