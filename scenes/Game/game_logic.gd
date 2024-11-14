extends Node2D

@export var spawn_level: Marker2D

@onready var collision := $StaticBody2D/CollisionPolygon2D
@onready var balls_container := $Balls

const BALL_SCENE := preload("res://scenes/Ball/Ball.tscn")

var score: int = 0
var current_ball: Ball = null

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
		current_ball.global_position.x = event.global_position.x
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func spawn_ball():
	current_ball = BALL_SCENE.instantiate()
	current_ball.position = Vector2(get_viewport().size.x / 2, spawn_level.position.y)
	balls_container.add_child(current_ball)
	current_ball.level = randi() % 3
	current_ball.freeze = true
