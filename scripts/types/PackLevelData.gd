class_name PackLevelData extends Resource

@export var texture: ImageTexture
@export var frame: bool
@export var ambient_sounds: Array[AudioStreamOggVorbis]
	
static func from(p_texture: ImageTexture, p_frame: bool, p_ambient_sounds: Array[AudioStreamOggVorbis]) -> PackLevelData:
	var new := PackLevelData.new()
	new.texture = p_texture
	new.frame = p_frame
	new.ambient_sounds = p_ambient_sounds
	return new
