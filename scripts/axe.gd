# axe.gd
# Orbits around its parent (the player), dealing damage once per full
# revolution to each body it touches. Meant to be added as a child of Player.
extends Node2D

@export var radius: float = 60.0
@export var rotation_speed: float = 3.0 # radians per second
@export var damage: int = 15

@onready var hit_area: Area2D = $HitArea

var angle: float = 0.0
var hit_this_lap: Dictionary = {} # bodies already damaged in the current orbit

func _ready() -> void:
	hit_area.body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	angle += rotation_speed * delta
	if angle >= TAU:
		angle -= TAU
		hit_this_lap.clear() # new lap starts, everyone can be hit again
	position = Vector2.RIGHT.rotated(angle) * radius

func _on_body_entered(body: Node2D) -> void:
	if body == get_parent():
		return # don't hit the player itself
	if hit_this_lap.has(body):
		return # already hit this lap, skip
	if body is Entity:
		body.take_damage(damage)
		hit_this_lap[body] = true
