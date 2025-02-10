extends Window

@export var music_volume: HSlider
@export var sfx_volume: HSlider
@export var resume_button: Button
@export var quit_button: Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.exclusive = true
	self.transient = true
	music_volume.value = Global.settings.music_volume
	sfx_volume.value = Global.settings.sfx_volume
	music_volume.value_changed.connect(_on_music_volume_changed)
	sfx_volume.value_changed.connect(_on_sfx_volume_changed)
	
	resume_button.connect("pressed", _on_resume_pressed)
	quit_button.connect("pressed", _on_quit_pressed)
	

func _on_music_volume_changed(vol: float):
	Global.settings.music_volume = vol
	Global.settings.apply()

func _on_sfx_volume_changed(vol: float):
	Global.settings.sfx_volume = vol
	Global.settings.apply()
	
func _on_resume_pressed():
	self.visible = false
	
func _on_quit_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/Home.tscn")
