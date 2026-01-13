extends Area3D
class_name Flag

var is_flag:bool = false
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass




func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D && !is_flag:
		animation_player.play("Risen")
		print("got")
		is_flag = true
		Gamemanager.instance.flags.append(self)
