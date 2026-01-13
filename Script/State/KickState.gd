extends State
# 挂载到 StateMachine/Attack 节点

# 攻击摩擦力倍率
const ATTACK_FRICTION_MULT = 2.0 

# 导出攻击动画的名称，用于获取时长或匹配
@export var animation_name: String = "Kick"
# 如果不想用动画帧事件，可以手动指定持续时间作为兜底
@export var fixed_duration: float = 0.5 
# 是否使用自动计时（如果不方便修改动画文件，设为 true）
@export var use_timer_fallback: bool = false

var _has_finished: bool = false

func enter(_msg := {}):
	_has_finished = false
	
	# 1. 刹车：攻击时通常瞬间失去大部分速度
	agent.velocity.x = 0
	agent.velocity.z = 0
	
	# 2. 播放动画
	agent.playback.travel(animation_name)
	
	# [方案 A - 资深推荐]：依赖动画帧事件调用 finish_attack()
	# 这种方式最精准，能配合动画的实际动作（比如收刀动作做完才结束）
	
	# [方案 B - 代码纯逻辑]：如果你不想动 AnimationPlayer，开启 use_timer_fallback
	# 或者尝试动态获取动画长度（需要 Agent 暴露 AnimationPlayer）
	if use_timer_fallback:
		# 创建一个不再依赖帧的计时器
		get_tree().create_timer(fixed_duration).timeout.connect(finish_attack)

func physics_update(delta: float):
	# 1. 应用重力 (Agent 通用逻辑通常只处理了基本的，这里确保空中攻击也能落地)
	if not agent.is_on_floor():
		agent.velocity += agent.get_gravity() * delta
		
	# 2. 施加高强度的摩擦力 (防止滑步)
	# 注意：如果你 Agent 里的变量是 acc_speed，请替换下面的 agent.acc_speed
	# 你的上文代码中用了 agent.fir_speed，如果是笔误请修正
	var friction = agent.acc_speed * ATTACK_FRICTION_MULT
	agent.velocity.x = move_toward(agent.velocity.x, 0, friction * delta)
	agent.velocity.z = move_toward(agent.velocity.z, 0, friction * delta)
	
	# [方案 C - 轮询检测（不推荐但可用）]
	# 检测 AnimationTree 是否已经自己切回了 Idle/Run
	# 警告：travel 是异步的，刚进入的那一帧可能 current_node 还没变，所以需要 _has_finished 标记防止误判
	# 且 AnimationTree 混合期间 get_current_node 结果可能不稳定
	# var current = agent.playback.get_current_node()
	# if current != animation_name:
	# 	finish_attack()

# --- 核心回调函数 ---
# 必须在 AnimationPlayer 的 "Attack" 动画末尾添加一个 Call Method Track 指向此函数
# 或者由计时器调用
func finish_attack():
	if _has_finished: return # 防止多次调用
	_has_finished = true
	
	# 切换回地面状态
	# 这里的 "Ground" 对应你合并了 Idle/Run 的那个状态节点名
	state_machine.transition_to("Ground")
