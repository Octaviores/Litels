extends Node

const Roles = preload("res://LitelsUI/LitelsUIScript/roles.gd")
const Builds = preload("res://Buildings/BuildingsScripts/Buildings.gd")

var roles_costs := {
	0: { "wood": 0, "stone": 0, "food": 0 },       # None
	1: { "wood": 5, "stone": 10, "food": 0 },     # Lumberjack
	2: { "wood": 5, "stone": 0, "food": 8 },     # Gatherer
	3: { "wood": 0, "stone": 3, "food": 10 },   # Miner
	4: { "wood": 0, "stone": 0, "food": 0 }    # Builder
}

var buildings_costs := {
	Builds.Build.SPAWNER: { "wood": 0, "stone": 10, "food": 0 }
}

func get_roles_costs(role_id: int, build_type: int = -1) -> Dictionary:
	if role_id != Roles.Role.BUILDER:
		return roles_costs[role_id]
		
	return buildings_costs.get(build_type, roles_costs[role_id])
		
