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
var char_four_star_pity: int
var wep_four_star_pity: int

var char_guarantee: bool
var wep_guarantee: bool
var char_four_star_guarantee: bool
var wep_four_star_guarantee: bool


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _init(in_remaining_pulls: int = 0, in_remaining_gems: int = 0, in_remaining_currency: int = 0, 
		in_char_pity: int = 0, in_wep_pity: int = 0, in_char_guarantee: bool = false, in_wep_guarantee: bool = false):
	self.remaining_pulls = in_remaining_pulls
	self.remaining_currency = in_remaining_currency
	self.remaining_gems = in_remaining_gems
	self.char_pity = in_char_pity
	self.wep_pity = in_wep_pity
	self.char_guarantee = in_char_guarantee
	self.wep_guarantee = in_wep_guarantee
	
	self.chars_pulled = 0
	self.weps_pulled = 0
	#self.chars_four_star_pulled = 0
	#self.weps_four_star_pulled = 0
	self.char_four_star_pity = 0
	self.wep_four_star_pity = 0
	self.char_four_star_guarantee = false
	self.wep_four_star_guarantee = false


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
	char_four_star_pity = 0
	wep_four_star_pity = 0
	char_guarantee = false
	wep_guarantee = false
	char_four_star_guarantee = false
	wep_four_star_guarantee = false
	
	# Convert currency and gems to pulls immediately on reset
	_currency_to_pulls(banner)
	_gems_to_pulls(banner)


# Convert currency to pulls
func _currency_to_pulls(banner: Banner) -> void:
	remaining_pulls += remaining_currency / banner.currency_conversion_rate # Excess currency not needed


# Convert gems to pulls
func _gems_to_pulls(banner: Banner) -> void:
	while remaining_gems >= banner.gem_conversion_rate:
		remaining_gems -= banner.gem_conversion_rate
		remaining_pulls += 1


# Gain gems, then check if it's enough gems to convert into a pull
func add_gems(banner: Banner, amount: int) -> void:
	remaining_gems += amount
	_gems_to_pulls(banner)


# Called when a 50/50 is won. Corresponding type is pulled, then guarantee is lost
func win_fifty_fifty(pull_type: Banner.PullType, rarity: Banner.Rarity) -> void:
	match pull_type:
		Banner.PullType.CHARACTER:
			match rarity:
				Banner.Rarity.FIVE_STAR:
					chars_pulled += 1
					char_guarantee = false
				Banner.Rarity.FOUR_STAR:
					char_four_star_guarantee = false
		Banner.PullType.WEAPON:
			match rarity:
				Banner.Rarity.FIVE_STAR:
					weps_pulled += 1
					wep_guarantee = false
				Banner.Rarity.FOUR_STAR:
					wep_four_star_guarantee = false


# Called when a 50/50 is lost. Guarantee is now true
func lose_fifty_fifty(pull_type: Banner.PullType, rarity: Banner.Rarity) -> void:
	match pull_type:
		Banner.PullType.CHARACTER:
			match rarity:
				Banner.Rarity.FIVE_STAR:
					char_guarantee = true
				Banner.Rarity.FOUR_STAR:
					char_four_star_guarantee = true
		Banner.PullType.WEAPON:
			match rarity:
				Banner.Rarity.FIVE_STAR:
					wep_guarantee = true
				Banner.Rarity.FOUR_STAR:
					wep_four_star_guarantee = true
