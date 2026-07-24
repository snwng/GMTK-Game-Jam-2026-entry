# This script defines the behavior of an enemy entity in the game.
class_name Enemy extends Entity


func _ready() -> void:
	self.visible = true
	await get_tree().process_frame
	$AnimatedSprite2D.play("idle")
