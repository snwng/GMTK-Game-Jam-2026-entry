class_name FX_Manager extends Node


const HITFX: PackedScene = preload("res://scenes/particles/hit_particles.tscn")
const EXPLOSTION: PackedScene = preload("res://scenes/particles/explosion_particles.tscn")


func _ready() -> void:
	Global.fx_manager = self


func spawn_particles(particle_scene: PackedScene, position: Vector2, rotation: float = 0.0) -> void:
	if not particle_scene:
		print("Error: Particle scene is null")
		return
	var particles: Particles = particle_scene.instantiate()
	particles.position = position
	particles.rotation = rotation
	Global.game_manager.add_2D_node(particles)
	particles.start()
