#extends PlayerMoveState

#func enter(_msg := {}):
	#player.playback.travel("Idle") # 假设AnimationTree有Idle
	#player.velocity.x = 0
	#player.velocity.z = 0
#
#func physics_update(delta: float):
	## 重力
	#if not player.is_on_floor():
		#player.velocity += player.get_gravity() * delta
	#
	## 状态转换
	#if Input.is_action_just_pressed("Jump") and player.is_on_floor():
		#get_parent().transition_to("Jump")
		#return
	#
	#if Input.is_action_just_pressed("Attack"):
		#get_parent().transition_to("Attack")
		#return
#
	#if Input.get_vector("Left", "Right", "Up", "Down") != Vector2.ZERO:
		#get_parent().transition_to("Run")
