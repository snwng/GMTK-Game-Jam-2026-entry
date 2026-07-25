# bomb.gd
# A bomb thrown by the player. After a short fuse it explodes, dealing
# damage to every Entity inside a circular area around it.

extends Node2D

const EXPLOSION_FX: PackedScene = preload("res://scenes/particles/explosion_particles.tscn")

@export var fuse_time: float = 2.50
@export var explosion_damage: int = 50

@onready var fuse_timer: Timer = $Timer
@onready var explosion_area: Area2D = $ExplosionArea

func _ready() -> void:
	explosion_area.monitoring = false
	fuse_timer.wait_time = fuse_time
	fuse_timer.one_shot = true
	fuse_timer.timeout.connect(_explode)
	fuse_timer.start()

func _explode() -> void:
	Global.fx_manager.spawn_particles(EXPLOSION_FX, global_position)
	explosion_area.monitoring = true
	await get_tree().physics_frame
	for body in explosion_area.get_overlapping_bodies():
		if body is Entity:
			body.take_damage(explosion_damage)
	queue_free()
