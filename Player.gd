# We can't do this because then every clone will be taking user input and reacting to collisions?
extends Mirrored

export var player_number: int = 1
var aim_left_string: String = "player" + (player_number as String) + "_aim_left"
var aim_right_string: String = "player" + (player_number as String) + "_aim_right"
var aim_up_string: String = "player" + (player_number as String) + "_aim_up"
var aim_down_string: String = "player" + (player_number as String) + "_aim_down"
var thrust_string: String = "player" + (player_number as String) + "_thrust"
var shoot_string: String = "player" + (player_number as String) + "_shoot"
var boost_left_string: String = "player" + (player_number as String) + "_boost_left"
var boost_right_string: String = "player" + (player_number as String) + "_boost_right"
var boost_up_string: String = "player" + (player_number as String) + "_boost_up"
var boost_down_string: String = "player" + (player_number as String) + "_boost_down"


var max_health = 100
var health_current = 100

export var max_speed = 100
export var forward_speed = 10
export var turning_speed = 10

# Boosting
enum BoostState {Available, Boosting, BoostOver}
export var max_boost_number = 3
export var boost_regen_milliseconds = 5
var boost_regen = 0
var current_boost_number = 3
var boostState = BoostState.Available
var boosted_time = 0
var max_boosted_time = 0.150

# Shooting
var projectile = preload("Scenes/Projectile.tscn")
var projectile_cooldown = 0.33
var projectile_cooldown_current = 0



var max_speed_squared = max_speed * max_speed

# Called when the node enters the scene tree for the first time.
func _ready():
	aim_left_string = "player" + (player_number as String) + "_aim_left"
	aim_right_string = "player" + (player_number as String) + "_aim_right"
	aim_up_string = "player" + (player_number as String) + "_aim_up"
	aim_down_string = "player" + (player_number as String) + "_aim_down"
	thrust_string = "player" + (player_number as String) + "_thrust"
	shoot_string = "player" + (player_number as String) + "_shoot"
	boost_left_string = "player" + (player_number as String) + "_boost_left"
	boost_right_string = "player" + (player_number as String) + "_boost_right"
	boost_up_string = "player" + (player_number as String) + "_boost_up"
	boost_down_string = "player" + (player_number as String) + "_boost_down"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	if !is_primary:
		return
		
	handle_boosting(delta)
	
	var isThrusting = Input.is_action_pressed(thrust_string)
	if isThrusting && boostState != BoostState.Boosting:
		apply_central_impulse(Vector2(cos(rotation), sin(rotation)) * forward_speed)
	
	if projectile_cooldown_current > 0:
		projectile_cooldown_current -= delta
	
	var isShooting = Input.is_action_pressed(shoot_string)
	if isShooting && projectile_cooldown_current <= 0:
		var direction = Vector2(cos(rotation), sin(rotation))
		var newProjectile = projectile.instance()
		newProjectile.position = position + direction * 20
		newProjectile.rotation = rotation
		newProjectile.linear_velocity = direction * 450
		
		# Todo: use signals instead.
		get_parent().add_child(newProjectile)
		projectile_cooldown_current = projectile_cooldown
		
	# Instantiate a new bullet.
	pass
	
func handle_boosting(delta):
	var boostingDirection = Input.get_vector(boost_left_string, boost_right_string, boost_up_string, boost_down_string)
	
	if boostState == BoostState.Available:
		if boostingDirection.length_squared() != 0 && current_boost_number > 0:
			print("boosting")
			apply_central_impulse(boostingDirection.normalized() * max_speed)
			boostState = BoostState.Boosting
			current_boost_number -= 1
	elif boostState == BoostState.Boosting:
		boosted_time += delta
		if boosted_time > max_boosted_time:
			print("boost over")
			boostState = BoostState.BoostOver
			boosted_time = 0
		else:
			apply_central_impulse(boostingDirection.normalized() * max_speed)
	if boostState == BoostState.BoostOver:
		if boostingDirection.length_squared() == 0:
			boostState = BoostState.Available
			print("boost available")
		pass
		
	if current_boost_number < max_boost_number:
		boost_regen += delta
		
	if boost_regen >= boost_regen_milliseconds:
		print("regained boost")
		boost_regen = 0
		current_boost_number += 1
	pass

func _integrate_forces(state: Physics2DDirectBodyState):
	
	
	if is_primary:
		#Cancel out any non-player rotation
		state.angular_velocity = 0
		
		#Aiming
		var aimingDirection = Input.get_vector(aim_left_string, aim_right_string, aim_up_string, aim_down_string)
		var currentDirection = Vector2(cos(rotation), sin(rotation))
		var radiansToAimingRotation = currentDirection.angle_to(aimingDirection)
		state.angular_velocity = clamp(radiansToAimingRotation * turning_speed, -turning_speed, turning_speed)
		
		#Moving
		if state.linear_velocity.length_squared() > max_speed_squared:
			state.linear_velocity = state.linear_velocity.normalized() * max_speed	
		
		
	._integrate_forces(state)
	
	
	pass
