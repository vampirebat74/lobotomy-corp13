/* E.G.O assimilation */
/obj/effect/proc_holder/ability/ego_assimilation
	name = "E.G.O assimilation"
	desc = "Convert an ALEPH E.G.O into a weapon comptaible with your suit. Can only be used once."
	action_icon = 'icons/obj/ego_weapons.dmi'
	action_icon_state = ""
	base_icon_state = "template"
	var/target_type = /obj/item/ego_weapon/mimicry
	var/obj/structure/toolabnormality/wishwell/linked_structure

/obj/effect/proc_holder/ability/ego_assimilation/Perform(atom/target, user)
	..()
	target = FindItems(user)//take the return value of the FindItems() proc here
	if(!target)
		to_chat(user, span_notice("There are no E.G.O weapons nearby."))
		return
	if(!istype(target, /obj/item/ego_weapon))
		to_chat(user, span_notice("That is not an E.G.O weapon."))
		return
	if(!linked_structure)//Refer to wishing well for a list of all ALEPH E.G.O
		linked_structure = GLOB.wishwell
		if(!linked_structure)
			to_chat(user, span_notice("This ability is currently unavailable."))
			return
	if(target.type in linked_structure.alephitem)//"alephitem" is a list
		new target_type(get_turf(target))
		qdel(target)
		DeleteAbility(user)//Deletes the ability and removes it from the ego suit
		return
	to_chat(user, span_notice("Target's risk level is too low."))

/obj/effect/proc_holder/ability/ego_assimilation/proc/FindItems(user)
	var/list/stufflist = list()
	var/obj/item/ego_weapon/chosen_ego
	for(var/obj/item/ego_weapon/i in view(2, user))
		stufflist += i
	chosen_ego = input(user, "Which E.G.O will you assimilate?") as null|anything in stufflist
	if(!chosen_ego)
		return
	return chosen_ego

/obj/effect/proc_holder/ability/ego_assimilation/proc/DeleteAbility(mob/living/carbon/human/user)
	var/obj/item/clothing/suit/armor/ego_gear/realization/mysuit = user.get_item_by_slot(ITEM_SLOT_OCLOTHING)
	if(!istype(mysuit))
		return
	mysuit.realized_ability = null//sets it to a null value
	qdel(src)

/obj/effect/proc_holder/ability/ego_assimilation/farmwatch
	base_icon_state = "farmwatch"
	action_icon_state = "farmwatch"
	target_type = /obj/item/ego_weapon/farmwatch

/obj/effect/proc_holder/ability/ego_assimilation/spicebush
	base_icon_state = "spicebush"
	action_icon_state = "spicebush"
	target_type = /obj/item/ego_weapon/spicebush

/obj/effect/proc_holder/ability/ego_assimilation/gasharpoon
	base_icon_state = "gasharpoon"
	action_icon_state = "gasharpoon"
	target_type = /obj/item/ego_weapon/shield/gasharpoon

/* Fragment of the Universe - One with the Universe */
/obj/effect/proc_holder/ability/universe_song
	name = "Song of the Universe"
	desc = "An ability that allows its user to damage and slow down the enemies around them."
	action_icon_state = "universe_song0"
	base_icon_state = "universe_song"
	cooldown_time = 20 SECONDS

	var/damage_amount = 50 // Amount of white damage dealt to enemies per "pulse".
	var/damage_slowdown = 0.7 // Slowdown per pulse
	var/damage_count = 5 // How many times the damage and slowdown is applied
	var/damage_range = 6

/obj/effect/proc_holder/ability/universe_song/Perform(target, mob/user)
	playsound(get_turf(user), 'sound/abnormalities/fragment/sing.ogg', 50, 0, 4)
	Pulse(user)
	for(var/i = 1 to damage_count - 1)
		addtimer(CALLBACK(src, PROC_REF(Pulse), user), i*3)
	return ..()

/obj/effect/proc_holder/ability/universe_song/proc/Pulse(mob/user)
	new /obj/effect/temp_visual/fragment_song(get_turf(user))
	for(var/mob/living/L in view(damage_range, user))
		if(user.faction_check_mob(L, FALSE))
			continue
		if(L.stat == DEAD)
			continue
		L.apply_damage(damage_amount, WHITE_DAMAGE, null, L.run_armor_check(null, WHITE_DAMAGE))
		new /obj/effect/temp_visual/revenant(get_turf(L))
		if(ishostile(L))
			var/mob/living/simple_animal/hostile/H = L
			H.TemporarySpeedChange(damage_slowdown, 5 SECONDS) // Slow down

/mob/living/simple_animal/hostile/shrimp_soldier/friendly/capitalism_shrimp
	name = "wellcheers corp liquidation officer"

/mob/living/simple_animal/hostile/shrimp_soldier/friendly/capitalism_shrimp/Initialize()
	.=..()
	QDEL_IN(src, (90 SECONDS))

/obj/effect/proc_holder/ability/shrimp
	name = "Backup Shrimp"
	desc = "Spawns 6 wellcheers corp liquidation officers for a period of time."
	action_icon_state = "shrimp0"
	base_icon_state = "shrimp"
	cooldown_time = 90 SECONDS



/obj/effect/proc_holder/ability/shrimp/Perform(target, mob/user)
	for(var/i = 1 to 6)
		new /mob/living/simple_animal/hostile/shrimp_soldier/friendly/capitalism_shrimp(get_turf(user))
	return ..()

/* Big Bird - Eyes of God */
/obj/effect/proc_holder/ability/lamp
	name = "Lamp of Salvation"
	desc = "An ability that slows and weakens all enemies around the user."
	action_icon_state = "lamp0"
	base_icon_state = "lamp"
	cooldown_time = 30 SECONDS

	var/debuff_range = 8
	var/debuff_slowdown = 0.5 // Slowdown per use(funfact this was meant to be an 80% slow but I accidentally made it 20%)

/obj/effect/proc_holder/ability/lamp/Perform(target, mob/user)
	cooldown = world.time + (2 SECONDS)
	if(!do_after(user, 1.5 SECONDS))
		to_chat(user, span_warning("You must stand still to see!"))
		return
	playsound(get_turf(user), 'sound/abnormalities/bigbird/hypnosis.ogg', 75, 0, 2)
	for(var/mob/living/L in view(debuff_range, user))
		if(user.faction_check_mob(L, FALSE))
			continue
		if(L.stat == DEAD)
			continue
		new /obj/effect/temp_visual/revenant(get_turf(L))
		if(ishostile(L))
			var/mob/living/simple_animal/hostile/H = L
			H.apply_status_effect(/datum/status_effect/salvation)
			H.TemporarySpeedChange(1 + debuff_slowdown , 15 SECONDS, TRUE) // Slow down_status_effect(/datum/status_effect/salvation)
	return ..()

/datum/status_effect/salvation
	id = "salvation"
	status_type = STATUS_EFFECT_UNIQUE
	duration = 15 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/salvation

/datum/status_effect/salvation/on_apply()
	. = ..()
	if(!isanimal(owner))
		return
	var/mob/living/simple_animal/M = owner
	M.AddModifier(/datum/dc_change/salvation)

/datum/status_effect/salvation/on_remove()
	. = ..()
	if(!isanimal(owner))
		return
	var/mob/living/simple_animal/M = owner
	M.RemoveModifier(/datum/dc_change/salvation)

/atom/movable/screen/alert/status_effect/salvation
	name = "Salvation"
	desc = "You will be saved... Also makes you to be more vulnerable to all attacks."
	icon = 'icons/mob/actions/actions_ability.dmi'
	icon_state = "salvation"

