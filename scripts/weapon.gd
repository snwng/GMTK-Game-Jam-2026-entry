class_name Weapon extends Node2D

@export var Projectile_Spawn_Offset: float = 90.0
@export var projectile: PackedScene
@export var cooldown: float = 0.5

var can_fire: bool = true


func trigger_pressed(_origin: Vector2, _angle: float) -> void:
	pass


func trigger_released(_origin: Vector2, _angle: float) -> void:
	pass
