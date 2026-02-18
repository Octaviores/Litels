extends TeamUnit
# Este script se encarga de mover al Litel

#esperara a estar listos
@onready var wall_sensor: RayCast2D = $WallSensor
@onready var resource_sensor: RayCast2D = $ResourceSensor


@onready var role_component: Node = $RoleComponent
@onready var ladder_component: Node = $LadderComponent
@onready var builder_component: Node = $BuilderComponent

@onready var litel_animations: AnimatedSprite2D = $LitelAnimations
@onready var arrows_animation: AnimationPlayer = $ArrowsAnimation

@onready var selection_sprite: Sprite2D = $SelectionSprite
@onready var hungry_sprite: Sprite2D = $HungrySprite
@onready var building_sprite: Sprite2D = $BuildingSprite

@onready var scenario_tilemap: TileMapLayer = null



#movimiento X e Y
const SPEED = 60.0
const SLOW_SPEED = 30.0
const JUMP_VELOCITY = -400.0
const CLIMB_SPEED = 50


#Para cambiar dirección de movimiento X e Y
var moving_right = true


#Cargo los roles
const Roles = preload("res://LitelsUI/LitelsUIScript/roles.gd")

#Roles
var resource_role := ResourceRole.new()

#Estados del litel para trabajar y caminar
enum State { WALK, WORK, WAIT }
var state: State = State.WALK


#Estados del litel para consumo de recursos
var hungry := false


#Variables para manejar colisiones con los recursos
var wood_layer := 7
var food_layer := 8
var stone_layer := 9


#Await entre estados WORK, WALK y WAIT
var rand_time_state = randf_range(0.0, 0.7)

#Para caminar hacia la construcción
var build_site: Node2D = null
var build_stand_cell: Vector2i
var going_to_build := false
var WORK_RATE := 5.0

#Controlar animaciones de selección
var is_selected := false
var is_leader := false


func _ready():
	
	# Manejar selecciónde litels,escaleras y recolección de recursos.
	add_to_group("Unit")
	scenario_tilemap = get_tree().get_first_node_in_group("scenario") as TileMapLayer
	
	#Timer para que cada litel consuma recursos
	var t := Timer.new()
	t.wait_time = 10
	t.one_shot = false
	t.autostart = true
	add_child(t)
	t.timeout.connect(_on_food_tick)
	

	
	
	
# ========================= LÓGICA DE MOVIMIENTO GENERAL =========================

