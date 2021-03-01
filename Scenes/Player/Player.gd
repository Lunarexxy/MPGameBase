extends Node2D


var speed:float = 100

# The peer that owns this player node
var peer_id:int setget set_peer_id
# The serverside position of the player. Useful for position interpolation.
puppetsync var server_position:Vector2 = Vector2(0,0)



func _ready():
	if is_server():
		position = Vector2(rand_range(0,1024), rand_range(0,800))
		server_position = position


func _process(delta: float):
	# If not connected or connecting, don't do anything.
	if get_tree().network_peer == null or get_tree().network_peer.get_connection_status() != 2: return
	
	# Serverside logic here. The server runs this on each active player object.
	if is_server():
		server_position = position
		rset_unreliable("server_position", server_position)
		return
	
	# Not our player object. Make it do whatever the server says they're doing.
	if !is_local_player():
		move_to_server_pos()
		return
	
	# This is our player object. Make requests to the server.
	if is_local_player():
		local_move()
		return

# Very basic serverside speedhack protection
master func validate_client_move(new_pos:Vector2):
	# Don't let clients make moves for other players
	if peer_id != get_tree().get_rpc_sender_id(): return
	
	if server_position.distance_to(new_pos) > speed*get_process_delta_time() * 1.5:
		rpc_id(get_tree().get_rpc_sender_id(), "force_to_server_position")
	else:
		position = new_pos
		server_position = new_pos

puppet func force_to_server_position():
	position = server_position

func local_move():
	var d_vec:Vector2 = Vector2(0,0)
	if Input.is_action_pressed("move_up"):
		d_vec.y += -1
	if Input.is_action_pressed("move_down"):
		d_vec.y += 1
	if Input.is_action_pressed("move_left"):
		d_vec.x += -1
	if Input.is_action_pressed("move_right"):
		d_vec.x += 1
	d_vec = d_vec.normalized()
	d_vec *= speed*get_process_delta_time()
	position += d_vec
	rpc_id(1, "validate_client_move", position)

func set_peer_id(id:int):
	peer_id = id
	name = str(peer_id)
	# Setting the name to the peer ID makes RPC calls a lot easier,
	# since the absolute path must match between client and server.

func move_to_server_pos():
	if position.distance_to(server_position) > speed*get_process_delta_time()*2:
		position = server_position
	else:
		position = position.linear_interpolate(server_position, 0.5)

func is_local_player() -> bool:
	return peer_id == get_tree().get_network_unique_id()

func is_server() -> bool:
	return get_tree().get_network_unique_id() == 1
