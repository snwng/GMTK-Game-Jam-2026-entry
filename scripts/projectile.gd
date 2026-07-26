# This script defines the behavior of a bullet in the game. It handles movement, collision detection, and damage application to entities.
class_name Projectile extends Node2D

const SPEED: float = 350.0
const LIFETIME: float = 2.0
const DAMAGE: int = 50

var timer: Timer
var hitbox: Area2D
var direction: Vector2

# Referencias directas a tus nodos de sonido
@onready var shoot_audio: AudioStreamPlayer2D = $ShootAudio
@onready var hit_audio: AudioStreamPlayer2D = $HitAudio


func _ready() -> void:
	hitbox = $Area2D
	timer = $Timer
	hitbox.body_entered.connect(_on_collision)
	timer.timeout.connect(_on_timeout)
	direction = (Transform2D(transform.x, transform.y, Vector2.ZERO) * Vector2.RIGHT).normalized()
	scale *= Global.bullet_scale_multiplier

	## 1/10 probabilidades de sonar al disparar
	#if randf() <= 0.1 and shoot_audio.stream:
		#_play_node_sound(shoot_audio)


func _physics_process(delta: float) -> void:
	position += direction * SPEED * delta


func _on_timeout() -> void:
	queue_free()


func _on_collision(body: Node2D) -> void:
	if body is Entity:
		body.take_damage(int(DAMAGE * Global.damage_multiplier))
		body.knocback(global_position.direction_to(body.global_position))
	
	# 1/10 probabilidades de sonar al pegar
	#if randf() <= 0.1 and hit_audio.stream:
	_play_node_sound(hit_audio)

	Global.fx_manager.spawn_particles(Global.fx_manager.HITFX, global_position, rotation - PI / 2)
	Global.game_manager.player.camera.screen_shake() 
	
	queue_free() # La bala muere, pero el audio sigue vivo porque lo sacamos del árbol de la bala


# Función auxiliar para reproducir tu nodo
func _play_node_sound(audio_node: AudioStreamPlayer2D) -> void:
	audio_node.pitch_scale = randf_range(0.85, 1.15) # Pitch aleatorio
	
	# TRUCO DE JAM: Lo sacamos del proyectil y lo movemos a la escena principal 
	# para que no se corte cuando el proyectil ejecute queue_free()
	audio_node.reparent(get_tree().current_scene)
	audio_node.play()
	
	# Se destruye solo cuando termine de sonar
	audio_node.finished.connect(audio_node.queue_free)





#class_name Projectile extends Node2D
#
#const SPEED: float = 350.0
#const LIFETIME: float = 2.0
#const DAMAGE: int = 50
#
#var timer: Timer
#var hitbox: Area2D
#var direction: Vector2
#
#
#func _ready() -> void:
	#hitbox = $Area2D
	#timer = $Timer
	#hitbox.body_entered.connect(_on_collision)
	#timer.timeout.connect(_on_timeout)
	#direction = (Transform2D(transform.x, transform.y, Vector2.ZERO) * Vector2.RIGHT).normalized() # Get the direction the bullet is facing
	#scale *= Global.bullet_scale_multiplier
#
#func _physics_process(delta: float) -> void:
	#position += direction * SPEED * delta
#
#
#func _on_timeout() -> void:
	#queue_free()
#
#
#func _on_collision(body: Node2D) -> void:
	#if body is Entity:
		#body.take_damage(int(DAMAGE * Global.damage_multiplier)) #Neon: this change is for the upgrades
		#body.knocback(global_position.direction_to(body.global_position))
	#queue_free()
	#Global.fx_manager.spawn_particles(Global.fx_manager.HITFX, global_position, rotation - PI / 2)
	#Global.game_manager.player.camera.screen_shake()
