extends Control

@onready var username_edit := $MarginContainer/VBoxContainer/HBoxContainer/UsernameEdit

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
	update_username_edit()
	
func _on_backend_error():
	print("Errore")
	
func update_username_edit():
	var account = await Global.backend.client.get_account_async(Global.backend.session)
	username_edit.text = account.user.username
	
func _on_username_edit_submit():
	var username = username_edit.text
	await Global.backend.client.update_account_async(Global.backend.session, username)

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/Home.tscn")
