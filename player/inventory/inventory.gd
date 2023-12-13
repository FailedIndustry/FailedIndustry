extends Resource
class_name Inventory

@export var items: Array[ItemWrapper]
var owner: Player

## Drops the item passed in. Can be a fraction of what the player actually has.
## In the case of error, -1 is returned
func drop(item: ItemWrapper) -> int:
    if remove(item) != 0: return -1
    
    create_item(item)
    return 0
    

func create_item(item: ItemWrapper) -> int:
    var rotation = owner.camera.global_rotation
    var z = cos(rotation.x)*cos(rotation.y)
    var y = sin(rotation.x)
    var x = sin(rotation.y)
    var end = Vector3(-x,y,-z) * 3
    Logger.info("%s" % end)    
    var world: Node = owner.get_node('/root/Main')
    var physical_item = item.item_type.physical_item.instantiate()
    physical_item.item_data = item
    physical_item.global_position = end + owner.global_position
    world.add_child(physical_item)
    return 0

## Removes the item passed in. Can be a fraction of what the player actually has.
## In the case of error, -1 is returned
func remove(item: ItemWrapper) -> int:
    var index: int = filter_for_type(item.item_type)
    # in the case of [method filter_for_type] errored
    if index == -1: return -1
    var to_change = items[index]
    if to_change.quantity > item.quantity:
        to_change.quantity -= item.quantity
        return 0
    elif to_change.quantity == item.quantity:
        to_change.quantity = 0
        items.remove_at(index)
        return 0
    else:
        Logger.error("inventory.remove: Tried to remove more than inv has")
        return -1

## Returns -1 in case of no match or error
func filter_for_type(type: ItemType):
    var index: int = -1
    for i: int in range(0, items.size()):
        if items[i].item_type == type:
            # If the index has already been set
            if index != -1: 
                Logger.error("Two items of same type in array")
                return -1
            else:
                index = i
    
    return index

## Add item to inventory. CAUITION Should never be called directly, only from interaction
## on an item. This is to make sure that there are checks in place for validation
func add(item: ItemWrapper) -> int:
    items.append(item)
    return 0
