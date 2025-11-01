extends AudioStreamPlayer2D

enum SOUNDTRACKS {
	TITLE_SCREEN,
	IN_GAME
}

var current_soundtrack: SOUNDTRACKS

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.bus = &"Music"
	
func ensure_soundtrack_playing(track: SOUNDTRACKS):
	if current_soundtrack != track or not self.playing:
		current_soundtrack = track
		self.stream = get_soundtrack_stream(track)
		self.play()
		
	
func get_soundtrack_stream(track: SOUNDTRACKS) -> AudioStreamOggVorbis:
	match track:
		SOUNDTRACKS.TITLE_SCREEN:
			return load("res://assets/audio/title-screen.ogg")
		SOUNDTRACKS.IN_GAME:
			return load("res://assets/audio/music.ogg")
		_:
			printerr("Match statement clause not handled")
			return
			
