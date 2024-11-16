extends CharacterBody3D

# References

@onready var head = $head
@onready var standing_coll = $standing
@onready var crouching_coll = $crouching
@onready var head_check = $head_check
@onready var Ray = $head/Camera3D/Ray
@onready var interact_btn = $object_info_Label/interaction_png
@onready var crouch_button = $"Virtual Joystick/crouch"
@onready var stand_button = $"Virtual Joystick/stand"
@onready var rot_obj_node = $head/Camera3D/OBJ_PICKER/Body3D
@onready var ray = $head/Camera3D/OBJ_PICKER/InteractRay
@onready var joint_3d = $head/Camera3D/OBJ_PICKER/Joint3D
@onready var marker = $head/Camera3D/OBJ_PICKER/Marker3D
@onready var un_interact_button = $"un-interact_button"


# State machine variables

var is_crouching = false
var is_standing = false
var is_running = false

# Variables

var pull_power = 20
var current_speed = 6.0
var direction = Vector3.ZERO
var lerp_speed = 20
var mouse_sense = 0.2
var crouching_depth = -1.5
var picked_obj
var rot_power = 0.05

# Constants

const walking_speed = 6.0
const sprinting_speed = 10.0
const crouching_speed = 1.0
const jump_velocity = 4.5


# ready functions 

func _ready() -> void:
	un_interact_button.visible = false
	

# Input functions

func _input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		if event.position.x >= get_viewport().size.x/2.0:
			rotate_y(deg_to_rad(-event.relative.x * mouse_sense))
			head.rotate_x(deg_to_rad(-event.relative.y * mouse_sense))
			head.rotation.x = clamp(head.rotation.x, deg_to_rad(-88.0), deg_to_rad(88.0))
	

# Object picking functions 

func rot_obj(event):
	if picked_obj != null:
		if event is InputEventMouseMotion:
			rot_obj_node.rotate_x(deg_to_rad(event.relative.y * rot_power))
			rot_obj_node.rotate_y(deg_to_rad(event.relative.x * rot_power))
		

func pick_object():
	var coll = ray.get_collider()
	if coll != null and coll.is_in_group("INT"):
		picked_obj = coll
		joint_3d.set_node_b(picked_obj.get_path())
		
		
	

func drop_obj():
	if picked_obj != null:
		picked_obj = null
		joint_3d.set_node_b(joint_3d.get_path())
		
		
	

# process functions

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		if picked_obj == null:
			pick_object()
			un_interact_button.visible = true
			
		

	if Input.is_action_pressed("F"):
		if picked_obj != null:
			drop_obj()
			un_interact_button.visible = false


	if picked_obj != null:
		var a = picked_obj.global_transform.origin
		var b = marker.global_transform.origin
		picked_obj.set_linear_velocity((b-a)*pull_power)
		
# Physics functions

func _physics_process(delta: float) -> void:
	
	
		
		# crouch function
		
	if Input.is_action_pressed("Crouch"):
		current_speed = crouching_speed
		head.position.y = lerp(head.position.y,2.4 + crouching_depth,delta*lerp_speed)
		standing_coll.disabled = true
		crouching_coll.disabled = false
		is_crouching = true
		
		
		
	elif !head_check.is_colliding():
		
		standing_coll.disabled = false
		crouching_coll.disabled = true
		head.position.y = 1.8
		current_speed = walking_speed
		is_standing = true
		
		
		# sprint management
		
	if Input.is_action_pressed("Sprint"):
		current_speed = sprinting_speed
		is_running = true
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



	move_and_slide();
	
