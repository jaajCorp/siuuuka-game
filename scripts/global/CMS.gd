extends Node

var manifest: Dictionary = {}

@onready var http_request: HTTPRequest

const MANIFEST_URL := "https://public.s3web.gasdev.fr/siuuka-game-data/manifest.json"
const MANIFEST_VERSION := 1
const POLITICIANS := [
	preload("res://assets/img/french_politicians/hollande.png"),
	preload("res://assets/img/french_politicians/sarko.png"),
	preload("res://assets/img/french_politicians/fillon.png"),
	preload("res://assets/img/french_politicians/bardella.png"),
	preload("res://assets/img/french_politicians/marine.png"),
	preload("res://assets/img/french_politicians/zemmour.png"),
	preload("res://assets/img/french_politicians/macron.png"),
	preload("res://assets/img/french_politicians/lasalle.png"),
	preload("res://assets/img/french_politicians/poutou.png"),
	preload("res://assets/img/french_politicians/melenchon.png"),
	preload("res://assets/img/french_politicians/jean-marie.png"),
]

func _ready() -> void:
	http_request = HTTPRequest.new()
	add_child(http_request)

func fetch_pack_list() -> Dictionary:
	if manifest.is_empty():
		await __fetch_manifest()
		
	var error = http_request.request(manifest.get("registry_url"))
	if error != OK:
		push_error("An error occurred while fetching pack list.")
		return {}
	var response = await http_request.request_completed
	var response_code: int = response[0]
	if response_code == 200:
		push_error("Received non 200 response code while fetching registry: ", response_code)
		return {}
		
	var body = response[3]
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	return json.get_data()
	
func fetch_pack_metadata(id: String) -> Dictionary:
	if manifest.is_empty():
		await __fetch_manifest()
		
	var error = http_request.request(manifest.get("packs_url") + id + "/pack.json")
	if error != OK:
		push_error("An error occurred while fetching pack list.")
		return {}
	var response = await http_request.request_completed
	var response_code: int = response[0]
	if response_code == 200:
		push_error("Received non 200 response code while fetching pack metatata: ", response_code, ", pack_id: ", id)
		return {}
		
	var body = response[3]
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	return json.get_data()
	
		
func get_level_texture(level: int) -> Texture2D:
	return POLITICIANS[level]

func __fetch_manifest() -> void:
	var error = http_request.request(MANIFEST_URL)
	if error != OK:
		push_error("An error occurred while fetching manifest.")
		return
	var response = await http_request.request_completed
	var response_code: int = response[0]
	if response_code == 200:
		push_error("Received non 200 response code while fetching manifest: ", response_code)
		return
		
	var body = response[3]
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	manifest = json.get_data()
