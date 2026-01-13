extends State

# 假设 AnimationTree 中对应的 Node 名字叫 "Shoot"
# 如果是 BlendSpace1D/2D，确保名字对应即可

func enter(_msg := {}):
	# 进入状态时播放射击动画
	# 注意：如果你的 Shoot 是 AnimationTree 的一个 OneShot 节点，
	# 这里可能需要 request OneShot，但作为独立 State，通常意味着这是一个 Loop 动画
	agent.playback.travel("Shoot")

func physics_update(delta: float):
	var input = agent.input_controller
	if not input: return
	
	# --- 1. 状态流转 (Exit Conditions) ---
	
	# 如果松开开火键 -> 回到移动状态 (Move/Idle)
	if not input.is_firing:
		state_machine.transition_to("Move")
		return

	# 优先级处理：换弹、跳跃等是否打断射击？
	# 如果允许"跳射"，则不需要这段；如果射击是地面行为，则保留
	if input.consume_jump() and agent.is_on_floor():
		state_machine.transition_to("Jump")
		return
	
	# 显式处理受击或死亡通常由 Agent._on_take_damage 全局接管，这里不用管
	
	# --- 2. 旋转逻辑 (Rotation) ---
	
	# 射击状态下，角色必须强制朝向准星/摄像机方向 (Strafe)
	# 这里的逻辑复用了你 MoveState 中的方案 A
	if input.spring_arm:
		var cam_rot = input.spring_arm.global_rotation.y
		# 20.0 是旋转速度，射击时通常需要高响应，可以直接写死或用 agent 变量
		agent.rotate_model(cam_rot, delta, 20.0) 
	
	# --- 3. 移动逻辑 (Movement) ---
	
	var dir = input.move_vec
	
	# 射击时的移动惩罚 (例如：仅允许 50% 速度移动)
	# 不要在脚本里加 export var shoot_speed，直接乘系数保持代码整洁
	var current_speed = agent.speed * 0.5 
	
	if dir:
		agent.velocity.x = move_toward(agent.velocity.x, dir.x * current_speed, agent.acc_speed * delta)
		agent.velocity.z = move_toward(agent.velocity.z, dir.z * current_speed, agent.acc_speed * delta)
	else:
		# 停止时的摩擦力处理
		agent.velocity.x = move_toward(agent.velocity.x, 0, agent.fir_speed * delta)
		agent.velocity.z = move_toward(agent.velocity.z, 0, agent.fir_speed * delta)
