# Thx to https://shaggydev.com/2025/06/12/godot-awaiting-signals/

class_name SignalGroup
extends RefCounted

signal _all_complete
signal _one_complete

var _counter: int = 0

func all(signals: Array) -> void:
	_counter = signals.size()
	
	if _counter == 0:
		return
		
	for sig in signals:
		sig.connect(_on_signal_complete, CONNECT_ONE_SHOT)
	
	await _all_complete
	
func any(signals: Array) -> void:
	_counter = signals.size()
	
	if _counter == 0:
		return
		
	for sig in signals:
		sig.connect(_on_signal_complete, CONNECT_ONE_SHOT)
	
	await _one_complete
	
func _on_signal_complete() -> void:
	_counter -= 1
	_one_complete.emit()
	if _counter == 0:
		_all_complete.emit()
