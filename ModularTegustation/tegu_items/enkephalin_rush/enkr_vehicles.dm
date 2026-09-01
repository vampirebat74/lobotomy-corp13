GLOBAL_LIST_EMPTY(lobotomy_boats)

/obj/vehicle/sealed/adventure_boat
	name = "boat"
	desc = "A boat. This shouldn't be available."
	icon_state = "middle_ship"
	icon = 'icons/obj/vehicles.dmi'
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	can_buckle = FALSE
	var/list/shipturfs = list()
	var/capacity = list()
	var/mob/living/driver
	var/obj/structure/boat_interior/interior
	var/datum/sailor/my_sailor
	max_occupants = 1

/obj/vehicle/sealed/adventure_boat/Initialize()
	..()
	for(var/obj/structure/boat_interior/myboat in GLOB.lobotomy_boats)
		if(myboat.current_vessel)
			continue
		interior = myboat
		for(var/turf/open/T in view(12, myboat))
			shipturfs += T
		myboat.current_vessel = src
		GLOB.lobotomy_boats -= myboat
		break

/obj/vehicle/sealed/adventure_boat/generate_actions()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/disembark)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/enter)

/obj/vehicle/sealed/adventure_boat/Destroy()
	if(interior)
		interior.current_vessel = 0
		GLOB.lobotomy_boats += interior
	..()

/obj/vehicle/sealed/adventure_boat/attack_hand(mob/living/carbon/human/user)
	user.forceMove(get_turf(interior))
	say("This is where you'll be connecting to your boat: [get_turf(interior)]")

/obj/vehicle/sealed/adventure_boat/examine(mob/user)
	. = ..()
	. += "It can carry [max_occupants] occupants."

/obj/vehicle/sealed/adventure_boat/relaymove(mob/living/user, direction)
	vehicle_move(direction)
	return TRUE

/obj/vehicle/sealed/adventure_boat/vehicle_move(direction, forcerotate = FALSE)
	if(!COOLDOWN_FINISHED(src, cooldown_vehicle_move))
		return FALSE
	COOLDOWN_START(src, cooldown_vehicle_move, movedelay)
	if(dir != direction)
		setDir(direction)
		return TRUE

	set_glide_size(DELAY_TO_GLIDE_SIZE(movedelay))
	//Otherwise just walk normally
	. = step(src,direction, dir)

/obj/vehicle/sealed/adventure_boat/add_occupant(mob/M, control_flags)
	//RegisterSignal(M, COMSIG_LIVING_DEATH, PROC_REF(mob_exit)) - Causes a runtime, hopefully nothing bad comes from disabling this
	. = ..()
	update_icon()

/obj/vehicle/sealed/adventure_boat/say(message as text, language, ignore_spam, forced, sanitize, spans)
	if(!my_sailor)//The boat should generally not speak without a sailor present
		return ..()
	name = my_sailor.name
	..()
	name = initial(name)

/obj/vehicle/sealed/adventure_boat/proc/AddSailor(datum/sailor/D)
	my_sailor = D
	var/spawned = FALSE
	for(var/turf/T in shipturfs)
		for(var/obj/effect/landmark/sailor_spawn/L in T)
			D.landmark = L
			D.RespawnMob()
			to_chat(world, "L [L] has been assigned and RespawnMob() has been called on datum [D]")
			spawned = TRUE
			break
	if(!spawned)
		to_chat(world, "AddSailor on [D] has failed to activate. Check if the landmark has been found.")

/obj/vehicle/sealed/adventure_boat/skiff
	name = "skiff"
	desc = "A small vessel popularized by the fixer of the great lake. Experienced sailors use it to hunt massive whales."
	icon_state = "goliath_boat"
	icon = 'icons/obj/lavaland/dragonboat.dmi'
	max_occupants = 2

/obj/vehicle/sealed/adventure_boat/sloop
	name = "sloop"
	desc = "A larger vessel that serves as a generalist when navigating throughout the Great Lake."
	//icon_state = "sloop"
	max_occupants = 4

/obj/structure/boat_shop
	name = "boat shop"
	desc = "A place to buy boats"
	icon = 'icons/obj/vending.dmi'
	icon_state = "liberationstation"
	anchored = TRUE
	density = TRUE
	var/list/dock = list()