/* Nothing There - Shell */
/obj/effect/proc_holder/ability/goodbye
	name = "Goodbye"
	desc = "An ability that does massive damage in an area and heals you."
	action_icon_state = "goodbye0"
	base_icon_state = "goodbye"
	cooldown_time = 30 SECONDS

	var/damage_amount = 400 // Amount of good bye damage

/obj/effect/proc_holder/ability/goodbye/Perform(target, mob/user)
	var/mob/living/carbon/human/H = user
	cooldown = world.time + (1.5 SECONDS)
	playsound(get_turf(user), 'sound/abnormalities/nothingthere/goodbye_cast.ogg', 75, 0, 5)
	if(!do_after(user, 1 SECONDS))
		to_chat(user, span_warning("You must stand still to do the nothing there classic!"))
		return
	for(var/turf/T in view(2, user))
		new /obj/effect/temp_visual/nt_goodbye(T)
		for(var/mob/living/L in T)
			if(user.faction_check_mob(L, FALSE))
				continue
			if(L.stat == DEAD)
				continue
			H.adjustBruteLoss(-10)
			L.apply_damage(damage_amount, RED_DAMAGE, null, L.run_armor_check(null, RED_DAMAGE), spread_damage = TRUE)
			if(L.health < 0)
				L.gib()
	playsound(get_turf(user), 'sound/abnormalities/nothingthere/goodbye_attack.ogg', 75, 0, 7)
	return ..()
/* Mosb - Laughter */
/obj/effect/proc_holder/ability/screach
	name = "Screach"
	desc = "An ability that damages all enemies around the user and increases their weakness to black damage."
	action_icon_state = "screach0"
	base_icon_state = "screach"
	cooldown_time = 20 SECONDS

	var/damage_amount = 200 // Amount of black damage dealt to enemies. Humans receive half of it.
	var/damage_range = 7

/obj/effect/proc_holder/ability/screach/Perform(target, mob/user)
	cooldown = world.time + (2 SECONDS)
	playsound(get_turf(user), 'sound/abnormalities/mountain/bite.ogg', 50, 0)
	if(!do_after(user, 1.5 SECONDS))
		to_chat(user, span_warning("You must stand still to screach!"))
		return
	var/mob/living/carbon/human/H = user
	playsound(get_turf(user), 'sound/abnormalities/mountain/scream.ogg', 75, 0, 2)
	visible_message(span_danger("[H] screams wildly!"))
	new /obj/effect/temp_visual/voidout(get_turf(H))
	for(var/mob/living/L in view(damage_range, user))
		if(user.faction_check_mob(L, FALSE))
			continue
		if(L.stat == DEAD)
			continue
		L.apply_damage(ishuman(L) ? damage_amount*0.5 : damage_amount, BLACK_DAMAGE, null, L.run_armor_check(null, BLACK_DAMAGE))
		L.apply_status_effect(/datum/status_effect/mosb_black_debuff)
	return ..()

/datum/status_effect/mosb_black_debuff
	id = "mosb_black_debuff"
	status_type = STATUS_EFFECT_UNIQUE
	duration = 15 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/mosb_black_debuff

/datum/status_effect/mosb_black_debuff/on_apply()
	. = ..()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.physiology.black_mod *= 1.5
		return
	var/mob/living/simple_animal/M = owner
	M.AddModifier(/datum/dc_change/mosb_black)

/datum/status_effect/mosb_black_debuff/on_remove()
	. = ..()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.physiology.black_mod /= 1.5
		return
	var/mob/living/simple_animal/M = owner
	M.RemoveModifier(/datum/dc_change/mosb_black)

/atom/movable/screen/alert/status_effect/mosb_black_debuff
	name = "Dread"
	desc = "Your fear is causing you to be more vulnerable to BLACK attacks."
	icon = 'icons/mob/actions/actions_ability.dmi'
	icon_state = "screach"

/* Judgement Bird - Head of God */
/obj/effect/proc_holder/ability/judgement
	name = "Soul Judgement"
	desc = "An ability that damages all enemies around the user and increases their weakness to pale damage."
	action_icon_state = "judgement0"
	base_icon_state = "judgement"
	cooldown_time = 20 SECONDS

	var/damage_amount = 150 // Amount of pale damage dealt to enemies. Humans receive half of it.
	var/damage_range = 9

/obj/effect/proc_holder/ability/judgement/Perform(target, mob/user)
	cooldown = world.time + (2 SECONDS)
	playsound(get_turf(user), 'sound/abnormalities/judgementbird/pre_ability.ogg', 50, 0)
	var/obj/effect/temp_visual/judgement/still/J = new (get_turf(user))
	animate(J, pixel_y = 24, time = 1.5 SECONDS)
	if(!do_after(user, 1.5 SECONDS))
		to_chat(user, span_warning("You must stand still to perform judgement!"))
		return
	playsound(get_turf(user), 'sound/abnormalities/judgementbird/ability.ogg', 75, 0, 2)
	for(var/mob/living/L in view(damage_range, user))
		if(user.faction_check_mob(L, FALSE))
			continue
		if(L.stat == DEAD)
			continue
		new /obj/effect/temp_visual/judgement(get_turf(L))
		L.apply_damage(ishuman(L) ? damage_amount*0.5 : damage_amount, PALE_DAMAGE, null, L.run_armor_check(null, PALE_DAMAGE))
		L.apply_status_effect(/datum/status_effect/judgement_pale_debuff)
	return ..()

/datum/status_effect/judgement_pale_debuff
	id = "judgement_pale_debuff"
	status_type = STATUS_EFFECT_UNIQUE
	duration = 15 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/judgement_pale_debuff

/datum/status_effect/judgement_pale_debuff/on_apply()
	. = ..()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.physiology.pale_mod /= 1.5
		return
	var/mob/living/simple_animal/M = owner
	M.AddModifier(/datum/dc_change/godhead)

/datum/status_effect/judgement_pale_debuff/on_remove()
	. = ..()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.physiology.pale_mod *= 1.5
		return
	var/mob/living/simple_animal/M = owner
	M.RemoveModifier(/datum/dc_change/godhead)

/atom/movable/screen/alert/status_effect/judgement_pale_debuff
	name = "Soul Drain"
	desc = "Your sinful actions have made your soul more vulnerable to PALE attacks."
	icon = 'icons/mob/actions/actions_ability.dmi'
	icon_state = "judgement"

/obj/effect/proc_holder/ability/fire_explosion
	name = "Match flame"
	desc = "An ability that deals high amount of RED damage to EVERYONE around the user after short delay."
	action_icon_state = "fire0"
	base_icon_state = "fire"
	cooldown_time = 30 SECONDS
	var/explosion_damage = 1000 // Humans receive half of it.
	var/explosion_range = 6

/obj/effect/proc_holder/ability/fire_explosion/Perform(target, mob/user)
	cooldown = world.time + (5 SECONDS)
	playsound(get_turf(user), 'sound/abnormalities/scorchedgirl/pre_ability.ogg', 50, 0, 2)
	if(!do_after(user, 1.5 SECONDS))
		to_chat(user, span_warning("You must stand still to ignite the explosion!"))
		return
	playsound(get_turf(user), 'sound/abnormalities/scorchedgirl/ability.ogg', 60, 0, 4)
	var/obj/effect/temp_visual/human_fire/F = new(get_turf(user))
	F.alpha = 0
	F.dir = user.dir
	animate(F, alpha = 255, time = (2 SECONDS))
	if(!do_after(user, 2.5 SECONDS))
		to_chat(user, span_warning("You must stand still to finish the ability!"))
		animate(F, alpha = 0, time = 5)
		return
	animate(F, alpha = 0, time = 5)
	INVOKE_ASYNC(src, PROC_REF(FireExplosion), get_turf(user))
	return ..()

