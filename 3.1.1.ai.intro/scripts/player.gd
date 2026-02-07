extends CharacterBody2D


const SPEED = 400.0
var brake_mod = 0.08


var health = 100
var stamina = 100

var health_recovery_stamina_tsh = 80

var stamina_delta = 0.3

var stamina_walking = 0.2
var stamina_running = -0.5
var stamina_melee = -30.0
var stamina_range = -0.4


var is_stamina_break = false

var defense = 1.0
var melee_attack = 15

var aim_target = Vector2()
var power_range = 0
var delta_power_range = 100

@onready var health_progress_bar: TextureProgressBar = $HealthProgressBar
@onready var stamina_progress_bar: TextureProgressBar = $StaminaProgressBar

#@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar
@onready var my_attack: Area2D = $MyAttack
@onready var t_attack_ready: Timer = $TAttackReady
@onready var t_heal_ready: Timer = $THealReady
@onready var animation_player: AnimationPlayer = $Skeleton2D/AnimationPlayer
@onready var skeleton_2d: Skeleton2D = $Skeleton2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var weapon_sprite: AnimatedSprite2D = $Skeleton2D/Bone2D/Attack/WeaponSprite


var ready_to_attack = true
var ready_to_heal = false

var selected_weapon = 1

const ARROW = preload("res://scenes/arrow.tscn")
@export var ranged: Node2D = null
var number_arrows = 7

@export var hud_n_arrows: Label = null

func _ready() -> void:
	health = 100
	stamina = 100
	weapon_sprite.play("Sword")
	animation_player.play("idle")
	

func _physics_process(delta: float) -> void:
	health_progress_bar.value = health
	stamina_progress_bar.value = stamina
	stamina_delta = 0.8
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	
	print(str(is_stamina_break))
	if direction.length() != 0 and not is_stamina_break:
		if stamina < 10:
			is_stamina_break = true
		else:
			if Input.is_action_pressed("ui_run") and not is_stamina_break:
				velocity = direction * SPEED * 2.0
				stamina_delta = -0.5
			else:
				velocity = direction * SPEED
				stamina_delta = 0.2
	elif is_stamina_break:
		if stamina > 30:
			is_stamina_break = false
		stamina_delta = 0.4
		var velocity_len = move_toward(velocity.length(), 0, SPEED * brake_mod)
		velocity = velocity.normalized() * velocity_len
	else:
		stamina_delta = 0.4
		var velocity_len = move_toward(velocity.length(), 0, SPEED * brake_mod)
		velocity = velocity.normalized() * velocity_len
	if direction.x < 0:
		sprite_2d.scale.x = -2.5
		skeleton_2d.scale.x = -1
	elif direction.x > 0:
		sprite_2d.scale.x = 2.5
		skeleton_2d.scale.x = 1
		
	if Input.is_action_just_pressed("ui_aim") and number_arrows > 0 and selected_weapon == 2:
		aim_target = get_global_mouse_position()
		power_range = 0
	if Input.is_action_pressed("ui_aim") and number_arrows > 0 and selected_weapon == 2:
		stamina_delta += stamina_range
		power_range += delta_power_range * delta
		print(power_range)
	if Input.is_action_just_released("ui_aim") and number_arrows > 0 and selected_weapon == 2:
		aim_target = get_global_mouse_position()
		var new_arrow = ARROW.instantiate()
		new_arrow.position = self.position
		new_arrow.speed_direction = (aim_target - self.global_position).normalized()
		power_range = clamp(power_range, 0, 100)
		new_arrow.set_power(power_range/100)
		ranged.add_child(new_arrow)
		number_arrows -= 1
		power_range = 0
	move_and_slide()
	
	stamina += stamina_delta
	check_limits()
	print(stamina)
	if health < 80 and ready_to_heal and stamina > health_recovery_stamina_tsh:
		health += delta
	if (Input.is_action_just_pressed("ui_accept") and 
		ready_to_attack and 
		selected_weapon == 1 and 
		stamina > stamina_melee):
		stamina += stamina_melee
		attack_enemies()
		ready_to_attack = false
		t_attack_ready.start(0.7)
	
	if Input.is_action_just_released("ui_select_1"):
		selected_weapon = 1
		weapon_sprite.play("Sword")
		#weapon_sprite.stop()
		#animation_player.play("Attack")
		#animation_player.stop
	if Input.is_action_just_released("ui_select_2"):
		selected_weapon = 2
		animation_player.play("Bow")
		animation_player.stop
		
		weapon_sprite.play("Bow")
		weapon_sprite.stop()
	update_n_arrows()

func check_limits():
	
	health = clamp(health, 0, 100)
	stamina = clamp(stamina, 0, 100)

func update_n_arrows():
	if hud_n_arrows != null:
		hud_n_arrows.text = str(number_arrows)

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


func _on_pickup_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("pickable"):
		number_arrows += 1
		area.queue_free()
