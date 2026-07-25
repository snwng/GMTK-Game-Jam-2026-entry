# This script defines the behavior of a bullet in the game. It handles movement, collision detection, and damage application to entities.
class_name Projectile extends Node2D

const SPEED: float = 350.0
const LIFETIME: float = 2.0
const DAMAGE: int = 50

var timer: Timer
var hitbox: Area2D
var direction: Vector2


func _ready() -> void:
	hitbox = $Area2D
	timer = $Timer
	hitbox.body_entered.connect(_on_collision)
	timer.timeout.connect(_on_timeout)
	direction = (Transform2D(transform.x, transform.y, Vector2.ZERO) * Vector2.RIGHT).normalized() # Get the direction the bullet is facing
	scale *= Global.bullet_scale_multiplier

func _physics_process(delta: float) -> void:
	position += direction * SPEED * delta


func _on_timeout() -> void:
	queue_free()


func _on_collision(body: Node2D) -> void:
	if body is Entity:
		body.take_damage(int(DAMAGE * Global.damage_multiplier)) #Neon: this change is for the upgrades
	queue_free()
	Global.fx_manager.spawn_particles(Global.fx_manager.HITFX, global_position, rotation - PI / 2)
	Global.game_manager.player.camera.screen_shake()
