class_name StateMachine extends Node

@export var initial_state: State
@onready var state: State = initial_state

func _ready() -> void:
	await owner.ready
	for child in get_children():
		if child is State:
			child.agent = owner
			child.state_machine = self # [修改处] 必须加上这行，否则子状态无法跳转
	
	if state:
		state.enter()

func _process(delta: float) -> void:
	state.update(delta)

func _physics_process(delta: float) -> void:
	
		state.physics_update(delta)
	
func transition_to(target_state_name: String, msg: Dictionary = {}) -> void:
	if not has_node(target_state_name):
		push_error("StateMachine: State not found -> " + target_state_name)
		return

	state.exit()
	state = get_node(target_state_name)
	state.enter(msg)
