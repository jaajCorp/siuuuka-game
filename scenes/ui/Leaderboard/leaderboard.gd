extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not Global.backend.socket:
		_on_backend_error()
	elif Global.backend.socket.is_connecting_to_host():
		Global.backend.socket.connected.connect(_on_backend_ready)
		Global.backend.socket.connection_error.connect(_on_backend_error)
	elif Global.backend.socket.is_connected_to_host():
		_on_backend_ready()
	else:
		_on_backend_error()

func _on_backend_ready():
	print("Ready")
	
func _on_backend_error():
	print("Errore")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
