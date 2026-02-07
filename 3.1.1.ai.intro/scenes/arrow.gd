extends Area2D

var speed_direction = Vector2(1, 0)

@export var arrow_speed:float = 2000.0
@export var base_damage = 10
@export var final_damage = 0

var travel_distance = 0
var max_distance = 1000
var final_distance = 0
func _physics_process(delta: float) -> void:
	self.rotation = speed_direction.angle()
	self.position += speed_direction.normalized() * arrow_speed * delta
	travel_distance += arrow_speed * delta
	
	if travel_distance > final_distance:
		stop_arrow()

func stop_arrow():
	arrow_speed = 0
	self.remove_from_group("range_attack")
	self.add_to_group("pickable")

func set_power(power_in:float):
	
	final_damage = base_damage * power_in
	final_distance = max_distance * power_in
