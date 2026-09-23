/datum/species/sweeper
	name = "Sweeper"
	id = "sweeper"
	sexes = FALSE
	//mutant_bodyparts = list("wings" = "Tank")

	nojumpsuit = TRUE
	species_traits = list(NO_UNDERWEAR, NOEYESPRITES)
	inherent_traits = list(TRAIT_ADVANCEDTOOLUSER, TRAIT_GENELESS)
	use_skintones = FALSE
	changesource_flags = MIRROR_BADMIN | WABBAJACK
	no_equip = list( ITEM_SLOT_OCLOTHING, ITEM_SLOT_GLOVES, ITEM_SLOT_FEET, ITEM_SLOT_ICLOTHING, ITEM_SLOT_BACK, ITEM_SLOT_NECK, ITEM_SLOT_EYES)

/datum/species/sweeper/check_roundstart_eligible()
	if(SSevents.holidays && SSevents.holidays[HALLOWEEN])
		return TRUE
	return FALSE

/mob/living/carbon/human/species/sweeper/Initialize(mapload, cubespawned=FALSE, mob/spawner)
	var/tank = icon('icons/mob/mutant_bodyparts.dmi', "tank_sweeper_ADJ")
	add_overlay(tank)
	return ..()
