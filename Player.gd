extends CharacterBody3D

@onready var camera = $Camera3D

@export var SPEED = 5.0
@export var JUMP_VELOCITY = 3
@export var MOUSE_SPEED = 0.0015
@export var INTERACTION_DISTANCE = 1


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _enter_tree():
	Logger.debug("Setting multiplayer authority to %s for self" % name)
	set_multiplayer_authority(str(name).to_int())

func _ready():
	if not is_multiplayer_authority():
		Logger.debug("Local is not authority for %s, skipping _ready()" % name)
		return
	
	Logger.debug("Local is authority for %s, capturing mouse and setting \
				  current camera" % name)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true
	
func _unhandled_input(event):
	if not is_multiplayer_authority(): return
	
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SPEED)
		camera.rotate_x(-event.relative.y * MOUSE_SPEED)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
		return
	
	if event.is_action_pressed("interact"):
		Logger.debug("Player pressed interact button")
		interact()

func interact():
		const ITEM_MASK = 0b100
		
		var query = PhysicsRayQueryParameters3D.create(
			camera.position, 
			-camera.global_rotation.normalized() * INTERACTION_DISTANCE
		) 
		query.collide_with_areas = true
		query.collision_mask = ITEM_MASK
		
		var result = get_world_3d().direct_space_state.intersect_ray(query)
		if result.is_empty():
			Logger.debug("No item found in raycast")
			return
		
		Logger.debug("Found item in raycast(id:%d)" % result["collider_id"])
		result["collider"].test_event()
		
func _physics_process(delta):
	if not is_multiplayer_authority(): return
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		Logger.trace("Player (%s) jumped with vel. y: %f" % [name, JUMP_VELOCITY])
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		Logger.trace("Moving Player %s with vel. x: %f z: %f" % [name, velocity.x, velocity.z])
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()