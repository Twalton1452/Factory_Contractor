extends Node

## Autoloaded

signal added(data: ComponentData)
signal subtracted(data: ComponentData)
signal changed

const MAX_INVENTORY_SLOT_CAPACITY = 999

var items : Dictionary = {} # { key: ComponentData: val: int }

func _ready():
	if OS.has_feature("editor"):
		for data in ComponentDB.available_recipes:
			add(data, MAX_INVENTORY_SLOT_CAPACITY)
	else:
		add(ComponentDB.BASIC_EXTRACTOR, 2)
		add(ComponentDB.CONVEYOR_BELT, 30)
		add(ComponentDB.BASIC_ASSEMBLER, 4)
		add(ComponentDB.STORAGE_BUILDING, 3)

func add(data: ComponentData, amount: int = 1) -> void:
	if items.has(data):
		items[data] += amount
	else:
		items[data] = amount
	
	items[data] = clampi(items[data], 1, MAX_INVENTORY_SLOT_CAPACITY)
	added.emit(data)
	changed.emit()

func subtract(data: ComponentData, amount: int = 1) -> void:
	if items.has(data):
		items[data] -= amount
		items[data] = clampi(items[data], 0, MAX_INVENTORY_SLOT_CAPACITY)
		subtracted.emit(data)
		changed.emit()

func has(data: ComponentData) -> bool:
	return items.has(data)

func how_many(data: ComponentData) -> int:
	return items[data] if has(data) else 0
