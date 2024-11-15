class_name ResourcePack extends Resource

signal loaded(error: CMS.CMSError)

class PackLevelData extends Resource:
	var texture: ImageTexture
	var ambient_sounds: Array[AudioStreamOggVorbis]
	
	func _init(texture: ImageTexture, ambient_sounds: Array[AudioStreamOggVorbis]) -> void:
		self.texture = texture
		self.ambient_sounds = ambient_sounds

class PackUI extends Resource:
	var primary: Color
	var primary_content: Color
	
	func _init(data: Dictionary) -> void:
		primary = data.get("primary")
		primary_content = data.get("primary-content")

@export var background: ImageTexture
@export var ui: PackUI
@export var levels: Array[PackLevelData]

var id: String

func _init(id: String):
	self.id = id
	load_assets()
	
func load_assets():
	var meta = await CMS.fetch_pack_metadata(id)
	if meta.has("error"):
		emit_signal("loaded", meta.get("error"))
		return
	
	self.background = await load_texture_asset(meta.get("background"))
	self.ui = PackUI.new(meta.get("ui"))
	for level in meta.get("levels"):
		var texture := await load_texture_asset(level.get("texture"))
		if texture == null:
			emit_signal("loaded", CMS.CMSError.DATA_INTEGRITY)
			return
		self.levels.push_back(PackLevelData.new(texture, []))
		
	
	emit_signal("loaded", CMS.CMSError.OK)
	
func load_texture_asset(asset_path: String) -> ImageTexture:
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
		
	return ImageTexture.create_from_image(image)
