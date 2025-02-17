extends Control

@export var pause_button: Button
@export var background: ResponsiveTextureRect

@onready var game_core := $VBoxContainer/Center/AspectRatioContainer/JarTexture/VBoxContainer/JarInside/GameCore
@onready var game_over_dialog := $GameOverDialog
@onready var animation_player := $AnimationPlayer
@onready var best_score_splash := $VBoxContainer/Top/GridContainer/Score/Panel/BestScoreSplash
@onready var next_ball_preview := $VBoxContainer/Top/GridContainer/Next/MarginContainer/VBoxContainer/Panel/CenterContainer/NextBallPreview

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	best_score_splash.visible = false
	
	assert(background != null)
	background.portrait_texture = Global.current_pack.background
	background.landscape_texture = Global.current_pack.background_landscape
	background.queue_redraw()
	
	game_core.connect("game_over", _on_game_over)
	game_core.connect("best_score", _on_best_score)
	game_core.connect("next_ball_update", _on_next_ball_update)
	game_over_dialog.connect("confirmed", _on_dialog_confirmed)
	game_over_dialog.connect("canceled", _on_dialog_canceled)


func _on_game_over():
	game_over_dialog.visible = true
	
func _on_best_score():
	best_score_splash.visible = true
	if not animation_player.is_playing():
		animation_player.play("best_score")
		
func _on_next_ball_update(ball: Ball):
	next_ball_preview.texture = Global.current_pack.get_level_texture(ball.level)
	next_ball_preview.queue_redraw()

func _on_dialog_confirmed():
	game_core.reset()
	
func _on_dialog_canceled():
	get_tree().change_scene_to_file("res://scenes/ui/Home.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_exit_button_pressed() -> void:
	_on_dialog_canceled()
