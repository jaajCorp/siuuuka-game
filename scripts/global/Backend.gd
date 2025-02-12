class_name Backend extends Node

enum Error {
	SESSION_AUTH,
	SESSION_REFRESH,
	SOCKET_CONNECTION
}

signal error(code: Error)

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
		error.emit(Error.SESSION_AUTH)
		return
	print("Successfully authenticated to the backend: %s" % session)

	socket = Nakama.create_socket_from(client)

	var connected : NakamaAsyncResult = await socket.connect_async(session)
	if connected.is_exception():
		print("An error occurred while connecting to backend: %s" % connected)
		error.emit(Error.SOCKET_CONNECTION)
		return
	print("Backend socket connected.")

func _ready() -> void:
	var refresh_timer := Timer.new()
	refresh_timer.wait_time = 60.0
	refresh_timer.autostart = true
	refresh_timer.one_shot = false
	
	refresh_timer.timeout.connect(_on_session_refresh_timer_timeout)
	add_child(refresh_timer)
	
func _on_session_refresh_timer_timeout() -> void:
	session = await client.session_refresh_async(session)
	if session.is_exception():
		print("An error occurred while refreshing the backend session: %s" % session)
		error.emit(Error.SESSION_REFRESH)
