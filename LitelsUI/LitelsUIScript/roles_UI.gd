extends Control
# Este script se encarga de detectar cuándo presionan un botón y asignar un rol
# Y actualizar la UI de costos

const Roles = preload("res://LitelsUI/LitelsUIScript/roles.gd")

@onready var role_blocks := {
	Roles.Role.LUMBERJACK: $MarginContainer/HResCostContainer/HLumbResContainer,
	Roles.Role.GATHERER:  $MarginContainer/HResCostContainer/HGathResContainer,
	Roles.Role.MINER:  $MarginContainer/HResCostContainer/HMinerResContainer,
}
#Actualizado los costos 
func _ready() -> void:  
	_update_all_costs()
	
	
# ========================= ACTUALIZACIÓN DE COSTO DE ROLES =========================

# Actualizo costo por cada Rol 
func _update_all_costs() -> void:
	for role_id in role_blocks.keys():
		_update_role_cost(role_id)

# Actualizo costo por cada label
func _update_role_cost(role_id: int) -> void:
	var cost := RolesCost.get_roles_costs(role_id)
	var block : Node = role_blocks[role_id]

	for container in block.get_children():
		for node in container.get_children():
			_apply_cost_to_label(node, cost)

# Aplico la actualización de cada label
func _apply_cost_to_label(node: Node, cost: Dictionary) -> void:
	if not (node is Label):
		return

	var n := node.name.to_lower()
	if "wood" in n:
		node.text = str(cost["wood"])
	elif "stone" in n:
		node.text = str(cost["stone"])
	elif "food" in n:
		node.text = str(cost["food"])




# ========================= ASIGNACIÓN DE ROLES =========================

#Si presiono el botón "Lenador", cambio el rol
func _on_lumberjack_button_pressed() -> void:
	RoleManager.assign_role(Roles.Role.LUMBERJACK, LitelManager.unit_selected)

func _on_gatherer_button_pressed() -> void:
	RoleManager.assign_role(Roles.Role.GATHERER, LitelManager.unit_selected)
			
func _on_miner_button_pressed() -> void:
	RoleManager.assign_role(Roles.Role.MINER, LitelManager.unit_selected)
			
