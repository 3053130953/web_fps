extends Area3D

@export var rotation_speed:float = 0.5
@export var orginal_y:float
@export var float_speed:float = 0.01
@export var float_magnitude:float = 0.05


@export var diamond_model:PackedScene
@export var coin_model:PackedScene
@export var cherry_model:PackedScene

enum Collectable_Type{
	DIAMOND,
	COIN,
	CHERRY,
}
@export var type: Collectable_Type

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	orginal_y = position.y
	type = randi_range(0,2)
	var model:PackedScene
	match type:
		Collectable_Type.DIAMOND:
			model = diamond_model
		Collectable_Type.CHERRY:
			model = cherry_model
		Collectable_Type.COIN:
			model = coin_model
		_:
			printerr("damn")
	var cur_model = model.instantiate()
	add_child(cur_model)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotation.y += rotation_speed *delta
	position.y = orginal_y + sin(Time.get_ticks_msec() * float_speed) * float_magnitude


func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		Gamemanager.instance.collect_item(Collectable_Type.find_key(type))
		self.queue_free()
