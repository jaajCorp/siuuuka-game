extends Control

@export_category("Game")
@export var background: ResponsiveTextureRect
@export var game_core:  GameCore
@export var game_serializer: GameSerializer
@export var next_ball_preview: TextureRect

@export_category("Dialogs")
@export var game_over_dialog: Window
@export var pause_dialog: Window

@export_category("Animation")
@export var animation_player: AnimationPlayer
@export var best_score_splash: Label

@export_category("Leaderboard")
@export var leaderboard_updater: LeaderboardUpdater
@export var leaderboard_updater_label: Label

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
	
	leaderboard_updater.best_score_submitted.connect(_on_best_leaderboard_score)
	leaderboard_updater.score_submitted.connect(_on_leaderboard_submit)
	leaderboard_updater.submit_error.connect(_on_leaderboard_submit_error)
	
	get_tree().root.go_back_requested.connect(_on_android_back_pressed)
	
	if game_serializer.has_save():
		game_serializer.restore_game.call_deferred()
		# Avoid players backing up progress
		game_serializer.reset_save.call_deferred()


func _on_game_over(_score: int):
	game_serializer.reset_save()
	game_over_dialog.visible = true
	
	leaderboard_updater_label.text = "Sending score to leaderboard..."
	
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

func _on_best_leaderboard_score(leaderboard_id: String):
	leaderboard_updater_label.text = "Scored new personnal best score on %s !" % [leaderboard_id.replace("_", " ")]

func _on_leaderboard_submit():
	leaderboard_updater_label.text = "Leaderboard score submitted"

func _on_leaderboard_submit_error(exception: NakamaException):
	const RESTART_WAIT_SEC := 10
	
	if not Global.backend.is_healthy:
		Global.backend.create_session_and_connect()
	Global.backend.refresh_session()
		
	for i in range(RESTART_WAIT_SEC):
		leaderboard_updater_label.text = "Error while sending score to the leaderboard (%s). Retrying in %ds" % [exception.message, (RESTART_WAIT_SEC-i)]
		await get_tree().create_timer(1).timeout
	
	leaderboard_updater._on_game_over(game_core.score)

func _on_quit_button_pressed() -> void:
	if get_tree() != null:
		get_tree().change_scene_to_file("res://scenes/Home/Home.tscn")

func _on_android_back_pressed() -> void:
	_on_pause_pressed()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
