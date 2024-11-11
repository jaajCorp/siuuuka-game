extends Node

const POLITICIANS := [
	preload("res://assets/img/french_politicians/hollande.png"),
	preload("res://assets/img/french_politicians/sarko.png"),
	preload("res://assets/img/french_politicians/bardella.png"),
	preload("res://assets/img/french_politicians/zemmour.png"),
	preload("res://assets/img/french_politicians/marine.png"),
	preload("res://assets/img/french_politicians/macron.png"),
	preload("res://assets/img/french_politicians/jean-marie.png"),
	preload("res://assets/img/french_politicians/lasalle.png"),
]

func get_level_texture(level: int) -> Texture2D:
	return POLITICIANS[level]
