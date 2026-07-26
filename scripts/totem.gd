# totem.gd
# Stationary magic totem. While alive, it doubles the player's time drain.
# Must be destroyed by the player to stop the effect.
class_name Totem extends Entity

@onready var sprite: Sprite2D = $Sprite2D
var glow_tween: Tween

func _init() -> void:
	MAX_HEALTH = 60 # ajustá según cuántos golpes querés que aguante
	health = MAX_HEALTH

func _ready() -> void:
	Global.time_drain_multiplier = 2.0
	_start_glow()



func _process(_delta: float) -> void:
	if not is_alive():
		Global.time_drain_multiplier = 1.0
		queue_free()

func _start_glow() -> void:
	glow_tween = create_tween()
	glow_tween.set_loops() # loop infinito
	glow_tween.tween_property(sprite, "modulate", Color(1.5, 1.1, 0.3), 0.5) # brillo naranja/amarillo
	glow_tween.tween_property(sprite, "modulate", Color(1, 1, 1), 0.5) # vuelve a color normal
