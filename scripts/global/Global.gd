extends Node

@export var current_pack: ResourcePack
@onready var settings: GameSettings
@onready var backend: Backend

const SETTINGS_SAVE_PATH := "user://settings.tres"

func _ready() -> void:
	get_tree().set_auto_accept_quit(false)
	
	if FileAccess.file_exists(SETTINGS_SAVE_PATH):
		print("Loading settings from file")
		settings = ResourceLoader.load(SETTINGS_SAVE_PATH)
	else:
		settings = GameSettings.new()
	settings.apply()
		
	var save_timer = Timer.new()
	save_timer.autostart = true
	save_timer.wait_time = 30
	save_timer.connect("timeout", save_state)
	
	backend = await Backend.new()
	add_child(backend)
		
func save_state():
	print("Saving state")
	var result := ResourceSaver.save(settings, SETTINGS_SAVE_PATH)
	if result != OK:
		printerr("Failed to save state: ", result)
		
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_state()
		get_tree().quit()
	
