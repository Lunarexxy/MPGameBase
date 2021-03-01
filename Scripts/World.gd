extends Node2D

var player_scene = preload("res://Scenes/Player/Player.tscn")

func _ready():
	pass

func _on_player_connected(peer_id):
	if peer_id == 1: return # Server doesn't get a player
	var player = player_scene.instance()
	player.set_peer_id(peer_id)
	add_child(player)

func _on_player_disconnected(peer_id):
	var player = get_node(str(peer_id))
	if player != null: player.queue_free()

func _on_server_disconnected():
	for ply in get_tree().get_nodes_in_group("Players"):
		ply.queue_free()
