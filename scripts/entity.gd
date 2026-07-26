# This script defines a base class for all entities in the game, including players and enemies. It handles movement, health management, and basic entity behavior.
class_name Entity extends CharacterBody2D

@export var VELOCITY: float = 300.0
@export var ACCELERATION: float = 4000.0
@export var DECELERATION: float = 4000.0
@export var MAX_HEALTH: int = 100
@export var KNOCKBACK_FORCE: float = 500.0

var health: int = 100

const FLASH_COLOR: Color = Color(1, 0.3, 0.3) # reddish tint
const FLASH_DURATION: float = 0.15

func take_damage(amount: int, flash: bool = true) -> void:
	health -= amount
	health = max(health, 0)
	if flash:
		_flash_red()


func heal(amount: int) -> void:
	health += amount
	#health = min(health, MAX_HEALTH)


func move(direction: Vector2, delta: float) -> void:
	var rate: float = ACCELERATION if direction != Vector2.ZERO else DECELERATION
	velocity = velocity.move_toward(direction * VELOCITY, rate * delta)


func is_alive() -> bool:
	return health > 0

func knocback(direction: Vector2, force: float = KNOCKBACK_FORCE) -> void:
	velocity += direction.normalized() * force

func _flash_red() -> void:
	var sprite: CanvasItem = _get_visual_node()
	if not sprite:
		return
	var tween: Tween = create_tween()
	tween.tween_property(sprite, "modulate", FLASH_COLOR, 0.0) # instant tint
	tween.tween_property(sprite, "modulate", Color.WHITE, FLASH_DURATION)

func _get_visual_node() -> CanvasItem:
	# Both Player and Enemy use an AnimatedSprite2D named "AnimatedSprite2D"
	if has_node("AnimatedSprite2D"):
		return $AnimatedSprite2D
	return null
