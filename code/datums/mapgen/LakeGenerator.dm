//Might need to do away with this entirely and have something else generate the lakes

#define WAVE_ATTACK 1
#define WAVE_PERSISTENT 2
#define WAVE_OBJECT 2

GLOBAL_LIST_INIT(lake_colors, list(
	COLOR_WHITE,
	COLOR_SILVER,
	COLOR_GRAY,
	COLOR_ALMOST_BLACK,
	COLOR_RED,
	COLOR_MAROON,
	COLOR_YELLOW,
	COLOR_OLIVE,
	COLOR_LIME,
	COLOR_GREEN,
	COLOR_CYAN,
	COLOR_BLUE,
	COLOR_NAVY,
	COLOR_PINK,
	COLOR_MAGENTA,
	null,
))

/datum/map_generator/lake_generator
	var/name = "Lake Generator"
	///Weighted list of the types that spawns if the turf is open
	var/open_turf_types = list(/turf/open/water/deep = 1)


	///Weighted list of extra features that can spawn in the area, such as geysers.
	var/list/feature_spawn_list = list(/obj/item/rawpe)//Use this for points of interest
	///Weighted list of mobs that can spawn in the area.
	var/list/mob_spawn_list = list()
	///Weighted list of flora that can spawn in the area.
	var/list/flora_spawn_list = list(/obj/structure/flora/ash/garden/seaweed = 1, /obj/structure/flora/ausbushes/fullgrass = 1, /obj/structure/flora/ausbushes/grassybush = 1, /obj/structure/flora/ausbushes/lavendergrass = 1, /obj/structure/flora/grass/jungle = 2, /obj/structure/flora/grass/jungle/b = 2)
	// Weighted list of Megafauna that can spawn in the caves
	var/list/megafauna_spawn_list


	///Base chance of spawning a mob
	var/mob_spawn_chance = 0
	///Base chance of spawning flora
	var/flora_spawn_chance = 0
	///Base chance of spawning features
	var/feature_spawn_chance = 1
	///Unique ID for this spawner
	var/string_gen

	///Chance of cells starting closed
	var/initial_closed_chance = 0
	///Amount of smoothing iterations
	var/smoothing_iterations = 20
	///How much neighbours does a dead cell need to become alive
	var/birth_limit = 4
	///How little neighbours does a alive cell need to die
	var/death_limit = 3

/datum/map_generator/lake_generator/generate_terrain(list/turfs)
	. = ..()
	var/start_time = REALTIMEOFDAY
	string_gen = rustg_cnoise_generate("[initial_closed_chance]", "[smoothing_iterations]", "[birth_limit]", "[death_limit]", "[world.maxx]", "[world.maxy]") //Generate the raw CA data

	for(var/i in turfs) //Go through all the turfs and generate them
		var/turf/gen_turf = i

		var/area/A = gen_turf.loc
		//if(!(A.area_flags & CAVES_ALLOWED))
		//	continue

		var/closed = text2num(string_gen[world.maxx * (gen_turf.y - 1) + gen_turf.x])

		var/stored_flags
		if(gen_turf.turf_flags & NO_RUINS)
			stored_flags |= NO_RUINS

		var/turf/new_turf = pickweight(open_turf_types)

		new_turf = gen_turf.ChangeTurf(new_turf, initial(new_turf.baseturfs), CHANGETURF_DEFER_CHANGE)

		new_turf.flags_1 |= stored_flags

		if(!closed)//Open turfs have some special behavior related to spawning flora and mobs.

			var/turf/open/new_open_turf = new_turf

			///Spawning isn't done in procs to save on overhead on the 60k turfs we're going through.

			//FLORA SPAWNING HERE
			var/atom/spawned_flora
			if(flora_spawn_list && prob(flora_spawn_chance))
				var/can_spawn = TRUE

				if(!(A.area_flags & FLORA_ALLOWED))
					can_spawn = FALSE
				if(can_spawn)
					spawned_flora = pickweight(flora_spawn_list)
					spawned_flora = new spawned_flora(new_open_turf)

			//FEATURE SPAWNING HERE
			var/atom/spawned_feature
			if(feature_spawn_list && prob(feature_spawn_chance))
				var/can_spawn = TRUE

				if(!(A.area_flags & FLORA_ALLOWED)) //checks the same flag because lol dunno
					can_spawn = FALSE

				var/atom/picked_feature = pickweight(feature_spawn_list)

				for(var/obj/structure/F in range(7, new_open_turf))
					if(istype(F, picked_feature))
						can_spawn = FALSE

				if(can_spawn)
					spawned_feature = new picked_feature(new_open_turf)

			//MOB SPAWNING HERE

			if(mob_spawn_list && !spawned_flora && !spawned_feature && prob(mob_spawn_chance))
				var/can_spawn = TRUE

				if(!(A.area_flags & MOB_SPAWN_ALLOWED))
					can_spawn = FALSE

				var/atom/picked_mob = pickweight(mob_spawn_list)

				if(picked_mob == SPAWN_MEGAFAUNA) //
					if((A.area_flags & MEGAFAUNA_SPAWN_ALLOWED) && megafauna_spawn_list?.len) //this is danger. it's boss time.
						picked_mob = pickweight(megafauna_spawn_list)
					else //this is not danger, don't spawn a boss, spawn something else
						picked_mob = pickweight(mob_spawn_list - SPAWN_MEGAFAUNA) //What if we used 100% of the brain...and did something (slightly) less shit than a while loop?

				for(var/thing in urange(12, new_open_turf)) //prevents mob clumps
					if(!ishostile(thing) && !istype(thing, /obj/structure/spawner))
						continue
					if((ispath(picked_mob, /mob/living/simple_animal/hostile/megafauna) || ismegafauna(thing)) && get_dist(new_open_turf, thing) <= 7)
						can_spawn = FALSE //if there's a megafauna within standard view don't spawn anything at all
						break
					if(ispath(picked_mob, /mob/living/simple_animal/hostile/asteroid) || istype(thing, /mob/living/simple_animal/hostile/asteroid))
						can_spawn = FALSE //if the random is a standard mob, avoid spawning if there's another one within 12 tiles
						break
					if((ispath(picked_mob, /obj/structure/spawner/lavaland) || istype(thing, /obj/structure/spawner/lavaland)) && get_dist(new_open_turf, thing) <= 2)
						can_spawn = FALSE //prevents tendrils spawning in each other's collapse range
						break

				if(can_spawn)
					if(ispath(picked_mob, /mob/living/simple_animal/hostile/megafauna/bubblegum)) //there can be only one bubblegum, so don't waste spawns on it
						megafauna_spawn_list.Remove(picked_mob)

					new picked_mob(new_open_turf)
		CHECK_TICK

	var/message = "[name] finished in [(REALTIMEOFDAY - start_time)/10]s!"
	to_chat(world, span_boldannounce("[message]"))
	log_world(message)

