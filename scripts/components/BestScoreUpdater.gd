class_name BestScoreUpdater extends Node

@export var game: GameCore

func _ready() -> void:
	game.game_over.connect(_on_game_over)
	
func _on_game_over(score: int) -> void:
	var client = Global.backend.client
	var session = Global.backend.session
	var record : NakamaAPI.ApiLeaderboardRecord = await client.write_leaderboard_record_async(session, "weekly_leaderboard", score, 0)
