extends CharacterBody3D  # 或 Area3D/RigidBody3D，根据实际需求选择

# 移动参数
@export var speed := 2.0
@export var direction_change_interval := 3.0

var player


# 内部变量
var _current_direction := Vector3.ZERO
var _timer := 0.0

func _ready():
	# 初始化随机方向
	_timer = direction_change_interval
	_randomize_direction()
	

func _physics_process(delta):
	# 更新计时器
	player = get_player()
	if not is_on_floor():
		velocity += get_gravity() * delta
		print(velocity.y)
	
	if player:
		_look_player(player)
	else:
		_spare_time(delta)
	

func _spare_time(delta):
	
	_timer -= delta
	if _timer <= 0:
		_randomize_direction()
		_timer = direction_change_interval
	#print(velocity.y)
	# 应用移动
	velocity.x = _current_direction.x * speed
	velocity.z = _current_direction.z * speed
	print(velocity)
	move_and_slide()

func _randomize_direction():
	# 生成随机水平方向（Y轴为0，保持水平移动）
	_current_direction = Vector3(
		randf_range(-1.0, 1.0),
		0,
		randf_range(-1.0, 1.0)
	).normalized()
	
	# 可选：让怪物面朝移动方向
	if _current_direction.length() > 0.1:
		var target_position = global_transform.origin + _current_direction
		look_at(target_position, Vector3.UP)
		rotate_y(PI)  # 这样就将正面从-Z转到了Z

func get_player():
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		return players[0]
	return null

func _look_player(player):
	
	var direction = (player.global_transform.origin - global_transform.origin).normalized()
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	move_and_slide()
		# 面向玩家
	look_at(Vector3(player.global_transform.origin.x, global_transform.origin.y, player.global_transform.origin.z), Vector3.UP)
	rotate_y(PI)
	
	# 连接hurtbox的信号
	

# 受伤函数
