extends MarginContainer

onready var CardDatabase = preload("res://Card/CardDatabase.gd")
var CardName = 'BLANK'
onready var CardInfo = CardDatabase.DATA[CardDatabase.get(CardName)]
onready var CardImage = str("res://", CardInfo[0], "/", CardName,".png")

enum{
	InHand
	InPlay
	Dragging
	ZoomInHand
	DrawCard
	Reorganise
	Discard
}
var state = InHand
var startposition = 0
var targetposition = 0
var startrotation = 0
var targetrotation = 0
var time = 0
var drawTime = .7
var setup = true
var startscale = Vector2()
var ZoomInSize = 2
var ZoomInTime = 0.1
var cardposition = Vector2()
var ReorganiseZoom = true
var CardsInHand = 0
var CardNumber = 0
var NearbyCards
var MoveNearbyCardCheck = false
var MoveToDiscard = false
onready var originalScale = rect_scale.x
func _ready():
	print(CardInfo)
	print(CardImage)
	var CardSize = rect_size
	$Border.scale *= CardSize/$Border.texture.get_size()
	$Card.texture = load(CardImage)
	#$Card.scale *= CardSize/$Card.texture.get_size()
	$CardBack.scale *= CardSize/$CardBack.texture.get_size()
	$Zoom.rect_scale *= CardSize/$Zoom.rect_size
	var HP = str(CardInfo[1])
	var DMG = str(CardInfo[2])
	var DESC = str(CardInfo[3])
	var TYPE = str(CardInfo[4])
	$Text/Name/Name/CenterContainer/Label.text = CardName
	$Text/HPDMG/HP/CenterContainer/Label.text = HP
	$Text/HPDMG/DMG/CenterContainer/Label.text = DMG
	$Text/Description/Name/CenterContainer/Label.text = DESC
	$Text/Type/Type/CenterContainer/Label.text = TYPE
	
var CardSelected = true
var OldState = INF
var InMouseTime = 0.1
var MoveIntoPlay = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
	match state:
		ZoomInHand, Dragging:
			if event.is_action_pressed("rightclick"):
				print("a")
				rect_scale = Vector2(1.5,1.5)
				rect_position = Vector2(500,550)
			if event.is_action_pressed("leftclick"):
				if CardSelected == true:
					OldState = state
					state = Dragging
					setup = true
					CardSelected = false
			if event.is_action_released("leftclick"):
				if CardSelected == false:
					if $Text/Type/Type/CenterContainer/Label.text == "Unit":
						if OldState == ZoomInHand:
							var CardSlots = $'../../CardSlots'
							var CardSlotEmpty = $'../../'.CardSlotEmpty
							for i in range(CardSlots.get_child_count()):
								if CardSlotEmpty[i]:
									var CardSlotPos = CardSlots.get_child(i).rect_position
									var CardSlotSize = CardSlots.get_child(i).rect_size
									var MousePos = get_global_mouse_position()
									if MousePos.x < CardSlotPos.x + CardSlotSize.x && MousePos.x > CardSlotPos.x \
										&& MousePos.y < CardSlotPos.y + CardSlotSize.y && MousePos.y > CardSlotPos.y:
											setup = true
#											MoveToDiscard = true
#											state = Discard
											MoveIntoPlay = true
											targetposition = CardSlotPos - $'../../'.CardSize/2
											CardSlotEmpty = [false]
											print("a")
											state = InPlay
											CardSelected = true
											break
											
							if state != InPlay:
									setup = true
									targetposition = cardposition
									state = Reorganise
									CardSelected = true
							else:
								pass
						else:
							setup = true
							targetposition = cardposition
							state = Reorganise
							CardSelected = true
					else:
						setup = true
						targetposition = cardposition
						state = Reorganise
						CardSelected = true
func _physics_process(delta):
	match state:
		InHand:
			pass
		InPlay:
			if MoveIntoPlay:
				if setup:
					setup()
				if time <= 1:
					rect_position = startposition.linear_interpolate(targetposition, time)
					time += delta*4
				else:
					rect_position = targetposition
					rect_rotation = 0
					MoveIntoPlay = false
		Dragging:
			if setup:
				setup()
			if time <= 1:
				rect_position = startposition.linear_interpolate(get_global_mouse_position() - $'../../'.CardSize, time)
				#rect_rotation = startrotation * (1-time) + targetposition*time
				rect_scale = Vector2(0.5,0.5)
				time += delta*4
			else:
				rect_position = get_global_mouse_position() - $'../../'.CardSize
				rect_rotation = 0
				
		ZoomInHand:
			if setup:
				setup()
				
			if time <= 1:
				#rect_position = startposition.linear_interpolate(targetposition, time)
				#rect_rotation = startrotation * (1-time) + targetposition*time
				#rect_scale = startrotation * (1-time) + originalScale*2*time
				#rect_scale = rect_scale*2

				time += delta/float(ZoomInTime)
