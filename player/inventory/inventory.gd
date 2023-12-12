extends Resource
class_name Inventory

@export var items: Array[ItemWrapper]

func drop_at_index(index: int) -> int:
	var dropped_data = items[index]
	if items.size() <= index:
		Logger.error("Attempted to drop out of bounds item (%s > %s)" \
				   % [index, items.size()])
		return 1
	else:
		items.remove_at(index)
		return 0

## Add item to inventory. CAUITION Should never be called directly, only from interaction
## on an item. This is to make sure that there are checks in place for validation
func add(item: ItemWrapper) -> int:
	items.append(item)
	return 0

func drop_amount(index: int, amount: int) -> int:
	var dropped_data = items[index]
	if dropped_data.quantity < amount:
		Logger.error("Tried to drop more than the item type holds! (%s < %s)"
				   % [dropped_data.quantity, amount])
		return 1
	elif dropped_data == amount:
		return drop_at_index(index)
	else:
		dropped_data.quantity -= amount
		return 0