/obj/effect/proc_holder/ability/fire_explosion/proc/FireExplosion(turf/T)
	playsound(T, 'sound/abnormalities/scorchedgirl/explosion.ogg', 125, 0, 8)
	for(var/i = 1 to explosion_range)
		for(var/turf/open/TT in spiral_range_turfs(i, T) - spiral_range_turfs(i-1, T))
			new /obj/effect/temp_visual/fire(TT)
			for(var/mob/living/L in TT)
				if(L.stat == DEAD)
					continue
				playsound(get_turf(L), 'sound/effects/wounds/sizzle2.ogg', 25, TRUE)
				L.apply_damage(ishuman(L) ? explosion_damage*0.5 : explosion_damage, RED_DAMAGE, null, L.run_armor_check(null, RED_DAMAGE))
		sleep(1)

/* King of Greed - Gold Experience */
/obj/effect/proc_holder/ability/road_of_gold
	name = "The Road of Gold"
	desc = "An ability that teleports you to the nearest non-visible threat.If you use a Gold Rush weapon, you can significantly weaken the enemy for a few seconds."
	action_icon_state = "gold0"
	base_icon_state = "gold"
	cooldown_time = 30 SECONDS

	var/list/spawned_effects = list()
	var/using_goldrush

/obj/effect/proc_holder/ability/road_of_gold/Perform(mob/living/simple_animal/hostile/target, mob/user)
	if(!istype(user))
		return ..()
	cooldown = world.time + (2 SECONDS)
	target = null
	var/dist = 100
	for(var/mob/living/simple_animal/hostile/H in GLOB.alive_mob_list)
		if(H.z != user.z)
			continue
		if(H.stat == DEAD)
			continue
		if(H.status_flags & GODMODE)
			continue
		if(user.faction_check_mob(H, FALSE))
			continue
		if(H in view(7, user))
			continue
		var/t_dist = get_dist(user, H)
		if(t_dist >= dist)
			continue
		dist = t_dist
		target = H
	if(!target)
		to_chat(user, span_notice("You can't find anything else nearby!"))
		return ..()
	Circle(null, null, user)
	var/pre_circle_dir = user.dir
	to_chat(user, span_warning("You begin along the Road of Gold to your target!"))
	if(!do_after(user, 15, src))
		to_chat(user, span_warning("You abandon your path!"))
		CleanUp()
		return ..()
	animate(user, alpha = 0, time = 5)
	step_towards(user, get_step(user, pre_circle_dir))
	new /obj/effect/temp_visual/guardian/phase(get_turf(src))
	var/turf/open/target_turf = get_step_towards(target, user)
	if(!istype(target_turf))
		target_turf = pick(get_adjacent_open_turfs(target))
	if(!target_turf)
		to_chat(user, span_warning("No road leads to that target!?"))
		CleanUp()
		return ..()
	var/obj/effect/qoh_sygil/kog/KS = Circle(target_turf, get_step(target_turf, pick(GLOB.cardinals)), null)
	sleep(5)
	user.dir = get_dir(user, target)
	animate(user, alpha = 255, time = 5)
	new /obj/effect/temp_visual/guardian/phase/out(get_turf(KS))
	user.forceMove(get_turf(KS))
	CleanUp()
	sleep(2.5)
	step_towards(user, get_step_towards(KS, target))
	if(get_dist(user, target) <= 1)
		var/obj/item/held = user.get_active_held_item()
		if(held)
			held.attack(target, user)
			if(held == /obj/item/ego_weapon/goldrush/nihil || held == /obj/item/ego_weapon/goldrush)
				target.apply_status_effect(/datum/status_effect/GoldStaggered)
	return ..()

/obj/effect/proc_holder/ability/road_of_gold/proc/CleanUp()
	for(var/obj/effect/FX in spawned_effects)
		if(istype(FX, /obj/effect/qoh_sygil/kog))
			var/obj/effect/qoh_sygil/kog/KS = FX
			KS.fade_out()
			continue
		FX.Destroy()
	listclearnulls(spawned_effects)

/obj/effect/proc_holder/ability/road_of_gold/proc/Circle(turf/first_target, turf/second_target, mob/user = null)
	var/obj/effect/qoh_sygil/kog/KS
	if(user)
		KS = new(get_turf(user))
	else
		KS = new(first_target)
	spawned_effects += KS
	var/matrix/M = matrix(KS.transform)
	M.Translate(0, 32)
	var/rot_angle
	var/my_dir
	if(user)
		my_dir = user.dir
		rot_angle = Get_Angle(user, get_step(user, my_dir))
	else
		my_dir = get_dir(first_target, second_target)
		rot_angle = Get_Angle(first_target, get_step_towards(first_target, second_target))
	M.Turn(rot_angle)
	switch(my_dir)
		if(EAST)
			M.Scale(0.5, 1)
			KS.layer += 0.1
		if(WEST)
			M.Scale(0.5, 1)
			KS.layer += 0.1
		if(NORTH)
			M.Scale(1, 0.5)
			KS.layer += 0.1
		if(SOUTH)
			M.Scale(1, 0.5)
			KS.layer -= 0.1
	KS.transform = M
	return KS

/datum/status_effect/GoldStaggered
	status_type = STATUS_EFFECT_UNIQUE
	duration = 5 SECONDS

/datum/status_effect/GoldStaggered/on_apply()
	. = ..()
	var/mob/living/simple_animal/M = owner
	M.AddModifier(/datum/dc_change/gold_staggered)

/datum/status_effect/GoldStaggered/on_remove()
	. = ..()
	var/mob/living/simple_animal/M = owner
	M.RemoveModifier(/datum/dc_change/gold_staggered)


/* Servant of Wrath - Wounded Courage */
/obj/effect/proc_holder/ability/justice_and_balance
	name = "For the Justice and Balance of this Land"
	desc = "An ability with 3 charges. Each use smashes all enemies in the area around you and buffs you, the third charge is amplified. \
		Each hit grants you a temporary bonus to justice, hitting the same target increases this bonus."
	action_icon_state = "justicebalance0"
	base_icon_state = "justicebalance"
	cooldown_time = 1 MINUTES

	var/max_charges = 3
	var/charges = 3
	var/list/spawned_effects = list()
	var/list/SFX = list(
		'sound/abnormalities/wrath_servant/big_smash3.ogg',
		'sound/abnormalities/wrath_servant/big_smash2.ogg',
		'sound/abnormalities/wrath_servant/big_smash1.ogg'
		)
	var/damage = 30
	var/list/targets_hit = list()

/obj/effect/proc_holder/ability/justice_and_balance/Perform(target, user)
	INVOKE_ASYNC(src, PROC_REF(Smash), user, charges)
	charges--
	if(charges < 1)
		charges = max_charges
		targets_hit = list()
		return ..()

/obj/effect/proc_holder/ability/justice_and_balance/proc/Smash(mob/user, on_use_charges)
	playsound(user, SFX[on_use_charges], 25*(4-on_use_charges))
	var/temp_dam = damage
	temp_dam *= 1 + (get_attribute_level(user, JUSTICE_ATTRIBUTE)/100)
	if(on_use_charges <= 1)
		temp_dam *= 1.5
	for(var/turf/open/T in range(3, user))
		if(T.z != user.z)
			continue
		new /obj/effect/temp_visual/small_smoke/halfsecond/green(T)
		for(var/mob/living/L in T)
			if(L.status_flags & GODMODE)
				continue
			if(L == user)
				continue
			if(L.stat == DEAD)
				continue
			if(user.faction_check_mob(L))
				continue
			if(L in targets_hit)
				targets_hit[L] += 1
			else
				targets_hit[L] = 1
			L.apply_damage(temp_dam, BLACK_DAMAGE, null, L.run_armor_check(null, BLACK_DAMAGE), spread_damage = TRUE)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	var/datum/status_effect/stacking/justice_and_balance/JAB = H.has_status_effect(/datum/status_effect/stacking/justice_and_balance)
	if(!JAB)
		JAB = H.apply_status_effect(/datum/status_effect/stacking/justice_and_balance)
		if(!JAB)
			return
	for(var/hit in targets_hit)
		JAB.add_stacks(targets_hit[hit])

