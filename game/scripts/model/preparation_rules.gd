extends RefCounted

## Character preparation modifiers. Levels in a saved preset are the chosen
## base levels; the visible and in-game levels include these modifiers.
const BACKSTORY_SKILLS := {
	"unknown": {},
	"rural_child": {"plants": 1, "animals": 1},
	"town_child": {"social": 1, "crafting": 1},
	"apprentice": {"construction": 1, "crafting": 1},
	"vatgrown_soldier": {"shooting": 2, "melee": 1},
	"farmer": {"plants": 2},
	"builder": {"construction": 2},
	"medic": {"medical": 2},
	"scholar": {"intellectual": 2}
}
## Backgrounds represent training. Traits and health change behavior or
## capacity, not the amount of training a colonist has received.
const TRAIT_SKILLS := {}
const CONDITION_SKILLS := {}

## RimWorld's human body-part HP and injury pain multipliers inform these
## preparation presets. Foxtopia still simulates one whole-body HP pool, but
## prepared wounds keep their part and count for display and safe setup checks.
const CONDITION_INJURIES := {
	"scar": {"kind": "scar", "severity": 0.0, "bleeding": 0.0},
	"cut_light": {"kind": "cut", "severity": 4.0, "bleeding": 0.10},
	"cut_deep": {"kind": "cut", "severity": 16.0, "bleeding": 0.40},
	"bruise": {"kind": "bruise", "severity": 6.0, "bleeding": 0.0},
	"burn": {"kind": "burn", "severity": 8.0, "bleeding": 0.0},
	"scratch": {"kind": "scratch", "severity": 4.0, "bleeding": 0.10}
}
const WOUND_PAIN_PER_SEVERITY := {"cut": 0.0125, "bruise": 0.0125, "burn": 0.01875,
	"scratch": 0.0125, "scar": 0.00625}
## The names are editor presets; RimWorld itself stores numeric severity.
## Values are deliberately limited by preparation_injury_error for each part.
const INJURY_SEVERITY_TIERS := ["minor", "moderate", "severe", "extreme"]
const INJURY_SEVERITY_PRESETS := {
	"scar": {"minor": 1.0, "moderate": 2.0, "severe": 3.0, "extreme": 4.0},
	"cut_light": {"minor": 2.0, "moderate": 4.0},
	"cut_deep": {"severe": 16.0, "extreme": 18.0},
	## Severe and extreme bruises are historical save values (6/8 damage).
	## New bruises use light or moderate labels; old rows retain their damage.
	"bruise": {"minor": 2.0, "moderate": 6.0, "severe": 6.0, "extreme": 8.0},
	"burn": {"minor": 2.0, "moderate": 5.0, "severe": 8.0, "extreme": 12.0},
	"scratch": {"minor": 2.0, "moderate": 4.0, "severe": 6.0, "extreme": 8.0}
}
const INJURY_DEFAULT_TIERS := {"scar": "minor", "cut_light": "moderate",
	"cut_deep": "severe", "bruise": "moderate", "burn": "severe", "scratch": "moderate"}
const INJURY_CAUSES := {
	"scar": ["unknown", "old_cut", "old_burn", "old_scratch"],
	"cut_light": ["unknown", "knife", "sword", "glass"],
	"cut_deep": ["unknown", "knife", "sword", "glass"],
	"bruise": ["unknown", "human_fist", "animal_strike", "blunt_weapon", "fall"],
	"burn": ["unknown", "fire", "hot_surface"],
	"scratch": ["unknown", "animal_claw"]
}
const BODY_PART_HP := {"head": 25.0, "torso": 40.0,
	"left_arm": 30.0, "right_arm": 30.0, "left_leg": 30.0, "right_leg": 30.0}
const LEGACY_INJURY_PARTS := {"scar": "torso", "cut_light": "left_arm", "cut_deep": "right_leg",
	"bruise": "torso", "burn": "left_arm"}
const MAX_PREPARATION_INJURIES := 6
const MAX_PREPARATION_PAIN := 0.60
const MAX_PREPARATION_BLEEDING := 0.80
const MIN_PREPARATION_HP := 55.0

## Game simulation values shared with the preparation descriptions.
const TRAIT_EFFECTS := {
	"hardworking": {"work_speed_factor": 1.20},
	"lazy": {"work_speed_factor": 0.80},
	"curious": {"research_speed_factor": 1.30},
	"timid": {"combat_damage_factor": 0.75},
	"kind": {"kind_words_mood": 5, "kind_words_opinion": 15, "kind_words_interval": 6},
	"ugly": {"first_impression_opinion": -20},
	"abrasive": {"argument_interval": 3}
}


static func trait_effects(trait_id: String) -> Dictionary:
	return TRAIT_EFFECTS.get(trait_id, {}).duplicate(true)


static func condition_injury(condition_id: String) -> Dictionary:
	return CONDITION_INJURIES.get(condition_id, {}).duplicate(true)


static func injury_default_tier(injury_id: String) -> String:
	return str(INJURY_DEFAULT_TIERS.get(injury_id, "minor"))


