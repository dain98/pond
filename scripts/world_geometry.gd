class_name PondWorldGeometry
extends RefCounted

## Authoritative gameplay geometry for the settlement master map.
##
## The background is intentionally presentation-only. Keeping these shapes in
## one place lets the server validate movement without loading rendered assets,
## and gives future fishing, housing, and interaction systems shared landmarks.

const WORLD_SIZE := Vector2(1920.0, 1080.0)
const WORLD_BOUNDS := Rect2(12.0, 32.0, 1896.0, 1036.0)

const MAIN_POND_CENTER := Vector2(1250.0, 455.0)
const MAIN_POND_RADII := Vector2(300.0, 235.0)

# Segment endpoints are stored as (x1, y1, x2, y2). The creek is deliberately
# approximated with broad, simple capsules so collision remains predictable.
const CREEK_RADIUS := 22.0
const CREEK_SEGMENTS: Array[Vector4] = [
	Vector4(925.0, 120.0, 948.0, 190.0),
	Vector4(948.0, 190.0, 1005.0, 252.0),
	Vector4(1005.0, 252.0, 1070.0, 285.0),
	Vector4(1602.0, 0.0, 1582.0, 88.0),
	Vector4(1582.0, 88.0, 1500.0, 155.0),
	Vector4(1500.0, 155.0, 1424.0, 218.0),
	Vector4(1424.0, 218.0, 1370.0, 270.0),
]

# Docks and bridges override water collision and are intentionally generous so
# the character cannot snag on illustrated railings or shoreline pixels.
const WALKABLE_WATER_RECTS: Array[Rect2] = [
	Rect2(982.0, 405.0, 175.0, 92.0), # Main west dock
	Rect2(1384.0, 350.0, 94.0, 80.0), # East fishing dock
	Rect2(1344.0, 548.0, 112.0, 96.0), # Southeast fishing dock
	Rect2(984.0, 218.0, 78.0, 58.0), # West creek bridge
	Rect2(1382.0, 166.0, 86.0, 68.0), # North creek bridge
]

# Only solid back walls and landmark props are blocked for now. Venue and
# lounge floors remain walkable social spaces.
const OBSTACLE_RECTS: Array[Rect2] = [
	Rect2(590.0, 292.0, 264.0, 68.0), # Lounge back wall and roof
	Rect2(873.0, 294.0, 62.0, 78.0), # Community bulletin board
	Rect2(492.0, 752.0, 224.0, 62.0), # Cafe back wall
	Rect2(728.0, 752.0, 218.0, 62.0), # Bar back wall
	Rect2(962.0, 752.0, 188.0, 62.0), # Game room back wall
]

const WOODLAND_CENTER := Vector2(1702.0, 700.0)
const WOODLAND_RADII := Vector2(154.0, 184.0)


static func is_position_walkable(candidate: Vector2) -> bool:
	if not WORLD_BOUNDS.has_point(candidate):
		return false

	for surface in WALKABLE_WATER_RECTS:
		if surface.has_point(candidate):
			return true

	if _is_in_ellipse(candidate, MAIN_POND_CENTER, MAIN_POND_RADII):
		return false

	for segment in CREEK_SEGMENTS:
		if _distance_squared_to_segment(
			candidate,
			Vector2(segment.x, segment.y),
			Vector2(segment.z, segment.w)
		) <= CREEK_RADIUS * CREEK_RADIUS:
			return false

	for obstacle in OBSTACLE_RECTS:
		if obstacle.has_point(candidate):
			return false

	if _is_in_ellipse(candidate, WOODLAND_CENTER, WOODLAND_RADII):
		return false

	return true


static func _is_in_ellipse(candidate: Vector2, center: Vector2, radii: Vector2) -> bool:
	var normalized := (candidate - center) / radii
	return normalized.length_squared() < 1.0


static func _distance_squared_to_segment(point: Vector2, start: Vector2, end: Vector2) -> float:
	var segment := end - start
	var length_squared := segment.length_squared()
	if is_zero_approx(length_squared):
		return point.distance_squared_to(start)
	var amount := clampf((point - start).dot(segment) / length_squared, 0.0, 1.0)
	return point.distance_squared_to(start + segment * amount)
