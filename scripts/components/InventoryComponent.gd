extends Node

class_name InventoryComponent

var items: Array = []

func add_item(item: String):
    items.append(item)
    EventBus.inventory_changed.emit(items)

func remove_item(item: String):
    items.erase(item)
    EventBus.inventory_changed.emit(items)

func count() -> int:
    return items.size()