static func injury_causes(injury_id: String) -> Array:
	return (INJURY_CAUSES.get(injury_id, ["unknown"]) as Array).duplicate()


static func injury_severity_tiers(injury_id: String) -> Array:
	var result: Array = []
	var presets: Dictionary = INJURY_SEVERITY_PRESETS.get(injury_id, {})
	for tier in INJURY_SEVERITY_TIERS:
		if injury_id == "bruise" and tier in ["severe", "extreme"]: continue
		if presets.has(tier): result.append(tier)
	return result


static func injury_severity(injury_id: String, tier: String) -> float:
	if tier.is_empty():
		return float(CONDITION_INJURIES.get(injury_id, {}).get("severity", 0.0))
	return float(INJURY_SEVERITY_PRESETS.get(injury_id, {}).get(tier, 0.0))


static func injury_point_factor(entry: Dictionary) -> float:
	var injury_id := str(entry.get("kind", ""))
	var tier := str(entry.get("severity_tier", ""))
	if tier.is_empty(): return 1.0
	var baseline := float(CONDITION_INJURIES.get(injury_id, {}).get("severity", 0.0))
	if injury_id == "scar": baseline = 1.0
	return clampf(injury_severity(injury_id, tier) / maxf(1.0, baseline), 0.25, 3.0)


## Expand both current editable injury rows and older condition-only presets.
## Each returned dictionary describes one wound, rather than one UI row.
static func prepared_injuries(person: Dictionary) -> Array:
	var wounds: Array = []
	for raw_condition in person.get("health_conditions", []):
		var condition_id := str(raw_condition)
		# Older presets store scars as a condition with no body part. Preserve
		# their existing pain without creating a second wound or double charging it.
		if condition_id == "scar": continue
		if not CONDITION_INJURIES.has(condition_id): continue
		var legacy_wound: Dictionary = condition_injury(condition_id)
		legacy_wound["body_part"] = str(LEGACY_INJURY_PARTS[condition_id])
		legacy_wound["source_condition"] = condition_id
		wounds.append(legacy_wound)
	for raw_entry in person.get("health_injuries", []):
		if not raw_entry is Dictionary: continue
		var entry: Dictionary = raw_entry
		var injury_id := str(entry.get("kind", ""))
		if not CONDITION_INJURIES.has(injury_id): continue
		var count := clampi(int(entry.get("count", 1)), 0, MAX_PREPARATION_INJURIES)
		for instance in range(count):
			var wound: Dictionary = condition_injury(injury_id)
			var tier := str(entry.get("severity_tier", ""))
			if not tier.is_empty():
				var severity := injury_severity(injury_id, tier)
				wound["severity"] = severity
				wound["bleeding"] = severity * 0.025 if str(wound["kind"]) in ["cut", "scratch"] else 0.0
			wound["body_part"] = str(entry.get("body_part", ""))
			wound["cause"] = str(entry.get("cause", "unknown"))
			wound["severity_tier"] = tier
			wound["source_condition"] = ""
			wounds.append(wound)
	return wounds


## Return an actionable error instead of silently clipping a hazardous setup.
static func preparation_injury_error(person: Dictionary) -> String:
	var raw_entries: Variant = person.get("health_injuries", [])
	if not raw_entries is Array: return "Invalid prepared injuries."
	var row_keys: Dictionary = {}
	for raw_entry in raw_entries:
		if not raw_entry is Dictionary: return "Invalid prepared injury."
		var entry: Dictionary = raw_entry
		var injury_id := str(entry.get("kind", ""))
		var body_part := str(entry.get("body_part", ""))
		if not CONDITION_INJURIES.has(injury_id) or not BODY_PART_HP.has(body_part):
			return "Invalid injury type or body part."
		var tier := str(entry.get("severity_tier", ""))
		if not tier.is_empty() and not INJURY_SEVERITY_PRESETS[injury_id].has(tier):
			return "Invalid injury severity."
		var cause := str(entry.get("cause", "unknown"))
		if not injury_causes(injury_id).has(cause):
			return "Invalid injury cause for this type."
		var raw_count: Variant = entry.get("count", 1)
		if not (raw_count is int or raw_count is float) or float(raw_count) != float(int(raw_count)) or int(raw_count) < 1 or int(raw_count) > 3:
			return "Injury count must be between one and three."
		var row_key := "%s:%s:%s:%s" % [injury_id, body_part, tier, cause]
		if row_keys.has(row_key): return "Merge repeated injuries on the same body part."
		row_keys[row_key] = true
	var wounds := prepared_injuries(person)
	if wounds.size() > MAX_PREPARATION_INJURIES:
		return "A colonist may start with at most six injuries."
	var part_damage: Dictionary = {}
	var total_severity := 0.0
	var total_bleeding := 0.0
	for wound in wounds:
		var part := str(wound.get("body_part", ""))
		var severity := float(wound.get("severity", 0.0))
		part_damage[part] = float(part_damage.get(part, 0.0)) + severity
		total_severity += severity
		total_bleeding += float(wound.get("bleeding", 0.0))
	for part in part_damage:
		var max_damage_ratio := 0.35 if part == "head" else 0.50 if part == "torso" else 0.60
		if float(part_damage[part]) > float(BODY_PART_HP[part]) * max_damage_ratio:
			return "Too much damage to one body part."
	if total_severity > 100.0 - MIN_PREPARATION_HP:
		return "Starting injuries would leave too little health."
	if total_bleeding > MAX_PREPARATION_BLEEDING + 0.0001:
		return "Starting injuries cause too much bleeding."
	var scar_pain := 0.05 if (person.get("health_conditions", []) as Array).has("scar") else 0.0
	var total_pain := scar_pain
	for wound in wounds: total_pain += wound_pain(wound)
	if total_pain >= MAX_PREPARATION_PAIN:
		return "Starting injuries would cause too much pain."
	return ""


