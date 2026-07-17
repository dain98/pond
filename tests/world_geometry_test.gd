extends SceneTree

var failed := false


func _init() -> void:
	_expect_walkable(Vector2(900.0, 650.0), "central commons spawn")
	_expect_walkable(Vector2(300.0, 320.0), "housing plot approach")
	_expect_walkable(Vector2(720.0, 500.0), "lounge floor")
	_expect_walkable(Vector2(600.0, 900.0), "cafe floor")
	_expect_walkable(Vector2(1050.0, 450.0), "main dock")
	_expect_walkable(Vector2(1020.0, 245.0), "west creek bridge")
	_expect_walkable(Vector2(1880.0, 1048.0), "inside southeast world edge")

	_expect_blocked(Vector2(-1.0, 500.0), "outside world")
	_expect_blocked(Vector2(1250.0, 455.0), "main pond")
	_expect_blocked(Vector2(940.0, 165.0), "west creek")
	_expect_blocked(Vector2(700.0, 320.0), "lounge back wall")
	_expect_blocked(Vector2(600.0, 780.0), "cafe back wall")
	_expect_blocked(Vector2(1702.0, 700.0), "dense east woodland")

	if failed:
		quit(1)
	else:
		print("Pond world geometry test passed.")
		quit()


func _expect_walkable(position: Vector2, description: String) -> void:
	if not PondWorldGeometry.is_position_walkable(position):
		push_error("Expected %s at %s to be walkable." % [description, position])
		failed = true


func _expect_blocked(position: Vector2, description: String) -> void:
	if PondWorldGeometry.is_position_walkable(position):
		push_error("Expected %s at %s to be blocked." % [description, position])
		failed = true
