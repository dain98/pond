extends Node2D

const PORT := 43117
const MAX_CLIENTS := 8
const SNAPSHOT_INTERVAL := 1.0 / 20.0
const PLAYER_SCENE := preload("res://scenes/player.tscn")

var players: Dictionary = {}
var player_names: Dictionary = {}
var snapshot_elapsed := 0.0
var run_seconds := -1.0
var run_elapsed := 0.0
var automated_input_enabled := false
var automated_direction := Vector2.ZERO
var automated_spawn_position := Vector2.ZERO
var movement_observed_logged := false
var visual_elapsed := 0.0
var water_frame := 0

var name_edit: LineEdit
var address_edit: LineEdit
var status_label: Label
var host_button: Button
var join_button: Button
var disconnect_button: Button


func _ready() -> void:
	_build_world_labels()
	_build_connection_panel()
	_connect_multiplayer_signals()
	_apply_command_line()
	queue_redraw()


func _process(delta: float) -> void:
	_update_local_input()
	visual_elapsed += delta
	var next_water_frame := int(visual_elapsed * 3.0) % 4
	if next_water_frame != water_frame:
		water_frame = next_water_frame
		queue_redraw()

	if _network_is_active() and multiplayer.is_server():
		snapshot_elapsed += delta
		if snapshot_elapsed >= SNAPSHOT_INTERVAL:
			snapshot_elapsed = fmod(snapshot_elapsed, SNAPSHOT_INTERVAL)
			_broadcast_snapshot()

	if run_seconds > 0.0:
		run_elapsed += delta
		if run_elapsed >= run_seconds:
			_disconnect_from_session(false)
			get_tree().quit()


func _draw() -> void:
	_draw_ground()
	_draw_lounge()
	_draw_pond()
	_draw_dock()
	_draw_props()


func _draw_ground() -> void:
	draw_rect(Rect2(0.0, 0.0, 640.0, 360.0), Color("5e8b55"))

	var dark_patches: Array[Rect2] = [
		Rect2(3, 42, 38, 15), Rect2(252, 18, 28, 11), Rect2(292, 286, 40, 16),
		Rect2(563, 17, 52, 14), Rect2(591, 309, 35, 18), Rect2(9, 324, 46, 19),
	]
	for patch in dark_patches:
		draw_rect(patch, Color("527c4b"))
		draw_rect(Rect2(patch.position + Vector2(4, 3), patch.size - Vector2(9, 7)), Color("66945a"))

	var path_points := PackedVector2Array([
		Vector2(252, 354), Vector2(275, 294), Vector2(269, 236),
		Vector2(292, 180), Vector2(284, 122), Vector2(320, 55), Vector2(352, -8),
	])
	draw_polyline(path_points, Color("b8955f"), 54.0, false)
	draw_polyline(path_points, Color("d0b174"), 43.0, false)

	var path_stones: Array[Rect2] = [
		Rect2(257, 331, 15, 6), Rect2(274, 301, 9, 5), Rect2(257, 266, 17, 7),
		Rect2(274, 225, 13, 6), Rect2(279, 190, 18, 7), Rect2(276, 151, 10, 5),
		Rect2(295, 111, 17, 6), Rect2(308, 72, 12, 5), Rect2(329, 32, 16, 6),
	]
	for stone in path_stones:
		draw_rect(stone, Color("dec58e"))
		draw_rect(Rect2(stone.position + Vector2(2, stone.size.y - 2), Vector2(stone.size.x - 3, 2)), Color("a88458"))


