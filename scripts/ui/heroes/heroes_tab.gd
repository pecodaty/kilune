class_name HeroesTab
extends Control
## Heroes tab: hero header on top, six sub-tab pages (Class, Skills, Talents,
## Equipment, Cards, Pets) in a clipped content wrapper, a shared detail
## modal, and the sub-tab bar below. Browsing and equipping stay separate.
## Spec: docs/art-direction/interface-heroes-screen.md and
## references/reference-code/src/app/App.tsx.

signal class_equipped(class_id: StringName)
signal abilities_open_requested(class_id: StringName)

## Until a HeroSystem owns progression, the reference state applies:
## Hunter is the equipped class.
@export var current_class: StringName = &"hunter":
	set(v):
		current_class = v
		_apply_state()
@export var browsed_class: StringName = &"druid":
	set(v):
		browsed_class = v
		_apply_state()

@onready var _header: HeroHeader = $Rows/HeroHeader
@onready var _rail: ClassRail = $Rows/ContentWrapper/ClassPage/ClassRail
@onready var _arch: PortraitArch = $Rows/ContentWrapper/ClassPage/DetailColumn/PortraitArch
@onready var _info: ClassInfoPanel = $Rows/ContentWrapper/ClassPage/DetailColumn/ClassInfoPanel
@onready var _modal: ItemModal = $Rows/ContentWrapper/ItemModal
@onready var _sub_bar: SubTabBar = $Rows/SubTabBar

var _pages: Dictionary = {}


func _ready() -> void:
	clip_contents = true
	_pages = {
		&"class": $Rows/ContentWrapper/ClassPage,
		&"skills": $Rows/ContentWrapper/SkillsTab,
		&"talents": $Rows/ContentWrapper/TalentsTab,
		&"equipment": $Rows/ContentWrapper/EquipmentTab,
		&"cards": $Rows/ContentWrapper/CardsTab,
		&"pets": $Rows/ContentWrapper/PetsTab,
	}
	_rail.class_browsed.connect(browse)
	_info.class_selected.connect(_on_class_selected)
	_info.abilities_pressed.connect(func() -> void: abilities_open_requested.emit(browsed_class))
	_sub_bar.sub_tab_selected.connect(show_sub_tab)
	for tab_id in [&"equipment", &"cards"]:
		(_pages[tab_id] as SubTabPage).modal_requested.connect(_modal.show_payload)
	_apply_state()


## Switch the visible sub-tab page.
func show_sub_tab(tab_id: StringName) -> void:
	if not _pages.has(tab_id):
		return
	_sub_bar.active = tab_id
	for id in _pages:
		_pages[id].visible = id == tab_id
	if _modal.visible:
		_modal.close()


## Show a class's details without equipping it.
func browse(class_id: StringName) -> void:
	browsed_class = class_id


func _on_class_selected() -> void:
	current_class = browsed_class
	class_equipped.emit(current_class)


func _apply_state() -> void:
	if not is_node_ready():
		return
	var cls := HeroClassData.class_data(browsed_class)
	_rail.set_browsed(browsed_class)
	_rail.set_current(current_class)
	_arch.set_class(cls)
	_info.set_class(cls, browsed_class == current_class)
