extends Node2D

@export var litel_scene: PackedScene


@onready var spawn_position: Marker2D = $SpawnPosition
@onready var timer_spawn: Timer = $TimerSpawn



var is_building := true

func _ready():
	timer_spawn.stop() #Que no spawnee litels mientras se construye

func finalize_building() -> void:
	
	is_building = false


	timer_spawn.start()




func _on_timer_spawn_timeout() -> void:
	if is_building:
		return

	var litel := litel_scene.instantiate()
	get_parent().add_child(litel)
	litel.global_position = spawn_position.global_position
	litel.velocity.y = -200
