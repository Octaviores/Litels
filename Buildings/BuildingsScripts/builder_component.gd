extends Node
#Este script inicializa la construcción seleccionada delante del Builder


@onready var role_component: Node = $"../RoleComponent"
@onready var bm := get_tree().get_first_node_in_group("building_manager") as Node2D

#const Builds = preload("res://Buildings/BuildingsScripts/Buildings.gd")


const Roles = preload("res://LitelsUI/LitelsUIScript/roles.gd")

var build_type : int
var units: Array
var site: Node2D




func _ready() -> void:
	role_component.role_changed.connect(_on_role_changed)




func _on_role_changed(_old_role, new_role) -> void:

	if new_role == Roles.Role.BUILDER:
		units = LitelManager.unit_selected
		var leader = units[0]
		
		
		# Si no es lider, no sirve. El site es null
		if get_parent() != leader:
			return


		var btd_component : Node= leader.get_node("BuildingTileDataComponent")
		var leader_cell = btd_component.get_build_cell(build_type)
		
		site = bm.request_site(
			leader.team_id,
			build_type,
			leader_cell,
			leader
		)

		if site != null:
			_start_building()



func _start_building() -> void:
	var participants : Array = units.slice(0,min(3, units.size()))
	for p in participants:
		p.assign_build_site(site)


func stop_building(u):
	u.state = u.State.WALK
	u.role_component.set_role(Roles.Role.NONE)

		

	
