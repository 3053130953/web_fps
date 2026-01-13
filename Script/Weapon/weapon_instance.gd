# res://Scenes/Weapons/weapon_instance.gd
class_name WeaponInstance
extends Node3D

# 定义信号，通知Manager子弹射出了，或者需要换弹
signal weapon_fired(cur_ammo)
signal weapon_out_of_ammo

@export var stats: WeaponStats

@onready var mesh_instance: Node3D = $mesh
@onready var muzzle_point: Marker3D = $mesh/Marker3D
@onready var cooldown_timer: Timer = $Timer/CooldownTimer
@export var audio_player: AudioStreamPlayer3D
@export var animation_player: AnimationPlayer

var current_ammo: int
var is_reloading: bool = false

func _ready():
	# 初始化枪械数据
	if stats:
		initialize(stats)

func initialize(new_stats: WeaponStats):
	stats = new_stats
	var new_weapon_mode = stats.mesh.instantiate()
	if mesh_instance: mesh_instance.add_child(new_weapon_mode)
	current_ammo = stats.max_ammo
	if cooldown_timer:
		cooldown_timer.wait_time = stats.fire_rate
		cooldown_timer.one_shot = true

# 尝试射击（由 Manager 调用）
func attempt_shoot() -> bool:
	if is_reloading or not cooldown_timer.is_stopped():
		return false
	
	if current_ammo <= 0:
		emit_signal("weapon_out_of_ammo")
		reload()
		return false
	
	# 执行射击逻辑
	current_ammo -= 1
	cooldown_timer.start()
	play_effects()
	
	emit_signal("weapon_fired", current_ammo)
	return true # 返回 true 表示射击成功，Manager 可以进行射线检测

func play_effects():
	# 1. 播放声音
	if stats.shoot_sound:
		audio_player.stream = stats.shoot_sound
		audio_player.play()
	
	# 2. 生成枪口火光 (此处省略具体粒子代码)
	# var flash = muzzle_flash_scene.instantiate()
	# muzzle_point.add_child(flash)

# 获取枪口的世界坐标（给射线检测用，或者给子弹轨迹用）
func get_muzzle_position() -> Vector3:
	return muzzle_point.global_position

func reload() -> void:
	if is_reloading or current_ammo == stats.max_ammo: return
	
	is_reloading = true
	emit_signal("reload_started")
	
	# 这里简单模拟，实际上应该等待 AnimationPlayer 的 finished 信号
	await get_tree().create_timer(1.5).timeout 
	
	current_ammo = stats.max_ammo
	is_reloading = false
	emit_signal("reload_finished")
