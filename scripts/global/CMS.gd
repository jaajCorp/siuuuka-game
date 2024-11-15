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

enum CMSError {
	OK,
	INTERNET_ERROR,
	SERVER_ERROR,
	DATA_INTEGRITY,
	MANIFEST_VERSION,
}
	

func _ready() -> void:
	http_request = HTTPRequest.new()
	add_child(http_request)

func fetch_manifest() -> Dictionary:
	var manifest := await __generic_json_fetch(MANIFEST_URL)
	if manifest.has("error"):
		# Let callers handle the error
		return manifest
	
	if manifest.get("version") != MANIFEST_VERSION:
		return { "error": CMSError.MANIFEST_VERSION }
		
	return manifest

func fetch_pack_list() -> Dictionary:
	if manifest.is_empty():
		manifest = await fetch_manifest()
		if manifest.has("error"):
			# Let callers handle the error
			return manifest
		
	var registry = await __generic_json_fetch(manifest.get("registry_url"))
	
	return registry
	
func fetch_pack_metadata(id: String) -> Dictionary:
	if manifest.is_empty():
		manifest = await fetch_manifest()
		if manifest.has("error"):
			# Let callers handle the error
			return manifest
		
	var pack_meta = await __generic_json_fetch(manifest.get("packs_url") + id + "/pack.json")
	
	return pack_meta
	
func fetch_pack_asset(id: String, asset: String) -> PackedByteArray:
	if manifest.is_empty():
		manifest = await fetch_manifest()
		if manifest.has("error"):
			# Error not passed, if only rust...
			return []
	var response = await __generic_fetch(manifest.get("packs_url") + id + "/assets/" + asset)
	if response.has("error"):
		return []
		
	return response.get("body")
		
func __generic_fetch(url: String) -> Dictionary:
	var error: Error = http_request.request(url)
	if error != OK:
		return {"error": CMSError.INTERNET_ERROR, "code": error}
	var response = await http_request.request_completed
	var result: int = response[0]
	if result != OK:
		return {"error": CMSError.INTERNET_ERROR, "code": result}
	
	var status_code: int = response[1]
	if status_code != 200:
		return {"error": CMSError.SERVER_ERROR, "code": status_code}
		
	return {
		"status_code": response[1],
		"headers": response[2],
		"body": response[3]
	}
	
func __generic_json_fetch(url: String) -> Dictionary:
	var response := await __generic_fetch(url)
	if response.has("error"):
		# Let callers handle the error
		return response
	
	var body: PackedByteArray = response.get("body")
	var json := JSON.new()
	var parse_error := json.parse(body.get_string_from_utf8())
	if parse_error != OK:
		return{"error": CMSError.DATA_INTEGRITY, "code": parse_error}
		
	return json.get_data()
