extends Node2D


@onready var blinking_label: Label = $Label
@onready var label_blink_timer: Timer = $LabelBlinkTimer


func _ready() -> void:

	$Intro_music.play()

func _on_LabelBlinkTimer_timeout() -> void:
	# label blinks
	blinking_label.visible = not blinking_label.visible


func _on_button_mouse_entered() -> void:
	$Hover_sound.play()


func _on_credits_pressed() -> void:
	$Press_sound.play()
	await get_tree().create_timer(0.5).timeout
	#get_tree().change_scene_to_file("")


func _on_start_pressed() -> void:
	$Press_sound.play()
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/levels/main_scene.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
