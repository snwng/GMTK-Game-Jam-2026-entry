# This script is attached to the GameManager node and manages the game state, including loading and changing scenes, managing the player, and providing access to the current 2D and UI scenes.
class_name GameManager extends Node

@onready var world2D: Node2D = $World2D
@onready var ui: CanvasLayer = $UI
@onready var health_label: Label = $UI/Health
@onready var update_timer: Timer = $UI/Timer
@onready var wave_manager: Node = $WaveManager

@onready var win_screen: Sprite2D = $UI/Color_ganaste
@onready var win_label: Label = $UI/Label_win
@onready var win_music: AudioStreamPlayer = $WinMusic 
@onready var lose_screen: Sprite2D = $UI/Color_lose
@onready var lose_label: Label = $UI/Label_lose
@onready var retry_button: Button = $UI/Button_retry

var player: Player = null
var current_2D_scene: Node = null
var current_UI_scene: Node = null

var game_over_flag: bool = false

func _ready() -> void:
	# Set the global game controller reference
	Global.game_manager = self

	load_player()

	_update_health_display()

	# Connect the Timer's timeout signal to our update function via code
	update_timer.timeout.connect(_on_timer_timeout)
	
	$"10000_hours".play()


func _process(_delta: float) -> void:
	if player != null and not player.is_alive() and not game_over_flag:
		on_player_defeated()

func get_player() -> Node:
	# Get the player node
	return self.player



func get_current_2D_scene() -> Node:
	# Get the current 2D scene node
	return self.current_2D_scene

func add_2D_node(node: Node2D) -> void:
	# Add a 2D node to the world2D node
	world2D.add_child(node)

func load_player() -> void:
	var player_scene: PackedScene = load("res://scenes/entities/player.tscn")
	world2D.add_child(player_scene.instantiate())


func close_scene(scene: Node, delete := true) -> void:
	# Close the given scene and optionally delete it from memory, might cause memory leaks if not careful
	if not scene:
		return
	if delete:
		scene.queue_free()
	else:
		scene.get_parent().remove_child(scene)
	scene = null


func change_2D_scene(path: String, delete := true) -> void:
	# Change the current 2D scene to the one specified by the path, optionally deleting the previous scene from memory
	if not ResourceLoader.exists(path):
		print("Error: Scene path doesn't exist")
		return
	close_scene(current_2D_scene, delete)
	var scene_resource: PackedScene = load(path)
	var instance: Node = scene_resource.instantiate()
	world2D.add_child(instance)
	current_2D_scene = instance


func change_UI_scene(path: String, delete := true) -> void:
	# Change the current UI scene to the one specified by the path, optionally deleting the previous scene from memory
	if not ResourceLoader.exists(path):
		print("Error: Scene path doesn't exist")
		return
	close_scene(current_UI_scene, delete)
	var scene_resource: PackedScene = load(path)
	var instance: Node = scene_resource.instantiate()
	ui.add_child(instance)
	current_UI_scene = instance


func _unhandled_input(event: InputEvent) -> void:
	pass
	# TEMPORARY: press U to test the upgrade screen. Remove this later
	# once the real "all enemies defeated" trigger is hooked up.
	#if event.is_action_pressed("test_upgrade"):
		#show_upgrade_screen()

func show_upgrade_screen() -> void:
	if game_over_flag:
		return
	change_UI_scene("res://scenes/ui/upgrades_store.tscn")
	current_UI_scene.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true


func _update_health_display() -> void:
	if player != null:
		var total_seconds: int = player.health
		var minutes: int = total_seconds / 60
		var seconds: int = total_seconds % 60
		health_label.text = "HP: %02d:%02d" % [minutes, seconds]

func _on_timer_timeout() -> void:
	_update_health_display()
	
	
func on_boss_defeated() -> void:
	game_over_flag = true
	win_screen.visible = true
	win_label.text = "You win! \nThanks for playing."
	win_label.visible = true
	win_music.play()
	await get_tree().create_timer(4.0).timeout
	get_tree().change_scene_to_file("res://scenes/main_menu/credits.tscn")


func on_player_defeated() -> void:
	game_over_flag = true
	get_tree().paused = true # opcional: congela todo al perder, como con upgrades

	lose_screen.visible = true
	lose_label.visible = true
	lose_label.text = "You lose! \nThanks for playing.\nPress to retry"
	retry_button.visible = true
	retry_button.process_mode = Node.PROCESS_MODE_ALWAYS # para que funcione aunque esté pausado
	retry_button.pressed.connect(_on_retry_pressed)

	await get_tree().create_timer(5.0).timeout
	if not retry_button.pressed.is_connected(_on_retry_pressed):
		return # ya se apretó retry, no seguir a créditos
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu/credits.tscn")

func _on_retry_pressed() -> void:
	retry_button.pressed.disconnect(_on_retry_pressed) # marca que ya se usó, para frenar el timer de arriba
	get_tree().paused = false
	get_tree().reload_current_scene()
