class_name GameSettings extends Resource

@export var best_score: int = 0
@export var selected_pack_id: String = ""
@export var music_volume: int = 100
@export var sfx_volume: int = 100

func apply():
	var music_bus := AudioServer.get_bus_index("Music")
	var sfx_bus := AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(music_volume/100.0))
	AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(sfx_volume/100.0))
