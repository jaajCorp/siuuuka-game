class_name PackLevelData extends Resource

@export var texture: ImageTexture
@export var ambient_sounds: Array[AudioStreamOggVorbis]
	
static func from(texture: ImageTexture, ambient_sounds: Array[AudioStreamOggVorbis]) -> PackLevelData:
	var new := PackLevelData.new()
	new.texture = texture
	new.ambient_sounds = ambient_sounds
	return new
