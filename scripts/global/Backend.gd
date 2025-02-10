class_name Backend extends Node

var client : NakamaClient
var socket : NakamaSocket
var session : NakamaSession 
var device_id = OS.get_unique_id()

func _init() -> void:
	var config := ConfigFile.new()
	config.load("res://secrets/nakama.cfg")
	client = Nakama.create_client(
		config.get_value("client", "server_key"),
		config.get_value("client", "host"),
		config.get_value("client", "port"),
		config.get_value("client", "scheme")
	)
	
	session = await client.authenticate_device_async(device_id)
	if session.is_exception():
		print("An error occurred while autheticating to the backend: %s" % session)
		return
	print("Successfully authenticated to the backend: %s" % session)

	socket = Nakama.create_socket_from(client)

	var connected : NakamaAsyncResult = await socket.connect_async(session)
	if connected.is_exception():
		print("An error occurred while connecting to backend: %s" % connected)
		return
	print("Backend socket connected.")

func is_ok():
	return socket.is_connected_to_host()
