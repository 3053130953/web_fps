# res://Scripts/Resources/weapon_stats.gd
class_name WeaponStats
extends Resource

@export_group("Visuals")
@export var weapon_name: String = "Rifle"
@export var mesh: PackedScene  # 枪的模型
@export var shoot_sound: AudioStream
@export var reload_sound: AudioStream

@export_group("Combat Stats")
@export var damage: float = 10.0
@export var fire_rate: float = 0.1 # 射击间隔（秒）
@export var max_ammo: int = 30
@export var max_range: float = 100.0 # 射程
@export var is_automatic: bool = true # 是否全自动
@export var spread: float = 0.05 # 射击散布（后坐力基础）
