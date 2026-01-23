extends TeamUnit
# Este script se encarga de mover al Litel

#esperara a estar listos
@onready var wall_sensor: RayCast2D = $WallSensor
@onready var resource_sensor: RayCast2D = $ResourceSensor

@onready var role_component: Node = $RoleComponent
@onready var ladder_component: Node = $LadderComponent


@onready var litel_animations: AnimatedSprite2D = $LitelAnimations
@onready var arrows_animation: AnimationPlayer = $ArrowsAnimation
@onready var selection_sprite: Sprite2D = $SelectionSprite
@onready var hungry_sprite: Sprite2D = $HungrySprite


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


func _ready():
	
	# Manejar selecciónde litels,escaleras y recolección de recursos.
	add_to_group("Unit")

	
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
				role_component.start_work(desired)
			else:
				role_component.stop_work(rand_time_state)
		else: 
				anim_to_play = "litel_walk"


	move_and_slide()

	if ladder_component.is_climbing and current_role == Roles.Role.MINER and is_on_floor():
		ladder_component.exited_ladder()
		print("salí")
	
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
func _on_input_event(_viewport, event, _shape_idx):
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
		
		
	



# ========================= LÓGICA DE CONSUMO DE RECURSOS =========================

func _on_food_tick() -> void:
	if GameState.pay(team_id, {"food": 1}):
		hungry = false
	else:
		hungry = true
