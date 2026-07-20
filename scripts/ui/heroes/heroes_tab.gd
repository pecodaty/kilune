class_name HeroesTab
extends Control
## Heroes owns Fern's session-local progression state and binds every mutable
## character tab to it. The default destination is the live Stats sheet.

@onready var _header: HeroHeader = $Rows/HeroHeader
@onready var _stats: StatsTab = $Rows/ContentWrapper/StatsTab
@onready var _skills: SkillsTab = $Rows/ContentWrapper/SkillsTab
@onready var _talents: TalentsTab = $Rows/ContentWrapper/TalentsTab
@onready var _equipment: EquipmentTab = $Rows/ContentWrapper/EquipmentTab
@onready var _modal: ItemModal = $Rows/ContentWrapper/ItemModal
@onready var _sub_bar: SubTabBar = $Rows/SubTabBar

var _state := HeroProgressionState.new()
var _pages: Dictionary = {}


func _ready() -> void:
	clip_contents = true
	_pages = {
		&"stats": _stats,
		&"skills": _skills,
		&"talents": _talents,
		&"equipment": _equipment,
		&"cards": $Rows/ContentWrapper/CardsTab,
		&"pets": $Rows/ContentWrapper/PetsTab,
	}
	_header.bind_state(_state)
	_stats.bind_state(_state)
	_skills.bind_state(_state)
	_talents.bind_state(_state)
	_equipment.bind_state(_state)
	_sub_bar.sub_tab_selected.connect(show_sub_tab)
	_modal.action_pressed.connect(_equipment.perform_item_action)
	for tab_id in [&"equipment", &"cards"]:
		(_pages[tab_id] as SubTabPage).modal_requested.connect(_modal.show_payload)
	show_sub_tab(&"stats")


func show_sub_tab(tab_id: StringName) -> void:
	if not _pages.has(tab_id):
		return
	_sub_bar.active = tab_id
	for id in _pages:
		_pages[id].visible = id == tab_id
	if _modal.visible:
		_modal.close()
