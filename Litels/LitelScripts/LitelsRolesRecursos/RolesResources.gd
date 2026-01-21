extends RefCounted
#Este script se encarga
class_name ResourceRole

func update(litel: Node) -> Node:
	var resource_sensor: RayCast2D = litel.get_node("ResourceSensor")
	if resource_sensor.is_colliding():
		return resource_sensor.get_collider()
	return null
