extends Area3D

@export var jump_velocity:float = 10
@export var effect:GPUParticles3D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _Jump_box(body: Node3D) -> void:
	if body is CharacterBody3D:
		effect.emitting
		body.velocity.y = jump_velocity
		effect.restart()

func _get_flag():
	pass
