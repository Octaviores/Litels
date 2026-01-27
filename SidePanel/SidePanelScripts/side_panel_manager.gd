extends Control
#Este script se encarga de abrir y cerrar el panel izquierdo de construcciones


@onready var main_menu: Panel = $MarginContainer/HBoxContainer/Menu
@onready var open_text: TextureRect = $MarginContainer/HBoxContainer/VBoxContainer/SideBarArrow/OpenSideBarTexture
@onready var side_bar_arrow: Panel = $MarginContainer/HBoxContainer/VBoxContainer/SideBarArrow

var is_open := false

func _ready():
	_set_open(false)


func _process(_delta):
	var mouse_pos = get_global_mouse_position()
	var should_open = false
	
	if side_bar_arrow.get_global_rect().has_point(mouse_pos):
		should_open = true
		
	if main_menu.get_global_rect().has_point(mouse_pos):
		should_open = true

	if should_open != is_open:
		_set_open(should_open)

func _set_open(open: bool) -> void:
	is_open = open
	main_menu.visible = open
	
	
