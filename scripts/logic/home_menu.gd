extends Control

@export var status_label: Label

@export var start_button: Button
@export var store_button: Button
@export var quit_button: Button

@export var pack: ResourcePack

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_button.disabled = true
	start_button.connect("pressed", _on_start_pressed)
	fetch_remote_data()

func fetch_remote_data():
	print_status("Fetching status")
	var manifest: Dictionary = await CMS.fetch_manifest()
	if check_error(manifest):
		return
	
	print_status("Fetching latest content")
	var default_pack_id: String = manifest.get("default_pack_id")
	
	pack = ResourcePack.new(default_pack_id)
	pack.connect("load_progress_update", _on_pack_load_progress_update)
	await pack.loaded
	
	print_status("Ready !")
	GameSettings.current_pack = pack
	start_button.disabled = false
	

func _on_start_pressed():
	get_tree().change_scene_to_file("res://scenes/Game/GameUI.tscn")

func _on_pack_load_progress_update(current: int, total: int):
	print_status("Fetching latest content (%d/%d)" % [current, total])

func print_status(status: String):
	status_label.text = status
	
func check_error(data: Dictionary):
	if data.has("error"):
		print("ERROR: ", data)
		var error: CMS.CMSError = data.get("error")
		printerr(error)
		if error == CMS.CMSError.INTERNET_ERROR:
			pass
		elif error == CMS.CMSError.SERVER_ERROR:
			pass
		elif error == CMS.CMSError.DATA_INTEGRITY:
			pass
		elif error == CMS.CMSError.MANIFEST_VERSION:
			pass
		else:
			printerr("WTF")
		return true
	else:
		return false
