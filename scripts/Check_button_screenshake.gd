extends CheckButton


func _ready() -> void:
	# Sync the button state with the global configuration
	button_pressed = Global.screen_shake_enabled
	
	# Set initial text display based on the loaded state
	_update_text(button_pressed)
	
	# Connect the toggled signal to handle state changes
	toggled.connect(_on_toggled)


func _on_toggled(toggled_on: bool) -> void:
	# Save choice globally
	Global.screen_shake_enabled = toggled_on
	
	# Update label text
	_update_text(toggled_on)


func _update_text(is_on: bool) -> void:
	# Change text dynamically depending on the state
	if is_on:
		text = "Screenshake: ON"
	else:
		text = "Screenshake: OFF"
