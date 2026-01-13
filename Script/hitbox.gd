extends Area3D

@export var attack_timer:Timer

var damage:int

@onready var animationtree:AnimationTree = $"../AnimationTree"
var play_back:AnimationNodeStateMachinePlayback

var player_in_range: bool = false
var player_body: Node3D = null

func _ready() -> void:
	
	play_back = animationtree.get("parameters/playback")
	if attack_timer:
		attack_timer.timeout.connect(_on_attack_timer_timeout)


func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("Hurtbox"):
		area.take_damage(self,damage)
		player_in_range = true
		player_body = area

		# 立即执行一次攻击
		play_back.travel("attack-melee-right")
		
		# 启动计时器，设置攻击间隔（例如2秒）
		if attack_timer:
			attack_timer.start(2.0)  # 每2秒攻击一次

func _on_area_exited(area: Area3D) -> void:
	if area.is_in_group("Hurtbox"):
		
		player_in_range = false
		player_body = null
		
		# 停止计时器
		if attack_timer:
			attack_timer.stop()

# 计时器超时时的处理函数
func _on_attack_timer_timeout():
	if player_in_range and player_body:
		# 执行攻击动画
		play_back.travel("attack-melee-right")

		# 重新启动计时器，实现周期性攻击
		attack_timer.start(2.0)  # 保持相同的间隔
