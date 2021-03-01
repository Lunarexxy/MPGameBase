extends Node

signal player_connected(peer_id)
signal player_disconnected(peer_id)
signal connected_to_server
signal connection_failed
signal server_disconnected


# Holds the player peer IDs. Actual player data is stored in Player nodes.
# Similar to what you get from SceneTree.get_network_connected_peers(),
# but also contains the local client peer ID, and does not contain the server.
var player_list:Array


func _ready():
	# Shared
	get_tree().connect("network_peer_connected",    self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	# Client only
	get_tree().connect("connected_to_server",       self, "_connected_ok")
	get_tree().connect("connection_failed",         self, "_connected_fail")
	get_tree().connect("server_disconnected",       self, "_server_disconnected")

func _player_connected(id:int):
	if id != 1 && !player_list.has(id): player_list.append(id)
	emit_signal("player_connected", id)

func _player_disconnected(id:int):
	if player_list.has(id): player_list.erase(id)
	emit_signal("player_disconnected", id)
	
func _connected_ok():
	emit_signal("connected_to_server")

func _connected_fail():
	emit_signal("connection_failed")

func _server_disconnected():
	stop()
	emit_signal("server_disconnected")

func init_server(port:int):
	var peer:NetworkedMultiplayerENet = NetworkedMultiplayerENet.new()
	var err:int = peer.create_server(port)
	if err == OK:
		get_tree().network_peer = peer
	
func init_client(ip:String, port:int):
	var peer:NetworkedMultiplayerENet = NetworkedMultiplayerENet.new()
	var err:int = peer.create_client(ip, port)
	if err == OK:
		get_tree().network_peer = peer
		# Add local peer ID to the player list.
		# "network_peer_connected" signal doesn't fire for local client, and so must be done manually.
		var local_peer_id:int = get_tree().network_peer.get_unique_id()
		player_list.append(local_peer_id)
		emit_signal("player_connected", local_peer_id)
		
func stop():
	get_tree().network_peer = null
	player_list.clear()
	print("Connection closed.")
