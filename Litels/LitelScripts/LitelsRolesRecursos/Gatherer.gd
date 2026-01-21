extends RefCounted
#Este script se encarga
class_name GathererRole

func update(litel: Node) -> Node:
	var tree_sensor: RayCast2D = litel.get_node("TreeSensor")
	if tree_sensor.is_colliding():
		return tree_sensor.get_collider()
	return null
