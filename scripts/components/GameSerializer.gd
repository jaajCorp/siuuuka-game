class_name GameSerializer extends Node

@export var game: GameCore

func save_game():
	assert(game != null)
	var balls: Array[Dictionary] = []
	for ball: Ball in game.balls_container.get_children():
		if ball == game.held_ball: continue
		
		var ball_state := {}
		
		ball_state["position"] = ball.position
		ball_state["level"] = ball.level
		
		balls.push_back(ball_state)
		
	var ball_queue: Array[int] = []
	for ball: Ball in game.ball_queue:
		ball_queue.push_back(ball.level)
		
	var held_ball := game.held_ball.level
		
	var save := {
		"balls": balls,
		"queue": ball_queue,
		"held": held_ball,
		"debug_score": game.score
	}
	
	Global.settings.game_save = save
	Global.save_state()

func has_save() -> bool:
	return Global.settings.game_save != {}

func restore_game():
	assert(Global.settings.game_save != {})
	var save := Global.settings.game_save
	
	_restore_balls(save.get("balls"))
	_restore_score(save.get("balls"))
	print("Computed score: %d, saved score: %d" % [game.score, save.get("debug_score")])
	_restore_queue(save.get("queue"))
	_restore_held(save.get("held"))
	
func reset_save():
	Global.settings.game_save = {}
	Global.save_state()
	

func _restore_balls(balls: Array[Dictionary]) -> void:
	for child in game.balls_container.get_children():
		child.queue_free()
	
	for ball_save in balls:
		var ball_position: Vector2 = ball_save.get("position")
		var ball_level: int = ball_save.get("level")
		
		var ball := game.BALL_SCENE.instantiate()
		game.balls_container.add_child(ball)
		
		ball.position = ball_position
		ball.level = ball_level
		
		ball.update_level()

func _restore_queue(queue: Array[int]):
	game.ball_queue = []
	
	for ball_level in queue:
		var ball = game.BALL_SCENE.instantiate()
		ball.level = ball_level
		ball.update_level()
		
		game.ball_queue.push_back(ball)
	game.next_ball_update.emit(game.ball_queue.front())

func _restore_held(ball_level: int):
	var ball := game.BALL_SCENE.instantiate()
	game.balls_container.add_child(ball)
	
	ball.level = ball_level
	
	ball.update_level()
	
	ball.freeze = true
	ball.collision.disabled = true
	ball.connect("merged", game._on_ball_merge)
	
	game.held_ball = ball
	game._input(InputEventMouseMotion.new())

func _restore_score(balls: Array[Dictionary]):
	var score := 0
	for ball_save in balls:
		var ball_level: int = ball_save.get("level")
		print(ball_level)
		score += _get_ball_level_score(ball_level)
		
	game.score = score
	
func _get_ball_level_score(level: int) -> int:
	return level * 2
