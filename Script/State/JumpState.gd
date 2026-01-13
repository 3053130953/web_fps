extends State
# 挂载到 StateMachine/Jump 节点

func enter(_msg := {}):
	# 施加跳跃力
	agent.velocity.y = agent.jump_velocity
	# 播放跳跃动画 (假设你的 StateMachine 里有一个叫 "Jump" 的节点)
	agent.playback.travel("Jump")

func physics_update(delta: float):
	# 1. 检测落地转换
	# 注意：刚刚起跳的一瞬间 is_on_floor() 可能还为 true，或者 velocity.y > 0
	# 所以通常判断：如果在下降中(y<0)且落地，或者落地且一段时间后
	if agent.is_on_floor():
		if agent.velocity.y <= 0: # 只有下落触地才算结束
			state_machine.transition_to("Ground")
			return

	var input = agent.input_controller
	if not input: return
	# 2. 空中移动控制 (Air Control)
	# 既然是资深开发，通常空中控制力会比地面小，这里我复用了地面的逻辑，
	# 你可以乘以一个 air_control_factor (比如 0.5) 来调整手感
	#var player = agent as Player
	#var direction = player.get_cam_relative_dir()
	var direction = input.move_vec
	
	if direction:
		agent.velocity.x = move_toward(agent.velocity.x, direction.x * agent.speed, agent.acc_speed * delta)
		agent.velocity.z = move_toward(agent.velocity.z, direction.z * agent.speed, agent.acc_speed * delta)
		
		# 空中是否允许转向？通常允许
		var target_angle = atan2(direction.x, direction.z)
		agent.rotate_model(target_angle, delta)
	else:
		# 空中阻力通常较小，不容易停下
		var air_friction = agent.fir_speed * 0.1 # 举例：空中阻力只有地面的10%
		agent.velocity.x = move_toward(agent.velocity.x, 0, air_friction * delta)
		agent.velocity.z = move_toward(agent.velocity.z, 0, air_friction * delta)
	
	# 重力由 Agent._physics_process 统一处理，这里不用写
