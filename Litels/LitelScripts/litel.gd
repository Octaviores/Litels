extends TeamUnit
# Este script se encarga de mover al Litel

#esperara a estar listos
@onready var wall_sensor: RayCast2D = $WallSensor
@onready var ladder_ajustment_component: Node = $LadderAjustmentComponent
@onready var ladder_tilemap: TileMapLayer = null

@onready var litel_animations: AnimatedSprite2D = $LitelAnimations
@onready var arrows_animation: AnimationPlayer = $ArrowsAnimation
@onready var selection_sprite: Sprite2D = $SelectionSprite
@onready var hungry_sprite: Sprite2D = $HungrySprite

@onready var resource_sensor: RayCast2D = $ResourceSensor
@onready var work_timer: Timer = $WorkTimer


#movimiento X e Y
const SPEED = 60.0
const SLOW_SPEED = 30.0
const JUMP_VELOCITY = -400.0
const CLIMB_SPEED = 50


#Para cambiar dirección de movimiento X e Y
var moving_right = true
var is_climbing = false


#Cargo los roles
const Roles = preload("res://LitelsUI/LitelsUIScript/roles.gd")
var current_role: Roles.Role = Roles.Role.NONE


#Roles
var resource_role := ResourceRole.new()


#Estados del litel para trabajar y caminar
enum State { WALK, WORK, WAIT }
var state: State = State.WALK
var work_target: Node = null
var counted_as_lumberjack_worker := false
var counted_as_gatherer_worker := false
var counted_as_miner_worker := false
var escape_to_surface := false


#Estados del litel para consumo de recursos
var hungry := false


#Await entre estados WORK, WALK y WAIT
var stop_work_pending := false
var rand_time_state = randf_range(0.0, 0.7)


#Variables para manejar colisiones con los recursos
var wood_layer := 7
var food_layer := 8
var stone_layer := 9




func _ready():
	
	# Manejar selecciónde litels,escaleras y recolección de recursos.
	add_to_group("Unit")
	ladder_tilemap = get_tree().get_first_node_in_group("ladder") as TileMapLayer
	work_timer.timeout.connect(_on_work_resources)
	
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

	if is_climbing:
		velocity.x = 0
		var climb_dir := -1.0
		if escape_to_surface:
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
				if 	escape_to_surface:
					anim_to_play = "litel_ladder"
				else:
					anim_to_play = "litel_walk"
					exited_ladder()
	else:
		if not is_on_floor():
			velocity += get_gravity() * delta
		#if is_on_floor():
		#	exited_ladder()
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
			if current_role == Roles.Role.LUMBERJACK:
				anim_to_play = "lumberjack_work" if (state == State.WORK) else "lumberjack_walk"
			elif current_role == Roles.Role.GATHERER:	
				anim_to_play = "gatherer_work" if (state == State.WORK) else "gatherer_walk"
			elif current_role == Roles.Role.MINER:	
				anim_to_play = "miner_work" if (state == State.WORK) else "miner_walk"

			if desired != null:
				start_work(desired)
			else:
				stop_work(rand_time_state)
		else: 
				anim_to_play = "litel_walk"


	move_and_slide()

	if is_climbing and current_role == Roles.Role.MINER and is_on_floor():
		exited_ladder()
	
	if escape_to_surface and global_position.y <= -256:
		escape_to_surface = false
		exited_ladder()


	if litel_animations.animation != anim_to_play:
		litel_animations.play(anim_to_play)


#Cambia de dirección si colisiona con un muro invisible
func turn():
		moving_right = !moving_right
		scale.x = -scale.x
	
	
	
	
	
	
	
	
	
	
# ========================= LÓGICA DE LA ESCALERA =========================	


#Si está en la escalera, desactivo la colisión con la plataforma
func entered_ladder():
	is_climbing = true
	ladder_ajustment_component.up_climbing()

	
	
#Si no está en la escalera, activo la colisión con la plataforma
func exited_ladder():
	if not is_climbing:
		return
	
	is_climbing = false
	ladder_ajustment_component.up_not_climbing()
	if current_role == Roles.Role.LUMBERJACK and moving_right:
		turn()
	if current_role == Roles.Role.GATHERER and !moving_right:
		turn()
	if current_role == Roles.Role.MINER and moving_right:
		turn()
	
#Detecta si el Litel está en un escalera
func _on_player_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("ladder"):
		_update_ladder_state()


#Detecta si el Litel no está en la escalera	
func _on_player_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("ladder"):
		exited_ladder()


#Función para obtener el ladder_role de una escalera
func _update_ladder_state():

	# Obtengo la posición local del Litel y del Tile donde se encuentra
	var cell := ladder_tilemap.local_to_map(
		ladder_tilemap.to_local(global_position)
	)

	# Obtengo los datos del Tile, sino, null
	var tile_data := ladder_tilemap.get_cell_tile_data(cell)
	if tile_data == null:
		return

	# Obtengo el valor del CustomDataLayer "ladder_role"
	var ladder_role: int = int(tile_data.get_custom_data("ladder_role"))
	if ladder_role == null:
		return
		

	
	if ladder_role == current_role:
		entered_ladder()
	elif current_role != Roles.Role.MINER and escape_to_surface:
		entered_ladder()
	else:
		return











