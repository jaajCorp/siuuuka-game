extends Node2D

signal game_over

@export var spawn_level: Marker2D
@export var balls_container: Node2D
@export var score_label: Label

@onready var game_end_timer := $GameEndTimer

const BALL_SCENE := preload("res://scenes/Ball/Ball.tscn")

var current_ball: Ball = null
var score: int = 0 :
	set(value):
		score = value
		if score_label:
			score_label.text = str(score)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_end_timer.connect("timeout", check_game_end)
	game_end_timer.start()
	
	spawn_ball()

func _input(event: InputEvent) -> void:
	if not current_ball: return
	if event is InputEventMouse:
		var local_mouse_pos: Vector2 = (event.global_position - global_position) / scale
		current_ball.position.x = clamp(local_mouse_pos.x, current_ball.get_radius(), get_width() - current_ball.get_radius())
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
				if current_ball:
					current_ball.freeze = false
					current_ball.collision.disabled = false
					current_ball = null
					await get_tree().create_timer(0.4).timeout
					spawn_ball()
		
		

func _on_ball_merge(new_ball: Ball):
	new_ball.connect("merged", _on_ball_merge)
	score += new_ball.level * 2
	
func spawn_ball():
	current_ball = BALL_SCENE.instantiate()
	current_ball.position = Vector2(get_width() / 2, spawn_level.position.y)
	balls_container.add_child(current_ball)
	current_ball.level = randi() % 3
	current_ball.freeze = true
	current_ball.collision.disabled = true
	current_ball.connect("merged", _on_ball_merge)
	
func check_game_end():
	var min_y := spawn_level.position.y
	for ball: Ball in balls_container.get_children():
		if (ball.position.y - ball.get_radius()) < min_y and not ball.freeze:
			if ball.is_outside:
				if current_ball:
					current_ball.queue_free()
					current_ball = null
				print("u ded")
				game_end_timer.stop()
				emit_signal("game_over")
			else:
				ball.is_outside = true
		else:
			ball.is_outside = false

func reset():
	score = 0
	if current_ball:
		current_ball.queue_free()
	for child in balls_container.get_children():
		child.queue_free()
	
	game_end_timer.start()
	spawn_ball()

func get_width() -> int:
	return ProjectSettings.get_setting("display/window/size/viewport_width", 720)
