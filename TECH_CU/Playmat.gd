extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const CardSize = Vector2(125,175)
const CardBase = preload("res://CardBASE.tscn")
const playerHand = preload("res://playerHand.gd")
const CardSlot = preload("res://CardSlot.tscn")
var CardSelected = []
var DeckSize = playerHand.cardList.size()

onready var DeckPosition = $Deck.position
#onready var DiscardPosition = $Discard.position
onready var cardSpread = get_viewport().size * Vector2(0.5, 1.3)
onready var horizontalRadius = get_viewport().size.x*0.45
onready var verticalRadius = get_viewport().size.y*0.40
var angle = deg2rad(90) - 0.5
var Spread = 0.2*CardSize.x/125
var cardSpreadAngle = Vector2()
var CardsInHand = -1
var CardNumber = 0
var cardposition = Vector2()
# Called when the node enters the scene tree for the first time.
enum{
	InHand
	InPlay
	Dragging
	ZoomInHand
	DrawCard
	Reorganise
	Discard
}
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
var CardSlotEmpty = []
func _ready():
	randomize()
	var NewSlot = CardSlot.instance()
	NewSlot.rect_position = get_viewport().size *0.4
	NewSlot.rect_size = CardSize
	$CardSlots.add_child(NewSlot)
	CardSlotEmpty.append(true)

func drawCard():
	angle = PI/2 + Spread*(float(CardsInHand)/2 - CardsInHand)
	var newCard = CardBase.instance()
	CardSelected = randi()%DeckSize
	newCard.CardName = playerHand.cardList[CardSelected]
	newCard.rect_position = DeckPosition - CardSize/2 # -cardsize/2 make the cards start to go from deck to hand from where the deck is
#	newCard.Discard = DiscardPosition - CardSize/2
	newCard.rect_scale *= CardSize/newCard.rect_size
	newCard.state = DrawCard
	CardNumber = 0
	$Cards.add_child(newCard)
	playerHand.cardList.erase(playerHand.cardList[CardSelected])
	angle += 0.3
	DeckSize -= 1
	CardsInHand += 1
	OrganiseHand()
	return DeckSize
func OrganiseHand():
	for Card in $Cards.get_children():
		angle = PI/2 + Spread*(float(CardsInHand)/2 - CardNumber)
		cardSpreadAngle = Vector2(horizontalRadius * cos(angle), -verticalRadius * sin(angle))
		Card.startposition = Card.rect_position
		Card.targetposition = cardSpread + cardSpreadAngle - CardSize
		Card.cardposition = Card.targetposition #card default pos
		Card.startrotation = Card.rect_rotation
		Card.targetrotation = (90 - rad2deg(angle))/4
		Card.state = Reorganise
		CardNumber += 1
		if Card.state == InHand:
			Card.state = Reorganise
			Card.startposition = Card.rect_position # -cardsize/2 make the cards start to go from deck to hand from where the deck is
		elif Card.state == DrawCard:
			Card.startposition = Card.targetposition - ((Card.targetposition - Card.rect_position)/(1-Card.time))
