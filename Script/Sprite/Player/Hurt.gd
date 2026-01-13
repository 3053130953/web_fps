extends State

@export var knockback_force: float = 10.0
@export var knockback_upward_force: float = 5.0
@export var stun_duration: float = 0.4

var timer: float = 0.0

func enter(msg := {}):
	# 这是一个具体的 Action，需要强制播放动画
	agent.playback.travel("Hurt") 
	timer = stun_duration
	
	# 重置垂直速度，确保击退跳跃高度一致
	agent.velocity.y = knockback_upward_force
	
	
	# 计算水平击退
	var source_pos = msg.get("source_pos", agent.global_position + agent.global_transform.basis.z)
	var dir = (agent.global_position - source_pos).normalized()
	dir.y = 0
	
	var knockback_vel = dir * knockback_force
	agent.velocity.x = knockback_vel.x
	agent.velocity.z = knockback_vel.z

func physics_update(delta: float):
	# 在受击状态下，通常只需要施加阻力，不允许玩家控制移动
	agent.velocity.x = move_toward(agent.velocity.x, 0, delta * 5)
	agent.velocity.z = move_toward(agent.velocity.z, 0, delta * 5)
	
	timer -= delta
	# 时间到且落地，切回地面状态
	if timer <= 0 and agent.is_on_floor():
		# 这里切回 "Idle" 或 "Ground"，取决于你的状态机里叫什么
		# 哪怕切回去时 velocity 还有一点点，AnimationTree 也会自动处理过渡
		state_machine.transition_to("Ground")
		#state_machine.transition_to("Ground")