func _draw_lounge() -> void:
	draw_rect(Rect2(15, 59, 227, 267), Color(0.10, 0.16, 0.12, 0.28))
	draw_rect(Rect2(20, 54, 224, 266), Color("70513b"))
	draw_rect(Rect2(25, 60, 214, 255), Color("bd8c5d"))

	for y in range(64, 315, 12):
		draw_line(Vector2(25, y), Vector2(239, y), Color("a87550"), 1.0)
	for x in range(29, 239, 28):
		draw_line(Vector2(x, 60), Vector2(x, 315), Color(0.30, 0.20, 0.15, 0.18), 1.0)

	draw_rect(Rect2(15, 43, 234, 40), Color("2f4c4c"))
	draw_rect(Rect2(20, 48, 224, 28), Color("3f6864"))
	for x in range(24, 244, 12):
		draw_line(Vector2(x, 49), Vector2(x - 7, 75), Color("294642"), 3.0)
	draw_rect(Rect2(25, 76, 214, 35), Color("674634"))
	draw_rect(Rect2(31, 82, 202, 23), Color("392f29"))

	for x in [40, 58, 76, 188, 206, 224]:
		draw_rect(Rect2(x, 87, 5, 10), Color("8eb9a2"))
		draw_rect(Rect2(x + 1, 85, 3, 3), Color("d7c26e"))
	draw_rect(Rect2(35, 111, 194, 20), Color("573c2e"))
	draw_rect(Rect2(35, 108, 194, 8), Color("d09a5c"))
	for x in [56, 92, 128, 164, 200]:
		draw_rect(Rect2(x - 7, 137, 14, 7), Color("7b4d3b"))
		draw_rect(Rect2(x - 4, 144, 3, 12), Color("4a342b"))
		draw_rect(Rect2(x + 2, 144, 3, 12), Color("4a342b"))

	draw_rect(Rect2(40, 176, 80, 54), Color("91555c"))
	draw_rect(Rect2(45, 181, 70, 44), Color("b66f68"))
	draw_rect(Rect2(142, 235, 76, 52), Color("456d6b"))
	draw_rect(Rect2(147, 240, 66, 42), Color("5d8b7d"))
	for center in [Vector2(80, 202), Vector2(180, 259)]:
		draw_rect(Rect2(center - Vector2(18, 8), Vector2(36, 16)), Color("5a3e31"))
		draw_rect(Rect2(center - Vector2(15, 7), Vector2(30, 11)), Color("b27d4e"))
		draw_rect(Rect2(center + Vector2(-2, 5), Vector2(4, 7)), Color("49332a"))

	for x in [20, 235]:
		draw_rect(Rect2(x, 72, 7, 247), Color("4c362d"))
		draw_rect(Rect2(x + 1, 74, 3, 241), Color("8e6142"))


func _draw_pond() -> void:
	var bank := PackedVector2Array([
		Vector2(461, 55), Vector2(523, 61), Vector2(577, 88), Vector2(616, 132),
		Vector2(629, 187), Vector2(619, 245), Vector2(586, 298), Vector2(532, 326),
		Vector2(464, 330), Vector2(399, 309), Vector2(354, 270), Vector2(330, 216),
		Vector2(334, 157), Vector2(365, 102), Vector2(410, 70),
	])
	var water := PackedVector2Array([
		Vector2(463, 63), Vector2(520, 68), Vector2(570, 93), Vector2(607, 136),
		Vector2(620, 188), Vector2(610, 240), Vector2(579, 289), Vector2(528, 316),
		Vector2(466, 320), Vector2(405, 301), Vector2(363, 264), Vector2(340, 214),
		Vector2(343, 160), Vector2(372, 110), Vector2(414, 78),
	])
	draw_colored_polygon(bank, Color("d2bd79"))
	draw_colored_polygon(water, Color("267f92"))

	var shallow := PackedVector2Array([
		Vector2(468, 76), Vector2(521, 83), Vector2(562, 105), Vector2(590, 140),
		Vector2(599, 184), Vector2(589, 226), Vector2(561, 265), Vector2(518, 288),
		Vector2(469, 293), Vector2(419, 278), Vector2(383, 247), Vector2(363, 207),
		Vector2(367, 163), Vector2(389, 123), Vector2(423, 93),
	])
	draw_colored_polygon(shallow, Color("3999a6"))

	var shift := float(water_frame * 3)
	for sparkle in [Vector2(389, 133), Vector2(448, 93), Vector2(537, 130), Vector2(572, 226), Vector2(438, 278)]:
		var point: Vector2 = sparkle + Vector2(fmod(shift, 7.0), 0.0)
		draw_rect(Rect2(point, Vector2(9, 2)), Color("82d1d3"))
		draw_rect(Rect2(point + Vector2(3, -2), Vector2(3, 2)), Color("b8e3d5"))

	for pad in [Vector2(393, 185), Vector2(548, 164), Vector2(520, 262)]:
		draw_rect(Rect2(pad - Vector2(5, 2), Vector2(10, 5)), Color("638e4e"))
		draw_rect(Rect2(pad + Vector2(1, -1), Vector2(5, 2)), Color("85ad5c"))
	for fish in [Vector2(475, 225), Vector2(550, 205), Vector2(433, 151)]:
		draw_rect(Rect2(fish - Vector2(5, 1), Vector2(9, 3)), Color(0.08, 0.27, 0.34, 0.38))
		draw_rect(Rect2(fish + Vector2(4, -2), Vector2(3, 5)), Color(0.08, 0.27, 0.34, 0.38))


