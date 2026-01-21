extends Control
#Este script se encarga de ver qué litels se seleccionaron y setearles un rol

const Roles = preload("res://LitelsUI/LitelsUIScript/roles.gd")

var current_role: Roles.Role = Roles.Role.NONE

signal role_selected(role_id)
#Si presiono el botón "Lenador", cambio el rol
func _on_lumberjack_button_pressed() -> void:
	role_selected.emit(Roles.Role.LUMBERJACK)
	for unit in LitelManager.unit_selected:
		if unit.current_role == Roles.Role.LUMBERJACK:
			unit.set_role(Roles.Role.NONE)
		else:
			unit.set_role(Roles.Role.LUMBERJACK)
			
func _on_gatherer_button_pressed() -> void:
	for unit in LitelManager.unit_selected:
		if unit.current_role == Roles.Role.GATHERER:
			unit.set_role(Roles.Role.NONE)
		else:
			unit.set_role(Roles.Role.GATHERER)
			
func _on_miner_button_pressed() -> void:
	for unit in LitelManager.unit_selected:
		if unit.current_role == Roles.Role.MINER:
			unit.set_role(Roles.Role.NONE)
		else:
			unit.set_role(Roles.Role.MINER)
