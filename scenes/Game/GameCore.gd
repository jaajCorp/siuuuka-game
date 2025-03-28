class_name GameCore extends Node2D

signal game_over(score: int)
signal best_score(score: int)
signal next_ball_update(ball: Ball)

@export var spawn_level: Marker2D
@export var balls_container: Node2D
@export var score_label: Label

@onready var game_end_timer := $GameEndTimer

const BALL_SCENE := preload("res://scenes/Ball/Ball.tscn")

var held_ball: Ball = null
var ball_queue: Array[Ball] = []
var max_ball_level: int = 0
var score: int = 0 :
	set(value):
		if not is_game_over():
			score = value
			_on_score_update()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_end_timer.connect("timeout", check_game_end)
	game_end_timer.start()
	
	Music.ensure_soundtrack_playing(Music.SOUNDTRACKS.IN_GAME)
	
	call_deferred("reset")

func _input(event: InputEvent) -> void:
	if held_ball == null: return
	
	if event is InputEventMouse:
		var local_mouse_pos: Vector2 = (event.global_position - global_position) / scale
		held_ball.position.x = clamp(local_mouse_pos.x, held_ball.get_radius(), get_width() - held_ball.get_radius())
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed and event.position.y > spawn_level.global_position.y:
				if held_ball:
					held_ball.freeze = false
					held_ball.collision.disabled = false
					held_ball = null
					await get_tree().create_timer(0.4).timeout
					spawn_ball()
		
		

func _on_ball_merge(new_ball: Ball):
	new_ball.connect("merged", _on_ball_merge)
	score += new_ball.level * 2
	max_ball_level = max(max_ball_level, new_ball.level)
	
func _on_score_update():
	if score_label:
		score_label.text = str(score)
	if score > Global.settings.best_score:
		Global.settings.best_score = score
		Global.save_state()
		best_score.emit(score)
	
func spawn_ball():
	held_ball = ball_queue.pop_front()
	
	var new_ball := BALL_SCENE.instantiate()
	new_ball.level = randi() % clamp(max_ball_level, 3, 5)
	ball_queue.push_back(new_ball)
	next_ball_update.emit(ball_queue.front())

	balls_container.add_child(held_ball)
	held_ball.update_level()
	held_ball.position = Vector2(get_width() / 2.0, spawn_level.position.y)
	held_ball.freeze = true
	held_ball.collision.disabled = true
	held_ball.connect("merged", _on_ball_merge)
	
func check_game_end():
	var min_y := spawn_level.position.y
	for ball: Ball in balls_container.get_children():
		if (ball.position.y - ball.get_radius()) < min_y and not ball.freeze:
			if ball.is_outside:
				if held_ball:
					held_ball.queue_free()
					held_ball = null
				print("u ded")
				game_end_timer.stop()
				game_over.emit(score)
			else:
				ball.is_outside = true
		else:
			ball.is_outside = false

func reset():
	ball_queue = [ BALL_SCENE.instantiate(), BALL_SCENE.instantiate() ]
	if held_ball:
		held_ball.queue_free()
	for child in balls_container.get_children():
		child.queue_free()
	
	max_ball_level = 0
	game_end_timer.start()
	# Reset score after game_end_timer.start() in order to bypass the score setter
	score = 0
	spawn_ball()
	
func is_game_over() -> bool:
	return game_end_timer.is_stopped()

func get_width() -> int:
	return ProjectSettings.get_setting("display/window/size/viewport_width", 720)