func _draw_dock() -> void:
	draw_rect(Rect2(319, 169, 143, 51), Color(0.10, 0.13, 0.10, 0.30))
	draw_rect(Rect2(321, 163, 139, 52), Color("5d3e2f"))
	draw_rect(Rect2(323, 165, 135, 46), Color("a86f45"))
	for x in range(326, 458, 14):
		draw_line(Vector2(x, 166), Vector2(x, 210), Color("6d4634"), 2.0)
	for post in [Vector2(326, 158), Vector2(451, 158), Vector2(326, 207), Vector2(451, 207)]:
		draw_rect(Rect2(post, Vector2(7, 16)), Color("49342b"))
		draw_rect(Rect2(post + Vector2(1, 1), Vector2(4, 5)), Color("c18b50"))


func _draw_props() -> void:
	_draw_tree(Vector2(48, 338), Color("477844"))
	_draw_tree(Vector2(603, 346), Color("3f7140"))
	_draw_tree(Vector2(615, 62), Color("4b7f47"))

	for bush in [Vector2(260, 54), Vector2(301, 326), Vector2(623, 278), Vector2(267, 102)]:
		draw_rect(Rect2(bush - Vector2(10, 5), Vector2(20, 10)), Color("345f3c"))
		draw_rect(Rect2(bush - Vector2(7, 8), Vector2(14, 11)), Color("5c914d"))
		draw_rect(Rect2(bush - Vector2(2, 7), Vector2(6, 4)), Color("79aa58"))

	for flower in [Vector2(258, 246), Vector2(302, 88), Vector2(313, 303), Vector2(626, 119), Vector2(582, 323)]:
		draw_rect(Rect2(flower, Vector2(2, 5)), Color("426d3d"))
		draw_rect(Rect2(flower - Vector2(2, 1), Vector2(6, 3)), Color("e9bf5b"))
		draw_rect(Rect2(flower, Vector2(2, 2)), Color("f4e3a0"))

	draw_rect(Rect2(268, 38, 49, 35), Color(0.08, 0.12, 0.09, 0.28))
	draw_rect(Rect2(265, 34, 49, 35), Color("624332"))
	draw_rect(Rect2(269, 38, 41, 25), Color("c39a61"))
	draw_rect(Rect2(273, 41, 13, 9), Color("e5d7ae"))
	draw_rect(Rect2(290, 42, 16, 14), Color("d9856d"))
	draw_rect(Rect2(270, 68, 5, 13), Color("49332a"))
	draw_rect(Rect2(305, 68, 5, 13), Color("49332a"))


func _draw_tree(base: Vector2, canopy_color: Color) -> void:
	draw_rect(Rect2(base + Vector2(-4, -24), Vector2(9, 27)), Color("563c2d"))
	draw_rect(Rect2(base + Vector2(-2, -24), Vector2(4, 24)), Color("8d6040"))
	draw_rect(Rect2(base + Vector2(-18, -42), Vector2(36, 18)), canopy_color.darkened(0.16))
	draw_rect(Rect2(base + Vector2(-23, -35), Vector2(46, 17)), canopy_color)
	draw_rect(Rect2(base + Vector2(-14, -48), Vector2(28, 19)), canopy_color.lightened(0.12))
	draw_rect(Rect2(base + Vector2(-8, -44), Vector2(9, 6)), Color("79a95b"))


