extends TextureRect


func _ready() -> void:
	# Hidden by default until the player unlocks it
	visible = false


func _process(_delta: float) -> void:
	var player: Player = Global.game_manager.player
	if player == null:
		return

	# Show icon only if the player has unlocked the bomb
	visible = player.has_super_bomb

	if visible:
		# Modulate tint:
		if player.bomb_ready:
			modulate = Color(1.0, 1.0, 1.0, 1.0) # Normal color 
		else:
			modulate = Color(1.0, 0.3, 0.3, 0.2) # Reddish
