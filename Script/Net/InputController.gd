class_name InputController
extends Node

enum ControlMode {
	HUMAN,          # 本地玩家控制 (单机 或 联机主机)
	NETWORK_PUPPET, # 网络镜像 (联机中的其他玩家)
	AI              # 人工智能
}
# --- 外部引用 ---
@export_group("References")
@export var spring_arm: SpringArm3D

@export_group("Settings")
# [新增] 允许手动强制指定模式，默认为 "Auto" (自动检测)
@export var force_mode: ControlMode = ControlMode.HUMAN
@export var use_auto_config: bool = true
# --- [新增] 输入数据包 (这也是你需要放入 MultiplayerSynchronizer 里的变量) ---
# 状态机将直接读取这些变量，而不是读取 Input.is_action...
var move_vec: Vector3 = Vector3.ZERO
var is_sprinting: bool = false
var is_aiming: bool = false
var is_firing: bool = false

# [新增] 动作缓冲 (Action Buffer)
# 对于 Jump/Attack 这种 One-shot 信号，单纯的 bool 同步可能会丢帧
# 在严谨的架构中，通常使用 RPC 或 帧序号，这里使用"请求标记"方式简化演示
var jump_request: bool = false
var attack_request: bool = false
var kick_request: bool = false
var emote_wave_request: bool = false
var emote_sit_request: bool = false
var exc_request: bool = false

var _current_mode: ControlMode

func _ready() -> void:
	_setup_control_mode()
	# [新增] 只有拥有权限的客户端才开启处理
func _setup_control_mode() -> void:
	if not use_auto_config:
		_current_mode = force_mode
		return

	# [核心架构逻辑] 自动判断模式
	if multiplayer.has_multiplayer_peer():
		# 如果连上了网
		if is_multiplayer_authority():
			_current_mode = ControlMode.HUMAN # 我是本机
		else:
			_current_mode = ControlMode.NETWORK_PUPPET # 我是别人的镜像
	else:
		# 如果没联网 (单机模式)
		# 默认是 HUMAN，除非你想写 AI，可以在生成时手动改为 AI
		_current_mode = ControlMode.HUMAN

	# 只有 HUMAN 和 AI 需要在本地进行处理
	# PUPPET 只需要等着数据被同步过来，不需要 update
	var is_active_controller = (_current_mode == ControlMode.HUMAN or _current_mode == ControlMode.AI)
	set_process(is_active_controller)
	set_physics_process(is_active_controller)
	
	# 只有本机人类需要处理鼠标捕获
	if _current_mode != ControlMode.HUMAN:
		set_process_unhandled_input(false)
	
	print("InputController initialized as: ", ControlMode.keys()[_current_mode])
	#var is_auth = is_multiplayer_authority()
	#set_process(is_auth)
	#set_physics_process(is_auth)
	#
	## 如果不是本机控制，确保鼠标不被锁定 (防止两个窗口抢鼠标)
	#if not is_auth:
		#set_process_unhandled_input(false)

func _physics_process(delta: float) -> void:
	# 1. 持续性输入 (Continuous Input)
	_process_movement()
	
	# 2. 状态性输入
	is_aiming = Input.is_action_pressed("aim")
	is_firing = Input.is_action_pressed("fire")
	# 3. 瞬发性输入 (One-shot Input)
	# 注意：这些请求需要在被状态机消费后重置为 false
	if Input.is_action_just_pressed("Jump"): jump_request = true
	if Input.is_action_just_pressed("Attack"): attack_request = true
	if Input.is_action_just_pressed("Kick"): kick_request = true
	if Input.is_action_just_pressed("reload"): exc_request = true
	if Input.is_action_just_pressed("emote_wave"): emote_wave_request = true
	if Input.is_action_just_pressed("emote_sit"): emote_sit_request = true
	#if Input.is_action_just_pressed("fire"): fire_request = true
	#if Input.is_action_just_pressed("aim"): aim_request = true
	#if Input.is_action_just_released("aim"): aim_request = false
func _process_movement() -> void:
	# [修改] 计算逻辑移入 InputController，保持 Player 纯净
	var raw_input = Input.get_vector("Left", "Right", "Up", "Down")
	
	if raw_input == Vector2.ZERO:
		move_vec = Vector3.ZERO
		return

	var dir = Vector3.ZERO
	if spring_arm:
		dir.x = raw_input.x
		dir.z = raw_input.y
		# 基于摄像机视角的转换
		dir = dir.rotated(Vector3.UP, spring_arm.rotation.y).normalized()
	else:
		# Fallback if no camera
		dir = Vector3(raw_input.x, 0, raw_input.y).normalized()
	#print(dir)
	move_vec = dir

# [新增] 供状态机调用：消费动作请求
# 这是一个非常常用的模式，防止动作被重复执行
func consume_jump() -> bool:
	if jump_request:
		jump_request = false
		return true
	return false

func consume_attack() -> bool:
	if attack_request:
		attack_request = false
		return true
	return false

func consume_kick() -> bool:
	if kick_request:
		kick_request = false
		return true
	return false
	
func consume_exc() -> bool:
	if exc_request:
		exc_request = false
		return true
	return false
	
func consume_emote_wave() -> bool:
	if emote_wave_request:
		emote_wave_request = false
		return true
	return false
	
func consume_emote_sit() -> bool:
	if emote_sit_request:
		emote_sit_request = false
		return true
	return false

#func consume_fire() -> bool:
	#if fire_request:
		#fire_request = false
		#return true
	#return false
#
#func consume_aim() -> bool:
	#if !aim_request:
		#aim_request = true
		#return true
	#return false
