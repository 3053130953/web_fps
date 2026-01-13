extends State
class_name EmoteState

# 导出动画名称，方便复用或修改 Key
@export var current_anim: String = "Wave"


func enter(msg := {}):
	# 1. 彻底刹车：进入打招呼状态瞬间，清理所有水平速度
	agent.velocity.x = 0
	agent.velocity.z = 0
	if msg.has("anim_name"):
		current_anim = msg["anim_name"]
	else:
		current_anim = "Wave" # fallback
	# 2. 播放动画：直接使用 Agent 基类缓存好的 playback
	agent.playback.travel(current_anim)

func physics_update(_delta: float):
	# 1. 持续锁定水平移动
	# Agent._physics_process 会处理重力(Y轴)，所以这里只锁定 X/Z
	agent.velocity.x = 0
	agent.velocity.z = 0
	
	if Input.get_vector("Left", "Right", "Up", "Down") != Vector2.ZERO or Input.is_action_just_pressed("Jump"):
		# 如果是 Sit 这种循环动画，通常靠移动来打断
		state_machine.transition_to("Ground")
	# 资深提示：这里不需要调用 move_and_slide，因为 Agent._physics_process 会统一调用
	# 这里也不需要处理转向，打招呼通常是锁定朝向的

# --- 事件回调 ---
# 对应 Player._on_anim_event_finished -> StateMachine -> 这里
# 请确保 AnimationPlayer 的 "Wave" 动画末尾有 Call Method Track 调用 _on_anim_event_finished
func on_animation_finished():
	state_machine.transition_to("Ground")
