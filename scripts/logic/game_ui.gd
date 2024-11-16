extends Control

@export var pause_button: Button
@export var background: ResponsiveTextureRect

@onready var game_core := $VBoxContainer/Center/AspectRatioContainer/JarTexture/VBoxContainer/JarInside/GameCore
@onready var game_over_dialog := $GameOverDialog

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(background != null)
	background.portrait_texture = Global.current_pack.background
	background.landscape_texture = Global.current_pack.background_landscape
	background.queue_redraw()
	
	game_core.connect("game_over", _on_game_over)
	game_over_dialog.connect("confirmed", _on_dialog_confirmed)
	game_over_dialog.connect("canceled", _on_dialog_canceled)


func _on_game_over():
	game_over_dialog.visible = true

func _on_dialog_confirmed():
	game_core.reset()
	
func _on_dialog_canceled():
	get_tree().change_scene_to_file("res://scenes/ui/Home.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
