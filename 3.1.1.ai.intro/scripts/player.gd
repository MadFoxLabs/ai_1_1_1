extends CharacterBody2D


const SPEED = 400.0
var brake_mod = 0.08


var health = 100
var defense = 1.0
var melee_attack = 15

var aim_target = Vector2()

@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar
@onready var my_attack: Area2D = $MyAttack
@onready var t_attack_ready: Timer = $TAttackReady
@onready var t_heal_ready: Timer = $THealReady
@onready var animation_player: AnimationPlayer = $Skeleton2D/AnimationPlayer
@onready var skeleton_2d: Skeleton2D = $Skeleton2D
@onready var sprite_2d: Sprite2D = $Sprite2D

var ready_to_attack = true
var ready_to_heal = false

const ARROW = preload("res://scenes/arrow.tscn")
@export var ranged: Node2D = null

func _ready() -> void:
	health = 100
	animation_player.play("idle")

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
	if direction.x < 0:
		sprite_2d.scale.x = -2.5
		skeleton_2d.scale.x = -1
	elif direction.x > 0:
		sprite_2d.scale.x = 2.5
		skeleton_2d.scale.x = 1
		
	if Input.is_action_just_pressed("ui_aim"):
		aim_target = get_global_mouse_position()
	if Input.is_action_just_released("ui_aim"):
		var new_arrow = ARROW.instantiate()
		new_arrow.position = self.position
		new_arrow.speed_direction = (aim_target - self.global_position).normalized()
		ranged.add_child(new_arrow)
		
	move_and_slide()
	if health < 80 and ready_to_heal:
		health += delta
	if Input.is_action_just_pressed("ui_accept") and ready_to_attack:
		attack_enemies()
		ready_to_attack = false
		t_attack_ready.start(0.7)
	
		
		
func suffer_attack(damage):
	health -= damage * (1/defense)
	t_heal_ready.start(10)
	
	if health < 0:
		animation_player.stop()
		get_tree().change_scene_to_file("res://scenes/game_over.tscn")
	

func attack_enemies():
	animation_player.play("Attack")
	#var enemies = my_attack.get_overlapping_bodies()
	#for e in enemies:
		#if e.is_in_group("NPC"):d
			#e.suffer_attack(melee_attack)


func _on_t_attack_ready_timeout() -> void:
	ready_to_attack = true


func _on_t_heal_ready_timeout() -> void:
	ready_to_heal = true


func _on_my_attack_body_entered(body: Node2D) -> void:
	if body.is_in_group("NPC"):
		body.suffer_attack(melee_attack)
