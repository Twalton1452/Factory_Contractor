class_name Helpers

static func ray_cast(from: Node2D, direction: Vector2, distance: float, mask: int) -> Dictionary:
	var space_state = from.get_world_2d().direct_space_state
	var origin = from.global_position
	var end = origin + direction * distance
	var query = PhysicsRayQueryParameters2D.create(origin, end, mask)
	query.collide_with_areas = true
	return space_state.intersect_ray(query)