/datum/status_effect/stacking/justice_and_balance
	id = "EGO_JAB"
	status_type = STATUS_EFFECT_UNIQUE
	stacks = 0
	tick_interval = 10
	alert_type = /atom/movable/screen/alert/status_effect/justice_and_balance
	var/next_tick = 0

/atom/movable/screen/alert/status_effect/justice_and_balance
	name = "Justice and Balance"
	desc = "The power to preserve balance is in your hands. \
		Your Justice is increased by "
	icon = 'ModularTegustation/Teguicons/status_sprites.dmi'
	icon_state = "JAB"

/datum/status_effect/stacking/justice_and_balance/process()
	if(!owner)
		qdel(src)
		return
	if(next_tick < world.time)
		tick()
		next_tick = world.time + tick_interval
	if(duration != -1 && duration < world.time)
		qdel(src)

/datum/status_effect/stacking/justice_and_balance/add_stacks(stacks_added)
	if(!ishuman(owner))
		return
	if(stacks <= 0 && stacks_added < 0)
		qdel(src)
		return
	var/mob/living/carbon/human/H = owner
	H.adjust_attribute_buff(JUSTICE_ATTRIBUTE, stacks_added)
	stacks += stacks_added
	linked_alert.desc = initial(linked_alert.desc)+"[stacks]!"
	tick_interval = max(10 - (stacks/10), 0.1)

/datum/status_effect/stacking/justice_and_balance/can_have_status()
	if(!ishuman(owner))
		return FALSE
	var/mob/living/carbon/human/H = owner
	if(H.stat == DEAD)
		return FALSE
	var/obj/item/clothing/suit/armor/ego_gear/realization/woundedcourage/WC = H.get_item_by_slot(ITEM_SLOT_OCLOTHING)
	if(!istype(WC))
		return FALSE
	return TRUE

/obj/effect/proc_holder/ability/punishment
	name = "Punishment"
	desc = "Causes massive damage in a small area only when you take a blow."
	action_icon_state = "bird0"
	base_icon_state = "bird"
	cooldown_time = 25 SECONDS

/obj/effect/proc_holder/ability/punishment/Perform(target, mob/user)
	var/mob/living/carbon/human/H = user
	H.apply_status_effect(/datum/status_effect/punishment)
	return ..()

/datum/status_effect/punishment
	id = "EGO_P2"
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/punishment
	duration = 5 SECONDS

/atom/movable/screen/alert/status_effect/punishment
	name = "Ready to punish"
	desc = "You're ready to punish."
	icon = 'ModularTegustation/Teguicons/status_sprites.dmi'
	icon_state = "punishment"

/datum/status_effect/punishment/on_apply()
	. = ..()
	RegisterSignal(owner, COMSIG_MOB_APPLY_DAMGE, PROC_REF(Rage))

/datum/status_effect/punishment/proc/Rage(mob/living/sorce, obj/item/thing, mob/living/attacker)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/H = owner
	H.apply_status_effect(/datum/status_effect/pbird)
	H.remove_status_effect(/datum/status_effect/punishment)
	to_chat(H, span_userdanger("You strike back at the wrong doer!"))
	playsound(H, 'sound/abnormalities/apocalypse/beak.ogg', 100, FALSE, 12)
	for(var/turf/T in view(2, H))
		new /obj/effect/temp_visual/beakbite(T)
		for(var/mob/living/L in T)
			if(H.faction_check_mob(L, FALSE))
				continue
			if(L.stat == DEAD)
				continue
			L.apply_damage(500, RED_DAMAGE, null, L.run_armor_check(null, RED_DAMAGE), spread_damage = TRUE)
			if(L.health < 0)
				L.gib()

/datum/status_effect/pbird
	id = "EGO_PBIRD"
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/pbird
	duration = 20 SECONDS

/atom/movable/screen/alert/status_effect/pbird
	name = "Punishment"
	desc = "Their wrong doing brings you rage. \
		Your Justice is increased by 10."
	icon = 'ModularTegustation/Teguicons/status_sprites.dmi'
	icon_state = "punishment"

/datum/status_effect/pbird/on_apply()
	. = ..()
	var/mob/living/carbon/human/H = owner
	owner.color = COLOR_RED
	H.adjust_attribute_buff(JUSTICE_ATTRIBUTE, 10)

/datum/status_effect/pbird/on_remove()
	. = ..()
	var/mob/living/carbon/human/H = owner
	owner.color = null
	H.adjust_attribute_buff(JUSTICE_ATTRIBUTE, -10)

/obj/effect/proc_holder/ability/petal_blizzard
	name = "Petal Blizzard"
	desc = "Creates a big area of healing at the cost of double damage taken for a short period of time."
	action_icon_state = "petalblizzard0"
	base_icon_state = "petalblizzard"
	cooldown_time = 30 SECONDS
	var/healing_amount = 70 // Amount of healing to plater per "pulse".
	var/healing_range = 8

/obj/effect/proc_holder/ability/petal_blizzard/Perform(target, mob/user)
	var/mob/living/carbon/human/H = user
	to_chat(H, span_userdanger("You feel frailer!"))
	H.apply_status_effect(/datum/status_effect/bloomdebuff)
	playsound(get_turf(user), 'sound/weapons/fixer/generic/sword3.ogg', 75, 0, 7)
	for(var/turf/T in view(healing_range, user))
		pick(new /obj/effect/temp_visual/cherry_aura(T), new /obj/effect/temp_visual/cherry_aura2(T), new /obj/effect/temp_visual/cherry_aura3(T))
		for(var/mob/living/carbon/human/L in T)
			if(!user.faction_check_mob(L, FALSE))
				continue
			if(L.status_flags & GODMODE)
				continue
			if(L.stat == DEAD)
				continue
			if(L.is_working) //no work heal :(
				continue
			L.adjustBruteLoss(-healing_amount)
			L.adjustSanityLoss(-healing_amount)
	return ..()

/datum/status_effect/bloomdebuff
	id = "bloomdebuff"
	status_type = STATUS_EFFECT_UNIQUE
	duration = 15 SECONDS		//Lasts 30 seconds
	alert_type = /atom/movable/screen/alert/status_effect/bloomdebuff

/atom/movable/screen/alert/status_effect/bloomdebuff
	name = "Blooming Sakura"
	desc = "You Take 1.5x Damage."
	icon = 'ModularTegustation/Teguicons/status_sprites.dmi'
	icon_state = "marked_for_death"

/datum/status_effect/bloomdebuff/on_apply()
	. = ..()
	if(ishuman(owner))
		var/mob/living/carbon/human/L = owner
		L.physiology.red_mod *= 1.5
		L.physiology.white_mod *= 1.5
		L.physiology.black_mod *= 1.5
		L.physiology.pale_mod *= 1.5

/datum/status_effect/bloomdebuff/tick()
	var/mob/living/carbon/human/Y = owner
	if(Y.sanity_lost)
		Y.death()
	if(owner.stat == DEAD)
		for(var/mob/living/carbon/human/H in GLOB.player_list)
			if(H.stat != DEAD)
				H.adjustBruteLoss(-100) // It heals everyone to full
				H.adjustSanityLoss(-100) // It heals everyone to full

