# This script is attached to the Weapon node and handles the firing of projectiles.
class_name Weapon extends Node2D

@export var Projectile_Spawn_Offset: float = 50.0
@export var cooldown: float = 0.25

var can_fire: bool = true


func trigger_pressed(_origin: Vector2 = global_position, _angle: float = rotation) -> void:
	pass


func trigger_released(_origin: Vector2 = global_position, _angle: float = rotation) -> void:
	pass
