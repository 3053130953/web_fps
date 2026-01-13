extends SpringArm3D


@export var mouse_speed:float = 0.01

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var mouse_delta = event.relative
		rotation.y -= mouse_delta.x * mouse_speed
		rotation.x -= mouse_delta.y * mouse_speed
		rotation.x = clamp(rotation.x,-PI/4,PI/128)
	if event is InputEventKey:
		if event.keycode == KEY_TAB && event.pressed:
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			else:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
