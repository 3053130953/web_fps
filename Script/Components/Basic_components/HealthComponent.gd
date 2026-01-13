extends Node
class_name HealthComponent

# 优化信号：携带 attack_info (包含 source_pos 等)，以便观察者（Agent/UI）做出响应
# previous_health 用于 UI 表现扣血动画
signal damaged(attack_info: Dictionary, current_health: int, previous_health: int)
signal healed(amount: int, current_health: int)
signal died

@export var max_health: int = 100
var current_health: int
var is_dead: bool = false

func _ready() -> void:
	current_health = max_health

# 接收一个 Context 字典，比单纯传 int 更具扩展性（资深开发习惯）
# attack_info 结构示例: { "amount": 10, "source_pos": Vector3, "source_node": Node3D }
func take_damage(attack_info: Dictionary) -> void:
	if is_dead: return
	
	var amount = attack_info.get("amount", 0)
	var previous_health = current_health
	
	current_health -= amount
	current_health = max(0, current_health)
	
	# 广播伤害事件，Agent 会监听这个来播放受击动画
	emit_signal("damaged", attack_info, current_health, previous_health)
	
	if current_health == 0:
		die()

func heal(amount: int) -> void:
	if is_dead: return
	current_health += amount
	current_health = min(current_health, max_health)
	emit_signal("healed", amount, current_health)

func die() -> void:
	if is_dead: return
	is_dead = true
	emit_signal("died")
