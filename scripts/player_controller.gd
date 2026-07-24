# This script defines the behavior of the player character in the game. It handles input, movement, and weapon firing.
class_name Player extends Entity

@export var weapon: Weapon
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


var mouse_captured: bool = false
var can_interact: bool = true # This variable can be used to disable player interaction when needed, such as during cutscenes, dialogues, pauses, etc.
var is_mouse_form: bool = false # true after the Mouse Morph upgrade is applied

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_player(event.position)


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


func rotate_player(mouse: Vector2) -> void:
	if mouse_captured and can_interact:
		var center: Vector2 = get_global_transform_with_canvas().get_origin()
		var direction: Vector2 = mouse - center
		var angle: float = atan2(direction.y, direction.x) + PI / 2.0
		rotation = angle


func _ready() -> void:
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
				weapon.trigger_pressed(global_position, rotation)
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

func _update_animation() -> void:
	var is_moving: bool = velocity.length() > 5.0 # small threshold to avoid flicker when stopping
	var anim_name: String
	if is_moving:
		anim_name = "walk_mouse" if is_mouse_form else "walk_normal"
	else:
		anim_name = "idle_mouse" if is_mouse_form else "idle_normal"
	if animated_sprite.animation != anim_name:
		animated_sprite.play(anim_name)

func set_mouse_form(enabled: bool) -> void: #mouse (animal)
	is_mouse_form = enabled
