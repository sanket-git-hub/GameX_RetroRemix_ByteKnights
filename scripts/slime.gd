extends CharacterBody2D

@export var speed: int = 70      # Movement speed of the slime
@export var damage: int = 10      # Damage dealt by the slime
@export var attack_delay: float = 1.0  # Time between attacks in seconds
@export var attack_range: float = 5.0  # Range at which the slime can attack

var player = null  # Reference to the player
var can_attack = true  # Controls whether the slime can attack

@onready var attack_timer = Timer.new()
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D  # Reference to the sprite node
@onready var attack_area: Area2D = $AttackArea  # Reference to the AttackArea node (Area2D)

func _ready():
	add_child(attack_timer)
	attack_timer.wait_time = attack_delay
	attack_timer.one_shot = true
	attack_timer.timeout.connect(Callable(self, "_on_attack_timer_timeout"))  # Correct connect()

	# Ensure player is found in the "Player" group
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player = players[0]

	# Set initial animation
	if sprite:
		sprite.play("idle")  # Play idle animation by default

	# Connect the signal for collision detection from the attack Area2D
	if attack_area:
		attack_area.connect("body_entered", Callable(self, "_on_attack_area_entered"))  # Correct connection
	else:
		print("Error: AttackArea node not found!")

	# Connect animation finished signal once during initialization
	if sprite:
		sprite.connect("animation_finished", Callable(self, "_on_attack_animation_finished"))  # Correct connection

# Slime movement and animation handling
func _physics_process(_delta):
	if player and is_instance_valid(player):
		var direction = (player.global_position - global_position).normalized()

		# Check the distance to the player and stop when too close
		var distance_to_player = global_position.distance_to(player.global_position)

		# If too close, stop the movement or slow it down
		if distance_to_player > attack_range:
			velocity = direction * speed
		else:
			velocity = Vector2.ZERO  # Stop moving if the slime is within attack range

		move_and_slide()

		# Update the animation based on whether the slime is attacking or idle
		if sprite:
			if not can_attack:
				sprite.play("attack")  # Attack animation is played while attacking
			else:
				sprite.play("idle")  # Idle animation when not attacking

# This function is triggered when the player enters the attack area
func _on_attack_area_entered(body):
	print("Player entered attack area")  # Debugging
	if body.is_in_group("Player") and can_attack:
		# Trigger attack animation first, then apply damage
		if sprite:
			sprite.play("attack")
			print("Attack animation started")  # Debugging
		can_attack = false  # Prevent further attacks until the timer expires
		attack_timer.start()  # Start the attack cooldown timer

# After the attack animation finishes, damage is applied
func _on_attack_animation_finished(anim_name):
	print("Animation finished: ", anim_name)  # Debugging
	if anim_name == "attack":
		# Only apply damage after the attack animation has finished
		if player and player.is_instance_valid():
			player.take_damage(damage, (player.global_position - global_position).normalized())  # Apply damage to player
			print("Damage applied to player")  # Debugging

		# Reset attack animation logic
		sprite.play("idle")

# Timer handling to allow the slime to attack again after a delay
func _on_attack_timer_timeout():
	print("Attack timer finished")  # Debugging
	can_attack = true  # Reactivate attacking after the attack delay
	if sprite:
		sprite.play("idle")  # Return to idle animation after attack delay
