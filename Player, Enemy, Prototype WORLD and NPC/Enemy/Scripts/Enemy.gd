class_name Enemy extends CharacterBody3D

# Exports

@export_group("Enemy Assignments")
@export var PLAYER : CharacterBody3D
@export var NAVIGATION_AGENT : NavigationAgent3D
@export var ANIMATION_PLAYER : AnimationPlayer
@export var WALKING_SOUND_EFFECT : AudioStreamPlayer3D
@export var CHASING_SOUND_EFFECT : AudioStreamPlayer3D
@export var WANDER_TIME : float  = 60.00
@export var WALKING_SPEED : float = 2.00
@export var WALKING_ANIMATION_SPEED : float = 1.00
@export var CHASING_SPEED : float = 4.00
@export var CHASING_ANIMATION_SPEED : float = 1.00

# State Machine Variables

var isChasing : bool 
var isSearching : bool
var isJumpscare : bool
var isInBiggerDetector : bool
var youAreDead : bool
var lastPosition
var hasSeen : bool

# Enemy Variables

var speed = WALKING_SPEED
var randomPosition = Vector3(randf_range(-75, 50), position.y, randf_range(-85, 20))


func _ready():
	if not isJumpscare:
		wandering(0)
		

func _process(delta):
	if not isJumpscare:
		if PLAYER.isRunning:
			youAreDead = true
		
		if isInBiggerDetector and youAreDead:
			isChasing = true
			youAreDead = false
			randomPosition = PLAYER.global_position
		
		if isChasing:
			chase()
			speed = CHASING_SPEED
			ANIMATION_PLAYER.play("running")
			ANIMATION_PLAYER.speed_scale = CHASING_ANIMATION_SPEED
			CHASING_SOUND_EFFECT.play()
		else:
			speed = CHASING_SPEED
			wandering(delta)
			ANIMATION_PLAYER.play("walking")
			ANIMATION_PLAYER.speed_scale = WALKING_ANIMATION_SPEED
			WALKING_SOUND_EFFECT.play()
			
		
		var direction = NAVIGATION_AGENT.get_next_path_position()-global_position 
		direction = direction.normalized()
		
		velocity = velocity.lerp(direction * speed, delta * 10)


		move_and_slide()
	else:
		ANIMATION_PLAYER.play("idle")

func chase():
	look_at(PLAYER.position)
	NAVIGATION_AGENT.target_position = PLAYER.global_position

func wandering(delta):
	look_at(global_transform.origin + velocity)
	hasSeen = true
	NAVIGATION_AGENT.target_position = randomPosition
	if (abs(randomPosition.x - global_position.x) <=  5 and abs(randomPosition.z - global_position.z) <= 5) or WANDER_TIME <= 0:
		randomPosition = Vector3(randf_range(PLAYER.global_position.x-40, PLAYER.global_position.x+40), position.y, randf_range(PLAYER.global_position.z-40, PLAYER.global_position.z+40))
		clamp(randomPosition.x, 75, 56)
		clamp(randomPosition.z, 85, 20)
		WANDER_TIME = 60.00
		WANDER_TIME-=delta


func _on_player_detector_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		isChasing = true


func _on_player_detector_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		lastPosition = body.global_position
		randomPosition = lastPosition
		isChasing = false


func _on_bigger_detector_body_entered(_body: Node3D) -> void:
	isInBiggerDetector = true


func _on_bigger_detector_body_exited(_body: Node3D) -> void:
	isInBiggerDetector = false
	isChasing = false
