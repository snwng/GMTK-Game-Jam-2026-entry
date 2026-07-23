# This script defines the behavior of the player character in the game. It handles input, movement, and weapon firing.
class_name Player extends Entity

@export var Bullet_Spawn_Offset: float = 90.0
@export var Bullet_scene: PackedScene

var mouse_captured: bool = false
var can_interact: bool = true # This variable can be used to disable player interaction when needed, such as during cutscenes, dialogues, pauses, etc.


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_player(event.position)


func capture_mouse() -> void:
	mouse_captured = true
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED


func release_mouse() -> void:
	mouse_captured = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func rotate_player(mouse: Vector2) -> void:
	if mouse_captured and can_interact:
		var center: Vector2 = get_global_transform_with_canvas().get_origin()
		var direction: Vector2 = mouse - center
		var angle: float = atan2(direction.y, direction.x) + PI / 2.0
		rotation = angle


func fire_weapon() -> void:
	var offset: Vector2 = Vector2.UP.rotated(rotation) * Bullet_Spawn_Offset
	var bullet: Bullet = Bullet_scene.instantiate()
	bullet.position = global_position + offset
	bullet.rotation = self.rotation
	Global.game_manager.add_2D_node(bullet)


func _ready() -> void:
	pass # Replace with function body.


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("unfocus"):
		release_mouse()
	elif Input.is_action_just_pressed("fire"):
		if mouse_captured:
			if can_interact:
				fire_weapon()
		else:
			capture_mouse()


func _physics_process(delta: float) -> void:
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down") if can_interact else Vector2.ZERO
	move(input_dir, delta)
	move_and_slide()
