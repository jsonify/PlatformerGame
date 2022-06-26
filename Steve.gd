extends KinematicBody2D

enum States {AIR = 1, FLOOR, LADDER, WALL}
var state = States.AIR
var velocity := Vector2.ZERO
var coins := 0
var direction := 1
var last_jump_direction := 0
var on_ladder := false
const SPEED := 180
const RUNSPEED := 400
const GRAVITY := 35
const JUMPFORCE := -1100
const FIREBALL := preload("res://Fireball.tscn")

func _physics_process(delta):
	print(on_ladder)
	match state:
		States.AIR:
			if is_on_floor():
				last_jump_direction = 0
				state = States.FLOOR
				continue
			elif is_near_wall():
				state = States.WALL
				continue
			elif should_climb_ladder():
				state = States.LADDER
				continue
				
			$Sprite.play("air")
			if Input.is_action_pressed("right"):
				velocity.x = lerp(velocity.x, SPEED, 0.1) if velocity.x < SPEED else lerp(velocity.x, SPEED, 0.03)
				$Sprite.flip_h = false
			elif Input.is_action_pressed("left"):
				velocity.x = lerp(velocity.x, -SPEED, 0.1) if velocity.x > -SPEED else lerp(velocity.x, -SPEED, 0.03)
				$Sprite.flip_h = true
			else:
				velocity.x = lerp(velocity.x, 0, 0.2)
			set_direction()
			move_and_fall(false)
			fire()
			
		States.FLOOR:
			if !is_on_floor():
				state = States.AIR
				continue
			elif should_climb_ladder():
				state = States.LADDER
				continue
				
			if Input.is_action_pressed("right"):
				if Input.is_action_pressed("run"):
					velocity.x = lerp(velocity.x, RUNSPEED, 0.1)
					$Sprite.set_speed_scale(1.8)
				else:
					velocity.x = lerp(velocity.x, SPEED, 0.1)
					$Sprite.set_speed_scale(1.0)					
				$Sprite.play("walk")
				$Sprite.flip_h = false
			elif Input.is_action_pressed("left"):
				if Input.is_action_pressed("run"):
					velocity.x = lerp(velocity.x, -RUNSPEED, 0.1)
					$Sprite.set_speed_scale(1.8)
				else:
					velocity.x = lerp(velocity.x, -SPEED, 0.1)
					$Sprite.set_speed_scale(1.0)
				$Sprite.play("walk")
				$Sprite.flip_h = true
			else:
				$Sprite.play("idle")
				velocity.x = lerp(velocity.x, 0, 0.2)
	
			if Input.is_action_just_pressed("jump"):
				velocity.y = JUMPFORCE
				$SoundJump.play()
				state = States.AIR
			set_direction()
			move_and_fall(false)
			fire()
			
		States.WALL:
			if is_on_floor():
				last_jump_direction = 0
				state = States.FLOOR
				continue
			elif !is_near_wall():
				state = States.AIR
				continue
			$Sprite.play("wall")
			
			if direction != last_jump_direction and Input.is_action_pressed("jump") and ((Input.is_action_pressed("left") and direction == 1) or (Input.is_action_pressed("right") and direction == -1)):
				last_jump_direction = direction
				velocity.x = 450 * -direction
				velocity.y = JUMPFORCE * 0.7
				$SoundJump.play()
				state = States.AIR
			
			move_and_fall(true)
			
		States.LADDER:
			if !on_ladder:
				state = States.AIR
				continue
			elif is_on_floor() and Input.is_action_pressed("down"):
				state = States.FLOOR
				Input.action_release("down")
				Input.action_release("up")
				continue
			elif Input.is_action_pressed("jump"):
				Input.action_release("down")
				Input.action_release("up")
				velocity.y = JUMPFORCE * 0.7
				state = States.AIR
				continue
			
			if Input.is_action_pressed("down") or Input.is_action_pressed("up") or Input.is_action_pressed("left") or Input.is_action_pressed("right"):
				$Sprite.play("climb")
				print(Input)
			else:
				$Sprite.stop()
				
			if Input.is_action_pressed("up"):
				velocity.y = -SPEED
			elif Input.is_action_pressed("down"):
				velocity.y = SPEED
#			else:
#				velocity.y = lerp(velocity.y, 0, 0.3)
			
			if Input.is_action_pressed("left"):
				velocity.x = -SPEED / 6
			elif Input.is_action_pressed("right"):
				velocity.x = SPEED / 6
			else:
				velocity.y = lerp(velocity.x, 0, 0.3)
			
			velocity = move_and_slide(velocity, Vector2.UP)
			
func should_climb_ladder() -> bool:
	if on_ladder and (Input.is_action_pressed("up") or Input.is_action_pressed("down")):
		return true
	else:
		return false
	
func set_direction():
	direction = 1 if !$Sprite.flip_h else -1
	$Wallchecker.rotation_degrees = 90 * -direction
			
func is_near_wall():
	return $Wallchecker.is_colliding()

func fire():
	if Input.is_action_just_pressed("fire") and !is_near_wall():
		var f = FIREBALL.instance()
		f.direction = direction
		get_parent().add_child(f)
		f.position.y = position.y
		f.position.x = position.x + 25 * direction

func move_and_fall(slow_fall:bool):
	velocity.y = velocity.y + GRAVITY	
	if slow_fall:
		velocity.y = clamp(velocity.y, JUMPFORCE, 200)
	
	velocity = move_and_slide(velocity, Vector2.UP)



func _on_Fallzone_body_entered(body: Node) -> void:
	get_tree().change_scene("res://GameOver.tscn")

func bounce():
	velocity.y = JUMPFORCE * 0.7
	
func ouch(var enemyposx):
	set_modulate(Color(1, 0.3, 0.3, 0.3))
	velocity.y = JUMPFORCE * 0.4
	
	if position.x < enemyposx:
		velocity.x = -400
	elif position.x > enemyposx:
		velocity.x = 400
		
	Input.action_release("left")
	Input.action_release("right")
	
	$Timer.start()


func _on_Timer_timeout():
#	get_tree().change_scene("res://Level1.tscn")
	get_tree().change_scene("res://GameOver.tscn")


func _on_LadderChecker_body_entered(body):
	on_ladder = true


func _on_LadderChecker_body_exited(body):
		on_ladder = false