# ========================= LÓGICA DE SELECCIÓN DE LITELS =========================

#Si selecciono una unidad, reproduzco la animación. Sino, no
var select_mode : bool = false:     #los ":" al final lo convierte en una variable setter
	set(value):
		select_mode = value
		if value:
			selection_sprite.visible = true
			arrows_animation.play("litel_selected")
		else:
			selection_sprite.visible = false
			

func select():               # Selecciono una unidad
	select_mode = true

func deselect():            # Deselecciono una unidad
	select_mode = false

#Elegir 1 solo Litel
func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			select_mode = true
			for unit in LitelManager.unit_selected:
				if unit != self:
					unit.deselect()
			LitelManager.unit_selected = [self]
			
#Deseleccionar litels
func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		LitelManager.clear_selection() # click en vacío 
		
		
		
		
		
		
		

# ========================= LÓGICA DE ROLES =========================

#Manejador de Roles
func set_role(new_role: Roles.Role) -> void:
	if current_role == new_role:
		return

	# si estaba trabajando, paro siempre al cambiar rol
	stop_work(rand_time_state)

	if current_role == Roles.Role.MINER and new_role != Roles.Role.MINER:
		escape_to_surface = true

	
	
	current_role = new_role
	
	_apply_role_mask(current_role)

	#resource_sensor.enabled = (current_role == Roles.Role.LUMBERJACK)
	resource_sensor.force_raycast_update()


func _apply_role_mask(role: Roles.Role) -> void:
	# apago todas
	resource_sensor.set_collision_mask_value(7, false)
	resource_sensor.set_collision_mask_value(8, false)
	resource_sensor.set_collision_mask_value(9, false)

	# prendo la correspondiente
	match role:
		Roles.Role.LUMBERJACK: resource_sensor.set_collision_mask_value(7, true)
		Roles.Role.GATHERER:   resource_sensor.set_collision_mask_value(8, true)
		Roles.Role.MINER:      resource_sensor.set_collision_mask_value(9, true)

			
#Sumador de recolección de recursos
func _on_work_resources():
	if state != State.WORK:
		return

	#Rol Lumberjack
	match current_role:
		Roles.Role.LUMBERJACK: GameState.add_resource(team_id, "wood", 1)
		Roles.Role.GATHERER: GameState.add_resource(team_id, "food", 1)
		Roles.Role.MINER: GameState.add_resource(team_id, "stone", 1)
		
	

#Sumador de cantidad de trabajadores
func workers_count():
	var working := state == State.WORK
	
	match current_role:
		Roles.Role.LUMBERJACK:

			if working and not counted_as_lumberjack_worker :
				GameState.add_worker(team_id, "Lumberjack", 1)
				counted_as_lumberjack_worker = true
			elif not working and counted_as_lumberjack_worker:
				GameState.add_worker(team_id, "Lumberjack", -1)
				counted_as_lumberjack_worker = false
		
		Roles.Role.GATHERER:

			if working and not counted_as_gatherer_worker :
				GameState.add_worker(team_id, "Gatherer", 1)
				counted_as_gatherer_worker = true
			elif not working and counted_as_gatherer_worker:
				GameState.add_worker(team_id, "Gatherer", -1)
				counted_as_gatherer_worker = false
				
		Roles.Role.MINER:

			if working and not counted_as_miner_worker :
				GameState.add_worker(team_id, "Miner", 1)
				counted_as_miner_worker = true
			elif not working and counted_as_miner_worker:
				GameState.add_worker(team_id, "Miner", -1)
				counted_as_miner_worker = false

#Empieza a trabajar, activa contadores
func start_work(target: Node) -> void:
	if state == State.WORK and work_target == target:
		return

	
	state = State.WORK
	work_target = target

	timer_enter_work()
	workers_count() 


#Termina de trabajar, finalizaco contadores
func stop_work(delay: float) -> void:
	if state != State.WORK:
		return
	if stop_work_pending:
		return


		
	state = State.WAIT          # deja de estar "trabajando" pero todavía no camina
	work_target = null
	timer_exit_work()
	workers_count()
	
	stop_work_pending = true
	if delay > 0.0:
		await get_tree().create_timer(delay).timeout
	stop_work_pending = false

	if state != State.WAIT:   #por si durante el await volvió a WORK por alguna razón
		return
		
	state = State.WALK

	

#Inicio del temporizador para esperar 1 segundo para ir sumando 1 de recurso
func timer_enter_work():
	if work_timer.is_stopped():
		work_timer.start(1.0)


#Finalización del temporizador
func timer_exit_work():
	if not work_timer.is_stopped():
		work_timer.stop()










# ========================= LÓGICA DE CONSUMO DE RECURSOS =========================

func _on_food_tick() -> void:
	if GameState.pay(team_id, {"food": 1}):
		hungry = false
	else:
		hungry = true
