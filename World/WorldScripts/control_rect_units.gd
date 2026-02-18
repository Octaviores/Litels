extends Control

const DRAG_THRESHOLD := 8.0

var pending_click := false
var dragging := false
var start_pos := Vector2.ZERO
var end_pos := Vector2.ZERO
var rect := Rect2()

func _ready():
	set_process(false)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# bloquear solo inicio sobre UI
			if get_viewport().gui_get_hovered_control() != null:
				return
			pending_click = true
			dragging = false
			start_pos = get_viewport().get_mouse_position()
			end_pos = start_pos
			set_process(true)
		else:
			# release
			if dragging:
				# terminar drag: limpiar dibujo
				dragging = false
				rect = Rect2()
				queue_redraw()
			# si era click (no drag), no hace nada :
			# deja que el click del litel seleccione 1.
			pending_click = false
			set_process(false)

func _process(_delta: float) -> void:
	if not pending_click and not dragging:
		return

	end_pos = get_viewport().get_mouse_position()

	if not dragging:
		if start_pos.distance_to(end_pos) >= DRAG_THRESHOLD:
			dragging = true

	if dragging:
		_update_rect()
		LitelManager.selected_rect = rect
		queue_redraw()

	# si la UI se come el release, se cierra igual
	if pending_click and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		pending_click = false
		dragging = false
		rect = Rect2()
		queue_redraw()
		set_process(false)

func _update_rect():
	var pos := start_pos
	var size := end_pos - start_pos
	if size.x < 0:
		pos.x += size.x
		size.x = -size.x
	if size.y < 0:
		pos.y += size.y
		size.y = -size.y
	rect = Rect2(pos, size)

func _draw() -> void:
	if dragging and rect.size != Vector2.ZERO:
		draw_rect(rect, Color.RED, false, 2)
