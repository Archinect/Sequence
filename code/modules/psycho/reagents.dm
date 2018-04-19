//here be reagents affecting psy_state

/datum/reagent/consumable/ethanol/on_mob_life(mob/living/M)
	. = ..()
	M.psy_stabilize(0.125,50)

/datum/reagent/drug/nicotine/on_mob_life(mob/living/M)
	. = ..()
	M.psy_stabilize(0.125,50)
