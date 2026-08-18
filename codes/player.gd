extends Area2D

var is_dragging : bool = false
var screen_size : Vector2

# Kanjbdo l'node dyal l'animation bash nkhdmo bih
@onready var anim = $AnimatedSprite2D

func _ready():
	screen_size = get_viewport_rect().size
	position = Vector2(200, 300)
	# Kandémariw b l'animation dyal l'wst
	anim.play("idle")

func _input(event):
	if event is InputEventScreenTouch:
		is_dragging = event.pressed
		# Mli kiyhz sbe3o (not pressed), mrkaba trj3 t9ad
		if not event.pressed:
			anim.play("idle")
			
	elif event is InputEventScreenDrag and is_dragging:
		position += event.relative
		
		# Logique dyal l'animation 3la 7sab l'ittijah dyal sbe3 f l'axe X
		if event.relative.x < -2: # Mli kayk7ez l lissr (Negative X)
			anim.play("turn_left")
		elif event.relative.x > 2: # Mli kayk7ez l limn (Positive X)
			anim.play("turn_right")
		else:
			anim.play("idle") # Ila kan kaytl3 wla kayhbt ghir f blasso

func _process(delta):
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)
