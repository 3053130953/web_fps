extends Agent
class_name Player

static var instance: Player
#@export var camer: Camera3D

@export var weapon_manager:WeaponManager
# 注意：根据你的截图，RayCast3D 在 Camera3D 下面
@export var aim_raycast:RayCast3D

#@export var input_controller: InputController

func _ready() -> void:
	if not input_controller:
		push_error("Agent: InputController not assigned!")
	if instance == null: instance = self
	else: queue_free()
	super._ready() # 务必调用父类初始化
	if weapon_manager and aim_raycast:
		weapon_manager.init_laser(aim_raycast)

func _physics_process(delta: float) -> void:
	# 1. 调用父类 Agent 的物理逻辑 (处理重力、状态机更新、move_and_slide)
	super._physics_process(delta)
	
	# 2. [新增] 同步 InputController 的状态到 WeaponManager
	if input_controller and weapon_manager:
		_sync_weapon_input()

func _sync_weapon_input() -> void:
	# 同步瞄准状态 (bool)
	weapon_manager.set_aiming_state(input_controller.aim_request)
	
	# 同步开火状态 (bool - 按住)
	# WeaponManager 内部会根据全自动/半自动处理这个 bool
	weapon_manager.set_fire_input(input_controller.fire_request)

#func _set_weapon():
	#if input_controller and weapon_manager:
		## 同步瞄准状态
		##print("22")
		#weapon_manager.set_aiming_state(input_controller.is_aiming)
		## 同步开火状态
		#weapon_manager.set_fire_input(input_controller.is_firing)


func _on_anim_event_finished():
	# 只有当前状态有这个方法时才调用（避免在跑动时误触其他事件）
	if state_machine.state.has_method("on_animation_finished"):
		state_machine.state.on_animation_finished()
