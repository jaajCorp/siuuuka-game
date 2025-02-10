extends Control

var client : NakamaClient
var device_id = OS.get_unique_id()

@onready var socket = Nakama.create_socket_from(client)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var config := ConfigFile.new()
	config.load("res://secrets/nakama.cfg")
	client = Nakama.create_client(
		config.get_value("client", "server_key"),
		config.get_value("client", "host"),
		config.get_value("client", "port"),
		config.get_value("client", "scheme")
	)
	
	var session : NakamaSession = await client.authenticate_device_async(device_id)
	if session.is_exception():
		print("An error occurred: %s" % session)
		return
	print("Successfully authenticated: %s" % session)


	var connected : NakamaAsyncResult = await socket.connect_async(session)
	if connected.is_exception():
		print("An error occurred: %s" % connected)
		return
	print("Socket connected.")




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
