# This script defines the behavior of an enemy entity in the game.
class_name Enemy extends Entity

var goal: Entity
@export var attack_damage: int = 10
@export var attack_range: float = 30.0
@export var attack_cooldown: float = 1.0

var is_retreating: bool = false
const RETREAT_DISTANCE: float = 5.0
const RETREAT_SPEED: float = 100.0
const ATTACK_ANIM_DURATION: float = 0.15 

var can_attack: bool = true

func _init() -> void:
	VELOCITY = 50.0

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

		if is_retreating:
			velocity = -direction * RETREAT_SPEED
		elif distance > attack_range:
			move(direction, delta)
		else:
			move(Vector2.ZERO, delta)

		move_and_slide()
		if not is_retreating:
			_try_attack()

		if direction.x != 0:
			$AnimatedSprite2D.flip_h = direction.x > 0



func _try_attack() -> void:
	if not can_attack or not goal:
		return
	if global_position.distance_to(goal.global_position) <= attack_range:
		$AnimatedSprite2D.play("attack")
		goal.take_damage(attack_damage)
		
		# 80% de probabilidad (0.8) y comprobación de seguridad para evitar errores 'null'
		if is_alive() and randf() <= 0.99 and has_node("AudioStreamPlayer2D") and is_instance_valid($AudioStreamPlayer2D):
			$AudioStreamPlayer2D.pitch_scale = randf_range(0.85, 1.15)
			$AudioStreamPlayer2D.play()

		can_attack = false
		await $AnimatedSprite2D.animation_finished
		await get_tree().create_timer(ATTACK_ANIM_DURATION).timeout
		
		# Verificación extra por si murió durante los 'await'
		if is_alive():
			$AnimatedSprite2D.play("idle")
			
		is_retreating = true
		await get_tree().create_timer(RETREAT_DISTANCE / RETREAT_SPEED).timeout
		is_retreating = false
		await get_tree().create_timer(max(attack_cooldown - ATTACK_ANIM_DURATION - (RETREAT_DISTANCE / RETREAT_SPEED), 0.0)).timeout
		can_attack = true



#func _try_attack() -> void:
	#if not can_attack or not goal:
		#return
	#if global_position.distance_to(goal.global_position) <= attack_range:
		#$AnimatedSprite2D.play("attack")
		#goal.take_damage(attack_damage)
		#can_attack = false
		#await $AnimatedSprite2D.animation_finished
		#await get_tree().create_timer(ATTACK_ANIM_DURATION).timeout
		#if is_alive():
			#$AnimatedSprite2D.play("idle")
		#is_retreating = true
		#await get_tree().create_timer(RETREAT_DISTANCE / RETREAT_SPEED).timeout
		#is_retreating = false
		#await get_tree().create_timer(max(attack_cooldown - ATTACK_ANIM_DURATION - (RETREAT_DISTANCE / RETREAT_SPEED), 0.0)).timeout
		#can_attack = true
