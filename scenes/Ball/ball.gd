@tool
class_name Ball
extends RigidBody2D

@export_range(0, 10) var level: int = 0 :
	set(value):
		level = value
		update_level()
@export var texture: Texture2D : 
	set(value):
		texture = value
		if self.sprite:
			self.sprite.texture = value
		

@onready var sprite := $Sprite2D
@onready var collision := $CollisionShape2D

const LEVEL_SIZES := [
	1.0,
	1.25992104989487,
	1.587401051968192,
	2.0,
	2.51984209978974,
	3.174802103936383,
	4.0,
	5.03968419957948,
	6.349604207872766,
	8.0,
	10.07936839915896,
]

@onready var BASE_SIZE: Vector2 = Vector2.ONE * get_viewport().size.x / 12
const BASE_MASS: float = 1
const PACKED_SCENE = preload("res://scenes/Ball/Ball.tscn")

var is_merged: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Scale children
	sprite.scale = Vector2.ZERO
	collision.shape.radius = BASE_SIZE.x / 2
	
	contact_monitor = true
	max_contacts_reported = 8
	body_shape_entered.connect(_on_body_shape_entered)
	freeze_mode = FreezeMode.FREEZE_MODE_STATIC
	
	call_deferred("spawn_anim")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	if body.has_method("get_ball_level"):
		print("Collided with ball with level ", body.get_ball_level())
		var other_level: int = body.get_ball_level()
		if self.level == other_level and not (self.is_merged or body.is_merged):
			# Merge
			self.is_merged = true
			body.is_merged = true
			self.collision.set_deferred("disabled", true)
			body.collision.set_deferred("disabled", true)
			call_deferred("merge_with", body)
			
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

func merge_anim(merge_center: Vector2):
	var tween := get_tree().create_tween()
	tween.tween_property(self, "position", merge_center, 0.1)
	tween.play()
	await tween.finished
	queue_free()
	
func spawn_anim():
	var target_scale: Vector2 = BASE_SIZE / sprite.texture.get_size() * LEVEL_SIZES[level]
	sprite.scale = Vector2.ZERO
	
	var tween := get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(sprite, "scale", target_scale, 0.3)
	tween.play()

func update_level():
	# Visible scale
	var scale: float = LEVEL_SIZES[level]
	self.texture = TextureRegistry.get_level_texture(self.level)
	if self.sprite and self.collision:
		var base_sprite_scale: Vector2 = BASE_SIZE / sprite.texture.get_size()
		sprite.scale = base_sprite_scale * scale
		collision.scale = Vector2.ONE * scale
	# Mass
	self.mass = BASE_MASS * scale

func get_ball_level() -> int:
	return self.level
