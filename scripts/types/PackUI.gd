class_name PackUI extends Resource


@export var primary: Color
@export var primary_content: Color
	
static func from(data: Dictionary) -> PackUI:
	var new := PackUI.new()
	new.primary = data.get("primary")
	new.primary_content = data.get("primary-content")
	return new
