class_name Node2DContainer extends Control

@export var initial_size: Vector2
@onready var children := get_children()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.item_rect_changed.connect(_on_resized)


func _on_resized():
	for child in children:
		child.scale = get_global_rect().size / initial_size
