# This script defines the behavior of a bullet in the game. It handles movement, collision detection, and damage application to entities.
class_name Projectile extends Node2D

const SPEED: float = 500.0
const LIFETIME: float = 2.0
const DAMAGE: int = 10

var timer: Timer
var hitbox: Area2D
var direction: Vector2


func _ready() -> void:
	hitbox = $Area2D
	timer = $Timer
	hitbox.body_entered.connect(_on_collision)
	timer.timeout.connect(_on_timeout)
	direction = (Transform2D(transform.x, transform.y, Vector2.ZERO) * Vector2.UP).normalized() # Get the direction the bullet is facing

func _physics_process(delta: float) -> void:
	position += direction * SPEED * delta


func _on_timeout() -> void:
	queue_free()


func _on_collision(body: Node2D) -> void:
	if body is Entity:
		body.take_damage(int(DAMAGE * Global.damage_multiplier)) #Neon: this change is for the upgrades
	queue_free()
