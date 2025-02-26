class_name Ball extends RigidBody2D

signal merged(new_ball: Ball)

@export_range(0, 10) var level: int = 0 :
	set(value):
		level = value
		update_level()
@export var texture: Texture2D :
	set(value):
		texture = value
		if self.sprite:
			self.sprite.texture = value

@export_category("Ambient sounds")
@export var frequency_secs: int = 10 :
	set(value):
		frequency_secs = value
		if ambient_audio_timer:
			ambient_audio_timer.wait_time = value
@export_range(0, 100) var probability: int = 30

@onready var sprite := $Sprite2D
@onready var collision := $CollisionShape2D
@onready var merge_audio_player := $MergeAudioPlayer
@onready var ambient_audio_player := $AmbientAudioPlayer
@onready var ambient_audio_timer := $Timer

const LEVEL_SIZES := [
	1.0,
	1.31,
	2.0,
	2.25,
	2.63,
	3.44,
	4.0,
	4.9,
	5.51,
	6.88,
	8.14,
]

@onready var BASE_SIZE: Vector2 = Vector2.ONE * 50
const BASE_MASS: float = 0.01
const PACKED_SCENE = preload("res://scenes/Ball/Ball.tscn")

var is_merged: bool = false
var is_outside: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Scale children
	sprite.scale = Vector2.ZERO
	collision.shape.radius = BASE_SIZE.x / 2
	
	contact_monitor = true
	max_contacts_reported = 8
	body_shape_entered.connect(_on_body_shape_entered)
	
	ambient_audio_timer.wait_time = frequency_secs
	ambient_audio_timer.connect("timeout", _on_ambient_timer_timeout)
	
	call_deferred("spawn_anim")


func _on_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	if body is Ball:
		var other_level: int = body.level
		if self.level == other_level and not (self.is_merged or body.is_merged):
			# Merge
			self.is_merged = true
			body.is_merged = true
			self.collision.set_deferred("disabled", true)
			body.collision.set_deferred("disabled", true)
			call_deferred("merge_with", body)


func _on_ambient_timer_timeout():
	if randi() % 100 < probability and not ambient_audio_player.playing:
		var audio_stream := Global.current_pack.get_level_random_ambient(self.level)
		if audio_stream != null:
			ambient_audio_player.stream = audio_stream
			ambient_audio_player.play()

func merge_with(other: Ball):
	self.freeze = true
	other.freeze = true
	
	var merge_center: Vector2 = self.position - (self.position - other.position)/2.0
	var mean_linear_velocity: Vector2 = (self.linear_velocity + other.linear_velocity)/2.0
	var mean_angular_velocity: float = (self.angular_velocity + other.angular_velocity)/2.0
	
	var new_ball: Ball = PACKED_SCENE.instantiate()
	self.get_parent().add_child(new_ball)
	new_ball.level = self.level + 1
	new_ball.position = merge_center
	new_ball.linear_velocity = mean_linear_velocity
	new_ball.angular_velocity = mean_angular_velocity
	
	merge_anim(merge_center)
	other.merge_anim(merge_center)
	
	emit_signal("merged", new_ball)


func merge_anim(merge_center: Vector2):
	var tween := get_tree().create_tween()
	tween.tween_property(self, "position", merge_center, 0.1)
	tween.tween_property(ambient_audio_player, "volume_db", -24.0, 0.1)
	tween.play()
	merge_audio_player.play()
	await tween.finished
	queue_free()


func spawn_anim():
	var target_scale: Vector2 = get_sprite_level_scale(sprite, level)
	sprite.scale = Vector2.ZERO
	
	var tween := get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(sprite, "scale", target_scale, 0.3)
	tween.play()


func update_level():
	# Visible scale
	var level_size: float = LEVEL_SIZES[level]
	var level_data := Global.current_pack.get_level_data(self.level)
	self.texture = level_data.texture

	if self.sprite and self.collision:
		sprite.scale = get_sprite_level_scale(sprite, level)
		collision.scale = Vector2.ONE * level_size
		if not level_data.frame:
			self.sprite.material = null
	# Mass
	self.mass = BASE_MASS * level_size


func get_sprite_level_scale(sprite: Sprite2D, level: int) -> Vector2:
	return BASE_SIZE / sprite.texture.get_size() * LEVEL_SIZES[level]


func get_radius() -> int:
	return sprite.texture.get_width() * sprite.global_scale.x / 2.0
