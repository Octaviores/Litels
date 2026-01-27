extends Node

@onready var scenario_tilemap: TileMapLayer = null

func _ready():
	scenario_tilemap = get_tree().get_first_node_in_group("scenario") as TileMapLayer
	
func get_build_cell(build: int) -> Vector2i:
	var litel := get_parent()
	var dir := 1 if litel.moving_right else -1
	var distance := 5
	
	#Posición local del litel
	var map_cell := scenario_tilemap.local_to_map(
		scenario_tilemap.to_local(litel.global_position))
	var cell_target := map_cell + Vector2i(distance*dir,0)

	
	if not _is_cell_free(cell_target):
		return Vector2i(-1,-1)
	
	return cell_target

# Para ver si está el tile libre. un ID = -1 significa que está vacio
func _is_cell_free(cell: Vector2i) -> bool:
	return scenario_tilemap.get_cell_source_id(cell) == -1
