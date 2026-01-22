extends Control
#Este script visualiza elos recursos según el equipo

@onready var wood_label: Label = $MarginContainer/HhudContainer/HResContainer/HWoodContainer/WoodLabel
@onready var lumb_work_label: Label = $MarginContainer/HhudContainer/HWorkersContainer/HLumberjackContainer/LumbWorkLabel

@onready var berry_label: Label = $MarginContainer/HhudContainer/HResContainer/HBerryContainer/BerryLabel
@onready var gath_work_label: Label = $MarginContainer/HhudContainer/HWorkersContainer/HGathererContainer/GathWorkLabel

@onready var stone_label: Label = $MarginContainer/HhudContainer/HResContainer/HStoneContainer/StoneLabel
@onready var miner_work_label: Label = $MarginContainer/HhudContainer/HWorkersContainer/HMinerContainer/MinerWorkLabel

@export var local_team_id: int = 0


var worker_labels := {}
var resources_labels := {}

func _ready():

	worker_labels = {
		"Lumberjack": lumb_work_label,
		"Gatherer": gath_work_label,
		"Miner": miner_work_label
	}
	
	resources_labels = {
		"wood": wood_label,
		"food": berry_label,
		"stone": stone_label
	}
	
	GameState.resources_changed.connect(_on_resources_changed)   # Se conecta a la señal
	_on_resources_changed(local_team_id, GameState.get_resources(local_team_id))  #Llama a la función
	
	GameState.workers_changed.connect(_on_workers_changed)   
	_on_workers_changed(local_team_id, GameState.get_workers(local_team_id))
	



func _on_resources_changed(team_id: int, r: Dictionary) -> void:        #refresca los recursos
	if team_id != local_team_id:
		return
		
	for k in resources_labels.keys():
		resources_labels[k].text = str(r.get(k))
		
		
func _on_workers_changed(team_id: int, r: Dictionary) -> void:
	if team_id != local_team_id:
		return

	for k in worker_labels.keys():
		worker_labels[k].text = str(r.get(k))

	
