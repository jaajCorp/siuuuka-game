extends Control

@export var background: ResponsiveTextureRect

@onready var game_core := $VBoxContainer/Center/AspectRatioContainer/JarTexture/VBoxContainer/JarInside/GameCore
@onready var game_serializer := $GameSerializer

@onready var game_over_dialog := $GameOverDialog
@onready var pause_dialog := $PauseDialog

@onready var animation_player := $AnimationPlayer
@onready var best_score_splash := $VBoxContainer/Top/GridContainer/Score/Panel/BestScoreSplash
@onready var next_ball_preview := $VBoxContainer/Top/GridContainer/Next/MarginContainer/VBoxContainer/Panel/CenterContainer/NextBallPreview

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	best_score_splash.visible = false
	game_over_dialog.visible = false
	pause_dialog.visible = false
	
	assert(background != null)
	background.portrait_texture = Global.current_pack.background
	background.landscape_texture = Global.current_pack.background_landscape
	background.queue_redraw()
	
	game_core.connect("game_over", _on_game_over)
	game_core.connect("best_score", _on_best_score)
	game_core.connect("next_ball_update", _on_next_ball_update)
	
	get_tree().root.go_back_requested.connect(_on_android_back_pressed)
	
	if game_serializer.has_save():
		game_serializer.restore_game.call_deferred()
		# Avoid players backing up progress
		game_serializer.reset_save.call_deferred()


func _on_game_over(_score: int):
	game_serializer.reset_save()
	game_over_dialog.visible = true
	
func _on_best_score(_score: int):
	best_score_splash.visible = true
	if not animation_player.is_playing():
		animation_player.play("best_score")
		
func _on_next_ball_update(ball: Ball):
	next_ball_preview.texture = Global.current_pack.get_level_data(ball.level).texture
	next_ball_preview.queue_redraw()

func _on_pause_pressed():
	pause_dialog.visible = not pause_dialog.visible

func _on_restart_pressed():
	pause_dialog.visible = false
	game_over_dialog.visible = false
	game_core.reset()
	game_serializer.reset_save()
	
func _on_save_quit_button_pressed() -> void:
	game_serializer.save_game()
	_on_quit_button_pressed()
		

func _on_quit_button_pressed() -> void:
	if get_tree() != null:
		get_tree().change_scene_to_file("res://scenes/Home/Home.tscn")

func _on_android_back_pressed() -> void:
	_on_pause_pressed()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
