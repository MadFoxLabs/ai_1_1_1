extends CharacterBody2D


const SPEED = 400.0
var brake_mod = 0.08


var health = 100
var defense = 1.0
var melee_attack = 15

@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar
@onready var my_attack: Area2D = $MyAttack
@onready var t_attack_ready: Timer = $TAttackReady
@onready var t_heal_ready: Timer = $THealReady

var ready_to_attack = true
var ready_to_heal = false

func _ready() -> void:
	health = 100

func _physics_process(delta: float) -> void:
	texture_progress_bar.value = health
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if direction.length() != 0:
		velocity = direction * SPEED
	else:
		var velocity_len = move_toward(velocity.length(), 0, SPEED * brake_mod)
		velocity = velocity.normalized() * velocity_len
	
	move_and_slide()
	if health < 80 and ready_to_heal:
		health += delta
	if Input.is_action_just_pressed("ui_accept"):
		attack_enemies()
		ready_to_attack = false
		t_attack_ready.start(0.7)

func suffer_attack(damage):
	health -= damage * (1/defense)
	t_heal_ready.start(10)
	

func attack_enemies():
	var enemies = my_attack.get_overlapping_bodies()
	for e in enemies:
		if e.is_in_group("NPC"):
			e.suffer_attack(melee_attack)


func _on_t_attack_ready_timeout() -> void:
	ready_to_attack = true


func _on_t_heal_ready_timeout() -> void:
	ready_to_heal = true
