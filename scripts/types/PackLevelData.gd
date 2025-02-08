class_name PackLevelData extends Resource

@export var texture: ImageTexture
@export var frame: bool
@export var ambient_sounds: Array[AudioStreamOggVorbis]
	
static func from(texture: ImageTexture, frame: bool, ambient_sounds: Array[AudioStreamOggVorbis]) -> PackLevelData:
	var new := PackLevelData.new()
	new.texture = texture
	new.frame = frame
	new.ambient_sounds = ambient_sounds
	return new
