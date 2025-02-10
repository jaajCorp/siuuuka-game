extends Control

@onready var username_edit := $MarginContainer/VBoxContainer/HBoxContainer/UsernameEdit
@onready var scoreboard_grid := $MarginContainer/VBoxContainer/Panel/MarginContainer/VBoxContainer/GridContainer

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
	update_leaderboard_grid()

func _on_backend_error():
	print("Errore")
	
func update_username_edit():
	var account = await Global.backend.client.get_account_async(Global.backend.session)
	username_edit.text = account.user.username
	
func update_leaderboard_grid():
	var limit = 100
	var client = Global.backend.client
	var session = Global.backend.session
	var leaderboard_name = "weekly_leaderboard"
	var result : NakamaAPI.ApiLeaderboardRecordList = await client.list_leaderboard_records_async(session, leaderboard_name, null, null, limit, null)

	for child in scoreboard_grid.get_children():
		child.queue_free()

	for record in result.records:
		for field in [
			[0.2, record.rank], 
			[0.5, record.username], 
			[0.3, record.score]
		]:
			var label := Label.new()
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			label.size_flags_stretch_ratio = field[0]
			label.text = field[1]
			scoreboard_grid.add_child(label)
	
func _on_username_edit_submit():
	var username = username_edit.text
	await Global.backend.client.update_account_async(Global.backend.session, username)
	print("Updated username")

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/Home.tscn")
