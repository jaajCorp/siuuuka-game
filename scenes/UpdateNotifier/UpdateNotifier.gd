extends Window

@onready var http_request: HTTPRequest = $HTTPRequest
@onready var title_label := $Panel/MarginContainer/VBoxContainer/Title

var current_version_tag: String = "v" + ProjectSettings.get_setting("application/config/version")
var current_version: Array[int] = parse_version(current_version_tag)

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
	print("[UpdateChecker] Latest version tag: %s (current: %s)" % [tag, current_version_tag])
	
	var latest_version = parse_version(tag)
	var cmp = compare_versions(current_version, latest_version)
	if cmp < 0:
		latest_release_download_link = data.get("assets")[0].get("browser_download_url")
		title_label.text = "Update %s available" % [tag]
		self.visible = true
	
func parse_version(tag: String) -> Array[int]:
	assert(tag.begins_with("v"))
	tag.erase(0)
	
	var version_numbers := tag.split(".")
	assert(version_numbers.size() == 3)
	
	var out: Array[int] = []
	for number_str in version_numbers:
		out.push_back(int(number_str))
		
	return out

# -1 if a lesser than b (outdated), 1 if b greater than a, 0 if equals
func compare_versions(a: Array[int], b: Array[int]) -> int:
	assert(a.size() == b.size())
	for i in range(a.size()):
		if a[i] > b[i]:
			return 1
		elif a[i] < b[i]:
			return -1

	return 0
