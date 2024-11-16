extends Control

signal game_ready

@export var status_label: Label

@export var start_button: Button
@export var store_button: Button
@export var quit_button: Button

@onready var error_dialog := $AcceptDialog

var is_game_ready := false

func _ready() -> void:
	start_button.connect("pressed", _on_start_pressed)
	store_button.connect("pressed", _on_store_pressed)
	quit_button.connect("pressed", _on_quit_pressed)
	fetch_remote_data()

func fetch_remote_data():
	var pack: ResourcePack = null
	var online := true
	
	print_status("Fetching info")
	var manifest: Dictionary = await CMS.fetch_manifest()
	
	var pack_id: String = Global.settings.selected_pack_id
	if pack_id == "":
		if not manifest.has("error"):
			pack_id = manifest.get("default_pack_id")
		else:
			display_error(get_error_display(manifest))
			return
	
	pack = await fetch_pack(pack_id, not manifest.has("error"))
	
	if pack == null:
		printerr("Failed to fetch pack")
		display_error({
			"title": "Failed to download remote content", 
			"tip": "This game needs to be conencted to the interned the first time it is launched"}
		)
		return
		
	
	Global.current_pack = pack
	print_status("Ready !")
	is_game_ready = true
	emit_signal("game_ready")
	
	
func fetch_pack(pack_id: String, online := true) -> ResourcePack:
	var pack: ResourcePack = null
	if CMSCache.has_resource_pack(pack_id):
		print("Loading local pack: ", pack_id)
		print_status("Loading local assets")
		pack = await CMSCache.get_resource_pack(pack_id)
	elif online:
		print("Fetching remote pack: ", pack_id)
		print_status("Downloading latest content")
		pack = ResourcePack.new_from_id(pack_id)
		pack.connect("load_progress_update", _on_pack_load_progress_update)
		await pack.loaded
		var cache_result = CMSCache.save_resource_pack(pack)
		if cache_result != OK:
			display_error({"title": "Storage error", "tip": "Could not cache aseets on your storage device, please allow us to do so (i'm begging you)"})
			return
			
	return pack
	
var waiting_for_start := false
func _on_start_pressed():
	if waiting_for_start: return
	waiting_for_start = true
	
	if not is_game_ready:
		await self.game_ready
	get_tree().change_scene_to_file("res://scenes/Game/GameUI.tscn")
		
	
func _on_store_pressed():
	print_status("Coming soon")
	
func _on_quit_pressed():
	get_tree().quit()

func _on_pack_load_progress_update(current: int, total: int):
	print_status("Downloading latest content (%d/%d)" % [current, total])

func print_status(status: String):
	status_label.text = status
	
func display_error(display_data: Dictionary):
	error_dialog.title = display_data.get("title", "WTF")
	error_dialog.dialog_text = display_data.get("tip", "HMM, wut !?")
	error_dialog.visible = true
	
func get_error_display(data: Dictionary) -> Dictionary:
	assert(data.has("error"))
	print("ERROR: ", data)
	var error: CMS.CMSError = data.get("error")
	printerr(error)
	if error == CMS.CMSError.INTERNET_ERROR:
		return {
			"title": "No internet",
			"tip": "This game needs to be conencted to the interned the first time it is launched, try checking your internet connection or buy a Starlink subscription."
		}
	elif error == CMS.CMSError.SERVER_ERROR:
		return {
			"title": "Server error",
			"tip": "Our servers have problems, retry later :/"
		}
	elif error == CMS.CMSError.DATA_INTEGRITY:
		return {
			"title": "Data corrupted",
			"tip": "Try checking your internet connection or update the game."
		}
	elif error == CMS.CMSError.MANIFEST_VERSION:
		return {
			"title": "Outdated version",
			"tip": "Your game is outdated, try updating it."
		}
	else:
		return {
			"title": "Unknown error",
			"tip": "This is a serious issue, try contacting these idiots of developers, or update your game."
		}
