extends Control

@export var pause_button: Button
@export var background: ResponsiveTextureRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(background != null)
	background.portrait_texture = GameSettings.current_pack.background
	background.landscape_texture = GameSettings.current_pack.background_landscape
	background.queue_redraw()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
