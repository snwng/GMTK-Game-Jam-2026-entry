# This script defines the behavior of an enemy_golem entity in the game.


# This script defines the behavior of an enemy_golem entity in the game.
class_name Brute extends Entity

var goal: Entity
@export var attack_damage: int = 10
@export var attack_range: float = 60.0
@export var attack_cooldown: float = 1.0

var is_retreating: bool = false
const RETREAT_DISTANCE: float = 5.0
const RETREAT_SPEED: float = 80.0
const ATTACK_ANIM_DURATION: float = 0.15 

var can_attack: bool = true

# Referencia directa al nodo
@onready var hit_audio: AudioStreamPlayer = $AudioStreamPlayer


func _init() -> void:
	VELOCITY = 25.0
	MAX_HEALTH = 350
	health = MAX_HEALTH


func _ready() -> void:
	self.visible = true
	while not Global.game_manager or not Global.game_manager.player:
		await get_tree().process_frame
	goal = Global.game_manager.player
	$AnimatedSprite2D.play("idle")


func _process(_delta: float) -> void:
	if not is_alive():
		Global.game_manager.player.heal(15)
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
			$AnimatedSprite2D.flip_h = direction.x < 0


func _try_attack() -> void:
	if not can_attack or not goal:
		return
		
	if global_position.distance_to(goal.global_position) <= attack_range:
		can_attack = false
		$AnimatedSprite2D.play("attack")
		
		# Aplica daño al jugador
		goal.take_damage(attack_damage)
		
		# Suena siempre al pegar
		if has_node("AudioStreamPlayer"):
			$AudioStreamPlayer.pitch_scale = randf_range(0.8, 1.1)
			$AudioStreamPlayer.play()

		await get_tree().create_timer(ATTACK_ANIM_DURATION).timeout
		if is_alive():
			$AnimatedSprite2D.play("idle")
			
		is_retreating = true
		await get_tree().create_timer(RETREAT_DISTANCE / RETREAT_SPEED).timeout
		is_retreating = false
		await get_tree().create_timer(max(attack_cooldown - ATTACK_ANIM_DURATION - (RETREAT_DISTANCE / RETREAT_SPEED), 0.0)).timeout
		can_attack = true

#class_name Brute extends Entity
#
#var goal: Entity
#@export var attack_damage: int = 10
#@export var attack_range: float = 60.0
#@export var attack_cooldown: float = 1.0
#
#var is_retreating: bool = false
#const RETREAT_DISTANCE: float = 5.0
#const RETREAT_SPEED: float = 80.0
#const ATTACK_ANIM_DURATION: float = 0.15 
#
#var can_attack: bool = true
#var damage_dealt_this_attack: bool = false
#
#func _init() -> void:
	#VELOCITY = 25.0
	#MAX_HEALTH = 300
	#health = MAX_HEALTH
#
#func _ready() -> void:
	#self.visible = true
	#while not Global.game_manager or not Global.game_manager.player:
		#await get_tree().process_frame
	#goal = Global.game_manager.player
	#$AnimatedSprite2D.play("idle")
	#$AnimatedSprite2D.frame_changed.connect(_on_frame_changed)
#
#func _process(_delta: float) -> void:
	#if not is_alive():
		#Global.game_manager.player.heal(15)
		#get_parent().queue_free()
#
#func _physics_process(delta: float) -> void:
	#if goal and is_alive():
		#var distance: float = global_position.distance_to(goal.global_position)
		#var direction: Vector2 = (goal.global_position - global_position).normalized()
#
		#if is_retreating:
			#velocity = -direction * RETREAT_SPEED
		#elif distance > attack_range:
			#move(direction, delta)
		#else:
			#move(Vector2.ZERO, delta)
#
		#move_and_slide()
		#if not is_retreating:
			#_try_attack()
#
		#if direction.x != 0:
			#$AnimatedSprite2D.flip_h = direction.x < 0
#
#func _try_attack() -> void:
	#if not can_attack or not goal:
		#return
	#if global_position.distance_to(goal.global_position) <= attack_range:
		#damage_dealt_this_attack = false
		#$AnimatedSprite2D.play("attack")
		#await get_tree().create_timer(ATTACK_ANIM_DURATION).timeout
		#if is_alive():
			#$AnimatedSprite2D.play("idle")
		#is_retreating = true
		#await get_tree().create_timer(RETREAT_DISTANCE / RETREAT_SPEED).timeout
		#is_retreating = false
		#await get_tree().create_timer(max(attack_cooldown - ATTACK_ANIM_DURATION - (RETREAT_DISTANCE / RETREAT_SPEED), 0.0)).timeout
		#can_attack = true
#
#
#func _on_frame_changed() -> void:
	#if $AnimatedSprite2D.animation != "attack":
		#return
	#if $AnimatedSprite2D.frame == 1 and not damage_dealt_this_attack: # frame 1 = segundo frame (0-indexado)
		#if goal and global_position.distance_to(goal.global_position) <= attack_range:
			#goal.take_damage(attack_damage)
			#damage_dealt_this_attack = true
