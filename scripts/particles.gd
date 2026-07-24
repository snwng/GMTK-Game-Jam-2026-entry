class_name Particles extends Node2D


func _ready() -> void:
	$GPUParticles2D.finished.connect(queue_free)

func start() -> void:
	$GPUParticles2D.emitting = true
