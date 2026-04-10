extends CharacterBody2D

@export var max_speed: float = 120.0
@export var acceleration: float = 800.0
@export var friction: float = 600.0
@export var attack_duration: float = 0.3
var is_attacking: bool = false

@onready var anim = $Animations
@onready var hitbox = $hitbox

@export var dashSpeed = 400
@export var dashDistance = 100
var dashLocation = Vector2.ZERO 
var dashing = false


var last_direction: Vector2 = Vector2.DOWN  # default idle direction

func _physics_process(delta):
	
	

	# dash ability
	# dash ability
	if Input.is_action_just_pressed("dash"):
		if not dashing:
			var direction = Input.get_vector("moving_left", "moving_right", "moving_up", "moving_down")

			if direction != Vector2.ZERO:
				dashLocation = direction.normalized()
				dashing = true

	if dashing:
		velocity = dashLocation * dashSpeed
		dashDistance -= dashSpeed * 60
		anim.play("dash")
		if dashDistance <= 0:
			dashing = false
		
	
	
	var input_dir = Vector2.ZERO
	
	input_dir.x = Input.get_action_strength("moving_right") - Input.get_action_strength("moving_left")
	input_dir.y = Input.get_action_strength("moving_down") - Input.get_action_strength("moving_up")
	input_dir = input_dir.normalized()

	# Movement
	if is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	if input_dir != Vector2.ZERO:
		velocity = velocity.move_toward(input_dir * max_speed, acceleration * delta)
		last_direction = input_dir  # 🔥 store last movement direction
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	update_animation(input_dir)
	move_and_slide()
	



	
	
	if Input.is_action_just_pressed("attack") and not is_attacking:
		start_attack()
func update_animation(direction: Vector2):
	if is_attacking:
		return
	if direction == Vector2.ZERO:
		play_idle()
		return
	
	# Walking animations
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			anim.play("running_right")
		else:
			anim.play("running_left")
	else:
		if direction.y > 0:
			anim.play("running_front")
		else:
			anim.play("running_back")


func play_idle():
	if abs(last_direction.x) > abs(last_direction.y):
		if last_direction.x > 0:
			anim.play("idle_right")
		else:
			anim.play("idle_left")
	else:
		if last_direction.y > 0:
			anim.play("idle_front")
		else:
			anim.play("idle_back")



func start_attack():
	var overlapping_objects = hitbox.get_overlapping_bodies()
	for area in overlapping_objects:
		var parent = area.get_parent()
		print(parent.name)
		
		
	is_attacking = true
	play_attack_animation()
	await get_tree().create_timer(attack_duration).timeout
	is_attacking = false



	
func play_attack_animation():
	var anim_name = ""

	if abs(last_direction.x) > abs(last_direction.y):
		if last_direction.x > 0:
			anim_name = "attack_right"
		else:
			anim_name = "attack_left"
	else:
		if last_direction.y > 0:
			anim_name = "attack_down"
		else:
			anim_name = "attack_up"
	if anim.animation != anim_name:
		anim.play(anim_name)
