extends CharacterBody3D
class_name Agent

# --- 通用信号 ---
signal on_hit(source_node: Node3D, damage: int)
signal on_dead

# --- 核心组件 ---
@export_group("Core Components")
@export var input_controller: InputController
@export var state_machine: StateMachine
@export var animation_tree: AnimationTree
@export var model: Node3D
@export var hurtbox: Hurtbox
@export var health_com: HealthComponent

# --- 物理参数 ---
@export_group("Physics")
@export var speed: float = 10.0
@export var acc_speed: float = 50.0
@export var fir_speed: float = 500.0
@export var jump_velocity: float = 5.0
@export var gravity_scale: float = 1.0

# 缓存 Playback，虽然主要靠参数驱动，但 Attack/Hurt/Jump 这种 OneShot 还是需要 Travel
var playback: AnimationNodeStateMachinePlayback

func _ready() -> void:
	if animation_tree:
		playback = animation_tree["parameters/playback"]
	if health_com:
		health_com.damaged.connect(_on_health_damaged)
		health_com.died.connect(_on_health_died)
	if hurtbox:
		hurtbox.received_damage.connect(_on_take_damage)

func _physics_process(delta: float) -> void:
	# 1. 应用重力 (通用物理)
	if not is_on_floor():
		velocity += get_gravity() * gravity_scale * delta
	
	# 2. 移动由各子类或状态机计算完 velocity 后统一执行
	move_and_slide()
	
func _on_health_damaged(attack_info: Dictionary, _current: int, _previous: int) -> void:
	# 1. 播放受击特效/音效 (Agent层面的通用反馈)
	# SoundManager.play_hit_sfx()
	
	# 2. 状态机流转
	if state_machine:
		# 从 attack_info 字典中解包需要的数据传给 State
		state_machine.transition_to("Hurt", {
			"source_pos": attack_info.get("source_pos", global_position)
		})

func _on_health_died() -> void:
	# 停止物理处理
	set_physics_process(false)
	collision_layer = 0
	
	if state_machine:
		state_machine.transition_to("Death")

func _on_death() -> void:
	emit_signal("on_dead")
	
	# 切换到死亡状态
	if state_machine:
		state_machine.transition_to("Death")
	else:
		# 如果没有状态机，简单的处理可以是 queue_free 或者禁用碰撞
		set_physics_process(false)
		collision_layer = 0
# --- 统一受击接口 ---
func _on_take_damage(amount: int, source_pos: Vector3) -> void:
	# 1. 如果已经死了，通常不处理受击
	if health_com and health_com.is_dead:
		return

	# 2. 扣血
	if health_com:
		health_com.damage(amount)
	
	# 3. 发出 Agent 层的信号
	emit_signal("on_hit", null, amount) 
	
	# 4. 只有"活着"且"有状态机"才进入受击硬直状态
	if state_machine and (not health_com or not health_com.is_dead):
		# [修改处 1] 不要在这里计算方向，直接把攻击源位置传给 State
		# 这样 State 可以根据需要计算方向，或者处理其他逻辑
		state_machine.transition_to("Hurt", {"source_pos": source_pos})
		
		# 原来的代码删除了：
		# var knockback_dir = (global_position - source_pos).normalized()
		# knockback_dir.y = 0 
		# state_machine.transition_to("Hurt", {"knockback_dir": knockback_dir})
func rotate_model(target_angle: float, delta: float, rotation_speed: float = 15.0):
	model.global_rotation.y = lerp_angle(model.global_rotation.y, target_angle, delta * rotation_speed)