/obj/structure/boat_shop/attack_hand(mob/living/carbon/human/user)
	if(!LAZYLEN(dock))
		for(var/obj/effect/boatspawn/B in range(8, src))
			dock += B
		say("Calibration complete. Please try again.")
		return

	if(!LAZYLEN(GLOB.lobotomy_boats))
		say("There are too many boats at sea! Try later.")
	else
		say("Enjoy your free boat trial!")
		var/obj/effect/T = pick(dock)
		new /obj/vehicle/sealed/adventure_boat/skiff(get_turf(T))

/obj/effect/boatspawn
	icon = 'icons/mob/landmarks.dmi'
	icon_state = "x"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	alpha = 0

/obj/structure/boat_interior
	name = "to surface"
	desc = "A ladder leading to the top deck.."
	icon = 'icons/obj/structures.dmi'
	icon_state = "ladder10"
	var/obj/vehicle/sealed/adventure_boat/current_vessel

/obj/structure/boat_interior/Initialize(mapload)
	GLOB.lobotomy_boats += src
	..()

/obj/structure/boat_interior/attack_hand(mob/living/carbon/human/user)
	if(current_vessel)
		current_vessel.add_occupant(user)
		user.forceMove(current_vessel)
	else
		user.forceMove(locate(128, 4, 7))//un-hardcode this

//SAILOR DATUMS// These are very similar to abnormality datums

/datum/sailor
	var/name = "Sailor"
	/// We'll use abnormality risk levels as a comparable metric for its tier
	var/threat_level = ZAYIN_LEVEL
	var/mob/living/simple_animal/hostile/sailor/mob_path
	/// Reference to the door we own, only used for records swapping
	var/obj/machinery/door/airlock/door
	/// Reference to current mob, if alive
	var/mob/living/simple_animal/hostile/sailor/current
	/// Reference to respawn landmark
	var/obj/effect/landmark/sailor_spawn/landmark

/datum/sailor/New(obj/effect/landmark/sailor_spawn/new_landmark, mob/living/simple_animal/hostile/sailor/new_type)
	if(!new_landmark)
		CRASH("Sailor datum was created without reference to landmark.")
	if(!ispath(new_type))
		CRASH("Sailor datum was created without a path to the mob.")
	landmark = new_landmark
	mob_path = new_type
	name = initial(mob_path.name)
	to_chat(world, "Sailor datum has been created with mob path [mob_path]. Calling RespawnMob()!")

/datum/sailor/proc/RespawnMob()//doesn't work
	if(!istype(landmark))
		CRASH("Couldn't respawn an sailor [initial(mob_path.name)] due to missing landmark.")
	if(!ispath(mob_path))
		CRASH("Sailor tried to respawn a mob, but mob path wasn't valid.")
	if(istype(current))
		to_chat(world, "sailor failed istype() check")
		return
	var/turf/T = get_turf(landmark)
	current = new mob_path(T)
	to_chat(world, "Creating sailor mob [current] at landmark located at [T]")
	current.datum_reference = src
	current.setDir(WEST)
	name = current.name

/obj/structure/sailor_spawner //DEBUG OBJECT, REMOVE FROM PULL REQUEST
	name = "sailor spawner"
	desc = "A place to buy sailors"
	icon = 'icons/obj/vending.dmi'
	icon_state = "liberationstation"
	anchored = TRUE
	density = TRUE
	var/obj/vehicle/sealed/adventure_boat/mom
	var/datum/sailor/dad
	var/mob_path = /mob/living/simple_animal/hostile/sailor/noob

/obj/structure/sailor_spawner/attack_hand(mob/living/carbon/human/user)//whatever's going on here doesn't work
	say("Attempting to spawn a sailor!")
	for(var/obj/structure/boat_interior/I in view())
		mom = I.current_vessel
		if(!mom)
			say("Vessel not found!")
			return
		if(mom.my_sailor)
			say("Vessel already has a sailor!")
			return
		dad = new(new_landmark = I, new_type = mob_path)
		//dad.mob_path = mob_path
		mom.AddSailor(dad)
		say("AddSailor has been called!")