/datum/status_effect/bloomdebuff/on_remove()
	. = ..()
	if(ishuman(owner))
		var/mob/living/carbon/human/L = owner
		to_chat(L, span_userdanger("You feel normal!"))
		L.physiology.red_mod /= 1.5
		L.physiology.white_mod /= 1.5
		L.physiology.black_mod /= 1.5
		L.physiology.pale_mod /= 1.5

/mob/living/simple_animal/hostile/farmwatch_plant//TODO: give it an effect with the corresponding suit.
	name = "Tree of Desires"
	desc = "The growing results of your research."
	health = 60
	maxHealth = 60
	icon = 'ModularTegustation/Teguicons/tegumobs.dmi'
	icon_state = "farmwatch_tree"
	icon_living = "farmwatch_tree"
	icon_dead = "farmwatch_tree"
	faction = list("neutral")
	del_on_death = FALSE

/mob/living/simple_animal/hostile/farmwatch_plant/Move()
	return FALSE

/mob/living/simple_animal/hostile/farmwatch_plant/CanAttack(atom/the_target)
	return FALSE

/mob/living/simple_animal/hostile/farmwatch_plant/Initialize()
	. = ..()
	QDEL_IN(src, 15 SECONDS)

/mob/living/simple_animal/hostile/farmwatch_plant/death()
	density = FALSE
	animate(src, alpha = 0, time = 1)
	QDEL_IN(src, 1)
	..()

/mob/living/simple_animal/hostile/spicebush_plant
	name = "Soon-to-bloom flower"
	desc = "The reason you bloomed, sowing seeds of nostalgia, was to set your heart upon our new beginning."
	health = 1
	maxHealth = 1
	icon = 'ModularTegustation/Teguicons/tegumobs.dmi'
	icon_state = "spicebush_tree"
	icon_living = "spicebush_tree"
	icon_dead = "spicebush_tree"
	faction = list("neutral")
	del_on_death = FALSE
	var/pulse_cooldown
	var/pulse_cooldown_time = 1.8 SECONDS
	var/pulse_damage = -2

/mob/living/simple_animal/hostile/spicebush_plant/Move()
	return FALSE

/mob/living/simple_animal/hostile/spicebush_plant/CanAttack(atom/the_target)
	return FALSE

/mob/living/simple_animal/hostile/spicebush_plant/Initialize()
	. = ..()
	QDEL_IN(src, 20 SECONDS)

/mob/living/simple_animal/hostile/spicebush_plant/Life()
	. = ..()
	if(!.) // Dead
		return FALSE
	if((pulse_cooldown < world.time) && !(status_flags & GODMODE))
		HealPulse()

/mob/living/simple_animal/hostile/spicebush_plant/death()
	density = FALSE
	playsound(src, 'sound/weapons/ego/farmwatch_tree.ogg', 100, 1)
	animate(src, alpha = 0, time = 1 SECONDS)
	QDEL_IN(src, 1 SECONDS)
	..()

/mob/living/simple_animal/hostile/spicebush_plant/proc/HealPulse()
	pulse_cooldown = world.time + pulse_cooldown_time
	//playsound(src, 'sound/abnormalities/rudolta/throw.ogg', 50, FALSE, 4)//TODO: proper SFX goes here
	for(var/mob/living/carbon/human/L in range(8, src))//livinginview(8, src))
		if(L.stat == DEAD || L.is_working)
			continue
		L.adjustBruteLoss(-2)
		L.adjustSanityLoss(-2)

/obj/effect/proc_holder/ability/overheat
	name = "Overheat"
	desc = "Burn yourself away in exchange for power."
	action_icon_state = "overheat0"
	base_icon_state = "overheat"
	cooldown_time = 5 MINUTES

/obj/effect/proc_holder/ability/overheat/Perform(target, mob/user)
	var/mob/living/carbon/human/H = user
	to_chat(H, span_userdanger("Ashes to ashes!"))
	H.apply_status_effect(/datum/status_effect/overheat)
	return ..()

/datum/status_effect/overheat
	id = "overheat"
	status_type = STATUS_EFFECT_UNIQUE
	duration = 15 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/overheat

/atom/movable/screen/alert/status_effect/overheat
	name = "Overheating"
	desc = "You have full burn stacks in exchange for justice."
	icon = 'ModularTegustation/Teguicons/status_sprites.dmi'
	icon_state = "mortis"

/datum/status_effect/overheat/on_apply()
	. = ..()
	var/mob/living/carbon/human/H = owner
	H.adjust_attribute_buff(JUSTICE_ATTRIBUTE, 40)
	H.apply_lc_burn(50)
	var/datum/status_effect/stacking/lc_burn/B = H.has_status_effect(/datum/status_effect/stacking/lc_burn)
	B.safety = FALSE

/datum/status_effect/overheat/on_remove()
	. = ..()
	var/mob/living/carbon/human/H = owner
	H.adjust_attribute_buff(JUSTICE_ATTRIBUTE, -40)
	H.remove_status_effect(STATUS_EFFECT_LCBURN)

/* Yang - Duality */
/obj/effect/proc_holder/ability/tranquility
	name = "Tranquility"
	desc = "An ability that does massive white damage in an area and heals people's health and sanity. \
	Healing someone that's wearing harmony of duality will grant them huge buffs to their defenses and stats."
	action_icon_state = "yangform0"
	base_icon_state = "yangform"
	cooldown_time = 60 SECONDS

	var/damage_amount = 300 // Amount of explosion damage
	var/explosion_range = 15

/obj/effect/proc_holder/ability/tranquility/Perform(target, mob/living/carbon/human/user)
	cooldown = world.time + (1.5 SECONDS)
	if(!do_after(user, 1 SECONDS))
		to_chat(user, span_warning("You must stand still to explode!"))
		return
	new /obj/effect/temp_visual/explosion/fast(get_turf(user))
	var/turf/orgin = get_turf(user)
	var/list/all_turfs = RANGE_TURFS(explosion_range, orgin)
	for(var/i = 0 to explosion_range)
		for(var/turf/T in all_turfs)
			if(get_dist(user, T) > i)
				continue
			new /obj/effect/temp_visual/dir_setting/speedbike_trail(T)
			user.HurtInTurf(damage_amount, list(), WHITE_DAMAGE)
			for(var/mob/living/carbon/human/L in T)
				if(!user.faction_check_mob(L, FALSE))
					continue
				if(L.stat == DEAD)
					continue
				if(L.is_working) //no work heal :(
					continue
				L.adjustBruteLoss(-120)
				L.adjustSanityLoss(-120)
				new /obj/effect/temp_visual/healing(get_turf(L))
				if(istype(L.get_item_by_slot(ITEM_SLOT_OCLOTHING), /obj/item/clothing/suit/armor/ego_gear/realization/duality_yin))
					L.apply_status_effect(/datum/status_effect/duality_yang)
			all_turfs -= T
	return ..()

/datum/status_effect/duality_yang
	id = "EGO_YANG"
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/duality_yang
	duration = 90 SECONDS

/atom/movable/screen/alert/status_effect/duality_yang
	name = "Duality of harmony"
	desc = "Decreases white and pale damage taken by 25%. \
		All your stats are increased by 10."
	icon = 'ModularTegustation/Teguicons/status_sprites.dmi'
	icon_state = "duality"

/datum/status_effect/duality_yang/on_apply()
	. = ..()
	var/mob/living/carbon/human/H = owner
	H.physiology.white_mod *= 0.75
	H.physiology.pale_mod *= 0.75
	H.adjust_attribute_buff(FORTITUDE_ATTRIBUTE, 10)
	H.adjust_attribute_buff(PRUDENCE_ATTRIBUTE, 10)
	H.adjust_attribute_buff(TEMPERANCE_ATTRIBUTE, 10)
	H.adjust_attribute_buff(JUSTICE_ATTRIBUTE, 10)

