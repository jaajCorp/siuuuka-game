extends Node2D

@export var spawn_level: Marker2D
@export var balls_container: Node2D
@export var score_label: Label

const BALL_SCENE := preload("res://scenes/Ball/Ball.tscn")

var current_ball: Ball = null
var score: int = 0 :
	set(value):
		score = value
		if score_label:
			score_label.text = str(score)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_ball()
	

func _input(event: InputEvent) -> void:
	if not current_ball: return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if current_ball:
				current_ball.freeze = false
				current_ball = null
				await get_tree().create_timer(0.6).timeout
				spawn_ball()
	elif event is InputEventMouseMotion:
		var local_mouse_pos: Vector2 = (event.global_position - global_position) / scale
		current_ball.position.x = clamp(local_mouse_pos.x, current_ball.get_radius(), get_width() - current_ball.get_radius())
		

func _on_ball_merge(new_ball: Ball):
	new_ball.connect("merged", _on_ball_merge)
	score += new_ball.level * 2
	
func spawn_ball():
	current_ball = BALL_SCENE.instantiate()
	current_ball.position = Vector2(get_width() / 2, spawn_level.position.y)
	balls_container.add_child(current_ball)
	current_ball.level = randi() % 3
	current_ball.freeze = true
	current_ball.connect("merged", _on_ball_merge)
	
func get_width() -> int:
	return ProjectSettings.get_setting("display/window/size/viewport_width", 720)
