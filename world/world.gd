extends Node

@onready var main_menu = $CanvasLayer/Menu_connect
@onready var address_entry = $CanvasLayer/Menu_connect/MarginContainer/VBoxContainer/IP


const Player = preload("res://world/Player.tscn")
const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()

func _unhandled_input(event):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

func _notification(event):
	if event == NOTIFICATION_WM_CLOSE_REQUEST:
		multiplayer.multiplayer_peer = null
		get_tree().quit()

func _on_host_pressed():
	# Start as server.
	main_menu.hide()
	
	enet_peer.create_server(PORT)
	if enet_peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer server.")
		return
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	
	add_player(multiplayer.get_unique_id())

func _on_join_pressed():
	main_menu.hide()
	if address_entry.text == "":
		OS.alert("Need a remote to connect to.")
		return

	enet_peer.create_client(address_entry.text, PORT)
	if enet_peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer client.")
		return
	multiplayer.multiplayer_peer = enet_peer

func add_player(peer_id):
	var player = Player.instantiate()
	player.name = str(peer_id)
	add_child(player)

func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()
