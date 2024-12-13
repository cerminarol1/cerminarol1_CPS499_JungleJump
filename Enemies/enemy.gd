extends CharacterBody2D

# Exported variables with type hints
@export var speed: float = 50
@export var gravity: float = 900

# Regular variables
var facing: int = 1

var _sprite: Sprite2D = null                     # Cached reference for Sprite2D
var _animation_player: AnimationPlayer = null    # Cached reference for AnimationPlayer
var _collision_shape: CollisionShape2D = null    # Cached reference for CollisionShape2D

#lazy intialization for animationplayer 
func get_animation_player() -> AnimationPlayer:
	if _animation_player == null:
		_animation_player = $AnimationPlayer
	return _animation_player

# lazy initialization for CollisionShape2D
func get_collision_shape() -> CollisionShape2D:
	if _collision_shape == null:
		_collision_shape = $CollisionShape2D
	return _collision_shape

# lazy initialization for Sprite2D
func get_sprite() -> Sprite2D:
	if _sprite == null:
		_sprite = $Sprite2D
	return _sprite

func _physics_process(delta: float) -> void:
	#apply gravity to vertical velocity
	velocity.y += gravity * delta
	
	#set hortizontal veloctiy based on facing direction
	velocity.x = facing * speed 
	
	#flip the sprite based on movement direction
	get_sprite().flip_h = velocity.x > 0
	
	# move the character and handle collisions
	move_and_slide()
	
	#process collisions
	for i in range(get_slide_collision_count()):
		var collision: KinematicCollision2D = get_slide_collision(i)
		var collider: Node = collision.get_collider() as Node
		
		if collider.name == "Player":
			collider.hurt()
		if collision.get_normal().x != 0:
			facing = sign(collision.get_normal().x)
			velocity.y = -100
	#free the node if it falls to far 
	if position.y > 10000:
		queue_free()
		

func take_damage() -> void:
	#play death sound
	$DeathSound.play()
	
	# play the death animation
	get_animation_player().play("death")
	
	# disable the collision shape
	get_collision_shape().set_deferred("disabled", true)
	
	#stop processing physics for this node
	set_physics_process(false)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "death":
		queue_free()
