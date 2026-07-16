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
	# Placeholder town green and lounge floor.
	draw_rect(Rect2(0.0, 0.0, 1280.0, 720.0), Color("8ab17d"))
	draw_rect(Rect2(42.0, 126.0, 455.0, 520.0), Color("d9c39a"))
	draw_rect(Rect2(42.0, 126.0, 455.0, 18.0), Color("6f5643"))
	draw_rect(Rect2(42.0, 126.0, 18.0, 520.0), Color("6f5643"))
	draw_rect(Rect2(479.0, 126.0, 18.0, 520.0), Color("6f5643"))

	# Lounge tables and rugs.
	draw_rect(Rect2(96.0, 250.0, 150.0, 96.0), Color("bc8f6a"))
	draw_circle(Vector2(160.0, 430.0), 43.0, Color("755c48"))
	draw_circle(Vector2(365.0, 278.0), 43.0, Color("755c48"))
	draw_rect(Rect2(286.0, 428.0, 150.0, 110.0), Color("aa6f73"))

	# A simple pond with a rim matching its collision shape.
	draw_circle(Vector2(940.0, 390.0), 211.0, Color("d9c995"))
	draw_circle(Vector2(940.0, 390.0), 199.0, Color("4d98a6"))
	draw_circle(Vector2(906.0, 352.0), 139.0, Color("5cabb4"))
	draw_circle(Vector2(835.0, 314.0), 8.0, Color("94bb70"))
	draw_circle(Vector2(1024.0, 464.0), 10.0, Color("94bb70"))

	# Dock.
	draw_rect(Rect2(686.0, 348.0, 145.0, 78.0), Color("a8774f"))
	for x in range(696, 831, 22):
		draw_line(Vector2(x, 352.0), Vector2(x, 422.0), Color("6f4b39"), 2.0)


func _build_world_labels() -> void:
	var lounge_label := Label.new()
	lounge_label.position = Vector2(310.0, 590.0)
	lounge_label.text = "THE LOUNGE"
	lounge_label.add_theme_font_size_override("font_size", 24)
	lounge_label.add_theme_color_override("font_color", Color("5d4939"))
	add_child(lounge_label)

	var pond_label := Label.new()
	pond_label.position = Vector2(870.0, 92.0)
	pond_label.text = "THE POND"
	pond_label.add_theme_font_size_override("font_size", 24)
	pond_label.add_theme_color_override("font_color", Color("284f58"))
	add_child(pond_label)


func _build_connection_panel() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 10
	add_child(layer)

	var panel := PanelContainer.new()
	panel.position = Vector2(20.0, 20.0)
	panel.custom_minimum_size = Vector2(365.0, 0.0)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.055, 0.075, 0.08, 0.94)
	panel_style.border_color = Color("78c6a3")
	panel_style.set_border_width_all(2)
	panel_style.corner_radius_top_left = 8
	panel_style.corner_radius_top_right = 8
	panel_style.corner_radius_bottom_left = 8
	panel_style.corner_radius_bottom_right = 8
	panel.add_theme_stylebox_override("panel", panel_style)
	layer.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 14)
	panel.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	margin.add_child(column)

	var title := Label.new()
	title.text = "POND — SHARED ROOM"
	title.add_theme_font_size_override("font_size", 21)
	title.add_theme_color_override("font_color", Color("b9e3c6"))
	column.add_child(title)

	name_edit = LineEdit.new()
	name_edit.placeholder_text = "Your name"
	name_edit.text = "Fisher"
	name_edit.max_length = 24
	column.add_child(name_edit)

	address_edit = LineEdit.new()
	address_edit.placeholder_text = "Host address"
	address_edit.text = "127.0.0.1"
	column.add_child(address_edit)

	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 8)
	column.add_child(buttons)

	host_button = Button.new()
	host_button.text = "Host"
	host_button.pressed.connect(_start_host)
	buttons.add_child(host_button)

	join_button = Button.new()
	join_button.text = "Join"
	join_button.pressed.connect(_start_client.bind(""))
	buttons.add_child(join_button)

	disconnect_button = Button.new()
	disconnect_button.text = "Disconnect"
	disconnect_button.disabled = true
	disconnect_button.pressed.connect(_disconnect_from_session.bind(true))
	buttons.add_child(disconnect_button)

	status_label = Label.new()
	status_label.text = "Offline — UDP port %d" % PORT
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_color_override("font_color", Color("d8e5dc"))
	column.add_child(status_label)

	var help := Label.new()
	help.text = "Move with WASD, arrow keys, or the left stick."
	help.add_theme_font_size_override("font_size", 13)
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
		Vector2(560.0, 350.0),
		Vector2(560.0, 430.0),
		Vector2(620.0, 310.0),
		Vector2(620.0, 470.0),
		Vector2(530.0, 510.0),
		Vector2(530.0, 270.0),
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
