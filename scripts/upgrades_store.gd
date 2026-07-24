# upgrades_store.gd
# Shows 3 random upgrade buttons. Picking one applies its effect to the player
# and closes this screen. Health = time in this game, so "cost" is in seconds:
# positive cost drains time, negative cost grants extra time.
extends Control

@onready var buttons: Array[Button] = [$Button1, $Button2, $Button3]

var upgrade_pool: Array[Dictionary] = [
	{
		"name": "Big Bullets",
		"desc": "Fire rate doubled",
		"cost": 0,
		"apply": _apply_fire_rate,
	},
	{
		"name": "Super Bomb",
		"desc": "Your bullets deal way more damage",
		"cost": 0,
		"apply": _apply_damage,
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

func _close() -> void:
	Global.game_manager.close_scene(self)
	Global.game_manager.current_UI_scene = null
