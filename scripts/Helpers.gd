class_name Helpers

static func ray_cast(from: Node2D, direction: Vector2, distance: float, mask: int) -> Dictionary:
	var space_state = from.get_world_2d().direct_space_state
	var origin = from.global_position
	var end = origin + direction * distance
	var query = PhysicsRayQueryParameters2D.create(origin, end, mask)
	query.collide_with_areas = true
	return space_state.intersect_ray(query)

#region Directional rays in relation to the Node

## Cast a ray forward with respect to the Node's Transform
static func ray_forward(from: Node2D) -> Node2D:
	var forward = Helpers.ray_cast(from, from.transform.x, Constants.TILE_SIZE, Constants.FACTORY_LAYER)
	if forward.size() == 0:
		return null
	
	return forward.collider

## Cast a ray behind with respect to the Node's Transform
static func ray_behind(from: Node2D) -> Node2D:
	var behind = Helpers.ray_cast(from, -from.transform.x, Constants.TILE_SIZE, Constants.FACTORY_LAYER)
	if behind.size() == 0:
		return null
	return behind.collider

## Cast a ray left with respect to the Node's Transform
static func ray_left(from: Node2D) -> Node2D:
	var left = Helpers.ray_cast(from, from.transform.x.rotated(PI/2), Constants.TILE_SIZE, Constants.FACTORY_LAYER)
	if left.size() == 0:
		return null
	return left.collider

## Cast a ray right with respect to the Node's Transform
static func ray_right(from: Node2D) -> Node2D:
	var right = Helpers.ray_cast(from, from.transform.x.rotated(-PI/2), Constants.TILE_SIZE, Constants.FACTORY_LAYER)
	if right.size() == 0:
		return null
	return right.collider

#endregion
