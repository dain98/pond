class_name PondPlayer
extends CharacterBody2D

const SPEED := 96.0
const WORLD_BOUNDS := Rect2(12.0, 32.0, 616.0, 316.0)
const POND_CENTER := Vector2(480.0, 198.0)
const POND_RADII := Vector2(146.0, 126.0)
const DOCK_WALKABLE := Rect2(321.0, 163.0, 139.0, 54.0)

var peer_id := 0
var display_name := "Player"
var input_direction := Vector2.ZERO
var target_position := Vector2.ZERO
var player_color := Color("78c6a3")
var facing := Vector2.DOWN
var walk_phase := 0.0
var is_walking := false


func configure(new_peer_id: int, new_display_name: String, spawn_position: Vector2) -> void:
	peer_id = new_peer_id
	display_name = new_display_name
	position = spawn_position
	target_position = spawn_position
	player_color = _color_for_name(display_name)
	$NameLabel.text = display_name
	queue_redraw()


func _physics_process(delta: float) -> void:
	if multiplayer.is_server():
		var previous_position := position
		velocity = input_direction.limit_length(1.0) * SPEED
		move_and_slide()
		if _position_is_in_pond(position):
			position = previous_position
			velocity = Vector2.ZERO
		position.x = clampf(position.x, WORLD_BOUNDS.position.x, WORLD_BOUNDS.end.x)
		position.y = clampf(position.y, WORLD_BOUNDS.position.y, WORLD_BOUNDS.end.y)
		target_position = position
		_update_walk_animation(input_direction, delta)
	else:
		var blend := 1.0 - exp(-18.0 * delta)
		var movement := target_position - position
		position = position.lerp(target_position, blend)
		_update_walk_animation(movement.normalized() if movement.length() > 0.25 else Vector2.ZERO, delta)


func apply_server_position(server_position: Vector2) -> void:
	target_position = server_position


func _draw() -> void:
	var bob := -1.0 if is_walking and int(walk_phase) % 2 == 0 else 0.0
	var step := 1.0 if is_walking and int(walk_phase) % 2 == 0 else -1.0

	# Compact, layered pixel character with a readable top-down silhouette.
	draw_rect(Rect2(-7.0, 9.0, 14.0, 3.0), Color(0.04, 0.08, 0.08, 0.24))
	draw_rect(Rect2(-5.0 + step, 5.0 + bob, 4.0, 7.0), Color("21383d"))
	draw_rect(Rect2(1.0 - step, 5.0 + bob, 4.0, 7.0), Color("21383d"))
	draw_rect(Rect2(-6.0, -5.0 + bob, 12.0, 13.0), player_color.darkened(0.22))
	draw_rect(Rect2(-5.0, -5.0 + bob, 10.0, 11.0), player_color)
	draw_rect(Rect2(-8.0, -3.0 + bob, 3.0, 8.0), player_color.darkened(0.08))
	draw_rect(Rect2(5.0, -3.0 + bob, 3.0, 8.0), player_color.darkened(0.08))

	# Hair, face, and directional features.
	draw_rect(Rect2(-6.0, -14.0 + bob, 12.0, 9.0), Color("263c42"))
	draw_rect(Rect2(-5.0, -12.0 + bob, 10.0, 9.0), Color("e8ae72"))
	draw_rect(Rect2(-6.0, -14.0 + bob, 12.0, 4.0), Color("2a4145"))
	draw_rect(Rect2(-6.0, -11.0 + bob, 3.0, 5.0), Color("2a4145"))
	draw_rect(Rect2(4.0, -11.0 + bob, 2.0, 4.0), Color("2a4145"))

	if absf(facing.x) > absf(facing.y):
		var eye_x := 3.0 if facing.x > 0.0 else -4.0
		draw_rect(Rect2(eye_x, -9.0 + bob, 2.0, 2.0), Color("15272c"))
	elif facing.y >= 0.0:
		draw_rect(Rect2(-3.0, -9.0 + bob, 2.0, 2.0), Color("15272c"))
		draw_rect(Rect2(2.0, -9.0 + bob, 2.0, 2.0), Color("15272c"))

	# Small bright trim keeps the sprite distinct against grass and wood.
	draw_rect(Rect2(-4.0, 0.0 + bob, 8.0, 2.0), player_color.lightened(0.25))


func _update_walk_animation(direction: Vector2, delta: float) -> void:
	is_walking = direction.length() > 0.05
	if is_walking:
		facing = direction.normalized()
		walk_phase = fmod(walk_phase + delta * 9.0, 4.0)
	else:
		walk_phase = 0.0
	queue_redraw()


func _position_is_in_pond(candidate: Vector2) -> bool:
	if DOCK_WALKABLE.has_point(candidate):
		return false
	var normalized := (candidate - POND_CENTER) / POND_RADII
	return normalized.length_squared() < 1.0


func _color_for_name(player_name: String) -> Color:
	var palette: Array[Color] = [
		Color("78c6a3"),
		Color("f2a65a"),
		Color("8ea7e9"),
		Color("d884b7"),
		Color("e6c15a"),
		Color("74c9d4"),
	]
	return palette[absi(player_name.hash()) % palette.size()]
