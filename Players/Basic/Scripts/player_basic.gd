extends CharacterBody3D

# References

@onready var head = $head
@onready var standing_coll = $standing
@onready var crouching_coll = $crouching
@onready var head_check = $head_check

# Variables

var current_speed = 5.0
var direction = Vector3.ZERO
var lerp_speed = 20
var mouse_sense = 0.2
var crouching_depth = -0.5

# Constants

const walking_speed = 5.0
const sprinting_speed = 8.0
const crouching_speed = 2.0
const jump_velocity = 4.5

# Input functions

func _input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		if event.position.x >= get_viewport().size.x/2.0:
			rotate_y(deg_to_rad(-event.relative.x * mouse_sense))
			head.rotate_x(deg_to_rad(-event.relative.y * mouse_sense))
			head.rotation.x = clamp(head.rotation.x, deg_to_rad(-88.0), deg_to_rad(88.0))

# Physics functions

func _physics_process(delta: float) -> void:
	
	# crouch function
	
	if Input.is_action_pressed("Crouch"):
		current_speed = crouching_speed
		head.position.y = lerp(head.position.y,1.8 + crouching_depth,delta*lerp_speed)
		standing_coll.disabled = true
		crouching_coll.disabled = false
	elif !head_check.is_colliding():
		standing_coll.disabled = false
		crouching_coll.disabled = true
		head.position.y = 1.8
		current_speed = walking_speed
		
		# sprint management
		
		if Input.is_action_pressed("Sprint"):
			current_speed = sprinting_speed
		else:
			current_speed = walking_speed
			
	
	# gravity management
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	# jump management
	
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = jump_velocity

	# others
	
	var input_dir := Input.get_vector("Left", "Right", "Forward", "Backward")
	direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta*lerp_speed)
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
