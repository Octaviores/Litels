extends Node2D

signal finished(site)

@onready var bar: TextureProgressBar = $TextureProgressBar
@onready var ghost_spawner: Sprite2D = $GhostSpawner

var team_id: int 
var leader: Node 
var build_type: int 
var cell: Vector2i

var work := 0.0
var work_total := 100.0
var is_building := true


func _ready():
	ghost_spawner.modulate.a = 0.3

func add_work(amount: float) -> void:
	if not is_building:
		return

	work += amount
	bar.value = clamp(work / work_total, 0.0, 1.0) * 100.0

	if work >= work_total:
		is_building = false
		bar.visible = false
		ghost_spawner.modulate.a = 1.0
		finished.emit(self)
	