func _build_world_labels() -> void:
	var lounge_label := Label.new()
	lounge_label.position = Vector2(151.0, 294.0)
	lounge_label.text = "THE LOUNGE"
	lounge_label.add_theme_font_size_override("font_size", 12)
	lounge_label.add_theme_color_override("font_color", Color("5d4939"))
	add_child(lounge_label)

	var pond_label := Label.new()
	pond_label.position = Vector2(437.0, 38.0)
	pond_label.text = "THE POND"
	pond_label.add_theme_font_size_override("font_size", 12)
	pond_label.add_theme_color_override("font_color", Color("284f58"))
	add_child(pond_label)


func _build_connection_panel() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 10
	add_child(layer)

	var panel := PanelContainer.new()
	panel.position = Vector2(8.0, 8.0)
	panel.custom_minimum_size = Vector2(210.0, 0.0)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.055, 0.075, 0.08, 0.94)
	panel_style.border_color = Color("78c6a3")
	panel_style.set_border_width_all(1)
	panel_style.corner_radius_top_left = 4
	panel_style.corner_radius_top_right = 4
	panel_style.corner_radius_bottom_left = 4
	panel_style.corner_radius_bottom_right = 4
	panel.add_theme_stylebox_override("panel", panel_style)
	layer.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 7)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 7)
	panel.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 4)
	margin.add_child(column)

	var title := Label.new()
	title.text = "POND // SHARED ROOM"
	title.add_theme_font_size_override("font_size", 12)
	title.add_theme_color_override("font_color", Color("b9e3c6"))
	column.add_child(title)

	name_edit = LineEdit.new()
	name_edit.placeholder_text = "Your name"
	name_edit.text = "Fisher"
	name_edit.max_length = 24
	name_edit.custom_minimum_size.y = 21
	name_edit.add_theme_font_size_override("font_size", 10)
	column.add_child(name_edit)

	address_edit = LineEdit.new()
	address_edit.placeholder_text = "Host address"
	address_edit.text = "127.0.0.1"
	address_edit.custom_minimum_size.y = 21
	address_edit.add_theme_font_size_override("font_size", 10)
	column.add_child(address_edit)

	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 4)
	column.add_child(buttons)

	host_button = Button.new()
	host_button.text = "Host"
	host_button.add_theme_font_size_override("font_size", 9)
	host_button.pressed.connect(_start_host)
	buttons.add_child(host_button)

	join_button = Button.new()
	join_button.text = "Join"
	join_button.add_theme_font_size_override("font_size", 9)
	join_button.pressed.connect(_start_client.bind(""))
	buttons.add_child(join_button)

	disconnect_button = Button.new()
	disconnect_button.text = "Disconnect"
	disconnect_button.add_theme_font_size_override("font_size", 9)
	disconnect_button.disabled = true
	disconnect_button.pressed.connect(_disconnect_from_session.bind(true))
	buttons.add_child(disconnect_button)

	status_label = Label.new()
	status_label.text = "Offline — UDP port %d" % PORT
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_font_size_override("font_size", 9)
	status_label.add_theme_color_override("font_color", Color("d8e5dc"))
	column.add_child(status_label)

	var help := Label.new()
	help.text = "WASD / arrows / left stick"
	help.add_theme_font_size_override("font_size", 8)
	help.add_theme_color_override("font_color", Color("9fb3aa"))
	column.add_child(help)


func _connect_multiplayer_signals() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func _start_host() -> void:
	_disconnect_from_session(false)
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_server(PORT, MAX_CLIENTS)
	if error != OK:
		_set_status("Could not host on UDP port %d (error %d)." % [PORT, error])
		return

	multiplayer.multiplayer_peer = peer
	var host_name := _sanitized_name(name_edit.text)
	player_names[1] = host_name
	_spawn_player_local(1, host_name, _spawn_position(0))
	_set_connected_ui(true)
	_set_status("Hosting on UDP port %d as %s." % [PORT, host_name])
	print("POND_SERVER_STARTED port=%d name=%s" % [PORT, host_name])


