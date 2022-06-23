extends KinematicBody2D

enum States {AIR = 1, FLOOR, LADDER, WALL}
var state = States.AIR
var velocity := Vector2.ZERO
var coins := 0
const SPEED := 180
const RUNSPEED := 400
const JUMPFORCE := -1100
const GRAVITY := 35

func _physics_process(delta):
	print(state)
	match state:
		States.AIR:
			if is_on_floor():
				state = States.FLOOR
				continue
			$Sprite.play("air")
			if Input.is_action_pressed("right"):
				velocity.x = SPEED
				$Sprite.flip_h = false
			elif Input.is_action_pressed("left"):
				velocity.x = -SPEED
				$Sprite.flip_h = true
			else:
				velocity.x = lerp(velocity.x, 0, 0.2)
				move_and_fall()
		States.FLOOR:
			if not is_on_floor():
				state = States.AIR
			if Input.is_action_pressed("right"):
				if Input.is_action_pressed("run"):
					velocity.x = RUNSPEED
				else:
					velocity.x = SPEED
				$Sprite.play("walk")
				$Sprite.flip_h = false
			elif Input.is_action_pressed("left"):
				if Input.is_action_pressed("run"):
					velocity.x = -RUNSPEED
				else:
					velocity.x = -SPEED
				$Sprite.play("walk")
				$Sprite.flip_h = true
			else:
				$Sprite.play("idle")
				velocity.x = lerp(velocity.x, 0, 0.2)
	
			if Input.is_action_just_pressed("jump"):
				velocity.y = JUMPFORCE
				$SoundJump.play()
				state = States.AIR
				
			move_and_fall()
		
	

func move_and_fall():
	velocity.y = velocity.y + GRAVITY
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
