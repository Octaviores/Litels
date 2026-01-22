extends Node
#Script que se encarga de asignar roles según el costo en "RolesCost"
const Roles = preload("res://LitelsUI/LitelsUIScript/roles.gd")

var current_role: Roles.Role = Roles.Role.NONE

@export var local_team_id: int = 0


func assign_role(role_id: int, litels: Array) -> void:
	for unit in litels:
		var rc = unit.role_component 
		var current_role : int = rc.current_role
		if current_role == role_id:
			rc.set_role(Roles.Role.NONE)
		elif GameState.pay(local_team_id, RolesCost.get_roles_costs(role_id)):
			rc.set_role(role_id)
