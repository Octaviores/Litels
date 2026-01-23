extends Node

const Roles = preload("res://LitelsUI/LitelsUIScript/roles.gd")

@onready var work_timer: Timer = $"../WorkTimer"
@onready var litel := get_parent()

var current_role: int = Roles.Role.NONE

#Await entre estados WORK, WALK y WAIT
var stop_work_pending := false
var rand_time_state = randf_range(0.0, 0.7)

# Estados del litel
var escape_to_surface := false
enum State { WALK, WORK, WAIT }
var counted_as_lumberjack_worker := false
var counted_as_gatherer_worker := false
var counted_as_miner_worker := false
var work_target: Node = null

signal role_changed(old_role: int, new_role: int)

func _ready():
	
	# Manejar selecciónde litels,escaleras y recolección de recursos.
	
	work_timer.timeout.connect(_on_work_resources)
	


# ========================= LÓGICA DE ROLES =========================

#Manejador de Roles
func set_role(new_role: Roles.Role) -> void:
	if current_role == new_role:
		return

	var old := current_role
	# si estaba trabajando, paro siempre al cambiar rol
	stop_work(rand_time_state)

	if current_role == Roles.Role.MINER and new_role != Roles.Role.MINER:
		escape_to_surface = true

	
	
	current_role = new_role
	
	_apply_role_mask(current_role)


	litel.resource_sensor.force_raycast_update()
	role_changed.emit(old, current_role)

func _apply_role_mask(role: Roles.Role) -> void:
	# apago todas
	litel.resource_sensor.set_collision_mask_value(7, false)
	litel.resource_sensor.set_collision_mask_value(8, false)
	litel.resource_sensor.set_collision_mask_value(9, false)

	# prendo la correspondiente
	match role:
		Roles.Role.LUMBERJACK: litel.resource_sensor.set_collision_mask_value(7, true)
		Roles.Role.GATHERER:   litel.resource_sensor.set_collision_mask_value(8, true)
		Roles.Role.MINER:      litel.resource_sensor.set_collision_mask_value(9, true)

			
#Sumador de recolección de recursos
func _on_work_resources():
	if litel.state != litel.State.WORK:
		return

	#Rol Lumberjack
	match current_role:
		Roles.Role.LUMBERJACK: GameState.add_resource(litel.team_id, "wood", 1)
		Roles.Role.GATHERER: GameState.add_resource(litel.team_id, "food", 1)
		Roles.Role.MINER: GameState.add_resource(litel.team_id, "stone", 1)
		
	

#Sumador de cantidad de trabajadores
func workers_count():
	var working : bool = litel.state ==  litel.State.WORK
	
	match current_role:
		Roles.Role.LUMBERJACK:

			if working and not counted_as_lumberjack_worker :
				GameState.add_worker(litel.team_id, "Lumberjack", 1)
				counted_as_lumberjack_worker = true
			elif not working and counted_as_lumberjack_worker:
				GameState.add_worker(litel.team_id, "Lumberjack", -1)
				counted_as_lumberjack_worker = false
		
		Roles.Role.GATHERER:

			if working and not counted_as_gatherer_worker :
				GameState.add_worker(litel.team_id, "Gatherer", 1)
				counted_as_gatherer_worker = true
			elif not working and counted_as_gatherer_worker:
				GameState.add_worker(litel.team_id, "Gatherer", -1)
				counted_as_gatherer_worker = false
				
		Roles.Role.MINER:

			if working and not counted_as_miner_worker :
				GameState.add_worker(litel.team_id, "Miner", 1)
				counted_as_miner_worker = true
			elif not working and counted_as_miner_worker:
				GameState.add_worker(litel.team_id, "Miner", -1)
				counted_as_miner_worker = false

#Empieza a trabajar, activa contadores
func start_work(target: Node) -> void:
	if litel.state ==  litel.State.WORK and work_target == target:
		return

	
	litel.state =  litel.State.WORK
	work_target = target

	timer_enter_work()
	workers_count() 


#Termina de trabajar, finalizaco contadores
func stop_work(delay: float) -> void:
	if litel.state !=  litel.State.WORK:
		return
	if stop_work_pending:
		return


		
	litel.state =  litel.State.WAIT          # deja de estar "trabajando" pero todavía no camina
	work_target = null
	timer_exit_work()
	workers_count()
	
	stop_work_pending = true
	if delay > 0.0:
		await get_tree().create_timer(delay).timeout
	stop_work_pending = false

	if litel.state !=  litel.State.WAIT:   #por si durante el await volvió a WORK por alguna razón
		return
		
	litel.state =  litel.State.WALK

	

#Inicio del temporizador para esperar 1 segundo para ir sumando 1 de recurso
func timer_enter_work():
	if work_timer.is_stopped():
		work_timer.start(1.0)


#Finalización del temporizador
func timer_exit_work():
	if not work_timer.is_stopped():
		work_timer.stop()
