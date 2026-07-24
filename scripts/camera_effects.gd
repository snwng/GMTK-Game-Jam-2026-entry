class_name Camera extends Camera2D

@export var default_screen_shake_intensity: float = 5.0
@export var default_screen_shake_duration: float = 0.5
@export var shake_decay: float = 0.9
@export var noise_frequency: float = 2.0

var shake_intensity: float
var shake_time: float = 0.0
var total_shake_time: float = 0.0

var noise: FastNoiseLite = FastNoiseLite.new()

func _ready() -> void:
	randomize()
	noise.seed = randi()
	noise.frequency = noise_frequency


func _physics_process(delta: float) -> void:

	if shake_time > 0.0:
		shake_time -= delta
		offset = Vector2(
			noise.get_noise_2d(shake_time, 0) * shake_intensity,
			noise.get_noise_2d(0, shake_time) * shake_intensity
		)
		shake_intensity *= shake_decay
	else:
		offset = lerp(offset, Vector2.ZERO, delta * 5.0)


func screen_shake(
	intensity: float = default_screen_shake_intensity,
	duration: float = default_screen_shake_duration,
) -> void:
	randomize()
	noise.seed = randi()

	shake_intensity = intensity
	shake_time = duration
	total_shake_time = duration

func frame_freeze(duration: float) -> void:
	var original_time_scale: float = Engine.time_scale
	Engine.time_scale = 0.0
	await get_tree().create_timer(duration).timeout
	Engine.time_scale = original_time_scale
