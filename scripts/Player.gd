extends KinematicBody2D

var velocity = Vector2.ZERO
var move_speed = 850
var gravity = 1200
var jump_force = -720
var is_grounded

onready var raycasts = $raycasts
onready var collision = $collision

var _facing = 1
var _base_collision_pos = Vector2.ZERO
var _base_raycast_positions = []

func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	
	_get_input()
	
	velocity = move_and_slide(velocity)
	
	is_grounded = _check_is_ground()
	
	_set_animation()
	
#	print(velocity.y)
	
func _get_input():
	velocity.x = 0
	var move_direction = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	velocity.x = lerp(velocity.x, move_speed * move_direction, 0.2)
	
	if move_direction != 0:
		# Update facing only when there is input
		_facing = move_direction
		# Flip sprite visually
		$texture.flip_h = _facing < 0
		# Mirror collision and raycasts positions based on facing
		collision.position = Vector2(_base_collision_pos.x * _facing, _base_collision_pos.y)
		for i in range(raycasts.get_child_count()):
			var rc = raycasts.get_child(i)
			var base_pos = _base_raycast_positions[i]
			rc.position = Vector2(base_pos.x * _facing, base_pos.y)
		

func _ready() -> void:
	# Cache the base positions so we can mirror them when changing direction
	_base_collision_pos = collision.position
	_base_raycast_positions.clear()
	for rc in raycasts.get_children():
		_base_raycast_positions.append(rc.position)
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump") && is_grounded:
		velocity.y = jump_force / 2
		
func _check_is_ground():
	for raycast in raycasts.get_children():
		if raycast.is_colliding():
			return true
	return false
	
func _set_animation():
	var anim = "idle"
	
	if !is_grounded:
		anim = "jump"
		
	elif velocity.x != 0:
		anim = "run"
		
	if $anim.assigned_animation != anim:
		$anim.play(anim)
	
	
	
	
	
	
	
	
	
	
	

