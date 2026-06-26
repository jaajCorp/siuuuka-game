extends Control

signal game_ready

@export var status_label: Label
@export var progress_bar: ProgressBar

@export var start_button: Button
@export var leaderboard_button: Button
@export var quit_button: Button

@onready var error_dialog := $AcceptDialog

var game_loading := false

func _ready() -> void:
	error_dialog.visible = false
	progress_bar.visible = false
	
	start_button.connect("pressed", _on_start_pressed)
	leaderboard_button.connect("pressed", _on_leaderboard_pressed)
	quit_button.connect("pressed", _on_quit_pressed)
	
	Music.ensure_soundtrack_playing(Music.SOUNDTRACKS.TITLE_SCREEN)
	
	# Wait for backend to be initialized (required for easter egg)
	var signal_group := SignalGroup.new()
	await signal_group.any([Global.backend.connected, Global.backend.error])
	
	fetch_remote_data()

func fetch_remote_data():
	var pack: ResourcePack = null
	var online := true
	
	game_loading = true
	
	print_status("Fetching info")
	var manifest: Dictionary = await CMS.fetch_manifest()
	
	
	# Initialize to global setting, which might be empty!
	var current_pack_id: String = Global.settings.selected_pack_id
	
	if manifest.has("error"):
		# We are offline, use cached pack if available
		if current_pack_id:
			# We are saved, current pack is likely cached
			pass
		else:
			# We are screwed
			display_error(get_error_display(manifest))
			return
	else:
		# We are online
		var remote_default_pack_id = manifest.get("default_pack_id")
		if current_pack_id:
			# Check if default pack changed
			if current_pack_id != remote_default_pack_id:
				# Switch to this new pack
				current_pack_id = remote_default_pack_id
				Global.settings.selected_pack_id = current_pack_id
				Global.save_state()
		else:
			# First launch of the game
			current_pack_id = remote_default_pack_id
			Global.settings.selected_pack_id = current_pack_id
			Global.save_state()
	
	if Global.backend.is_healthy:
		var easter_egg_device_id = Global.backend.config.get_value("easter_egg", "device_id")
		var easter_egg_pack_id = Global.backend.config.get_value("easter_egg", "pack_id")
		
		var account = await Global.backend.client.get_account_async(Global.backend.session)

		if account and account.user and account.user.id == easter_egg_device_id:
			current_pack_id = easter_egg_pack_id
	
	pack = await fetch_pack(current_pack_id, not manifest.has("error"))
	
	if pack == null:
		printerr("Failed to fetch pack")
		if not error_dialog.visible:
			display_error({
				"title": "Failed to download remote content", 
				"tip": "This game needs to be connected to the internet the first time it is launched"}
			)
		return
		
	
	Global.current_pack = pack
	print_status("Ready !")
	game_loading = false
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
		progress_bar.visible = true
		var error = await pack.loaded
		progress_bar.visible = false
		if error != CMS.CMSError.OK:
			display_error(
				get_error_display({"error": error})
			)
			return

		var cache_result = CMSCache.save_resource_pack(pack)
		if cache_result != OK:
			display_error({"title": "Storage error", "tip": "Could not cache aseets on your storage device, please allow us to do so (i'm begging you)"})
			return
			
	return pack
	
var waiting_for_start := false
func _on_start_pressed():
	if waiting_for_start: return
	waiting_for_start = true
	
	if game_loading:
		await self.game_ready
	elif Global.current_pack == null:
		fetch_remote_data()
		await self.game_ready

	get_tree().change_scene_to_file("res://scenes/GameUI/GameUI.tscn")
		
	
func _on_leaderboard_pressed():
	get_tree().change_scene_to_file("res://scenes/Leaderboard/Leaderboard.tscn")
	
func _on_quit_pressed():
	get_tree().quit()

func _on_pack_load_progress_update(current: int, total: int):
	progress_bar.max_value = total
	progress_bar.value = current
	print_status("Downloading latest content (%d/%d)" % [current, total])

func print_status(status: String):
	status_label.text = status
	
func display_error(display_data: Dictionary):
	error_dialog.dialog_text = "%s\n\n%s" % [
		display_data.get("title", "WTF"), 
		display_data.get("tip", "HMM, wut !?")
	]
	error_dialog.visible = true
	waiting_for_start = false
	game_loading = false
	
func get_error_display(data: Dictionary) -> Dictionary:
	assert(data.has("error"))
	printerr(data)
	var error: CMS.CMSError = data.get("error")
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
