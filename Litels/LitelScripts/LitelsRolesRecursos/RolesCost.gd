extends Node


var roles_costs := {
	0: { "wood": 0, "stone": 0, "food": 0 },     # None
	1: { "wood": 5, "stone": 10, "food": 0 },   # Lumberjack
	2: { "wood": 5, "stone": 0, "food": 8 },   # Gatherer
	3: { "wood": 0, "stone": 3, "food": 10 }   # Miner
}

func get_roles_costs(role_id: int) -> Dictionary:
	return roles_costs[role_id]
