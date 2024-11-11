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

const BASE_SIZE: Vector2 = Vector2(52, 52)
const BASE_MASS: float = 1.0
const PACKED_SCENE = preload("res://scenes/Ball/Ball.tscn")

var is_merged: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Scale children
	sprite.scale = BASE_SIZE / sprite.texture.get_size()
	collision.shape.radius = BASE_SIZE.x / 2
	
	contact_monitor = true
	max_contacts_reported = 8
	body_shape_entered.connect(_on_body_shape_entered)
	freeze_mode = FreezeMode.FREEZE_MODE_STATIC
	

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
	var center_of_mass: Vector2 = self.position - (self.position - other.position)/2.0
	
	var new_ball: Ball = PACKED_SCENE.instantiate()
	self.get_parent().add_child(new_ball)
	new_ball.level = self.level + 1
	new_ball.position = center_of_mass
	
	await get_tree().create_timer(0.5).timeout
	self.queue_free()
	other.queue_free()
	

func update_level():
	# Visible scale
	var scale := Vector2.ONE * pow(PI/2, level)
	if self.sprite and self.collision:
		var base_sprite_scale: Vector2 = BASE_SIZE / sprite.texture.get_size()
		sprite.scale = base_sprite_scale * scale
		collision.scale = scale
	# Mass
	self.mass = BASE_MASS * scale.x

func get_ball_level() -> int:
	return self.level
