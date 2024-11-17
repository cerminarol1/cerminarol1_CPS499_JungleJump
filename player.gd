extends CharacterBody2D

@export var gravity: float = 750
@export var run_speed: float = 150
@export var jump_speed: float = -300

enum {IDLE, RUN, JUMP, HURT, DEAD}
var state: int = IDLE

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
		HURT:
			$AnimationPlayer.play("hurt")
		JUMP:
			$AnimationPlayer.play("jump_up")
		DEAD:
			hide()

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
	if jump and is_on_floor():
		change_state(JUMP)
		velocity.y = jump_speed
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
	#detect when a jump ends (move and slide's update to the is_on_floor)
	if state == JUMP and is_on_floor():
		change_state(IDLE)
	#check if character is falling
	if state == JUMP and velocity.y > 0:
		$AnimationPlayer.play("jump_down")
		
# reset function
func reset(_position: Vector2) -> void:
	position = _position
	show()
	change_state(IDLE)
