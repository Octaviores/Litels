extends Node2D
# Este script se encarga de seleccionar y deseleccionar unidades dentro del cuadro de seleccion

var unit_selected : Array      # Guardo los litels que seleccione en un array
var selected_rect : Rect2:      # Guardo posición y tamaño del cuadro de seleccion
	set(value):
		selected_rect = value
		check_unit()

func check_unit():
	unit_selected = []                                                         # array vacio
	var canvas_xform: Transform2D = get_viewport().get_canvas_transform()     # mundo -> pantalla
	for unit in get_tree().get_nodes_in_group("Unit"):                       # Por cada unidad 
		var unit_screen_pos: Vector2 = canvas_xform * unit.global_position
		if selected_rect.has_point(unit_screen_pos):                       # si hay un litel entro del cuadro
			unit.select()                                                 # La selecciono
			unit_selected.append(unit)                                   # y la guardo en el array
		else:
			unit.deselect()                                            # Si hay seleccionados fuera del cuadro, los deselecciono
	

func clear_selection():
	for unit in unit_selected:
		unit.deselect()
	unit_selected.clear()