#				if ReorganiseZoom == true:
#					ReorganiseZoom == false
#					CardsInHand = $'../../'.CardsInHand - 1 #offset for zeroth item
#					if CardNumber - 1 >= 0:
#						ReorganiseZoomCards(CardNumber - 1,true,1) #true is left
#					if CardNumber - 2 >= 0:
#						ReorganiseZoomCards(CardNumber - 2,true,1)
#					if CardNumber + 1 <= CardsInHand:
#						ReorganiseZoomCards(CardNumber + 1,false,1)
#					if CardNumber + 2 <= CardsInHand:
#						ReorganiseZoomCards(CardNumber + 2,false,1)
#				elif ReorganiseZoom == false:
#					print("b")
						
			else:
				rect_position = targetposition
				rect_rotation = targetrotation
				#rect_scale = originalScale
				#state = InHand
				time = 0
		DrawCard: #animate from going from deck to hand
			if time <= 1:
				rect_position = startposition.linear_interpolate(targetposition, time)
				#rect_rotation = startrotation * (1-time) + targetposition*time
				rect_scale.x = originalScale * abs(2*time-1)
				cardposition = targetposition
				$CardBack.visible = true
				if $CardBack.visible:
					if time >= 0.5:
						$CardBack.visible = false
				
				time += delta*4
			else:
				rect_position = targetposition
				rect_rotation = targetrotation
				state = InHand
		Reorganise:
			if setup:
				setup()
				
			if time <= 1:
				rect_scale = Vector2(0.5,0.5)
				rect_position = startposition.linear_interpolate(targetposition, time)
				#rect_rotation = startrotation * (1-time) + targetposition*time
				#rect_scale = startrotation * (1-time) + originalScale*time
				time += delta*4
#				if MoveNearbyCardCheck == false:
#					if CardNumber - 1 >= 0:
#						ResetCard(CardNumber - 1)
#						
#					if CardNumber - 2 >= 0:
#						#ResetCard(CardNumber - 2)
#						pass
#					if CardNumber + 1 <= CardsInHand:
#						ResetCard(CardNumber + 1)
#						
#					if CardNumber + 2 <= CardsInHand:
#						#ResetCard(CardNumber + 2)
#						pass
#				else:
#					pass
			else:
				rect_position = targetposition
				rect_rotation = targetrotation
				#rect_scale = originalScale
				state = InHand
				time = 0
		Discard:
			if MoveToDiscard:
				
				if setup:
					setup()
					targetposition = $Discard
				if time <= 1:
					rect_position = startposition.linear_interpolate(targetposition, time)
					time += delta*4
				else:
					rect_position = targetposition
					rect_rotation = 0
					MoveToDiscard = false
func a():
	if Input.is_action_pressed("rightclick"):
		print("a")
		rect_scale = Vector2(1.5,1.5)
		
	

func ReorganiseZoomCards(CardNumber,Left,SpreadFactor):
	NearbyCards = $'../'.get_child(CardNumber)
	print("a")
	if Left:
		NearbyCards.targetposition = NearbyCards.cardposition - SpreadFactor*Vector2(65,0)
	else:
		NearbyCards.targetposition = NearbyCards.cardposition + SpreadFactor*Vector2(65,0)
	NearbyCards.setup = true
	if state != Reorganise:
		NearbyCards.state = Reorganise

func ResetCard(CardNumber):
	NearbyCards = $'../'.get_child(CardNumber)
	NearbyCards.targetposition = NearbyCards.cardposition
	print(NearbyCards.targetposition)
	print("NearbyCards.cardposition")
	NearbyCards.setup = true
	NearbyCards.state = Reorganise

func setup():
	startposition = rect_position
	startrotation = rect_rotation
	#startscale = rect_scale
	time=0
	setup=false

func _on_Zoom_mouse_entered():
	match state:
		InHand, Reorganise:
			setup = true
			targetrotation = 0
			targetposition = cardposition
			state = ZoomInHand
			rect_scale = Vector2(.85, .85)
			targetposition.y = get_viewport().size.y - $'../../'.CardSize.y*1.85


func _on_Zoom_mouse_exited():
	match state:
		ZoomInHand:
			setup = true
			MoveNearbyCardCheck = false
			targetposition = cardposition
			state = Reorganise
