#extends CharacterBody3D
#class_name Player
#
#static var instance:Player
#
#@export var SPEED = 10
#@export var JUMP_VELOCITY = 5
#@export var camer:Camera3D
#
#@export var ACC_SPEED:float
#
#@export var hurtbox:Area3D
#@export var hurt_timer:Timer
#@export var hurt_cooldown:float
#
#@export var knockback_upward_force:float
#@export var knockback_force:float
#
#
#var is_invulnerable:bool
#
#@export var model:Node3D
#var target_angle:float = PI
#
#var spawn_pos:Vector3
#var playback:AnimationNodeStateMachinePlayback
#
#@onready var animation_tree: AnimationTree = $AnimationTree
#
#var can_move = true
#
#func _ready() -> void:
	#if instance == null:
		#instance = self
	#else:
		#queue_free()
	#playback = animation_tree["parameters/playback"]
	#spawn_pos = position
#
	#
#
##	
#func _process(delta: float) -> void:
	#var rota_angle = camer.global_rotation.y
	#var input_dir := Input.get_vector("Left", "Right", "Up", "Down")
	#var input_angle = atan2(input_dir.x , input_dir.y)
	#
	#if input_dir != Vector2.ZERO && !Input.is_action_pressed("Yes"):
		#target_angle = rota_angle + input_angle
	#elif Input.is_action_pressed("Yes"):
		#target_angle = rota_angle + PI
	#
	#model.global_rotation.y = lerp_angle(model.global_rotation.y,target_angle,delta * 15)
	##print(input_angle)
#func _physics_process(delta: float) -> void:
	##if !can_move:
		##return
	#if not is_on_floor():
		#velocity += get_gravity() * delta
	#
	## Handle jump.
	##if Input.is_action_pressed("Yes") and is_on_floor():
		##playback.travel("holding-left")
		##return
	#if Input.is_action_just_pressed("Hello") and is_on_floor():
		#playback.travel("Emote1")
		##set_physics_process(false)
	#if Input.is_action_just_pressed("Attack") and is_on_floor():
		#playback.travel("attack-melee-right")
	#elif Input.is_action_just_pressed("Kick") and is_on_floor():
		#playback.travel("Kick")
	##if Input.is_action_just_released("Yes") and is_on_floor():
		##playback.travel("emote-yes")
	#if Input.is_action_just_pressed("Jump") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
	##print("move")
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var input_dir := Input.get_vector("Left", "Right", "Up", "Down")
	#
	#var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#direction = direction.rotated(Vector3.UP,camer.global_rotation.y)
	#if direction:
		#velocity.x = move_toward(velocity.x, direction.x * SPEED, ACC_SPEED*delta)
		#velocity.z = move_toward(velocity.z, direction.z * SPEED, ACC_SPEED*delta)
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.z = move_toward(velocity.z, 0, SPEED)
	#
	#move_and_slide()
