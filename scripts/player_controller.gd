# This script defines the behavior of the player character in the game. It handles input, movement, and weapon firing.
class_name Player extends Entity

@export var weapon: Weapon
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


var camera: Camera

var mouse_captured: bool = false
var can_interact: bool = true # This variable can be used to disable player interaction when needed, such as during cutscenes, dialogues, pauses, etc.
var is_mouse_form: bool = false # true after the Mouse Morph upgrade is applied

# Super Bomb ability (unlocked via upgrade, thrown with right click)
var has_super_bomb: bool = false
var bomb_ready: bool = true
const BOMB_COOLDOWN: float = 10.0
const BOMB_SCENE_PATH: String = "res://scenes/Super_bomb.tscn"

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_weapon(event.position)
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		_throw_bomb()	


func capture_mouse() -> void:
	mouse_captured = true
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED


func release_mouse() -> void:
	mouse_captured = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func set_weapon(new_weapon: Weapon) -> void:
	if weapon:
		weapon.queue_free()
	weapon = new_weapon
	add_child(weapon)


func rotate_weapon(mouse: Vector2) -> void:
	if mouse_captured and can_interact:
		var center: Vector2 = get_global_transform_with_canvas().get_origin()
		var direction: Vector2 = mouse - center
		var angle: float = atan2(direction.y, direction.x)
		weapon.rotation = angle


func _ready() -> void:
	Global.game_manager.player = self
	camera = $Camera2D
	capture_mouse()
	var gun: PackedScene = load("res://scenes/entities/gun.tscn")
	set_weapon(gun.instantiate())



func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("unfocus"):
		release_mouse()
		weapon.trigger_released(global_position, rotation)
	elif Input.is_action_just_pressed("fire"):
		if mouse_captured:
			if can_interact:
				weapon.trigger_pressed(global_position)
		else:
			capture_mouse()
	elif Input.is_action_just_released("fire"):
		if mouse_captured:
			weapon.trigger_released(global_position, rotation)
	_update_animation()

func _physics_process(delta: float) -> void:
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down") if can_interact else Vector2.ZERO
	move(input_dir, delta)
	move_and_slide()


func _on_timer_timeout() -> void:
	self.take_damage(1)

func _update_animation() -> void:
	var is_moving: bool = velocity.length() > 5.0 # small threshold to avoid flicker when stopping
	var anim_name: String
	if is_moving:
		anim_name = "walk"
		# Flip sprite based on movement direction along the X axis
		if velocity.x < 0:
			animated_sprite.flip_h = true  # Facing left
		elif velocity.x > 0:
			animated_sprite.flip_h = false # Facing right
	else:
		anim_name = "idle"
	if animated_sprite.animation != anim_name:
		animated_sprite.play(anim_name)

func set_mouse_form(enabled: bool) -> void: #mouse (animal)
	is_mouse_form = enabled



func enable_super_bomb() -> void:
	has_super_bomb = true

func _throw_bomb() -> void:
	if not has_super_bomb or not bomb_ready or not can_interact:
		return
	bomb_ready = false
	var bomb_scene: PackedScene = load(BOMB_SCENE_PATH)
	var bomb: Node2D = bomb_scene.instantiate()
	Global.game_manager.add_2D_node(bomb)
	bomb.global_position = global_position
	# Wait 10 seconds cooldown
	await get_tree().create_timer(BOMB_COOLDOWN).timeout
	bomb_ready = true
