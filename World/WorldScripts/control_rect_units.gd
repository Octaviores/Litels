extends Control
# Este script se encarga de dibujar el cuadro de seleccion


var drawing := false                  # Flag para alternar entre modos (dibujo o no dibujo)
var start_position = Vector2.ZERO    # Posición del inicio del dibujo
var end_position = Vector2.ZERO     # Posición del Fin del dibujo
var selection_rect : Rect2         # Para guardar el cuadro de seleccion
var width = 0                     # Ancho de las lineas del cuadro


#Función para limpiar dibujos viejos y crear nuevos
func _draw():
	var rect_position = start_position               # Posicion inicial del cuadro
	var rect_size = end_position - start_position   # Tamaño del cuadro
	
	if rect_size.x <0:                            # El tamanio no puede ser negativo
		rect_position.x += rect_size.x           # Reajusto la posición inicial
		rect_size.x = abs(rect_size.x)
	if rect_size.y <0:
		rect_position.y += rect_size.y
		rect_size.y = abs(rect_size.y)
		
	selection_rect = Rect2(rect_position,rect_size)      # Gauardo la posicion y tamaño del cuadro
	draw_rect(selection_rect, Color.RED, false, width)  # Dibujo el cuadro



func _unhandled_input(event: InputEvent) -> void:
	
	var hovered := get_viewport().gui_get_hovered_control()
	if hovered != null:
		return
	
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:  # Click izquierdo activa el dibujado y setea el ancho de los bordes
			width = 2
			drawing = true
			start_position = event.position
			end_position = event.position
		if event.is_released() and event.button_index == MOUSE_BUTTON_LEFT:  # Soltar el click izquierdo desactiva el dibujado, reseteando ancho y posición
			width = 0
			drawing = false
			start_position = Vector2.ZERO
			end_position = Vector2.ZERO
			queue_redraw()                               # Llama a _draw() y y actualizo los elementos de dibujo
	
	if event is InputEventMouseMotion and drawing:      # Al mover el mouse, se actualiza la posición y los elementos de dibujo
		end_position = event.position
		queue_redraw()
		LitelManager.selected_rect = selection_rect    # le mando el tamaño y posición del cuadro al LittleManager
	
