# run_data.gd
extends RefCounted
class_name RunData


var remaining_pulls: int
var remaining_currency: int
var remaining_gems: int

var chars_pulled: int
var weps_pulled: int
var chars_4_star_pulled: int
var weps_4_star_pulled: int

var char_pity: int
var wep_pity: int
var char_4_star_pity: int
var wep_4_star_pity: int

var char_guarantee: bool
var wep_guarantee: bool
var char_4_star_guarantee: bool
var wep_4_star_guarantee: bool


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _init(remaining_pulls: int = 0, remaining_gems: int = 0, remaining_currency: int = 0, chars_pulled: int = 0,
		weps_pulled: int = 0, char_pity: int = 0, wep_pity: int = 0, char_guarantee: bool = false,
		wep_guarantee: bool = false):
	
	self.remaining_pulls = remaining_pulls
	self.remaining_currency = remaining_currency
	self.remaining_gems = remaining_gems
	self.chars_pulled = chars_pulled
	self.weps_pulled = weps_pulled
	self.char_pity = char_pity
	self.weps_pity = wep_pity
	self.char_guarantee = char_guarantee
	self.wep_guarantee = wep_guarantee
	
	self.chars_4_star_pulled = 0
	self.weps_4_star_pulled = 0
	self.char_4_star_pity = 0
	self.wep_4_star_pity = 0
	self.char_4_star_guarantee = false
	self.wep_4_star_guarantee = false


# Fully reset value of a simulation run. Use when starting a new run
func reset(banner: Banner) -> void:
	remaining_pulls = 0
	remaining_currency = 0
	remaining_gems = 0
	chars_pulled = 0
	weps_pulled = 0
	chars_4_star_pulled = 0
	weps_4_star_pulled = 0
	char_pity = 0
	wep_pity = 0
	char_4_star_pity = 0
	wep_4_star_pity = 0
	char_guarantee = false
	wep_guarantee = false
	char_4_star_guarantee = false
	wep_4_star_guarantee = false
	
	currency_to_pulls(banner)
	gems_to_pulls(banner)


func add_pulls(amount: int) -> void:
	remaining_pulls += amount


func currency_to_pulls(banner: Banner) -> void:
	remaining_pulls += remaining_currency / banner.currency_conversion_rate # Excess currency not needed


func gems_to_pulls(banner: Banner) -> void:
	while remaining_gems >= banner.gem_conversion_rate:
		remaining_gems -= banner.gem_conversion_rate
		add_pulls(1)


func add_gems(banner: Banner, amount: int) -> void:
	remaining_gems += amount
	gems_to_pulls(banner)


func win_fifty_fifty(banner_type: String) -> void:
	match banner_type:
		"CHARACTER":
			chars_pulled += 1
			char_guarantee = false
		"WEAPON":
			weps_pulled += 1
			wep_guarantee = false


func lose_fifty_fifty(banner_type: String) -> void:
	match banner_type:
		"CHARACTER":
			char_guarantee = true
		"WEAPON":
			wep_guarantee = true
