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


func load_player() -> void:
	# Load the player scene and add it to the world2D node
	pass


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