/datum/status_effect/duality_yang/on_remove()
	. = ..()
	var/mob/living/carbon/human/H = owner
	H.physiology.white_mod /= 0.75
	H.physiology.pale_mod /= 0.75
	H.adjust_attribute_buff(FORTITUDE_ATTRIBUTE, -10)
	H.adjust_attribute_buff(PRUDENCE_ATTRIBUTE, -10)
	H.adjust_attribute_buff(TEMPERANCE_ATTRIBUTE, -10)
	H.adjust_attribute_buff(JUSTICE_ATTRIBUTE, -10)

/*Child of the Galaxy - Our Galaxy */
/obj/effect/proc_holder/ability/galaxy_gift
	name = "An Eternal Farewell"
	desc = "Gives people around you a tiny pebble which will heal SP and HP for a short time."
	action_icon_state = "galaxy0"
	base_icon_state = "galaxy"
	cooldown_time = 60 SECONDS
	var/range = 6

/obj/effect/proc_holder/ability/galaxy_gift/Perform(target, mob/living/carbon/human/user)
	if(!istype(user))
		return
	var/list/existing_gifted = list()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.has_status_effect(/datum/status_effect/galaxy_gift))
			existing_gifted += H
	playsound(get_turf(user), 'sound/abnormalities/despairknight/gift.ogg', 50, 0, 2) //placeholder, uses KoD blessing noise at the moment
	for(var/turf/T in view(range, user))
		new /obj/effect/temp_visual/galaxy_aura(T)
		for(var/mob/living/carbon/human/H in T)
			if(!user.faction_check_mob(H, FALSE))
				continue
			if(H.stat == DEAD)
				continue
			if(H.is_working)
				continue
			var/datum/status_effect/galaxy_gift/new_gift = H.apply_status_effect(/datum/status_effect/galaxy_gift)
			new_gift.caster = user
			if(H == user)
				new_gift.watch_death = TRUE
			existing_gifted |= H
	for(var/mob/living/carbon/human/H in existing_gifted)
		var/datum/status_effect/galaxy_gift/gift = H.has_status_effect(/datum/status_effect/galaxy_gift)
		if(!gift)
			continue
		gift.gifted = existing_gifted
	return ..()

/datum/status_effect/galaxy_gift
	id = "galaxygift"
	status_type = STATUS_EFFECT_UNIQUE
	duration = 30 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/galaxy_gift
	var/base_heal_amt = 0.5
	var/base_dmg_amt = 45
	var/watch_death = FALSE
	var/list/gifted
	var/mob/living/carbon/human/caster

/atom/movable/screen/alert/status_effect/galaxy_gift
	name = "Parting Gift"
	desc = "You recover SP and HP over time temporarliy."
	icon = 'ModularTegustation/Teguicons/status_sprites.dmi'
	icon_state = "friendship"

/datum/status_effect/galaxy_gift/tick()
	. = ..()
	if(!ishuman(owner))
		qdel(src)
		return
	var/mob/living/carbon/human/Y = owner
	listclearnulls(gifted)
	for(var/mob/living/carbon/human/H in gifted)
		if(H == Y)
			continue
		if(H == caster)
			continue
		if(H.stat == DEAD || QDELETED(H))
			gifted -= H
			if(H) // If there's even anything left to remove
				H.remove_status_effect(/datum/status_effect/galaxy_gift)
	if(caster.stat == DEAD || QDELETED(Y))
		return watch_death ? Pop() : FALSE
	var/heal_mult = LAZYLEN(gifted)
	heal_mult = max(3, heal_mult)
	Y.adjustBruteLoss(-(base_heal_amt*heal_mult))
	Y.adjustSanityLoss(-(base_heal_amt*heal_mult))

/datum/status_effect/galaxy_gift/proc/Pop()
	var/damage_mult = LAZYLEN(gifted)
	for(var/mob/living/carbon/human/H in gifted)
		H.apply_damage(base_dmg_amt*damage_mult, BLACK_DAMAGE, null, H.run_armor_check(null, BLACK_DAMAGE), spread_damage = TRUE)
		H.remove_status_effect(/datum/status_effect/galaxy_gift)
		new /obj/effect/temp_visual/pebblecrack(get_turf(H))
		playsound(get_turf(H), "shatter", 50, TRUE)
		to_chat(H, span_userdanger("Your pebble violently shatters!"))
		caster = null
	return

/* Sleeping Beauty - Comatose */
/obj/effect/proc_holder/ability/comatose
	name = "Comatose"
	desc = "Fall asleep to gain 99% resistance to all normal damage."
	action_icon_state = "comatose0"
	base_icon_state = "comatose"
	cooldown_time = 30 SECONDS

/obj/effect/proc_holder/ability/comatose/Perform(target, mob/living/carbon/human/user)
	if(istype(user.get_item_by_slot(ITEM_SLOT_OCLOTHING), /obj/item/clothing/suit/armor/ego_gear/realization/comatose))
		user.Stun(15 SECONDS)
		user.Knockdown(1)
		user.playsound_local(get_turf(user), "sound/abnormalities/happyteddy/teddy_lullaby.ogg", 25, 0)
		user.apply_status_effect(/datum/status_effect/dreaming)
		return ..()

/datum/status_effect/dreaming
	id = "EGO_SLEEPING"
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/dreaming
	duration = 15 SECONDS

/atom/movable/screen/alert/status_effect/dreaming
	name = "Dreams of comfort"
	desc = "Decreases damage taken from conventional damage types by 99%"
	icon = 'ModularTegustation/Teguicons/status_sprites.dmi'
	icon_state = "comatose"

/datum/status_effect/dreaming/on_apply()
	. = ..()
	var/mob/living/carbon/human/H = owner
	H.physiology.red_mod /= 100
	H.physiology.white_mod /= 100
	H.physiology.black_mod /= 100
	H.physiology.pale_mod /= 100

/datum/status_effect/dreaming/on_remove()
	. = ..()
	var/mob/living/carbon/human/H = owner
	H.physiology.red_mod *= 100
	H.physiology.white_mod *= 100
	H.physiology.black_mod *= 100
	H.physiology.pale_mod *= 100

/* Wishing Well - Broken Crown */
/obj/effect/proc_holder/ability/brokencrown
	name = "Broken Crown"
	desc = "Extract a random empowered E.G.O. weapon once, return it to the armor to try for a different weapon. The item will automatically be returned if the armor is taken off."
	action_icon_state = "brokencrown0"
	base_icon_state = "brokencrown"
	cooldown_time = 5 MINUTES
	var/obj/structure/toolabnormality/wishwell/linked_structure
	var/list/ego_list = list()
	var/obj/item/ego_weapon/chosenEGO
	var/obj/item/linkeditem = null
	var/ready = TRUE

/obj/effect/proc_holder/ability/brokencrown/proc/Absorb(obj/item/I, mob/living/user)
	if(!ego_list || ready)
		to_chat(user, span_notice("You need to use this ability before you can recharge it!"))
		return FALSE
	if(!is_type_in_list(I, ego_list))
		return FALSE
	if(is_ego_melee_weapon(I))
		if(I.force_multiplier < 1.2)
			to_chat(user, span_notice("You must use a weapon with a damage multiplier of 20% or higher!"))
			return FALSE
		Reload(I, user)
		return TRUE
	return FALSE

/obj/effect/proc_holder/ability/brokencrown/proc/Reload(obj/item/I, mob/living/user)
	to_chat(user, span_nicegreen("The ability has been recharged."))
	ready = TRUE
	qdel(I)

