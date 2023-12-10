extends PanelContainer
class_name Slot

@onready var quantity_label = $QuantityLabel
@onready var texture_rect = $MarginContainer/TextureRect

var item: ItemData
## The index in the inventory from where the texture and quantity was drawn from.
var index: int
## The item owner when set_item was called
var is_grabbed: bool = false
var gui: Inventory_GUI

## [param index] is where the items lives in the underlying inventory.
## [param item] is the ItemData from which to draw quantity and texture.
## 
## There is potential for an error if [method _ready] gets called before 
## [method set_item]
func set_item(gui: Inventory_GUI, item: ItemData, index: int):
	self.item = item
	self.index = index
	self.gui = gui
	if texture_rect and quantity_label:
		render()
	else:
		# Then it will be rendered in [method _ready]
		pass

func render():
	if gui.inventory_owner != item.owner:
		Logger.error("mismatch in owners during inventory render")
		# self.hide()
		# return 
	Logger.info("setting texture to %s from %s" % [item.texture, texture_rect.texture])
	texture_rect.texture = item.texture
	tooltip_text = "%s\n%s" % [item.name, item.description]

	if item.quantity > 1:
		quantity_label.text = "%s" % item.quantity
		quantity_label.show()
	else:
		quantity_label.hide()

## There is potential for an error if [method _ready] gets called before 
## [method set_item]
func _ready():
	render()

func _on_gui_input(event):
	if item.owner != gui.inventory_owner:
		Logger.error("Mismatch in owners during GUI event")
		# self.hide()
		# return
	
	if event is InputEventMouseButton:
		if (event.button_index == MOUSE_BUTTON_LEFT \
				or event.button_index == MOUSE_BUTTON_RIGHT) \
				and event.is_pressed():
			Logger.info("Grabbing")
			gui.press_on_item(self)