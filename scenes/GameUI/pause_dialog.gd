extends Window

@export var music_volume: HSlider
@export var sfx_volume: HSlider

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	music_volume.value = Global.settings.music_volume
	sfx_volume.value = Global.settings.sfx_volume
	music_volume.value_changed.connect(_on_music_volume_changed)
	sfx_volume.value_changed.connect(_on_sfx_volume_changed)

func _on_music_volume_changed(vol: float):
	Global.settings.music_volume = int(vol)
	Global.settings.apply()

func _on_sfx_volume_changed(vol: float):
	Global.settings.sfx_volume = int(vol)
	Global.settings.apply()
