# This script defines a base class for all entities in the game, including players and enemies. It handles movement, health management, and basic entity behavior.
class_name Entity extends CharacterBody2D

@export var VELOCITY: float = 300.0
@export var ACCELERATION: float = 4000.0
@export var DECELERATION: float = 4000.0
@export var MAX_HEALTH: int = 100

var health: int = 100


func take_damage(amount: int) -> void:
	health -= amount
	health = max(health, 0)


func heal(amount: int) -> void:
	health += amount
	health = min(health, MAX_HEALTH)


func move(direction: Vector2, delta: float) -> void:
	var rate: float = ACCELERATION if direction != Vector2.ZERO else DECELERATION
	velocity = velocity.move_toward(direction * VELOCITY, rate * delta)


func is_alive() -> bool:
	return health > 0
