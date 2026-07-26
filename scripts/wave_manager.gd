# wave_manager.gd
extends Node
const ENEMY_SCENE: PackedScene = preload("res://scenes/entities/enemy.tscn")
const WITCH_SCENE: PackedScene = preload("res://scenes/entities/witch.tscn")
const BRUTE_SCENE: PackedScene = preload("res://scenes/entities/enemy_golem.tscn")
const RED_SCENE: PackedScene = preload("res://scenes/entities/red.tscn")
const SPAWN_DISTANCE: float = 500.0
signal wave_started()
var waves: Array[Dictionary] = [
	{"enemy": 10, "witch": 0, "brute": 0},
	{"enemy": 8, "witch": 2, "brute": 0},
	{"enemy": 7, "witch": 2, "brute": 1},
	{"enemy": 3, "witch": 4, "brute": 3},
	{"enemy": 1, "witch": 6, "brute": 3},
	{"enemy": 1, "witch": 4, "brute": 5},
	{"enemy": 1, "witch": 7, "brute": 2},
	{"enemy": 1, "witch": 2, "brute": 7},
]
var current_wave: int = 0
var enemies_alive: int = 0

func _ready() -> void:
	while not Global.game_manager:
		await get_tree().process_frame
	start_next_wave()

func start_next_wave() -> void:
	if current_wave >= waves.size():
		_spawn_boss()
		return
	var wave: Dictionary = waves[current_wave]
	_spawn_enemies(ENEMY_SCENE, wave.get("enemy", 0))
	_spawn_enemies(WITCH_SCENE, wave.get("witch", 0))
	_spawn_enemies(BRUTE_SCENE, wave.get("brute", 0))
	current_wave += 1
	print("Wave ", current_wave, " started with ", enemies_alive, " enemies")
	wave_started.emit()

func _spawn_boss() -> void:
	print("All waves complete! Spawning Red")
	var boss: Node2D = RED_SCENE.instantiate()
	Global.game_manager.add_2D_node(boss)
	boss.global_position = _get_random_spawn_position()

func _spawn_enemies(scene: PackedScene, count: int) -> void:
	for i in range(count):
		var instance: Node2D = scene.instantiate()
		instance.add_to_group("enemies")
		Global.game_manager.add_2D_node(instance)
		instance.global_position = _get_random_spawn_position()
		enemies_alive += 1
		instance.tree_exited.connect(_on_enemy_died)

func _on_enemy_died() -> void:
	enemies_alive -= 1
	if enemies_alive <= 0:
		Global.game_manager.show_upgrade_screen()

func _get_random_spawn_position() -> Vector2:
	var player: Player = Global.game_manager.player
	var angle: float = randf() * TAU
	return player.global_position + Vector2.RIGHT.rotated(angle) * SPAWN_DISTANCE

## Spawns enemies in hordes/waves. Waits until all enemies from the current
## wave are dead before spawning the next one.
#extends Node
#
#const ENEMY_SCENE: PackedScene = preload("res://scenes/entities/enemy.tscn")
#const WITCH_SCENE: PackedScene = preload("res://scenes/entities/witch.tscn")
#const BRUTE_SCENE: PackedScene = preload("res://scenes/entities/enemy_golem.tscn")
#
#const SPAWN_DISTANCE: float = 500.0
#
#signal  wave_started()
#
#var waves: Array[Dictionary] = [
	#{"enemy": 10, "witch": 0, "brute": 0},
	#{"enemy": 8, "witch": 2, "brute": 0},
	#{"enemy": 7, "witch": 2, "brute": 1},
	#{"enemy": 3, "witch": 4, "brute": 3},
	#{"enemy": 1, "witch": 6, "brute": 3},
	#{"enemy": 1, "witch": 4, "brute": 5},
	#{"enemy": 1, "witch": 7, "brute": 2},
	#{"enemy": 1, "witch": 2, "brute": 7},
#]
#
#var current_wave: int = 0
#var enemies_alive: int = 0
#
#func _ready() -> void:
	#while not Global.game_manager:
		#await get_tree().process_frame
	#start_next_wave()
	#wave_started.connect(_on_wave_started)
#
#func start_next_wave() -> void:
	#if current_wave >= waves.size():
		#print("All waves complete!")
		#return
	#var wave: Dictionary = waves[current_wave]
	#_spawn_enemies(ENEMY_SCENE, wave.get("enemy", 0))
	#_spawn_enemies(WITCH_SCENE, wave.get("witch", 0))
	#_spawn_enemies(BRUTE_SCENE, wave.get("brute", 0))
	#current_wave += 1
	#print("Wave ", current_wave, " started with ", enemies_alive, " enemies")
	#wave_started.emit()
#
#func _spawn_enemies(scene: PackedScene, count: int) -> void:
	#for i in range(count):
		#var instance: Node2D = scene.instantiate()
		#instance.add_to_group("enemies")
		#Global.game_manager.add_2D_node(instance)
		#instance.global_position = _get_random_spawn_position()
		#enemies_alive += 1
		#instance.tree_exited.connect(_on_enemy_died)
#
#func _on_enemy_died() -> void:
	#enemies_alive -= 1
	#if enemies_alive <= 0:
		#Global.game_manager.show_upgrade_screen()
#
#func _get_random_spawn_position() -> Vector2:
	#var player: Player = Global.game_manager.player
	#var angle: float = randf() * TAU
	#return player.global_position + Vector2.RIGHT.rotated(angle) * SPAWN_DISTANCE
#
#
#
#func _on_wave_started() -> void:
	#await get_tree().create_timer(1).timeout
	#Global.vo_manager.play_audio(Global.vo_manager.GENERIC_VO.pick_random())
	#print("triggered")
