extends KinematicBody2D
class_name Bullet

export(float) var speed = 3000
export(float) var damage = 100
export(float) var traza_lenght = 300

const KILL_TIMER = 1.0

var direction := Vector2.ZERO
var velocity := Vector2.ZERO
var current_damage := 0

var time_life_counter := 0.0
var is_alive := true
var is_traza_on := true

onready var _traza := $Line2D
var vtraza_lenght := Vector2.ZERO

func _ready():
	collision_layer = Util.LAYER_BULLET
	collision_mask = Util.MASK_BULLET
	z_index = Util.ZINDEX_BULLET
	z_as_relative = false
	_ready_()

func set_values(origin, target):
	direction = origin.direction_to(target)
	rotation = direction.angle() - PI / 2
	global_position = origin
	current_damage = damage
	is_alive = true

func _ready_():
	_traza.set_point_position(2,vtraza_lenght)

func _physics_process(delta):
	if is_alive:
		
		var collision  = move_and_collide(direction * speed * delta)
		if collision:
			var body = collision.collider
			hit(body)

		if is_traza_on:
			if vtraza_lenght.y < traza_lenght:
				vtraza_lenght.y += speed * delta
				_traza.set_point_position(2,-vtraza_lenght)
			else:
				is_traza_on = false
			
		time_life_counter += delta
		if time_life_counter >= KILL_TIMER:
			drop_bullet()

func drop_bullet():
	if is_alive:
		is_alive = false
		queue_free()

func hit(body):
	if is_alive:
		if body:
			var shield := 0
			if body.has_method("get_shield"):
				shield = body.get_shield()
			if body.has_method("give_damage"):
				body.give_damage(current_damage,global_position,direction)
				current_damage -= shield
				if current_damage <= 0:
					drop_bullet()
			else:
				drop_bullet()

# warning-ignore:unused_argument
func _on_Bullet_body_exited(body):
	if body.has_method("exit_damage"):
		body.exit_damage(global_position,direction)