static func wound_pain(wound: Dictionary) -> float:
	var kind := str(wound.get("kind", ""))
	if kind == "scar" and float(wound.get("severity", 0.0)) <= 0.0: return 0.05
	return maxf(0.0, float(wound.get("severity", 0.0))) * float(WOUND_PAIN_PER_SEVERITY.get(kind, 0.0125))


static func health_pain(health: Dictionary) -> float:
	var pain := 0.05 if (health.get("conditions", []) as Array).has("scar") else 0.0
	for wound in health.get("wounds", []):
		if wound is Dictionary:
			pain += wound_pain(wound)
	return clampf(pain, 0.0, 1.0)


## Foxtopia's coarse capacity model keeps affected limbs meaningful without
## treating a non-destroyed part as missing. Damage heals with the wound.
static func injury_capacity_factors(health: Dictionary) -> Dictionary:
	var damage: Dictionary = {}
	for raw_wound in health.get("wounds", []):
		if not raw_wound is Dictionary: continue
		var part := str(raw_wound.get("body_part", ""))
		if not BODY_PART_HP.has(part): continue
		damage[part] = float(damage.get(part, 0.0)) + maxf(0.0, float(raw_wound.get("severity", 0.0)))
	var head_fraction := clampf(float(damage.get("head", 0.0)) / float(BODY_PART_HP["head"]), 0.0, 1.0)
	var arm_fraction := clampf(float(damage.get("left_arm", 0.0)) / float(BODY_PART_HP["left_arm"]), 0.0, 1.0) + clampf(float(damage.get("right_arm", 0.0)) / float(BODY_PART_HP["right_arm"]), 0.0, 1.0)
	var leg_fraction := clampf(float(damage.get("left_leg", 0.0)) / float(BODY_PART_HP["left_leg"]), 0.0, 1.0) + clampf(float(damage.get("right_leg", 0.0)) / float(BODY_PART_HP["right_leg"]), 0.0, 1.0)
	return {"consciousness": clampf(1.0 - head_fraction * 0.35, 0.65, 1.0),
		"manipulation": clampf(1.0 - arm_fraction * 0.25, 0.50, 1.0),
		"moving": clampf(1.0 - leg_fraction * 0.35, 0.40, 1.0)}


static func injury_work_factor(health: Dictionary, work_type: String) -> float:
	var factors := injury_capacity_factors(health)
	var result := float(factors["consciousness"]) * float(factors["manipulation"])
	if work_type in ["chop", "mine", "harvest", "haul", "build"]:
		result *= float(factors["moving"])
	return result


static func pain_mood_penalty(pain: float) -> int:
	if pain >= 0.80: return -20
	if pain >= 0.40: return -15
	if pain >= 0.15: return -10
	if pain >= 0.01: return -5
	return 0


static func pain_work_factor(pain: float) -> float:
	return 1.0 - clampf((pain - 0.10) / 2.25, 0.0, 0.40)


static func skill_modifiers(childhood: String, adulthood: String, traits: Array, conditions: Array) -> Dictionary:
	var modifiers := {}
	for selection in [childhood, adulthood]:
		_accumulate(modifiers, BACKSTORY_SKILLS.get(selection, {}))
	for trait_id in traits:
		_accumulate(modifiers, TRAIT_SKILLS.get(str(trait_id), {}))
	for condition in conditions:
		_accumulate(modifiers, CONDITION_SKILLS.get(str(condition), {}))
	return modifiers


static func incapable_of(childhood: String, adulthood: String, traits: Array, _conditions: Array) -> Array:
	var result: Array = []
	if childhood == "vatgrown_soldier":
		result.append_array(["social", "medical"])
	if adulthood == "scholar":
		result.append("haul")
	if traits.has("pyromaniac"):
		result.append("firefighting")
	return result


static func effective_skills(base: Dictionary, childhood: String, adulthood: String, traits: Array, conditions: Array) -> Dictionary:
	var result: Dictionary = base.duplicate(true)
	var modifiers := skill_modifiers(childhood, adulthood, traits, conditions)
	for skill in modifiers:
		result[skill] = clampi(int(base.get(skill, 0)) + int(modifiers[skill]), 0, 20)
	return result


static func _accumulate(target: Dictionary, source: Dictionary) -> void:
	for skill in source:
		target[skill] = int(target.get(skill, 0)) + int(source[skill])
