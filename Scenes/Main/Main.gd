extends Node

onready var network = $Network
onready var world = $World
var ip = "localhost"
var port = 25505


func _ready():
	# These signals must be connected before server/client are initialized
	network.connect("player_connected", world, "_on_player_connected")
	network.connect("player_disconnected", world, "_on_player_disconnected")
	network.connect("server_disconnected", world, "_on_server_disconnected")
	
	if Array(OS.get_cmdline_args()).has("--server"):
		print("Starting server")
		network.init_server(port)
	else:
		print("Starting client")
		network.init_client(ip, port)
