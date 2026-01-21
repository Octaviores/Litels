extends Camera2D
# Este script se encarga del movimiento de la cámara según la posición del mouse

var cameraSpeed = 200   # Velocidad de la cámara
var borderSize = 40    # borde de margen de error al mover la cámara

func _ready() -> void:
	var screen = get_viewport_rect().size
	var half_view = (screen * 0.5) / zoom

	# Arriba a la izquierda "visible" del rectángulo de límites
	global_position = Vector2(
		limit_left + half_view.x,
		limit_top + half_view.y
	)



func _process(delta: float) -> void:
	
	# obtengo un vector que representa el ancho y alto del viewport en píxeles
	var screen = get_viewport_rect().size                    
	# devuelve las coordenadas del mouse respecto al viewport
	var mousePosition = get_viewport().get_mouse_position()  
	
	# Defino un vector para mover el eje x, eje y de la cámara de manera independiente
	var moving = Vector2.ZERO
	

	# Moviemiento eje x
	if mousePosition.x >= screen.x - borderSize:
		moving.x = 1
	if mousePosition.x <= 0 + borderSize:
		moving.x = -1
		

	
	# Movimiento eje y
	if mousePosition.y >= screen.y - borderSize:
		moving.y = 1
	if mousePosition.y <= 0 + borderSize:
		moving.y = -1

	global_position += moving * cameraSpeed * delta
	
	#Respetar límites del inspector
	var half_view = (screen * 0.5) / zoom

	global_position.x = clamp(global_position.x, limit_left + half_view.x, limit_right - half_view.x)
	global_position.y = clamp(global_position.y, limit_top + half_view.y, limit_bottom - half_view.y)
