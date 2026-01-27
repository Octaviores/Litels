extends Node
#Este script tiene funciones sumar recursos, trabajadores y emitir señales sobre ello según el equipo



#  ========================= vARIABLES Y SEÑALES =========================
signal resources_changed(team_id: int, resources: Dictionary)
signal workers_changed(team_id: int, worker_amount: Dictionary)

var resources_by_team := {
	0: { "wood": 200, "stone": 200, "food": 200 },
	1: { "wood": 0, "stone": 0, "food": 0 }
}

var worker_amount := {
	0: {"Lumberjack": 0, "Gatherer": 0, "Miner": 0 },
	1: {"Lumberjack": 0, "Gatherer": 0, "Miner": 0 }
}




#  ========================= RECURSOS Y TRABAJADORES =========================	

func add_resource(team_id: int, type: String, amount: int) -> void:
	
	resources_by_team[team_id][type] += amount
	resources_changed.emit(team_id, resources_by_team[team_id])
	
func get_resources(team_id: int) -> Dictionary:
	return resources_by_team[team_id]	
	
	
	
func add_worker(team_id: int, type: String, amount: int) -> void:
	worker_amount[team_id][type] += amount
	workers_changed.emit(team_id, worker_amount[team_id])
	
func get_workers(teamd_id: int) -> Dictionary:
	return worker_amount[teamd_id]








# ========================= CONSUMO DE RECURSOS PASIVO ========================= 

#Devuelve true o false dependiendo si puedo pagar los recursos
func can_pay(team_id: int, r: Dictionary) -> bool:
	return resources_by_team[team_id].food >= r.get("food", 0) \
		and resources_by_team[team_id].wood >= r.get("wood", 0) \
		and resources_by_team[team_id].stone >= r.get("stone", 0)  # El "\" es para seguir abajo.

# Resta los recursos
func pay(team_id: int, r: Dictionary) -> bool:

	if not can_pay(team_id, r):
		return false


	resources_by_team[team_id].food -= r.get("food", 0)
	resources_by_team[team_id].wood -= r.get("wood", 0)
	resources_by_team[team_id].stone -= r.get("stone", 0)
	
	resources_changed.emit(team_id, resources_by_team[team_id])
	return true
	



# ========================= CONSUMO DE RECURSOS POR ASIGNACIÓN DE ROL =========================
	
	
