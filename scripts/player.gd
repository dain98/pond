class_name PondPlayer
extends CharacterBody2D

const SPEED := 190.0
const WORLD_BOUNDS := Rect2(36.0, 82.0, 1208.0, 602.0)

var peer_id := 0
var display_name := "Player"
var input_direction := Vector2.ZERO
var target_position := Vector2.ZERO
var player_color := Color("78c6a3")


func configure(new_peer_id: int, new_display_name: String, spawn_position: Vector2) -> void:
	peer_id = new_peer_id
	display_name = new_display_name
	position = spawn_position
	target_position = spawn_position
	player_color = _color_for_peer(peer_id)
	$NameLabel.text = display_name
	queue_redraw()


func _physics_process(delta: float) -> void:
	if multiplayer.is_server():
		velocity = input_direction.limit_length(1.0) * SPEED
		move_and_slide()
		position.x = clampf(position.x, WORLD_BOUNDS.position.x, WORLD_BOUNDS.end.x)
		position.y = clampf(position.y, WORLD_BOUNDS.position.y, WORLD_BOUNDS.end.y)
		target_position = position
	else:
		var blend := 1.0 - exp(-18.0 * delta)
		position = position.lerp(target_position, blend)


func apply_server_position(server_position: Vector2) -> void:
	target_position = server_position


func _draw() -> void:
	# A deliberately simple, asset-free placeholder character.
	draw_circle(Vector2(0.0, 14.0), 12.0, Color(0.05, 0.08, 0.08, 0.28))
	draw_rect(Rect2(-10.0, -5.0, 20.0, 26.0), player_color.darkened(0.18))
	draw_rect(Rect2(-8.0, -2.0, 16.0, 20.0), player_color)
	draw_circle(Vector2(0.0, -10.0), 10.0, player_color.lightened(0.22))
	draw_rect(Rect2(-5.0, -12.0, 3.0, 3.0), Color("18242b"))
	draw_rect(Rect2(3.0, -12.0, 3.0, 3.0), Color("18242b"))
	draw_rect(Rect2(-8.0, 18.0, 6.0, 4.0), Color("263b40"))
	draw_rect(Rect2(2.0, 18.0, 6.0, 4.0), Color("263b40"))


func _color_for_peer(id: int) -> Color:
	var palette: Array[Color] = [
		Color("78c6a3"),
		Color("f2a65a"),
		Color("8ea7e9"),
		Color("d884b7"),
		Color("e6c15a"),
		Color("74c9d4"),
	]
	return palette[absi(id) % palette.size()]
