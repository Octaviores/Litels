extends Node2D

@export var litel_scene: PackedScene
@onready var spawn_position: Marker2D = $SpawnPosition
@onready var spawn_timer: Timer = $SpawnTimer



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass


func _on_spawn_timer_timeout() -> void:
	
	var litel := litel_scene.instantiate()
	print("litel: ", litel)
	get_parent().add_child(litel)
	litel.global_position = spawn_position.global_position
	print("posición: ", litel.global_position)

		
