extends Node
#Script que se encarga de asignar roles según el costo en "RolesCost"


@export var local_team_id: int = 0

const Roles = preload("res://LitelsUI/LitelsUIScript/roles.gd")
const Builds = preload("res://Buildings/BuildingsScripts/Buildings.gd")

var spawner_flag := false
var rand_time_state = randf_range(0.0, 0.7)




func assign_role(role_id: int, litels: Array, b: int) -> void:
	if litels.is_empty():
		return
	
	# si el rol es distinto, all_have_role = false
	var all_have_role := true
	for u in litels:
		u.builder_component.build_type = b
		if u.role_component.current_role != role_id:
			all_have_role = false
			break
		
	# si el rol es igual, se vuelven comunes
	if all_have_role:
		for u in litels:
			u.role_component.set_role(Roles.Role.NONE)
			u.role_component.stop_work(rand_time_state) 
		return


	# Cobro 1 vez por construccion si es BUILDER. Si la construcción es SPAWNER, cobro 1 vez en toda la partida
	# Si no es BUILDer, le cobro a cada litel
	if role_id == Roles.Role.BUILDER:
		if spawner_flag:
			return
		var cost := RolesCost.get_roles_costs(role_id, b)
		if not GameState.pay(local_team_id, cost):
			return
		if b == Builds.Build.SPAWNER:
			spawner_flag = true
	else:
		for u in litels:
			var cost := RolesCost.get_roles_costs(role_id, b)
			if not GameState.pay(local_team_id, cost):
				return

	# asigno todos los roles
	for u in litels:
		u.role_component.set_role(role_id)
		print("ahora yo tengo el rol:", role_id)
