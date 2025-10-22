extends Window

@onready var http_request: HTTPRequest = $HTTPRequest
@onready var title_label := $Panel/MarginContainer/VBoxContainer/Title

var current_version_tag: String = "v" + ProjectSettings.get_setting("application/config/version")
var current_version: Array[int] = parse_version(current_version_tag)[0]

var latest_release_download_link: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false
	
	http_request = HTTPRequest.new()
	add_child(http_request)
	
	check_app_update()

func _on_download_button_pressed() -> void:
	OS.shell_open(latest_release_download_link)

func _on_discard_button_pressed() -> void:
	self.visible = false

func check_app_update() -> void:
	print("[UpdateChecker] Checking for updates")
	var error := http_request.request("https://api.github.com/repos/JaajCorp/siuuuka-game/releases/latest")
	if error != OK:
		print("[UpdateChecker] Failed to request for updates")
		return
		
	var response = await http_request.request_completed
	
	var result: int = response[0]
	if result != OK:
		print("[UpdateChecker] Failed to fetch for updates")
		return
	var body: PackedByteArray = response[3]
	
	var json := JSON.new()
	var parse_error := json.parse(body.get_string_from_utf8())
	if parse_error != OK:
		print("[UpdateChecker] Failed to parse request body")
		return
	
	var data: Dictionary = json.get_data()
	var tag = data.get("tag_name")
	if tag:
		print("[UpdateChecker] Latest version tag: %s (current: %s)" % [tag, current_version_tag])
	else:
		printerr("Failed to retreive latest release tag: ", data)
		return
	
	var parsed_version = parse_version(tag)
	var latest_version = parsed_version[0]
	var release_candidate = parsed_version[1]
	
	# TODO: We could check for a previous release which is not a candidate but which is superior anyways.
	if release_candidate != null:
		print("Skipping release candidate %d for %s" % [release_candidate, tag])
		return

	var cmp = compare_versions(current_version, latest_version)
	if cmp < 0:
		latest_release_download_link = data.get("assets")[0].get("browser_download_url")
		title_label.text = "Update %s available" % [tag]
		self.visible = true
	
"""
Parse a semantic version string to an tuple of:
	- array of 3 ints representing version numbers
	- optional release candidate version
"""
func parse_version(tag: String) -> Array:
	assert(tag.begins_with("v"))
	tag.erase(0)
	
	var version_numbers := tag.split(".")
	assert(version_numbers.size() == 3)
	
	# Release candidate check
	var rc_num = null
	var split_last = version_numbers[2].split("-")
	if split_last.size() == 2:
		var patch: String = split_last[0]
		var rc: String = split_last[1]
		
		version_numbers[2] = patch
		assert(rc.begins_with("rc"))
		rc_num = int(rc.substr(2))
		
	else:
		assert(split_last.size() == 1)
	
	var version: Array[int] = []
	for number_str in version_numbers:
		version.push_back(int(number_str))
		
	return [version, rc_num]

# -1 if a lesser than b (outdated), 1 if b greater than a, 0 if equals
func compare_versions(a: Array[int], b: Array[int]) -> int:
	assert(a.size() == b.size())
	for i in range(a.size()):
		if a[i] > b[i]:
			return 1
		elif a[i] < b[i]:
			return -1

	return 0
