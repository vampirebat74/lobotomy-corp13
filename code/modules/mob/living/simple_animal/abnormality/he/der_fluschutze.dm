/mob/living/simple_animal/hostile/abnormality/der_fluschutze
	name = "Der Fluschutze"
	desc = "A tall man wearing ragged military fatigues. You can see the glint of a locket chained to his neck."
	icon = 'ModularTegustation/Teguicons/32x64.dmi'
	icon_state = "DrFluShots"
	icon_living = "DrFluShots"
	icon_dead = "DrFluShots"
	portrait = "der_fluschutze"
	maxHealth = 175
	health = 175
	ranged = TRUE
	casingtype = /obj/item/ammo_casing/caseless/ego_fellscatter
	projectilesound = 'sound/abnormalities/fluchschutze/fell_bullet.ogg'
	move_to_delay = 6
	damage_coeff = list(RED_DAMAGE = 0.5, WHITE_DAMAGE = 1.5, BLACK_DAMAGE = 1, PALE_DAMAGE = 1.2)
	stat_attack = HARD_CRIT
	vision_range = 28
	aggro_vision_range = 40
	threat_level = HE_LEVEL
	start_qliphoth = 3
	work_chances = list(
		ABNORMALITY_WORK_INSTINCT = 50,
		ABNORMALITY_WORK_INSIGHT = 40,
		ABNORMALITY_WORK_ATTACHMENT = 0,
		ABNORMALITY_WORK_REPRESSION = list(0, 0, 60, 60, 60),
	)
	work_damage_amount = 5
	work_damage_type = RED_DAMAGE
	chem_type = /datum/reagent/abnormality/sin/pride

	ego_list = list(
		/datum/ego_datum/weapon/fellbullet,
		/datum/ego_datum/weapon/fellscatter,
		/datum/ego_datum/armor/fellbullet,
	)
	//gift_type =  /datum/ego_gifts/fellbullet
	abnormality_origin = ABNORMALITY_ORIGIN_LIMBUS

	observation_prompt = "In this gory war, the devil approached me one day to suggest a deal. <br>\
		\"Thanks to that, I'm free to point the barrel at anyone I want. No matter where I fire it, this shotgun can blast anyone into fireworks like it hit them point blank, how wonderful is that? <br>\
		By the way, whose side are you on?\""
	observation_choices = list(
		"Tell him to look at the pendant on his neck" = list(TRUE, "Filled with rage, the shooter pointed its gun at me and pulled the trigger. <br>\
			However, the projectiles vanished in the air, and the shooter fell to the floor and started to cry."),
		"Say you're on his side" = list(FALSE, "The man scowls. <br>\"Let me do you a favor.\
		The people you love will remember you as yet another victim that lost their head."),
	)

	var/can_act = TRUE
	var/bullet_cooldown
	var/bullet_cooldown_time = 7 SECONDS
	var/bullet_fire_delay = 1.5 SECONDS
	var/bullet_max_range = 50
	var/bullet_damage = 50
	var/list/portals = list()
	var/zoomed = FALSE
	var/max_portals = 7
	var/current_portal_index = 0
	var/portal_cooldown
	var/portal_cooldown_time = 5 SECONDS
	var/icon_aim = 'ModularTegustation/Teguicons/64x64.dmi'

/mob/living/simple_animal/hostile/abnormality/der_fluschutze/Move()
	if(!can_act)
		return
	..()

/*/mob/living/simple_animal/hostile/abnormality/der_fluschutze/CanAttack(atom/the_target)
	if(!can_act)
		return
	..()*/

/mob/living/simple_animal/hostile/abnormality/der_fluschutze/AttackingTarget(atom/attacked_target)
	if(ranged_cooldown <= world.time)
		OpenFire(attacked_target)
		return

/mob/living/simple_animal/hostile/abnormality/der_fluschutze/OpenFire()
	if(!can_act)
		return
	AimAnimation()
	..()

/mob/living/simple_animal/hostile/abnormality/der_fluschutze/proc/AimAnimation()
	can_act = FALSE
	playsound(src, 'sound/abnormalities/fluchschutze/fell_aim.ogg', 80)
	icon = icon_aim
	pixel_x -= 16
	sleep(5)
	icon = initial(icon)
	pixel_x += 16
	can_act = TRUE
