class_name LeaderboardUpdater extends Node

@export var game: GameCore

signal score_submitted
signal best_score_submitted(leaderboard_name: String)
signal submit_error(exception: NakamaException)

func _ready() -> void:
	game.game_over.connect(_on_game_over)
	
func _on_game_over(score: int) -> void:
	var client := Global.backend.client
	var session := Global.backend.session
	for leaderboard_name in ["all_time_leaderboard", "weekly_leaderboard"]:
		var record : NakamaAPI.ApiLeaderboardRecord = await client.write_leaderboard_record_async(session, leaderboard_name, score, 0)
		if record.is_exception():
			submit_error.emit(record.get_exception())
			return
		elif record.score == str(score):
			best_score_submitted.emit(leaderboard_name)
	
	score_submitted.emit()
	
