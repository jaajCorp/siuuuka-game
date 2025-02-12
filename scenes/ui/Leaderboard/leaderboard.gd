extends Control

@onready var username_edit := $MarginContainer/VBoxContainer/HBoxContainer/UsernameEdit
@onready var scoreboard_grid := $MarginContainer/VBoxContainer/Panel/MarginContainer/VBoxContainer/GridContainer
@onready var virtual_keyboard_margin := $MarginContainer/VBoxContainer/VKeyboardMargin

@onready var popup := $Popup
@onready var popup_title := $Popup/VBoxContainer/Title
@onready var popup_content := $Popup/VBoxContainer/Content

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	popup.visible = false
	
	Global.backend.error.connect(_on_backend_error)
	Global.backend.connected.connect(_on_backend_ready)
	# Refreshes the list
	Global.backend.session_refreshed.connect(_on_backend_ready)
	if not Global.backend.is_healthy:
		Global.backend.create_session_and_connect()
	else:
		_on_backend_ready()

func _on_backend_ready():
	update_username_edit()
	update_leaderboard_grid()

func _on_backend_error(code: Backend.Error):
	popup.visible = true
	popup_title.text = "Error!"
	popup_content.text = "Failed to connect to the server, please check your internet connection (code: %s)" % [Backend.Error.keys()[code]]
	
	popup.confirmed.connect(_on_back_pressed, ConnectFlags.CONNECT_ONE_SHOT)
	
func update_username_edit():
	var account = await Global.backend.client.get_account_async(Global.backend.session)
	if account.is_exception():
		_on_backend_error(Backend.Error.API_CALL)
	else:
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
			label.add_theme_font_size_override("font_size", 44)
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			label.size_flags_stretch_ratio = field[0]
			label.text = field[1]
			scoreboard_grid.add_child(label)

func _on_username_edit_focus():
	var margin_height := DisplayServer.virtual_keyboard_get_height()
	if margin_height <= 0 and DisplayServer.has_feature(DisplayServer.FEATURE_VIRTUAL_KEYBOARD):
		margin_height = 440
	virtual_keyboard_margin.add_theme_constant_override("margin_bottom", margin_height)
	
func _on_username_edit_submit():
	var username = username_edit.text
	Global.backend.session.username = username
	await Global.backend.client.update_account_async(Global.backend.session, username)

	virtual_keyboard_margin.add_theme_constant_override("margin_bottom", 0)
	
	popup.visible = true
	popup_title.text = "Username updated!"
	popup_content.text = "Beat your personal weekly record to see it updated in the leaderboard"

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/Home.tscn")
