class_name Helpers

static func ray_cast(from: Node2D, direction: Vector2, distance: float, mask: int, hit_from_inside : bool = false) -> Dictionary:
	var space_state = from.get_world_2d().direct_space_state
	var origin = from.global_position
	var end = origin + direction * distance
	var query = PhysicsRayQueryParameters2D.create(origin, end, mask)
	query.collide_with_areas = true
	query.hit_from_inside = hit_from_inside
	return space_state.intersect_ray(query)

#region Directional rays in relation to the Node

## Cast a ray forward with respect to the Node's Transform
static func ray_forward(from: Node2D, distance: int = Constants.TILE_SIZE, mask: int = Constants.FACTORY_LAYER) -> Node2D:
	var forward = Helpers.ray_cast(from, from.transform.x, distance, mask)
	if forward.size() == 0:
		return null
	
	return forward.collider

## Cast a ray behind with respect to the Node's Transform
static func ray_behind(from: Node2D, distance: int = Constants.TILE_SIZE, mask: int = Constants.FACTORY_LAYER) -> Node2D:
	var behind = Helpers.ray_cast(from, -from.transform.x, distance, mask)
	if behind.size() == 0:
		return null
	return behind.collider

## Cast a ray left with respect to the Node's Transform
static func ray_left(from: Node2D, distance: int = Constants.TILE_SIZE, mask: int = Constants.FACTORY_LAYER) -> Node2D:
	var left = Helpers.ray_cast(from, from.transform.x.rotated(PI/2), distance, mask)
	if left.size() == 0:
		return null
	return left.collider

## Cast a ray right with respect to the Node's Transform
static func ray_right(from: Node2D, distance: int = Constants.TILE_SIZE, mask: int = Constants.FACTORY_LAYER) -> Node2D:
	var right = Helpers.ray_cast(from, from.transform.x.rotated(-PI/2), distance, mask)
	if right.size() == 0:
		return null
	return right.collider

## Cast a ray ontop of the Node. Used to find specific things when placing Nodes
static func ray_self(from: Node2D, mask: int) -> Node2D:
	var ontop_self = Helpers.ray_cast(from, Vector2(0.1, 0.1), 0.1, mask, true)
	if ontop_self.size() == 0:
		return null
	return ontop_self.collider

#endregion

#region Directional Helpers
# https://docs.godotengine.org/en/stable/tutorials/math/vector_math.html#dot-product

## Checks to see if a node is looking away from another node
static func is_node_facing_away_from_other_node(node_to_check: Node2D, against: Node2D) -> bool:
	var direction = (against.position - node_to_check.position).normalized()
	var dot = snapped(direction.dot(node_to_check.transform.x), 1.0)
	return dot <= 0

## Checks the rotations of two nodes facing the same direction (-> ->)
static func is_facing_same_direction(node_one: Node2D, node_two: Node2D) -> bool:
	var dot = node_one.transform.x.normalized().dot(node_two.transform.x.normalized())
	if dot == 1:
		return true
	return false

## Checks the rotations of two nodes facing each other (-> <-)
static func is_facing_each_other(node_one: Node2D, node_two: Node2D) -> bool:
	var dot = node_one.transform.x.normalized().dot(node_two.transform.x.normalized())
	if dot == -1:
		return true
	return false

## Checks the rotations of two nodes perpendicular to each other (-> v)
static func is_perpendicular(node_one: Node2D, node_two: Node2D) -> bool:
	var dot = node_one.transform.x.normalized().dot(node_two.transform.x.normalized())
	if is_equal_approx(dot, 0.0): # noticed 0.0000XXXX values
		return true
	return false

#endregion
