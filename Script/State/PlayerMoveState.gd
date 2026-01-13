extends State
# 这里的名字可以是 PlayerGroundState 或者 PlayerMoveState
# 它涵盖了 Idle 和 Run 的所有逻辑

func enter(_msg := {}):
	# 不再调用 playback.travel("Idle")
	# AnimationTree 会监测到 state 切换完成，并根据 velocity 自动处理
	pass

func physics_update(delta: float):
	# 1. 状态转换 (Priority: Jump > Attack)
	var input = agent.input_controller
	if not input: return
	
	if input.consume_emote_wave(): 
		_transition_to_emote("Wave")
		return
	elif input.consume_emote_sit():
		_transition_to_emote("Sit")
		return
	
	elif input.consume_jump() and agent.is_on_floor():
		state_machine.transition_to("Jump")
		return
	
	elif input.consume_attack():
		state_machine.transition_to("Attack")
		return
	elif input.consume_kick():
		state_machine.transition_to("Kick")
		return
	elif input.consume_fire():
		state_machine.transition_to("Kick")
		return
	# 2. 处理移动逻辑
	# 注意：这里的 agent 其实就是 Player 实例，强转一下是为了代码提示，或者在 Base State 里处理强转
	#print("here")
	#var player = agent as Player 
	#var direction = player.get_cam_relative_dir()
	var direction = input.move_vec
	var is_aiming = input.is_aiming
	
	var current_speed = agent.speed
	if is_aiming:
		current_speed *= 0.5 # 比如瞄准时速度减半
		
	if direction:
		# 加速
		#print("add")
		agent.velocity.x = move_toward(agent.velocity.x, direction.x * current_speed, agent.acc_speed * delta)
		agent.velocity.z = move_toward(agent.velocity.z, direction.z * current_speed, agent.acc_speed * delta)
		if is_aiming:
			# 方案 A：瞄准时，身体始终朝向摄像机前方 (Strafe 移动)
			# 获取摄像机水平朝向
			#var cam_forward = -agent.global_transform.basis.z # 或者从 Camera 获取
			if agent.input_controller.spring_arm: # 假设你能获取到摄像机或 SpringArm
				var cam_rot = agent.input_controller.spring_arm.global_rotation.y
				agent.rotate_model(cam_rot, delta, 20.0) # 快速旋转对齐摄像机
		else:
			# 方案 B：不瞄准时，身体朝向移动方向
			var target_angle = atan2(direction.x, direction.z)
			agent.rotate_model(target_angle, delta)
		# 旋转模型
		#var target_angle = atan2(direction.x, direction.z)
		#agent.rotate_model(target_angle, delta)
	else:
		# 减速 / 停止
		#print("del")
		agent.velocity.x = move_toward(agent.velocity.x, 0, agent.fir_speed * delta) # 减速通常用摩擦力，这里简化处理
		agent.velocity.z = move_toward(agent.velocity.z, 0, agent.fir_speed * delta)
		if is_aiming and agent.input_controller.spring_arm:
			var cam_rot = agent.input_controller.spring_arm.global_rotation.y
			agent.rotate_model(cam_rot, delta, 20.0)
	# 注意：move_and_slide 在 Agent._physics_process 里调用，这里只修改 velocity
func _transition_to_emote(anim_name: String) -> void:
	# 将目标动画名称通过 msg 字典传递给 EmoteState
	state_machine.transition_to("Emote", { "anim_name": anim_name })
