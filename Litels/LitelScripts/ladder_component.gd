extends Node
#Script que se encarga de ajustar las colisiones con la plataforma de la escalera


@onready var role_component: Node = $"../RoleComponent"
@onready var litel := get_parent()
@onready var ladder_tilemap: TileMapLayer = null

var platform_layer := 4
var is_climbing = false
const Roles = preload("res://LitelsUI/LitelsUIScript/roles.gd")


func _ready():
	ladder_tilemap = get_tree().get_first_node_in_group("ladder") as TileMapLayer
func up_climbing():
	litel.set_collision_mask_value(platform_layer, false)

func up_not_climbing():
	litel.set_collision_mask_value(platform_layer,true)


#Si está en la escalera, desactivo la colisión con la plataforma
func entered_ladder():
	is_climbing = true
	up_climbing()

	
	
#Si no está en la escalera, activo la colisión con la plataforma
func exited_ladder():
	var current_role : int = role_component.current_role
	if not is_climbing:
		return
	
	is_climbing = false
	up_not_climbing()
	if current_role == Roles.Role.LUMBERJACK and litel.moving_right:
		litel.turn()
	if current_role == Roles.Role.GATHERER and !litel.moving_right:
		litel.turn()
	if current_role == Roles.Role.MINER and !litel.moving_right:
		litel.turn()
	


#Función para obtener el ladder_role de una escalera
func _update_ladder_state():

	# Obtengo la posición local del Litel y del Tile donde se encuentra
	var cell := ladder_tilemap.local_to_map(
		ladder_tilemap.to_local(litel.global_position)
	)

	# Obtengo los datos del Tile, sino, null
	var tile_data := ladder_tilemap.get_cell_tile_data(cell)
	if tile_data == null:
		exited_ladder()
		return
	var ladder_role: int = int(tile_data.get_custom_data("ladder_role"))
	if ladder_role == null:
		return
		

	var current_role : int = role_component.current_role
	if ladder_role == current_role:
		entered_ladder()
	elif current_role != Roles.Role.MINER and role_component.escape_to_surface:
		entered_ladder()
	else:
		return


func _on_player_area_body_entered(_body: Node2D) -> void:
	_update_ladder_state()


func _on_player_area_body_exited(_body: Node2D) -> void:
	_update_ladder_state()
