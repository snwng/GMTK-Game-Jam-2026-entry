class_name VOManager extends Node

var queue: Array[AudioStream] = []
var audio_player: AudioStreamPlayer
var is_playing: bool = false

const GENERIC_VO: Array[AudioStream] = [
	preload("res://assets/audio/voiceovers/GENERIC_01.wav"),
	preload("res://assets/audio/voiceovers/GENERIC_02.wav"),
	preload("res://assets/audio/voiceovers/GENERIC_03.wav"),
	preload("res://assets/audio/voiceovers/GENERIC_04.wav"),
	preload("res://assets/audio/voiceovers/GENERIC_05.wav"),
	preload("res://assets/audio/voiceovers/GENERIC_06.wav"),
	preload("res://assets/audio/voiceovers/GENERIC_07.wav"),
	preload("res://assets/audio/voiceovers/GENERIC_08.wav"),
	preload("res://assets/audio/voiceovers/GENERIC_09.wav"),
	preload("res://assets/audio/voiceovers/GENERIC_10.wav"),
	preload("res://assets/audio/voiceovers/GENERIC_11.wav"),
	preload("res://assets/audio/voiceovers/GENERIC_12.wav"),
]

const DEATH_VO: AudioStream = preload("res://assets/audio/voiceovers/DEATH.wav")
const ONEMINLEFT_VO: AudioStream = preload("res://assets/audio/voiceovers/1MINLEFT.wav")
const COUNTDOWN_VO: AudioStream = preload("res://assets/audio/voiceovers/COUNTDOWN.wav")
const INTRO_VO: AudioStream = preload("res://assets/audio/voiceovers/INTRO.wav")
const TIMELEFT_VO: AudioStream = preload("res://assets/audio/voiceovers/TIMELEFT.wav")


func _ready() -> void:
	Global.vo_manager = self
	
	# Usamos AudioStreamPlayer normal para voces globales sin atenuación posicional
	audio_player = AudioStreamPlayer.new()
	audio_player.bus = &"Voices"
	add_child(audio_player) # Es seguro y permanece durante toda la vida del juego
	
	audio_player.finished.connect(_on_audio_finished)


func force_interrupt() -> void:
	queue.clear()
	is_playing = false
	if audio_player and audio_player.playing:
		audio_player.stop()


func play_audio(audio_stream: AudioStream) -> void:
	if not audio_stream:
		push_warning("VOManager: Se intentó reproducir un AudioStream nulo.")
		return
		
	queue.append(audio_stream)
	if not is_playing:
		_play_next()


func _play_next() -> void:
	if queue.is_empty():
		is_playing = false
		return
		
	is_playing = true
	var next_audio: AudioStream = queue.pop_front()
	audio_player.stream = next_audio
	audio_player.play()


func _on_audio_finished() -> void:
	_play_next()

#class_name VOManager extends Node
#
#
#var queue: Array[AudioStream]
#var audio_player: AudioStreamPlayer2D
#var is_playing: bool = false
#
#const  GENERIC_VO: Array[AudioStream] = [
	#preload("res://assets/audio/voiceovers/GENERIC_01.wav"),
	#preload("res://assets/audio/voiceovers/GENERIC_02.wav"),
	#preload("res://assets/audio/voiceovers/GENERIC_03.wav"),
	#preload("res://assets/audio/voiceovers/GENERIC_04.wav"),
	#preload("res://assets/audio/voiceovers/GENERIC_05.wav"),
	#preload("res://assets/audio/voiceovers/GENERIC_06.wav"),
	#preload("res://assets/audio/voiceovers/GENERIC_07.wav"),
	#preload("res://assets/audio/voiceovers/GENERIC_08.wav"),
	#preload("res://assets/audio/voiceovers/GENERIC_09.wav"),
	#preload("res://assets/audio/voiceovers/GENERIC_10.wav"),
	#preload("res://assets/audio/voiceovers/GENERIC_11.wav"),
	#preload("res://assets/audio/voiceovers/GENERIC_12.wav"),
#]
#
#const DEATH_VO: AudioStream = preload("res://assets/audio/voiceovers/DEATH.wav")
#const ONEMINLEFT_VO: AudioStream = preload("res://assets/audio/voiceovers/1MINLEFT.wav")
#const COUNTDOWN_VO: AudioStream = preload("res://assets/audio/voiceovers/COUNTDOWN.wav")
#const INTRO_VO: AudioStream = preload("res://assets/audio/voiceovers/INTRO.wav")
#const TIMELEFT_VO: AudioStream = preload("res://assets/audio/voiceovers/TIMELEFT.wav")
#
#
#func _ready() -> void:
	#Global.vo_manager = self
	#queue = []
	#audio_player = AudioStreamPlayer2D.new()
	#audio_player.bus = &"Voices"
	#while not Global.game_manager:
		#await get_tree().process_frame
	#Global.game_manager.add_2D_node(audio_player)
	#audio_player.finished.connect(_on_audio_finished)
#
#
#func force_interrupt() -> void:
	#if is_playing:
		#audio_player.stop()
		#is_playing = false
		#queue.clear()
#
#
#func play_audio(audio_stream: AudioStream) -> void:
	#if not audio_stream:
		#print("Error: Audio stream is null")
		#return
	#queue.append(audio_stream)
	#if not is_playing:
		#_play_next()
#
#func _play_next() -> void:
	#if queue.is_empty():
		#is_playing = false
		#return
	#is_playing = true
	#var next_audio: AudioStream = queue.pop_front()
	#audio_player.stream = next_audio
	#audio_player.play()
#
#func _on_audio_finished() -> void:
	#_play_next()