/obj/effect/proc_holder/ability/brokencrown/Perform(target, mob/living/carbon/human/user)
	if(!ready)
		to_chat(user, span_notice("This ability has been spent and needs to be recharged."))
		return
	if(istype(user.get_item_by_slot(ITEM_SLOT_OCLOTHING), /obj/item/clothing/suit/armor/ego_gear/realization/brokencrown))
		user.playsound_local(get_turf(user), "sound/abnormalities/bloodbath/Bloodbath_EyeOn.ogg", 25, 0)
		if(!linked_structure)
			linked_structure = locate(/obj/structure/toolabnormality/wishwell) in world.contents
			if(!linked_structure) //Somehow you got this ego on a non-facility map
				ego_list += /obj/item/ego_weapon/mimicry
				ego_list += /obj/item/ego_weapon/smile
				ego_list += /obj/item/ego_weapon/da_capo
				linked_structure = TRUE
		if(!LAZYLEN(ego_list))
			for(var/egoitem in linked_structure.alephitem)
				if(ispath(egoitem, /obj/item/ego_weapon) || ispath(egoitem, /obj/item/ego_weapon/ranged))
					ego_list += egoitem
					continue
		chosenEGO = pick(ego_list)
		var/obj/item/ego = chosenEGO //Not sure if there is a better way to do this
		if(ispath(ego, /obj/item/ego_weapon))
			var/obj/item/ego_weapon/egoweapon = new ego(get_turf(user))
			egoweapon.force_multiplier = 1.20
			egoweapon.name = "shimmering [egoweapon.name]"
			egoweapon.set_light(3, 6, "#D4FAF37")
			egoweapon.color = "#FFD700"
			linkeditem = egoweapon

		else if(ispath(ego, /obj/item/ego_weapon/ranged))
			var/obj/item/ego_weapon/ranged/egogun = new ego(get_turf(user))
			egogun.force_multiplier = 1.20
			egogun.projectile_damage_multiplier = 1.20
			egogun.name = "shimmering [egogun.name]"
			egogun.set_light(3, 6, "#D4FAF37")
			egogun.color = "#FFD700"
			linkeditem = egogun
		ready = FALSE
		return ..()

/obj/effect/proc_holder/ability/brokencrown/proc/Reabsorb()
	if(linkeditem && !ready)
		linkeditem.visible_message(span_userdanger("<font color='#CECA2B'>[linkeditem] glows brightly for a moment then... fades away without a trace.</font>"))
		qdel(linkeditem)
		ready = TRUE
	return

/* Opened Can of Wellcheers - Wellcheers */
/obj/effect/proc_holder/ability/wellcheers
	name = "Wellcheers Crew"
	desc = "Call up 3 of your finest crewmates for a period of time."
	action_icon_state = "shrimp0"
	base_icon_state = "shrimp"
	cooldown_time = 90 SECONDS

/obj/effect/proc_holder/ability/wellcheers/Perform(target, mob/user)
	for(var/i = 1 to 3)
		new /mob/living/simple_animal/hostile/shrimp/friendly(get_turf(user))
	return ..()

/mob/living/simple_animal/hostile/shrimp/friendly //HUGE buff shrimp
	name = "wellcheers boat fisherman"
	health = 700
	maxHealth = 700
	desc = "Are those fists?"
	melee_damage_lower = 40
	melee_damage_upper = 45
	icon_state = "wellcheers_ripped"
	icon_living = "wellcheers_ripped"
	faction = list("neutral", "shrimp")

/mob/living/simple_animal/hostile/shrimp/friendly/Initialize()
	.=..()
	AddComponent(/datum/component/knockback, 1, FALSE, TRUE)
	QDEL_IN(src, (90 SECONDS))

/mob/living/simple_animal/hostile/shrimp/friendly/AttackingTarget(atom/attacked_target)
	. = ..()
	if(.)
		var/mob/living/L = attacked_target
		if(L.health < 0 || L.stat == DEAD)
			L.gib() //Punch them so hard they explode
/* Flesh Idol - Repentance */
/obj/effect/proc_holder/ability/prayer
	name = "Prayer"
	desc = "An ability that does causes you to start praying reducing damage taken by 25% but removing your ability to move and lowers justice by 80. \
	When you finish praying everyone gets a 20 justice increase and gets healed."
	action_icon_state = "flesh0"
	base_icon_state = "flesh"
	cooldown_time = 180 SECONDS

/obj/effect/proc_holder/ability/prayer/Perform(target, mob/living/carbon/human/user)
	user.apply_status_effect(/datum/status_effect/flesh1)
	cooldown = world.time + (15 SECONDS)
	to_chat(user, span_userdanger("You start praying..."))
	if(!do_after(user, 15 SECONDS))
		user.remove_status_effect(/datum/status_effect/flesh1)
		return
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(!user.faction_check_mob(H, FALSE))
			continue
		if(H.stat == DEAD)
			continue
		if(H.z != user.z)
			continue
		playsound(H, 'sound/abnormalities/onesin/bless.ogg', 100, FALSE, 12)
		to_chat(H, span_nicegreen("[user]'s prayer was heard!"))
		H.adjustBruteLoss(-100)
		H.adjustSanityLoss(-100)
		H.apply_status_effect(/datum/status_effect/flesh2)
		new /obj/effect/temp_visual/healing(get_turf(H))
	return ..()

/datum/status_effect/flesh1
	id = "FLESH1"
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/flesh1
	duration = 15 SECONDS
	tick_interval = 3 SECONDS

/atom/movable/screen/alert/status_effect/flesh1
	name = "A prayer to god"
	desc = "You take random damage while praying."
	icon = 'ModularTegustation/Teguicons/status_sprites.dmi'
	icon_state = "flesh"

/datum/status_effect/flesh1/on_apply()
	. = ..()
	var/mob/living/carbon/human/H = owner
	ADD_TRAIT(H, TRAIT_IMMOBILIZED, type)

/datum/status_effect/flesh1/tick()
	. = ..()
	var/mob/living/carbon/human/H = owner
	var/list/damtypes = list(RED_DAMAGE, WHITE_DAMAGE, BLACK_DAMAGE, PALE_DAMAGE)
	var/damage = pick(damtypes)
	H.apply_damage(7, damage, null, H.run_armor_check(null, damage), spread_damage = TRUE)

/datum/status_effect/flesh1/on_remove()
	. = ..()
	var/mob/living/carbon/human/H = owner
	REMOVE_TRAIT(H, TRAIT_IMMOBILIZED, type)

/datum/status_effect/flesh2
	id = "FLESH2"
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/flesh2
	duration = 60 SECONDS

/atom/movable/screen/alert/status_effect/flesh2
	name = "An answer from god"
	desc = "Increases justice by 20."
	icon = 'ModularTegustation/Teguicons/status_sprites.dmi'
	icon_state = "flesh"

/datum/status_effect/flesh2/on_apply()
	. = ..()
	var/mob/living/carbon/human/H = owner
	H.adjust_attribute_buff(JUSTICE_ATTRIBUTE, 20)

/datum/status_effect/flesh2/on_remove()
	. = ..()
	var/mob/living/carbon/human/H = owner
	H.adjust_attribute_buff(JUSTICE_ATTRIBUTE, -20)

/obj/effect/proc_holder/ability/nest
	name = "Worm spawn"
	desc = "Spawns 7 worms that will seak out abormalities to infest in making them weaker to red damage."
	action_icon_state = "worm0"
	base_icon_state = "worm"
	cooldown_time = 30 SECONDS



/obj/effect/proc_holder/ability/nest/Perform(target, mob/user)
	for(var/i = 1 to 7)
		playsound(get_turf(user), 'sound/misc/moist_impact.ogg', 30, 1)
		var/landing
		landing = locate(user.x + pick(-2,-1,0,1,2), user.y + pick(-2,-1,0,1,2), user.z)
		var/mob/living/simple_animal/hostile/naked_nest_serpent_friend/W = new(get_turf(user))
		W.origin_nest = user
		W.throw_at(landing, 0.5, 2, spin = FALSE)
	return ..()

