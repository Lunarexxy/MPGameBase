# MPGameBase
 A starting point for a server-client multiplayer Godot game. It was built in Godot 3.2.3.

 This acts as an example of how you can do a simple authoritative server-client setup, since the official Godot documentation does not show it. Only 4 short scripts and 2 scenes are used.

 * `Main.gd` (and `Main.tscn`) acts as the starting point of the game. It's meant to connect signals between World, UI, and Network, so they can communicate in a modular fashion. It also starts the server or client. A .bat file in Exports/ helps with this.

 * `Network.gd` handles network setup and events. It emits signals to notify other nodes (through connections that Main sets up) that network-relevant events have happened. See [High-level Multiplayer](https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html) for more.

 * `World.gd` listens for "player connected/disconnected" events from Network, and spawns/despawns players in response.

 * `Player.gd` (and `Player.tscn`) is assigned a newly connected client's peer ID on spawn. This gives the client "ownership" of the node, without needing to set them as the network master of it. The server determines what the node is allowed to do and where it is. The client that owns the player node may request to move it using WASD. The clients who don't own it will just put it wherever the server says it belongs.

 * `UI.gd` doesn't do anything, but it's there as a guide. Make it load a menu scene or something!
 
 I'm relatively new to Godot networking, so I make no promises that it's good for a full-size game. In fact it's still missing an important feature, which is pausing the game to load data from the server.
 
 When making this, I also tried to follow the best practices laid out in [the Godot documentation](https://docs.godotengine.org/en/stable/getting_started/workflow/best_practices/index.html). I recommend you do too. The more modular and independent everything is, the easier networking will be.