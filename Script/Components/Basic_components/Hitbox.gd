extends Area3D
class_name Hitbox

# 造成的伤害量
@export var damage: int = 10
# 攻击源（通常设为持有武器的角色），用于防止自己打自己，或计算击退方向
@export var source_node: Node3D

# 可选：命中后的回调信号（比如播放命中音效/粒子）
signal on_hit_successfully(target: Node3D)

func _ready() -> void:
	# 自动绑定区域进入信号
	area_entered.connect(_on_area_entered)
	
	# 如果没有手动指定 source_node，尝试自动获取根节点
	if not source_node:
		source_node = owner

func _on_area_entered(area: Area3D) -> void:
	# 核心逻辑：只认 Hurtbox
	if area is Hurtbox:
		# 检查是否打到了自己 (防止 Hitbox 和 Hurtbox 在同一个父节点下误伤)
		if source_node and area.owner == source_node:
			return
		
		var attack_info = {
			"amount": damage,
			"source_node": source_node,
			# 使用 Hitbox 自身的位置作为伤害来源点，这对计算击退方向更精确
			"source_pos": global_position 
			# 扩展性：未来可以在这里添加 "element": "fire", "crit": true 等
		}
		# 调用 Hurtbox 的接口
		area.receive_hit(attack_info)
		
		# 发出命中信号
		emit_signal("on_hit_successfully", area.owner)