func _physics_process(delta: float) -> void:
	

	var anim_to_play := "litel_idle"
	var current_role : int = role_component.current_role
	
	if current_role == Roles.Role.BUILDER and build_site != null and not going_to_build:
		state = State.WORK
		build_site.add_work(delta * WORK_RATE)

	
		
	if going_to_build and build_site != null:
		var cell := scenario_tilemap.local_to_map(scenario_tilemap.to_local(global_position))

		# Si estoy en la celda para construir, freno
		if cell == build_stand_cell:
			going_to_build = false
			
		var face_right := cell.x >= build_stand_cell.x
		# si no, camino hacia la stand_cell
		if moving_right == face_right:
			turn() 
			

		velocity.x = SPEED if moving_right else -SPEED
		
	if ladder_component.is_climbing:
		velocity.x = 0
		var climb_dir := -1.0
		if role_component.escape_to_surface:
			climb_dir = -1.0
		else:
			# lógica normal
			if current_role == Roles.Role.MINER:
				climb_dir = 1.0
			else:
				climb_dir = -1.0

		velocity.y = CLIMB_SPEED * climb_dir
		match current_role:
			Roles.Role.LUMBERJACK: anim_to_play = "lumberjack_ladder"
			Roles.Role.GATHERER: anim_to_play = "gatherer_ladder"
			Roles.Role.MINER: anim_to_play = "miner_ladder"
			_: 
				if 	role_component.escape_to_surface:
					anim_to_play = "litel_ladder"
				else:
					anim_to_play = "litel_walk"
					ladder_component.exited_ladder()
	else:
		if not is_on_floor():
			velocity += get_gravity() * delta

		var desired := resource_role.update(self)

		if state == State.WALK: 
			if not hungry:
				velocity.x = SPEED if moving_right else -SPEED 
				hungry_sprite.visible = false
			else:
				velocity.x = SLOW_SPEED if moving_right else -SLOW_SPEED
				hungry_sprite.visible = true
				arrows_animation.play("hungry_arrow")

			if wall_sensor.is_colliding():
				turn() 
		elif state == State.WORK or state == State.WAIT:
			velocity.x = 0
			
		
		if current_role != Roles.Role.NONE:
		
			if state == State.WORK:
				match current_role:
					Roles.Role.LUMBERJACK: anim_to_play = "lumberjack_work"
					Roles.Role.GATHERER: anim_to_play = "gatherer_work"
					Roles.Role.MINER: anim_to_play = "miner_work"
					Roles.Role.BUILDER: anim_to_play = "builder_work"
			else:
				match current_role:
					Roles.Role.LUMBERJACK: anim_to_play = "lumberjack_walk"
					Roles.Role.GATHERER: anim_to_play = "gatherer_walk"
					Roles.Role.MINER: anim_to_play = "miner_walk"
					Roles.Role.BUILDER: anim_to_play = "builder_walk" 
			

			if desired != null:
				role_component.start_work(desired)
			else:
				role_component.stop_work(rand_time_state)
		else: 
				anim_to_play = "litel_walk"


	move_and_slide()

	if ladder_component.is_climbing and current_role == Roles.Role.MINER and is_on_floor():
		ladder_component.exited_ladder()

	
	if role_component.escape_to_surface and global_position.y <= -256:
		role_component.escape_to_surface = false
		ladder_component.exited_ladder()
		


	if litel_animations.animation != anim_to_play:
		litel_animations.play(anim_to_play)


#Cambia de dirección si colisiona con un muro invisible
func turn():
		moving_right = !moving_right
		scale.x = -scale.x
	
	
	
	

# ========================= LÓGICA DE SELECCIÓN DE LITELS =========================


func select():               # Selecciono una unidad
	select_mode(true)

func deselect():            # Deselecciono una unidad
	select_mode(false)
	
func select_mode(value: bool) -> void:   
	is_selected = value
	_update_selection_visual()

func set_leader(value: bool) -> void:
	is_leader = value
	_update_selection_visual()


func _update_selection_visual() -> void:
	if is_leader:
		selection_sprite.visible = false
		building_sprite.visible = true
		arrows_animation.play("litels_building")
	elif is_selected:
		building_sprite.visible = false
		selection_sprite.visible = true
		arrows_animation.play("litel_selected")
	else:
		building_sprite.visible = false
		selection_sprite.visible = false
		
#Elegir 1 solo Litel
func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			set_leader(true)
			get_viewport().set_input_as_handled()
			for unit in LitelManager.unit_selected:
				if unit != self:
					unit.deselect()
			LitelManager.unit_selected = [self]
	

			
#Deseleccionar litels
func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		LitelManager.clear_selection() # click en vacío 
		set_leader(false)
		
	

# ========================= CAMINAR HACIA LA CONSTRUCCIÓN =========================

func assign_build_site(site: Node2D):
	build_site = site
	going_to_build = true

	var site_cell: Vector2i = site.cell
	
	# Celda del litel
	# Posición GLobal -> Posición en el Tilemap
	# Posición en el TileMap -> Celda del TileMap (Vector2i)
	var litel_cell := scenario_tilemap.local_to_map(scenario_tilemap.to_local(global_position))
	
	# si estoy a la izquierda del site, me paro a su izquierda (x-1) mirando derecha.
	# si estoy a la derecha, me paro a su derecha (x+1) mirando izquierda.
	if litel_cell.x <= site_cell.x:
		build_stand_cell = site_cell + Vector2i(-1, 0)
	else:
		build_stand_cell = site_cell + Vector2i(2, 0)
		
		
		
# ========================= CONSUMO DE RECURSOS =========================

func _on_food_tick() -> void:
	if GameState.pay(team_id, {"food": 1}):
		hungry = false
	else:
		hungry = true
