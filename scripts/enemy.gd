# This script defines the behavior of an enemy entity in the game.
class_name Enemy extends Entity

var goal: Entity

func _init() -> void:
	VELOCITY = 50.0

func _ready() -> void:
	self.visible = true
	await get_tree().process_frame
	goal = Global.game_manager.player
	$AnimatedSprite2D.play("idle")

func _process(_delta: float) -> void:
	if not is_alive():
		get_parent().queue_free()

func _physics_process(delta: float) -> void:
	if goal and is_alive():
		var direction: Vector2 = (goal.global_position - global_position).normalized()
		move(direction, delta)
		move_and_slide()
