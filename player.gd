extends CharacterBody2D

signal life_changed(life: int)
signal died

@export var gravity: float = 750
@export var run_speed: float = 150
@export var jump_speed: float = -300
@export var life: int = 3:
	set(value):
		life = value
		life_changed.emit(life)
		if life <= 0:
			change_state(DEAD)
@export var max_jumps: int = 2
@export var double_jump_factor: float = 1.5
var jump_count: int = 0
var _dust: CPUParticles2D = null

func get_dust() -> CPUParticles2D:
	if _dust == null:
		_dust = $Dust
	return _dust

enum {IDLE, RUN, JUMP, HURT, DEAD}
var state: int = IDLE

func get_animation_player() -> AnimationPlayer: # to make double jump code work and test
	return $AnimationPlayer


func _ready() -> void:
	change_state(IDLE) # change_state needs to be defined 

# handle hanges to player state
func change_state(new_state: int) -> void:
	state = new_state
	match state:
		IDLE:
			$AnimationPlayer.play("idle")
		RUN:
			$AnimationPlayer.play("run")
		JUMP:
			$JumpSound.play()
			get_animation_player().play("jump_up") #$AnimationPlayer.play("jump_up")
			jump_count = 1
		HURT:
			$HurtSound.play()
			$AnimationPlayer.play("hurt")
			velocity.y = -200
			velocity.x = -100 * sign(velocity.x)
			life -= 1 
			if life > 0:
				await get_tree().create_timer(0.5).timeout
				change_state(IDLE)
		DEAD:
			died.emit()
			queue_free() #was hide

# player movement 
func get_input() -> void:
	var right: bool = Input.is_action_pressed("right")
	var left: bool = Input.is_action_pressed("left") 
	var jump: bool = Input.is_action_pressed("jump")
	
	# movement occurs in all states
	velocity.x = 0
	if right: 
		velocity.x += run_speed
		$Sprite2D.flip_h = false
	if left: 
		velocity.x -= run_speed
		$Sprite2D.flip_h = true
	if state == HURT:
		return
	# Double jump if we are currently in the air (from a jump not falling) and have jumps left
	#if jump and state == JUMP and jump_count < max_jumps and jump_count > 0:
		#get_animation_player().play("jump_up")# $AnimationPlayer.play("jump_up") 
		#velocity.y = jump_speed / double_jump_factor
		#jump_count += 1
	if jump and is_on_floor():
		change_state(JUMP)
		velocity.y = jump_speed
	if state == JUMP and is_on_floor():
		change_state(IDLE)
		jump_count = 0
		#$Dust.emitting = true#get_dust().emmitting = true
	if state == IDLE and velocity.x != 0 :
		change_state(RUN)
	if state == RUN and velocity.x ==0:
		change_state(IDLE)
	if state in [IDLE, RUN] and !is_on_floor():
		change_state(JUMP)



# add gravity and movement
func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta 
	# Process user input
	get_input()
	#update the player
	move_and_slide()
	#detect a collision against the Danger tilemap
	if state == HURT:
		return
	for i in range(get_slide_collision_count()):
		var collision: KinematicCollision2D = get_slide_collision(i)
		var collider: Object = collision.get_collider()
		if collider.is_in_group("danger"): 
			hurt()
		
		if collider.is_in_group("enemies"):
			if position.y < collider.position.y:
				collider.take_damage()
				velocity.y = -200
			else: 
				hurt()
	# Detect when a jump ends (move and slide's update to the is_on_floor)
	if state == JUMP and is_on_floor():
		change_state(IDLE)
		jump_count = 0
	#check if character is falling
	if state == JUMP and velocity.y > 0:
		$AnimationPlayer.play("jump_down")
	#free the node if it falls to far, does not work
	if position.y > 1000:
		queue_free()
		died.emit()

# reset function
func reset(_position: Vector2) -> void:
	position = _position
	show()
	change_state(IDLE)
	life = 3

#hurt function
func hurt() -> void: 
	if state != HURT:
		change_state(HURT)
