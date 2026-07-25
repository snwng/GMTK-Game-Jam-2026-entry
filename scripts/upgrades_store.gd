# upgrades_store.gd
# Shows 3 random upgrade buttons. Picking one applies its effect to the player
# and closes this screen. Health = time in this game, so "cost" is in seconds:
# positive cost drains time, negative cost grants extra time.
extends Control

@onready var buttons: Array[Button] = [$Button1, $Button2, $Button3]

var upgrade_pool: Array[Dictionary] = [
	{
		"name": "Rapid Fire",
		"desc": "Fire rate doubled",
		"cost": 0,
		"apply": _apply_fire_rate,
	},
	{
		"name": "Big Bullets",
		"desc": "Bullets are 50% bigger",
		"cost": 0,
		"apply": _apply_bullet_size,
	},
	{
		"name": "Heavy Rounds",
		"desc": "Your bullets deal way more damage",
		"cost": 0,
		"apply": _apply_damage,
	},
	{
	"name": "Super Bomb",
	"desc": "Right-click to throw a bomb that explodes in a wide area (10s cooldown)",
	"cost": 0,
	"apply": _apply_super_bomb,
	},
	{
		"name": "Fast Legs",
		"desc": "+10% movement speed",
		"cost": 0,
		"apply": _apply_speed,
	},
	{
		"name": "Axe Spinner",
		"desc": "An axe spins around you, protecting you",
		"cost": 30,
		"apply": _apply_axe,
	},
	{
		"name": "Turtle Shell",
		"desc": "You move slower, but gain extra time",
		"cost": -40,
		"apply": _apply_turtle,
	},
	{
		"name": "Mouse Morph",
		"desc": "Turn into a mouse: smaller hitbox, easier to dodge",
		"cost": 30,
		"apply": _apply_mouse,
	},
]

func _ready() -> void:
	locate_buttons()
	var choices: Array = upgrade_pool.duplicate()
	choices.shuffle()
	for i in range(buttons.size()):
		var upgrade: Dictionary = choices[i]
		var cost_text := ""
		if upgrade.cost > 0:
			cost_text = "\n(costs %d sec)" % upgrade.cost
		elif upgrade.cost < 0:
			cost_text = "\n(gain %d sec)" % -upgrade.cost
		buttons[i].text = upgrade.name + "\n" + upgrade.desc + cost_text
		buttons[i].pressed.connect(_on_upgrade_chosen.bind(upgrade))

func _on_upgrade_chosen(upgrade: Dictionary) -> void:
	var player: Player = Global.game_manager.get_player()
	upgrade.apply.call(player)
	if upgrade.cost > 0:
		player.take_damage(upgrade.cost)
	elif upgrade.cost < 0:
		player.heal(-upgrade.cost)
	_close()

# --- Upgrade effects ---

func _apply_fire_rate(player: Player) -> void:
	print("old cooldown: ", player.weapon.cooldown)
	player.weapon.cooldown /= 2.0
	print("New cooldown: ", player.weapon.cooldown)

func _apply_damage(player: Player) -> void:
	Global.damage_multiplier *= 5.0

func _apply_speed(player: Player) -> void:
	player.VELOCITY *= 1.10

func _apply_axe(player: Player) -> void:
	var axe_scene: PackedScene = load("res://scenes/axe.tscn")
	var axe: Node2D = axe_scene.instantiate()
	player.add_child(axe)
	print("Axe added, children of player now: ", player.get_children())

func _apply_turtle(player: Player) -> void:
	player.VELOCITY *= 0.7

func _apply_mouse(player: Player) -> void:
	var collision: CollisionShape2D = player.get_node("CollisionShape2D")
	collision.scale *= 0.6
	var animated_sprite: AnimatedSprite2D = player.get_node("AnimatedSprite2D")
	animated_sprite.scale *= 0.6
	player.set_mouse_form(true)

func _apply_bullet_size(player: Player) -> void:
	Global.bullet_scale_multiplier *= 1.5
	
func _apply_super_bomb(player: Player) -> void:
	player.enable_super_bomb()

func _close() -> void:
	get_tree().paused = false
	Global.game_manager.close_scene(self)
	Global.game_manager.current_UI_scene = null
	Global.game_manager.wave_manager.start_next_wave()	
	
func locate_buttons():
	# Screen setup
	var screen_width: float = 720.0
	
	# Button width and spacing (Locked horizontal dimensions)
	var button_width: float = 160.0
	var button_spacing: float = 20.0
	var target_y_position: float = 100.0
	
	# Math formulas to calculate the centering offset
	var total_buttons_width: float = button_width * 3
	var total_spacing_width: float = button_spacing * 2
	var total_block_width: float = total_buttons_width + total_spacing_width
	var start_margin_x: float = (screen_width - total_block_width) / 2.0
	
	# Array containing your button node references
	var ui_buttons: Array[Button] = [$Button1, $Button2, $Button3]
	
	# Loop to calculate and apply properties
	for index in range(ui_buttons.size()):
		var current_button: Button = ui_buttons[index]
		
		# 1. FORCE TEXT TO WRAP: This prevents the font from stretching the button horizontally
		current_button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		
		# 2. LOCK THE WIDTH: We set both Min and Max limits so it stays exactly at 160px
		current_button.custom_minimum_size.x = button_width
		current_button.size.x = button_width
		
		# Math formula for each button's unique X position
		var dynamic_x: float = start_margin_x + index * (button_width + button_spacing)
		
		# Apply the calculated coordinates
		current_button.position = Vector2(dynamic_x, target_y_position)
