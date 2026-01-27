extends Control
# Este script se encarga de detectar cuándo presionan un botón y asignar un rol
# Y actualizar la UI de costos

const Roles = preload("res://LitelsUI/LitelsUIScript/roles.gd")

@onready var role_blocks := {
	Roles.Role.LUMBERJACK: $HBoxContainer/HResCostContainer/HLumbResContainer,
	Roles.Role.GATHERER:  $HBoxContainer/HResCostContainer/HGathResContainer,
	Roles.Role.MINER:  $HBoxContainer/HResCostContainer/HMinerResContainer,
	Roles.Role.BUILDER:  $HBoxContainer/HResCostContainer/HBuilderResContainer,
}

@export var build_selection: Node

func _ready():
	_update_all_costs()
	if build_selection:
		build_selection.build_changed.connect(_on_build_changed)



func _on_build_changed() -> void:
	_update_role_cost(Roles.Role.BUILDER)
	
# ========================= ACTUALIZACIÓN DE COSTO DE ROLES =========================

# Actualizo costo por cada Rol 
func _update_all_costs() -> void:
	for role_id in role_blocks.keys():
		_update_role_cost(role_id)


# Actualizo costo por cada label
func _update_role_cost(role_id: int) -> void:
	var build_type = build_selection.current_build
	var cost := RolesCost.get_roles_costs(role_id, build_type)
	var block : Node = role_blocks[role_id]

	for container in block.get_children():
		for node in container.get_children():
			_apply_cost_to_label(node, cost)
			node.custom_minimum_size.x = 0

# Aplico la actualización de cada label
func _apply_cost_to_label(node: Node, cost: Dictionary) -> void:
	if not (node is Label):
		return

		# Evita que el Label se coma el ancho y empuje el layout

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
	RoleManager.assign_role(Roles.Role.LUMBERJACK, LitelManager.unit_selected, -1)

func _on_gatherer_button_pressed() -> void:
	RoleManager.assign_role(Roles.Role.GATHERER, LitelManager.unit_selected, -1)
			
func _on_miner_button_pressed() -> void:
	RoleManager.assign_role(Roles.Role.MINER, LitelManager.unit_selected, -1)
			
func _on_builder_button_pressed() -> void:
	var build_type = build_selection.current_build

	if build_type > 0:
		RoleManager.assign_role(Roles.Role.BUILDER, LitelManager.unit_selected, build_type)
		
