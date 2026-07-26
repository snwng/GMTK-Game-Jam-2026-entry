# This script defines the behavior of a witch's projectile in the game. It handles movement, collision detection, and damage application to entities.
class_name SpellProjectile extends Node2D
const SPEED: float = 250.0
const LIFETIME: float = 3.0
const DAMAGE: int = 15


# Referencias directas a tus nodos de sonido
@onready var shoot_audio: AudioStreamPlayer2D = $ShootAudio
@onready var hit_audio: AudioStreamPlayer2D = $HitAudio

var timer: Timer
var hitbox: Area2D
var direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	hitbox = $Area2D
	timer = $Timer
	hitbox.body_entered.connect(_on_collision)
	timer.timeout.connect(_on_timeout)

	# 3/10 probabilidades de sonar al disparar porque va a haber muchas brujas
	if randf() <= 0.3 and shoot_audio.stream:
		_play_node_sound(shoot_audio)	

func _physics_process(delta: float) -> void:
	position += direction * SPEED * delta

func _on_timeout() -> void:
	queue_free()

func _on_collision(body: Node2D) -> void:
	if body is Player:
		body.take_damage(DAMAGE)
		# 9/10 probabilidades de sonar al impactar
		if randf() <= 0.90 and hit_audio.stream:
			_play_node_sound(hit_audio)
			
		queue_free()

# Función que independiza el audio del proyectil y le aplica el pitch aleatorio
func _play_node_sound(audio_node: AudioStreamPlayer2D) -> void:
	audio_node.pitch_scale = randf_range(0.85, 1.15)
	audio_node.reparent(get_tree().current_scene)
	audio_node.play()
	audio_node.finished.connect(audio_node.queue_free)		