func _start_client(host_override: String = "") -> void:
	_disconnect_from_session(false)
	var host := host_override.strip_edges()
	if host.is_empty():
		host = address_edit.text.strip_edges()
	if host.is_empty():
		_set_status("Enter a host address first.")
		return

	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_client(host, PORT)
	if error != OK:
		_set_status("Could not connect to %s (error %d)." % [host, error])
		return

	multiplayer.multiplayer_peer = peer
	_set_connected_ui(true)
	_set_status("Connecting to %s:%d…" % [host, PORT])
	print("POND_CONNECTING host=%s port=%d" % [host, PORT])


func _disconnect_from_session(show_status: bool = true) -> void:
	if _network_is_active():
		multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()

	for player: PondPlayer in players.values():
		player.queue_free()
	players.clear()
	player_names.clear()
	snapshot_elapsed = 0.0
	automated_spawn_position = Vector2.ZERO
	movement_observed_logged = false
	_set_connected_ui(false)
	if show_status and status_label:
		_set_status("Offline — UDP port %d" % PORT)


func _on_peer_connected(peer_id: int) -> void:
	print("POND_PEER_CONNECTED id=%d" % peer_id)


func _on_peer_disconnected(peer_id: int) -> void:
	print("POND_PEER_DISCONNECTED id=%d" % peer_id)
	if multiplayer.is_server() and player_names.has(peer_id):
		player_names.erase(peer_id)
		_despawn_player.rpc(peer_id)


func _on_connected_to_server() -> void:
	var local_id := multiplayer.get_unique_id()
	_set_status("Connected as peer %d. Waiting for the room…" % local_id)
	_register_player.rpc_id(1, _sanitized_name(name_edit.text))
	print("POND_CONNECTED id=%d" % local_id)


func _on_connection_failed() -> void:
	_disconnect_from_session(false)
	_set_status("Connection failed. Check the address and UDP port %d." % PORT)
	print("POND_CONNECTION_FAILED")


func _on_server_disconnected() -> void:
	_disconnect_from_session(false)
	_set_status("The host closed the session.")
	print("POND_SERVER_DISCONNECTED")


@rpc("any_peer", "call_remote", "reliable", 0)
func _register_player(requested_name: String) -> void:
	if not multiplayer.is_server():
		return

	var sender_id := multiplayer.get_remote_sender_id()
	if sender_id <= 1 or player_names.has(sender_id):
		return

	for existing_id: int in player_names:
		var existing_player: PondPlayer = players[existing_id]
		_spawn_player.rpc_id(
			sender_id,
			existing_id,
			player_names[existing_id],
			existing_player.position
		)

	var safe_name := _sanitized_name(requested_name)
	var spawn_position := _spawn_position(player_names.size())
	player_names[sender_id] = safe_name
	_spawn_player.rpc(sender_id, safe_name, spawn_position)
	_set_status("Hosting %d player(s) on UDP port %d." % [players.size(), PORT])
	print("POND_PLAYER_REGISTERED id=%d name=%s" % [sender_id, safe_name])


@rpc("authority", "call_local", "reliable", 0)
func _spawn_player(peer_id: int, display_name: String, spawn_position: Vector2) -> void:
	_spawn_player_local(peer_id, display_name, spawn_position)


func _spawn_player_local(peer_id: int, display_name: String, spawn_position: Vector2) -> void:
	if players.has(peer_id):
		return
	var player := PLAYER_SCENE.instantiate() as PondPlayer
	player.name = "Player_%d" % peer_id
	$Players.add_child(player)
	player.configure(peer_id, display_name, spawn_position)
	players[peer_id] = player

	if not multiplayer.is_server() and peer_id == multiplayer.get_unique_id():
		automated_spawn_position = spawn_position
		_set_status("Connected as %s. %d player(s) in the room." % [display_name, players.size()])


@rpc("authority", "call_local", "reliable", 0)
func _despawn_player(peer_id: int) -> void:
	if not players.has(peer_id):
		return
	var player: PondPlayer = players[peer_id]
	players.erase(peer_id)
	player.queue_free()
	if multiplayer.is_server():
		_set_status("Hosting %d player(s) on UDP port %d." % [players.size(), PORT])


