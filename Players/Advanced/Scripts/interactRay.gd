extends RayCast3D

@onready var prompt = $"../../../object_info_Label"
@onready var hand = $"../../../../interaction_png"
@onready var second_hand = $"../../../../interaction_png2"

func _physics_process(_delta):
	
	var collider = get_collider()
	
	if collider is Interactable:
		hand.visible = true
		second_hand.visible = false
	elif collider is Interactable_object:
		second_hand.visible = true
		hand.visible = false
	else:
		hand.visible = false
		second_hand.visible = false

func _process(delta: float) -> void:
	if is_colliding():
		var hitObj = get_collider()
		if hitObj.has_method("interact") && Input.is_action_just_pressed("Interact"):
			hitObj.interact()
