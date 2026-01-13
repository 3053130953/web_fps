class_name WeaponManager
extends Node3D

@onready var laser_dot: Node3D = $LaserDot # ### [修改] 类型宽泛化，适应MeshInstance3D或其他
# [新增] 引用场景里的红点

var aim_raycast: RayCast3D
var current_weapon: WeaponInstance # ### [新增] 持有的当前武器实例
var is_aiming: bool = false
var is_trigger_held: bool = false # ### [新增] 用于全自动武器

@export var weapon_scene_proto:PackedScene
@export var stats: WeaponStats
@export var impact_effect_scene: PackedScene

func _ready():
	# 确保一开始红点是隐藏的
	if laser_dot:
		laser_dot.visible = false
	equip_weapon(stats)
# [新增] 初始化函数，由 Player 调用
func init_laser(ray: RayCast3D):
	aim_raycast = ray
	# 设置射线的长度为100米 (根据你的需求)
	aim_raycast.target_position = Vector3(0, 0, -100) 
	print(ray)
func equip_weapon(data: WeaponStats) -> void:
	# 卸载旧武器
	if current_weapon:
		current_weapon.queue_free()
	
	# 实例化新武器
	var new_wep = weapon_scene_proto.instantiate() as WeaponInstance
	
	# 挂载到指定位置（如果没有指定骨骼附件，就挂在 Manager 下）
	add_child(new_wep)
	
	# 初始化并保存引用
	new_wep.initialize(data)
	current_weapon = new_wep
	
func set_fire_input(is_pressed: bool) -> void:
	if is_pressed:
		print(is_pressed)
	is_trigger_held = is_pressed
	if is_pressed and current_weapon and not current_weapon.stats.is_automatic:
		_attempt_fire_logic()
# [新增] 核心逻辑：每帧更新红点位置
func _physics_process(delta: float) -> void: # ### [修改] 射击判定建议放在 physics_process
	# 1. 处理全自动射击
	if is_trigger_held and current_weapon and current_weapon.stats.is_automatic:
		_attempt_fire_logic()
	# 2. 处理激光指示器 (整合了你原本的 _process 逻辑)
	_update_laser(delta)
	
func _attempt_fire_logic() -> void:
	# 第一步：让武器尝试“开火”（扣子弹、播声音、算冷却）
	# 如果武器正在换弹或冷却中，它会返回 false
	if current_weapon.attempt_shoot():
		# 第二步：如果成功开火，计算命中 (Hitscan)
		_perform_hitscan_check()

func _perform_hitscan_check() -> void:
	if not aim_raycast: return
	
	# 强制更新射线，确保射击瞬间是最新的摄像机朝向
	aim_raycast.force_raycast_update()
	#print(aim_raycast.rotation)
	if aim_raycast.is_colliding():
		var collider = aim_raycast.get_collider()
		print(collider)
		var hit_point = aim_raycast.get_collision_point()
		
		print(hit_point)
		# print("Hit:", collider.name) # Debug
		
		# 造成伤害接口
		#if collider.has_method("take_damage"):
			#collider.take_damage(current_weapon.stats.damage)
			
		# 生成击中特效（从 WeaponInstance 获取弹孔/火花预制体，或者在这里直接生成）
		_spawn_impact_effect(hit_point, aim_raycast.get_collision_normal())
		
func _update_laser(_delta: float) -> void:
	if not laser_dot: return
	print(is_aiming)
	if is_aiming and aim_raycast:
		aim_raycast.force_raycast_update() # 如果性能敏感，可考虑每隔几帧更新，但在射击游戏建议实时
		
		if aim_raycast.is_colliding():
			var point = aim_raycast.get_collision_point()
			var normal = aim_raycast.get_collision_normal()
			laser_dot.global_position = point + (normal * 0.02) # 浮起一点防Z-fighting
			
			# 处理红点朝向，使其贴合表面（可选，增加高级感）
			if normal.is_normalized() and normal != Vector3.UP:
				laser_dot.look_at(point + normal, Vector3.UP)
				laser_dot.rotate_object_local(Vector3.RIGHT, -PI/2) # 视你的Mesh朝向而定
			
			laser_dot.visible = true
		else:
			laser_dot.visible = false # 没打中东西（比如打天空）也隐藏
	else:
		if laser_dot.visible: laser_dot.visible = false

func set_aiming_state(active: bool):
	is_aiming = active
#func _process(delta):

func _spawn_impact_effect(pos: Vector3, normal: Vector3) -> void:
	if not impact_effect_scene:
		return
	
	# 1. 实例化
	var effect = impact_effect_scene.instantiate()
	# 2. 添加到场景根节点
	# 注意：不要 add_child(effect) 到 WeaponManager 下，否则特效会随着枪移动
	get_tree().current_scene.add_child(effect)
	
	# 3. 设置位置
	effect.global_position = pos
	effect.emitting = true
	#print(effect.global_position)
	# 4. 设置朝向：让特效的 -Z 轴（通常是前方）对齐法线方向
	# 这是一个处理 look_at 遇到平行向量报错的标准写法
	if normal.is_equal_approx(Vector3.UP):
		effect.look_at(pos + normal, Vector3.RIGHT)
	elif normal.is_equal_approx(Vector3.DOWN):
		effect.look_at(pos + normal, Vector3.RIGHT)
	else:
		effect.look_at(pos + normal, Vector3.UP)
		
	# 5. (可选) 如果你的特效场景里没有自动销毁脚本，可以在这里加一个定时器保险
	# 2秒后自动清除，防止场景里堆积太多垃圾
	get_tree().create_timer(2.0).timeout.connect(effect.queue_free)