/datum/status_effect/stacking/infestation
	id = "EGO_NEST"
	status_type = STATUS_EFFECT_UNIQUE
	stacks = 1
	stack_decay = 0 //Without this the stacks were decaying after 1 sec
	duration = 15 SECONDS //Lasts for 4 minutes
	alert_type = /atom/movable/screen/alert/status_effect/justice_and_balance
	max_stacks = 20
	consumed_on_threshold = FALSE
	var/red = 0

/atom/movable/screen/alert/status_effect/infestation
	name = "Infestation"
	desc = "Your weakness to red damage is increased by "
	icon = 'ModularTegustation/Teguicons/status_sprites.dmi'
	icon_state = "infest"

/datum/status_effect/stacking/infestation/on_apply()
	. = ..()
	var/mob/living/simple_animal/M = owner
	M.AddModifier(/datum/dc_change/infested)

/datum/status_effect/stacking/infestation/on_remove()
	. = ..()
	var/mob/living/simple_animal/M = owner
	M.RemoveModifier(/datum/dc_change/infested)

/datum/status_effect/stacking/infestation/add_stacks(stacks_added)
	. = ..()
	if(!isanimal(owner))
		return
	var/mob/living/simple_animal/M = owner
	var/datum/dc_change/infested/mod = M.HasDamageMod(/datum/dc_change/infested)
	mod.potency = 1+(stacks/20)
	M.UpdateResistances()
	linked_alert.desc = initial(linked_alert.desc)+"[stacks*5]%!"

/mob/living/simple_animal/hostile/naked_nest_serpent_friend
	name = "friendly naked serpent"
	desc = "A sickly looking green-colored worm but looks friendly."
	icon = 'ModularTegustation/Teguicons/tegumobs.dmi'
	icon_state = "nakednest_serpent"
	icon_living = "nakednest_serpent"
	a_intent = "harm"
	melee_damage_lower = 1
	melee_damage_upper = 1
	maxHealth = 500
	health = 500 //STOMP THEM STOMP THEM NOW.
	move_to_delay = 3
	damage_coeff = list(BRUTE = 1, RED_DAMAGE = 1, WHITE_DAMAGE = 1, BLACK_DAMAGE = 1, PALE_DAMAGE = 1)
	stat_attack = HARD_CRIT
	density = FALSE //they are worms.
	robust_searching = 1
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	mob_size = MOB_SIZE_SMALL
	pass_flags = PASSTABLE | PASSMOB
	layer = ABOVE_NORMAL_TURF_LAYER
	mouse_opacity = MOUSE_OPACITY_OPAQUE //Clicking anywhere on the turf is good enough
	del_on_death = 1
	vision_range = 18 //two screens away
	faction = list("neutral")
	var/mob/living/carbon/human/origin_nest

/mob/living/simple_animal/hostile/naked_nest_serpent_friend/Initialize()
	.=..()
	AddComponent(/datum/component/swarming)
	QDEL_IN(src, (20 SECONDS))

/mob/living/simple_animal/hostile/naked_nest_serpent_friend/AttackingTarget(atom/attacked_target)
	var/mob/living/L = attacked_target
	var/datum/status_effect/stacking/infestation/INF = L.has_status_effect(/datum/status_effect/stacking/infestation)
	if(!INF)
		INF = L.apply_status_effect(/datum/status_effect/stacking/infestation)
		if(!INF)
			return
	INF.add_stacks(1)
	qdel(src)
	. = ..()

/mob/living/simple_animal/hostile/naked_nest_serpent_friend/LoseAggro() //its best to return home
	..()
	if(origin_nest)
		for(var/mob/living/carbon/human/H in oview(vision_range, src))
			if(origin_nest == H.tag)
				Goto(H, 5, 0)
				return
/mob/living/simple_animal/hostile/naked_nest_serpent_friend/Life()
	..()
	if(origin_nest)
		for(var/mob/living/carbon/human/H in oview(vision_range, src))
			if(origin_nest == H.tag)
				Goto(H, 5, 0)
				return

/* Wayward Passenger - Dimension Ripper */
/obj/effect/proc_holder/ability/rip_space
	name = "Rip Space"
	desc = "Travel at light speed between portals to attack your enemies."
	action_icon_state = "ripper0"
	base_icon_state = "ripper"
	cooldown_time = 1 MINUTES

/obj/effect/proc_holder/ability/rip_space/Perform(target, mob/living/user)
	var/list/targets = list()
	for(var/mob/living/L in view(8, user))
		if(L.stat == DEAD)
			continue
		if(L.status_flags & GODMODE)
			continue
		if(user.faction_check_mob(L, FALSE))
			continue
		targets += L
	if(!(LAZYLEN(targets)))
		to_chat(user, span_warning("There are no enemies nearby!"))
		return

	cooldown = world.time + (7 SECONDS)
	var/turf/origin = get_turf(user)
	var/dash_count = min(targets.len*3, 30) //Max 10 targets (7 Seconds)
	user.density = FALSE
	ADD_TRAIT(user, TRAIT_IMMOBILIZED, type)
	var/obj/effect/portal/warp/P = new(origin)
	playsound(user, 'sound/abnormalities/wayward_passenger/ripspace_begin.ogg', 100, 0)
	sleep(1 SECONDS)
	qdel(P)
	user.alpha = 0

	for(var/i = 1 to dash_count)
		var/mob/living/L = pick(targets)
		dash_attack(L, user)
		if(L.stat == DEAD)
			targets -= L
		if(!LAZYLEN(targets) || user.stat == DEAD)
			break

	user.alpha = 255
	new /obj/effect/temp_visual/rip_space(origin)
	user.forceMove(origin)
	user.density = TRUE
	REMOVE_TRAIT(user, TRAIT_IMMOBILIZED, type)
	playsound(user, 'sound/abnormalities/wayward_passenger/ripspace_end.ogg', 100, 0)
	return ..()

/obj/effect/proc_holder/ability/rip_space/proc/dash_attack(mob/living/target, mob/living/user)
	var/list/potential_TP = list()
	for(var/turf/T in range(3, target))
		if(T in range(2, target))
			continue
		potential_TP += T
	var/turf/start_point = pick(potential_TP)
	var/turf/end_point = get_step(get_turf(target), get_dir(start_point, target))
	end_point = get_step(end_point, get_dir(start_point, target))
	var/obj/effect/temp_visual/rip_space/X = new(start_point)
	var/obj/effect/temp_visual/rip_space/Y = new(end_point)

	var/obj/projectile/ripper_dash_effect/DE = new(start_point)
	DE.preparePixelProjectile(Y, X)
	DE.name = user.name
	DE.fire()
	user.orbit(DE, 0, 0, 0, 0, 0)

	sleep(1)
	target.apply_damage(100, RED_DAMAGE, null, target.run_armor_check(null, RED_DAMAGE))
	new /obj/effect/temp_visual/rip_space_slash(get_turf(target))
	new /obj/effect/temp_visual/ripped_space(get_turf(target))
	playsound(user, 'sound/abnormalities/wayward_passenger/ripspace_hit.ogg', 75, 0)
	sleep(1)
	qdel(DE)

/obj/projectile/ripper_dash_effect
	speed = 0.32
	icon = 'ModularTegustation/Teguicons/32x32.dmi'
	icon_state = "ripper_dash"
	projectile_piercing = ALL

/obj/projectile/ripper_dash_effect/on_hit(atom/target, blocked = FALSE)
	return
