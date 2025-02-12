class_name Backend extends Node

enum Error {
	API_CALL,
	SESSION_AUTH,
	SESSION_REFRESH,
	SOCKET_CONNECTION,
}

signal connected
signal error(code: Error)
signal session_refreshed

var client : NakamaClient
var socket : NakamaSocket
var session : NakamaSession

var is_healthy := false

var config := ConfigFile.new()
var device_id = OS.get_unique_id()

@onready var refresh_timer: Timer

func _init() -> void:
	config.load("res://secrets/nakama.cfg")
	client = Nakama.create_client(
		config.get_value("client", "server_key"),
		config.get_value("client", "host"),
		config.get_value("client", "port"),
		config.get_value("client", "scheme")
	)

func create_session_and_connect():
	session = await client.authenticate_device_async(device_id)
	if session.is_exception():
		print("An error occurred while autheticating to the backend: %s" % session)
		error.emit(Error.SESSION_AUTH)
		return
	print("Successfully authenticated to the backend: %s" % session)

	socket = Nakama.create_socket_from(client)

	var connection : NakamaAsyncResult = await socket.connect_async(session)
	if connection.is_exception():
		print("An error occurred while connecting to backend: %s" % connection)
		error.emit(Error.SOCKET_CONNECTION)
		return
	print("Backend socket connected.")
	connected.emit()
	
func refresh_session():
	session = await client.session_refresh_async(session)
	if session.is_exception():
		print("An error occurred while refreshing the backend session: %s" % session)
		error.emit(Error.SESSION_REFRESH)
	else:
		session_refreshed.emit()

func _ready() -> void:
	create_session_and_connect()
	
	refresh_timer = Timer.new()
	refresh_timer.wait_time = 60.0
	refresh_timer.autostart = false # Started manually after connect
	refresh_timer.one_shot = false
	
	refresh_timer.timeout.connect(_on_session_refresh_timer_timeout)
	add_child(refresh_timer)
	
	self.connected.connect(func (): is_healthy = true; refresh_timer.start())
	self.session_refreshed.connect(func (): is_healthy = true)
	self.error.connect(func (_code): is_healthy = false)
	
func _on_session_refresh_timer_timeout() -> void:
	refresh_session()
