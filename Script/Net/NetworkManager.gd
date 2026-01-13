extends Node

# 端口号
const PORT = 7777
# 玩家预制体路径 (请根据您的实际路径确认)
const PLAYER_SCENE_PATH = "res://Scenes/Player/Godot.tscn"

var peer = ENetMultiplayerPeer.new()
var player_scene = preload(PLAYER_SCENE_PATH)

func _ready():
	# 可以在这里处理命令行参数，用于无头服务器自动启动等
	pass

# --- 主机模式 (Host) ---
# 服务器同时也是玩家
func start_host():
	var error = peer.create_server(PORT)
	if error != OK:
		printerr("Failed to create server: ", error)
		return
	
	multiplayer.multiplayer_peer = peer
	print("Server started!")
	
	# 监听玩家连接信号
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	# 生成主机自己的角色 (ID: 1)
	spawn_player(1)

# --- 客户端模式 (Client) ---
func start_client(ip_address: String = "127.0.0.1"):
	var error = peer.create_client(ip_address, PORT)
	if error != OK:
		printerr("Failed to create client: ", error)
		return
		
	multiplayer.multiplayer_peer = peer
	print("Connecting to server at ", ip_address)

# --- 生成逻辑 (仅在服务器运行) ---
func spawn_player(peer_id: int):
	# 只有服务器有权在 MultiplayerSpawner 监控的节点下添加子节点
	if not multiplayer.is_server():
		return

	print("Spawning player: ", peer_id)
	var player = player_scene.instantiate()
	# [重要] 名字必须是 ID 字符串，这是 MultiplayerSpawner 识别对应关系的关键
	player.name = str(peer_id)
	
	# 将玩家放入 World 场景中存放玩家的容器
	# 假设您的场景树结构是 World -> PlayersContainer
	var container = get_node_or_null("/root/World/PlayersContainer")
	if container:
		container.add_child(player)
		# [核心权限设置]
		# 1. 整个 Player 节点默认归服务器 (Authority 1)，用于同步位置
		# 2. 找到 InputController 下的同步器，将权限转交给对应的玩家
		var input_sync = player.get_node("InputController/InputSynchronizer")
		if input_sync:
			input_sync.set_multiplayer_authority(peer_id)
	else:
		printerr("PlayersContainer not found!")

func _on_peer_connected(id: int):
	# 当新客户端连接时，为他生成角色
	spawn_player(id)

func _on_peer_disconnected(id: int):
	# 玩家断开时，销毁对应的节点
	var container = get_node_or_null("/root/World/PlayersContainer")
	if container and container.has_node(str(id)):
		container.get_node(str(id)).queue_free()