@rpc("any_peer", "call_remote", "unreliable_ordered", 0)
func _submit_input(direction: Vector2) -> void:
	if not multiplayer.is_server():
		return
	var sender_id := multiplayer.get_remote_sender_id()
	if players.has(sender_id):
		var player: PondPlayer = players[sender_id]
		player.input_direction = direction.limit_length(1.0)


func _update_local_input() -> void:
	if not _network_is_active():
		return
	var local_id := multiplayer.get_unique_id()
	if not players.has(local_id):
		return

	var direction := Vector2.ZERO
	if automated_input_enabled:
		direction = automated_direction
	elif not _text_input_has_focus():
		if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
			direction.x -= 1.0
		if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
			direction.x += 1.0
		if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
			direction.y -= 1.0
		if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
			direction.y += 1.0

		var stick := Vector2(
			Input.get_joy_axis(0, JOY_AXIS_LEFT_X),
			Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
		)
		if stick.length() >= 0.2:
			direction = stick

	direction = direction.limit_length(1.0)
	if multiplayer.is_server():
		var local_player: PondPlayer = players[local_id]
		local_player.input_direction = direction
	else:
		_submit_input.rpc_id(1, direction)


func _broadcast_snapshot() -> void:
	var state := {}
	for peer_id: int in players:
		var player: PondPlayer = players[peer_id]
		state[peer_id] = player.position
	_receive_snapshot.rpc(state)


@rpc("authority", "call_remote", "unreliable_ordered", 1)
func _receive_snapshot(state: Dictionary) -> void:
	for peer_id: int in state:
		if players.has(peer_id):
			var player: PondPlayer = players[peer_id]
			player.apply_server_position(state[peer_id])
			if (
				automated_input_enabled
				and not movement_observed_logged
				and peer_id == multiplayer.get_unique_id()
				and automated_spawn_position.distance_to(state[peer_id]) > 20.0
			):
				movement_observed_logged = true
				print("POND_MOVEMENT_OBSERVED id=%d position=%s" % [peer_id, state[peer_id]])


func _spawn_position(spawn_index: int) -> Vector2:
	var positions: Array[Vector2] = [
		Vector2(278.0, 176.0),
		Vector2(278.0, 215.0),
		Vector2(310.0, 150.0),
		Vector2(310.0, 240.0),
		Vector2(270.0, 270.0),
		Vector2(285.0, 125.0),
	]
	return positions[absi(spawn_index) % positions.size()]


func _sanitized_name(value: String) -> String:
	var safe := value.strip_edges().replace("\n", " ").replace("\r", " ").replace("\t", " ")
	safe = safe.substr(0, 24).strip_edges()
	return safe if not safe.is_empty() else "Fisher"


func _text_input_has_focus() -> bool:
	return get_viewport().gui_get_focus_owner() is LineEdit


func _network_is_active() -> bool:
	return not multiplayer.multiplayer_peer is OfflineMultiplayerPeer


func _set_connected_ui(connected: bool) -> void:
	if not host_button:
		return
	host_button.disabled = connected
	join_button.disabled = connected
	disconnect_button.disabled = not connected
	name_edit.editable = not connected
	address_edit.editable = not connected


func _set_status(message: String) -> void:
	if status_label:
		status_label.text = message


func _apply_command_line() -> void:
	var should_host := false
	var join_host := ""
	for argument in OS.get_cmdline_user_args():
		if argument == "--server":
			should_host = true
		elif argument.begins_with("--join="):
			join_host = argument.trim_prefix("--join=")
		elif argument.begins_with("--name="):
			name_edit.text = _sanitized_name(argument.trim_prefix("--name="))
		elif argument.begins_with("--run-seconds="):
			run_seconds = argument.trim_prefix("--run-seconds=").to_float()
		elif argument == "--move-right":
			automated_input_enabled = true
			automated_direction = Vector2.RIGHT

	if should_host:
		_start_host()
	elif not join_host.is_empty():
		address_edit.text = join_host
		_start_client(join_host)