/area/great_lake
	name = "The Great Lake"
	icon_state = "blue2"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	dynamic_lighting = DYNAMIC_LIGHTING_IFSTARLIGHT
	area_flags = VALID_TERRITORY | UNIQUE_AREA | FLORA_ALLOWED
	map_generator = /datum/map_generator/lake_generator
	var/law_text = null
	var/law//use tags for this?
	var/law_list = list("MOVE_DIR", "MOVE_SPECIFIC", "HOSTILE", "TIMER", "INHABITED", "TIME_LIMIT")
	var/generated = FALSE
	var/water_color
	var/risk_level = 1
	var/whale_chance = 30//Roll for this somewhere later in the code
	var/whale_type = /mob/living/simple_animal/hostile/ordeal/mermaid_porous
	var/wave_damage_type = RED_DAMAGE
	var/wave_damage = 15
	var/wave_effect = /obj/effect/temp_visual/fire
	var/wave_type = WAVE_ATTACK


/area/great_lake/Initialize(mapload)
	name = ""
	law_text = pick(law_list)
	..()
	wave_damage = risk_level * 15
	RunGeneration()
	ColorWater()

/area/great_lake/Entered(atom/movable/obj, atom/OldLoc)
	..()
	//if(!ishuman(obj))
	//	return
	for(var/obj/vehicle/sealed/adventure_boat/boat in get_turf(obj))
		boat.BoatWarning(water_color, law_text)
		if(prob(50))
			ActivateWave(boat)
		break

/area/great_lake/proc/ColorWater()
	if(!water_color)
		water_color = pick(GLOB.lake_colors)
	for(var/turf/T in contents)
		T.color = water_color

/area/great_lake/proc/ActivateWave(obj/vehicle/sealed/adventure_boat/boat)
	boat.can_move = FALSE
	var/spawning = FALSE
	var/wave_sound = 'sound/creatures/lc13/lake_entity/water_out.ogg'
	var/sleep_time = 4 SECONDS
	if(prob(whale_chance))
		spawning = TRUE
		sleep_time = 5 SECONDS
		wave_sound = 'sound/creatures/lc13/lake_entity/whale_moving.ogg'
	for(var/mob/living/L in boat.occupants)
		L.playsound_local(get_turf(L), wave_sound, 35, 0)
		shake_camera(L, 20, 3)
	sleep(sleep_time)
	if(spawning == TRUE)
		boat.WhaleAttack(whale_type)
		return
	else
		new wave_effect(get_turf(boat))
		for(var/turf/T in view(boat))
			if(prob(30))
				new wave_effect(T)
		for(var/mob/living/L in boat.occupants)
			L.deal_damage(wave_damage, wave_damage_type)
			L.playsound_local(get_turf(L), 'sound/creatures/lc13/lake_entity/boat_hit.ogg', 35, 0)
			shake_camera(L, 5, 10)
	boat.can_move = TRUE

/area/great_lake/random_lake
	name = "Random Lake"
	map_generator = null

#undef WAVE_ATTACK
#undef WAVE_PERSISTENT
#undef WAVE_OBJECT
