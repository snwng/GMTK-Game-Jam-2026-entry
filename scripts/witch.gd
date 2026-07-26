# This script defines the behavior of a witch entity in the game.
class_name Witch extends Entity

var goal: Entity
@export var attack_damage: int = 15
@export var attack_range: float = 300.0 # wider range to attack from distance
@export var attack_cooldown: float = 2.0
var can_attack: bool = true
const SPELL_SCENE_PATH: String = "res://scenes/entities/spell_projectile.tscn"

func _init() -> void:
	VELOCITY = 70.0

func _ready() -> void:
	self.visible = true
	while not Global.game_manager or not Global.game_manager.player:
		await get_tree().process_frame
	goal = Global.game_manager.player
	$AnimatedSprite2D.play("idle")

func _process(_delta: float) -> void:
	if not is_alive():
		Global.game_manager.player.heal(10)
		get_parent().queue_free()

func _physics_process(delta: float) -> void:
	if goal and is_alive():
		var distance: float = global_position.distance_to(goal.global_position)
		var direction: Vector2 = (goal.global_position - global_position).normalized()

		# if the player is near, the witch goes away
		if distance < attack_range * 0.5:
			move(-direction, delta)
		elif distance > attack_range:
			move(direction, delta)
		else:
			move(Vector2.ZERO, delta)

		move_and_slide()
		_try_attack(direction)

		if direction.x != 0:
			$AnimatedSprite2D.flip_h = direction.x < 0

func _try_attack(direction: Vector2) -> void:
	if not can_attack or not goal:
		return
	if global_position.distance_to(goal.global_position) <= attack_range:
		$AnimatedSprite2D.play("attack")
		_cast_spell(direction)
		can_attack = false
		await get_tree().create_timer(0.2).timeout
		if is_alive():
			$AnimatedSprite2D.play("idle")
		await get_tree().create_timer(attack_cooldown - 0.2).timeout
		can_attack = true

func _cast_spell(direction: Vector2) -> void:
	var spell_scene: PackedScene = load(SPELL_SCENE_PATH)
	var spell: Node2D = spell_scene.instantiate()
	spell.direction = direction
	spell.rotation = direction.angle() + PI / 2.0 #this is just visual so that the sprite looks at the correct direction
	Global.game_manager.add_2D_node(spell)
	spell.global_position = global_position
