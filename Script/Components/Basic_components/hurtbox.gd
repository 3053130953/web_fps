extends Area3D
class_name Hurtbox

# 显式依赖 HealthComponent
@export var health_com: HealthComponent
@export var cooldown: float = 1.0
@export var timer: Timer

var is_invulnerable: bool = false

func _ready() -> void:
	if timer:
		timer.timeout.connect(_on_timer_timeout)
		timer.one_shot = true
	
	if not health_com:
		health_com = owner.get_node_or_null("%HealthComponent")
		if not health_com:
			health_com = owner.find_child("HealthComponent")

# [修改] 接口参数变更：直接接收由 Hitbox 构建好的 Context 字典
# 这样 Hurtbox 不需要关心伤害是怎么算出来的，它只负责传递
func receive_hit(attack_info: Dictionary) -> void:
	if is_invulnerable or is_queued_for_deletion(): return
	if not health_com: return 
	
	start_invulnerability()
	
	# [修改] 直接驱动数据层，不再进行数据组装
	health_com.take_damage(attack_info)

# [删除] 删除了 _on_body_entered。
# 理由：根据你的要求，伤害逻辑应由 Hitbox 主动发起。
# 如果敌人身体碰撞需要造成伤害，应在敌人身上挂一个与碰撞体形状一致的 Hitbox。

func start_invulnerability():
	is_invulnerable = true
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
	if timer: timer.start(cooldown)

func _on_timer_timeout() -> void:
	is_invulnerable = false
	set_deferred("monitorable", true)
	set_deferred("monitoring", true)
