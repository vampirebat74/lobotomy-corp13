GLOBAL_LIST_EMPTY(lobotomy_boats)

/obj/vehicle/sealed/adventure_boat
	name = "boat"
	desc = "A boat. This shouldn't be available."
	icon_state = "middle_ship"
	icon = 'icons/obj/vehicles.dmi'
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	can_buckle = FALSE
	var/capacity = list()
	var/mob/living/driver
	var/obj/structure/boat_interior/interior
	var/mob/living/sailor
	max_occupants = 1

/obj/vehicle/sealed/adventure_boat/Initialize()
	..()
	for(var/obj/structure/boat_interior/myboat in GLOB.lobotomy_boats)
		if(myboat.current_vessel)
			continue
		interior = myboat
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
	RegisterSignal(M, COMSIG_LIVING_DEATH, PROC_REF(mob_exit))
	//RegisterSignal(M, COMSIG_MOB_CLICKON, PROC_REF(on_mouseclick))
	//RegisterSignal(M, COMSIG_MOB_SAY, PROC_REF(display_speech_bubble))
	. = ..()
	update_icon()

/obj/vehicle/sealed/adventure_boat/say(message as text, language, ignore_spam, forced, sanitize, spans)
	if(!sailor)//The boat should generally not speak without a sailor present
		return ..()
	name = sailor.name
	..()
	name = initial(name)

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
