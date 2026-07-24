# This script is attached to the GameManager node and manages the game state, including loading and changing scenes, managing the player, and providing access to the current 2D and UI scenes.
class_name GameManager extends Node

@onready var world2D: Node = $World2D
@onready var ui: Node = $UI

var player: Node = null
var current_2D_scene: Node = null
var current_UI_scene: Node = null


func _ready() -> void:
	# Set the global game controller reference
	Global.game_manager = self
	load_player()


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
	# Load the player scene and add it to the world2D node
	var player_scene: PackedScene = load("res://scenes/entities/player.tscn")
	var instance: Node = player_scene.instantiate()
	world2D.add_child(instance)
	# The script lives on the CharacterBody2D child, not on the root node
	self.player = instance.get_node("CharacterBody2D")


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
	# TEMPORARY: press U to test the upgrade screen. Remove this later
	# once the real "all enemies defeated" trigger is hooked up.
	if event.is_action_pressed("test_upgrade"):
		show_upgrade_screen()

func show_upgrade_screen() -> void:
	change_UI_scene("res://scenes/ui/upgrades_store.tscn")
