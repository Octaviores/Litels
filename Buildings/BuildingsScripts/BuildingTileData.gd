extends Node
#Este script sirve para ver si un tile está vacio (sin construccion)
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
	var cell := map_cell + Vector2i(distance*dir,0)
	var cell_target = get_ground_cell(cell)

	
	if not _is_cell_free(cell_target):
		return Vector2i(-1,-1)
	
	return cell_target

# Para ver si está el tile libre. un ID = -1 significa que está vacio
func _is_cell_free(cell: Vector2i) -> bool:
	return scenario_tilemap.get_cell_source_id(cell) == -1

func get_ground_cell(start_cell: Vector2i,  max_up := 12, max_down := 40) -> Vector2i:
	var cell := start_cell

	# Si está bloqueado, subir hasta encontrar espacio libre
	var up := 0
	while scenario_tilemap.get_cell_source_id(cell) != -1 and up < max_up:
		cell += Vector2i(0, -1)
		up += 1

	# Si no encontró lugar libre, cancelá
	#if scenario_tilemap.get_cell_source_id(cell) != -1:
		#return start_cell  # o Vector2i(-1, -1)

	# Si abajo está libre, seguir bajando hasta tocar el piso
	var down := 0
	while scenario_tilemap.get_cell_source_id(cell + Vector2i(0, 1)) == -1 and down < max_down:
		cell += Vector2i(0, 1)
		down += 1

	return cell
