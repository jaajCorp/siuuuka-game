class_name ResourcePack extends Resource

signal loaded(error: CMS.CMSError)
signal load_progress_update(current: int, total: int)

@export var id: String

@export_category("Data")
@export var background: ImageTexture
@export var background_landscape: ImageTexture
@export var ui: PackUI
@export var levels: Array[PackLevelData]

@export_category("Metadata")
@export var total_asset_count: int
@export var current_asset_count: int

static func new_from_id(target_id: String) -> ResourcePack:
	var new_pack := ResourcePack.new()
	new_pack.id = target_id
	new_pack.__load_assets()
	return new_pack
	
func __load_assets():
	load_progress_update.emit(0, 100)
	
	var meta = await CMS.fetch_pack_metadata(id)
	if meta.has("error"):
		loaded.emit(meta.get("error"))
		return
	total_asset_count = __get_total_asset_count(meta)
	
	self.background = await __load_texture_asset(meta.get("background"))
	self.background_landscape = await __load_texture_asset(meta.get("background_landscape"))
	
	self.ui = PackUI.from(meta.get("ui"))
	for level: Dictionary in meta.get("levels"):
		var texture := await __load_texture_asset(level.get("texture"))
		if texture == null:
			loaded.emit(CMS.CMSError.DATA_INTEGRITY)
			return
		var frame: bool = level.get("frame")
		var ambient_sounds: Array[AudioStreamOggVorbis] = []
		for sound: String in level.get("ambient_sounds"):
			var audio_stream := await __load_audio_asset(sound)
			if audio_stream == null:
				loaded.emit(CMS.CMSError.DATA_INTEGRITY)
				return
			
			ambient_sounds.push_back(audio_stream)
		
		self.levels.push_back(PackLevelData.from(texture, frame, ambient_sounds))
		
	
	loaded.emit(CMS.CMSError.OK)
	
func __load_texture_asset(asset_path: String) -> ImageTexture:
	print("Loading texture asset " + asset_path + " for pack " + id)
	var buffer := await CMS.fetch_pack_asset(id, asset_path)
	if buffer.is_empty():
		printerr("Failed to fetch image asset")
		return null
		
	var image := Image.new()
	var extension_raw := asset_path.rsplit(".", true, 1)[1].to_lower()
	if extension_raw == "png":
		image.load_png_from_buffer(buffer)
	elif extension_raw == "webp":
		image.load_webp_from_buffer(buffer)
	elif extension_raw == "jpg" or extension_raw == "jpeg":
		image.load_jpg_from_buffer(buffer)
	elif extension_raw == "svg":
		image.load_svg_from_buffer(buffer)
	else:
		printerr("Received invalid image format")
		return null
		
	if image.is_empty():
		printerr("Received corrupted image format")
		return null
	
	__incr_asset_count()
	return ImageTexture.create_from_image(image)
	
func __load_audio_asset(asset_path: String) -> AudioStreamOggVorbis:
	print("Loading audio asset " + asset_path + " for pack " + id)
	assert(asset_path.rsplit(".", true, 1)[1].to_lower() == "ogg")
	var buffer := await CMS.fetch_pack_asset(id, asset_path)
	if buffer.is_empty():
		printerr("Failed to fetch audio stream asset")
		return null
		
	var stream := AudioStreamOggVorbis.load_from_buffer(buffer)
	
	__incr_asset_count()
	return stream
	
func __get_total_asset_count(meta: Dictionary) -> int:
	var count = 2 # Background (portrait + landscape)
	for level: Dictionary in meta.get("levels"):
		count += 1 + len(level.get("ambient_sounds"))
		
	return count
	
func __incr_asset_count() -> void:
	current_asset_count += 1
	load_progress_update.emit(current_asset_count, total_asset_count)
	
func get_level_data(level: int) -> PackLevelData:
	return levels[level]
	
func get_level_random_ambient(level: int) -> AudioStreamOggVorbis:
	if levels[level].ambient_sounds.is_empty():
		return null
	else:
		return levels[level].ambient_sounds.pick_random()
