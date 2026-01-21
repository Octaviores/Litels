extends Node
#Script que se encarga de ajustar las colisiones con la plataforma de la escalera

@export var litel: CharacterBody2D
var platform_layer := 4


func up_climbing():
	litel.set_collision_mask_value(platform_layer, false)

func up_not_climbing():
	litel.set_collision_mask_value(platform_layer,true)
