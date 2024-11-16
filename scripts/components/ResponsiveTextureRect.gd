@tool
class_name ResponsiveTextureRect extends TextureRect

@export var portrait_texture: Texture2D:
	set(value):
		portrait_texture = value
		_on_resized()
@export var landscape_texture: Texture2D:
	set(value):
		landscape_texture = value
		_on_resized()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_on_resized()
	self.item_rect_changed.connect(_on_resized)


func _on_resized():
	var aspect_ratio := get_viewport_rect().size.x / get_viewport_rect().size.y
	if aspect_ratio > 1:
		expand_mode = EXPAND_FIT_WIDTH
		self.texture = landscape_texture
	else:
		expand_mode = EXPAND_FIT_HEIGHT
		self.texture = portrait_texture
	queue_redraw()
