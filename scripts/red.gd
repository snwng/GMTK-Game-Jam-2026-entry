class_name Red extends Entity

var goal: Entity

const SPELL_SCENE_PATH: String = "res://scenes/entities/red_projectile.tscn"
const TOTEM_SCENE_PATH: String = "res://scenes/entities/totem.tscn"

const BARRAGE_1_DURATION: float = 3.0
const TOTEM_WAIT_DURATION: float = 4.0
const BARRAGE_2_DURATION: float = 4.0
const KEEP_DISTANCE: float = 250.0
const PAUSE_BETWEEN_CASTS: float = 0.3
const ATTACKS_PER_BARRAGE: int = 4
const SPREAD_ANGLE: float = 0.25 # radianes de apertura entre cada tiro de la ráfaga de 5

enum AttackType { SINGLE, BURST }
var current_attack_type: int = AttackType.SINGLE
var fired_frames: Dictionary = {}
var is_casting: bool = false

var is_dying: bool = false

func _init() -> void:
	VELOCITY = 60.0 # doble de la velocidad anterior (30.0)
	MAX_HEALTH = 800
	health = MAX_HEALTH

func _ready() -> void:
	self.visible = true
	while not Global.game_manager or not Global.game_manager.player:
		await get_tree().process_frame
	goal = Global.game_manager.player
	$AnimatedSprite2D.play("idle")
	$AnimatedSprite2D.frame_changed.connect(_on_frame_changed)
	_run_cycle()

func _process(_delta: float) -> void:
	if not is_alive() and not is_dying:
		is_dying = true
		_die()



func _physics_process(delta: float) -> void:
	if not goal or not is_alive() or is_casting:
		return

	var distance: float = global_position.distance_to(goal.global_position)
	var direction: Vector2 = (goal.global_position - global_position).normalized()

	if distance < KEEP_DISTANCE:
		move(-direction, delta)
	elif distance > KEEP_DISTANCE + 50.0:
		move(direction, delta)
	else:
		move(Vector2.ZERO, delta)

	move_and_slide()

	if direction.x != 0:
		$AnimatedSprite2D.flip_h = direction.x > 0

# --- Main phase cycle (runs forever while the boss is alive) ---

func _run_cycle() -> void:
	while is_alive():
		await _run_barrage()
		if not is_alive():
			return
		_spawn_totem()
		await get_tree().create_timer(TOTEM_WAIT_DURATION).timeout

func _run_barrage() -> void:
	# 2 ataques simples y 2 en abanico, en orden aleatorio
	var attack_sequence: Array[int] = [
		AttackType.SINGLE, AttackType.SINGLE,
		AttackType.BURST, AttackType.BURST,
	]
	attack_sequence.shuffle()

	for i in range(ATTACKS_PER_BARRAGE):
		if not is_alive():
			return
		current_attack_type = attack_sequence[i]
		fired_frames.clear()
		is_casting = true
		$AnimatedSprite2D.play("tira_proyectil")
		await $AnimatedSprite2D.animation_finished
		is_casting = false
		if is_alive():
			$AnimatedSprite2D.play("idle")
		await get_tree().create_timer(PAUSE_BETWEEN_CASTS).timeout

# --- Frame-based firing ---
func _on_frame_changed() -> void:
	if $AnimatedSprite2D.animation != "tira_proyectil":
		return
	var frame: int = $AnimatedSprite2D.frame
	if fired_frames.has(frame):
		return

	match current_attack_type:
		AttackType.SINGLE:
			if frame in [2, 3, 4, 5]: # frames 3ro al 6to (1-indexado)
				_fire_single_spell()
				fired_frames[frame] = true
		AttackType.BURST:
			if frame == 2: # solo en el 3er frame
				_fire_burst_spell(5)
				fired_frames[frame] = true

func _fire_single_spell() -> void:
	if not goal:
		return
	var direction: Vector2 = (goal.global_position - global_position).normalized()
	_spawn_spell(direction)

func _fire_burst_spell(count: int) -> void:
	if not goal:
		return
	var base_direction: Vector2 = (goal.global_position - global_position).normalized()
	var base_angle: float = base_direction.angle()
	var half: int = count / 2
	for i in range(count):
		var offset: float = (i - half) * SPREAD_ANGLE
		var spell_direction: Vector2 = Vector2.RIGHT.rotated(base_angle + offset)
		_spawn_spell(spell_direction)

func _spawn_spell(direction: Vector2) -> void:
	var spell_scene: PackedScene = load(SPELL_SCENE_PATH)
	var spell: Node2D = spell_scene.instantiate()
	spell.direction = direction
	spell.rotation = direction.angle() + PI / 2.0
	Global.game_manager.add_2D_node(spell)
	spell.global_position = global_position

func _spawn_totem() -> void:
	var totem_scene: PackedScene = load(TOTEM_SCENE_PATH)
	var totem: Node2D = totem_scene.instantiate()
	Global.game_manager.add_2D_node(totem)
	totem.global_position = global_position + Vector2(100, 0)
	
func _die() -> void:
	$AnimatedSprite2D.play("muere")
	await $AnimatedSprite2D.animation_finished
	Global.game_manager.on_boss_defeated()
	get_parent().queue_free()	
