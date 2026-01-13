extends Node3D
class_name Gamemanager

static var instance : Gamemanager



@export var collected_items:Dictionary[String,int] = {
	"DIAMOND" : 0,
	"COIN" : 0,
	"CHERRY" : 0,
}

@export var item_labels: Dictionary[String,Label] = {
	"DIAMOND" : null,
	"COIN" : null,
	"CHERRY" : null,
}

var flags:Array[Flag] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if instance == null:
		instance = self
	else:
		queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _get_near():
	if flags.is_empty():
		return Player.instance.spawn_pos
	var closet_distance = flags[0].position.distance_squared_to(Player.instance.position)
	var closet_flag:Flag = flags[0]
	
	for flag in flags:
		var flag_distance = flag.position.distance_squared_to(Player.instance.position)
		if flag_distance < closet_distance:
			closet_flag = flag
			closet_distance = flag_distance

	return closet_flag.position + Vector3(0,5,0)


func _spawn_player(body: Node3D) -> void:
	if body is CharacterBody3D:
		Player.instance.position = _get_near()
		print(Player.instance.position)
func collect_item(type:String):
	collected_items[type] += 1
	item_labels[type].text = str(collected_items[type])
	print(collected_items)
