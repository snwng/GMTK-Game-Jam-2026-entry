# This script is a singleton that holds global variables and functions for the game.
extends Node

var game_manager: GameManager
var fx_manager: FX_Manager
var vo_manager: VOManager

var language: int = 1

var damage_multiplier: float = 1.0 #for upgrades
var bullet_scale_multiplier: float = 1.0 #for upgrades

var screen_shake_enabled: bool = true

var time_drain_multiplier: float = 1.0 #for the totem

func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	pass
