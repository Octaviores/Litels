extends Node2D
# Este script se encarga de seleccionar y deseleccionar unidades dentro del cuadro de seleccion

var unit_selected : Array      # Guardo los litels que seleccione en un array
var prev_selected: Array
var selected_rect : Rect2:      # Guardo posición y tamaño del cuadro de seleccion
	set(value):
		selected_rect = value
		check_unit()

		
func check_unit():
	# Limpiar todo lo anterior seleccionado
	for u in prev_selected:
		u.deselect()
		u.set_leader(false)

	unit_selected = []
	unit_selected = []                                                         # array vacio
	var canvas_xform: Transform2D = get_viewport().get_canvas_transform()     # mundo -> pantalla
	for unit in get_tree().get_nodes_in_group("Unit"):                       # Por cada unidad 
		var unit_screen_pos: Vector2 = canvas_xform * unit.global_position
		if selected_rect.has_point(unit_screen_pos):                       # si hay un litel entro del cuadro
			unit.select()                                                 # La selecciono
			unit_selected.append(unit)                                   # y la guardo en el array
			unit.set_leader(false)
			  
	# Asignar 1 solo lider                           
	if unit_selected.size()>0:
		unit_selected[0].set_leader(true)
		
	#Guardar los anteriores, porque algunos quedan colgados con animaciones arriba
	prev_selected = unit_selected.duplicate()

func clear_selection():
	for unit in unit_selected:
		unit.deselect()
		unit.set_leader(false)
	unit_selected.clear()
	prev_selected.clear()
	
