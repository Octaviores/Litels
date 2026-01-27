extends Node2D
#Este scrpit sirve para ver qué sitios están reservados  y cuales no, para construir

@export var site_container: Node2D
@export var building_site_scene: PackedScene  #Para instanciar escenas
@export var litel_spawner_scene: PackedScene
@export var finished_container: Node2D

@onready var scenario_tilemap: TileMapLayer = get_tree().get_first_node_in_group("scenario") as TileMapLayer


const Builds = preload("res://Buildings/BuildingsScripts/Buildings.gd")
var reserved_cells := {} # Dictionary<Vector2i, bool>
var spawner_flag := false


func request_site(team_id: int, build_type: int, cell: Vector2i, leader) -> Node2D:
	if reserved_cells.has(cell):
		return
	
	#para spawnear 1 vez	
	if build_type == Builds.Build.SPAWNER and spawner_flag:
		return null
		
	#reservo
	reserved_cells[cell] = true
	

	var site = building_site_scene.instantiate()
	site_container.add_child(site)
	
	site.build_type = build_type
	site.cell = cell
	site.team_id = team_id
	site.leader = leader
	
	#posicionar en el mundo
	var pos := scenario_tilemap.map_to_local(cell)
	pos += Vector2(scenario_tilemap.tile_set.tile_size) / 2.0
	site.global_position = scenario_tilemap.to_global(pos)
	

	site.finished.connect(_on_site_finished)
	return site
	


func _on_site_finished(site):
	reserved_cells.erase(site.cell)

	if site.build_type == Builds.Build.SPAWNER:
		var spawner := litel_spawner_scene.instantiate()
		finished_container.add_child(spawner)
		spawner.global_position = site.global_position
		spawner.call_deferred("finalize_building") # activa el timer
		
	for u in get_tree().get_nodes_in_group("Unit"):
		if u.build_site == site:
			u.builder_component.stop_building(u)
