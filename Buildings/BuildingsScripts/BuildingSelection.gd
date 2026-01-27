extends Node
#Este script manda señales de las construcciones seleccionadas en el panel izquierdo

const Builds = preload("res://Buildings/BuildingsScripts/Buildings.gd")


var current_build: int = Builds.Build.NONE
signal build_changed()

func _on_spawner_button_pressed() -> void:
	current_build = Builds.Build.SPAWNER
	build_changed.emit()
