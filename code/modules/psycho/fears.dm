/datum/psy_fear/pandora
	power = 500
	impact = 500
	indication_prob = 100
	affect_message = "You did a grave mistake"

/datum/psy_fear/vaoe
	var/range = 3

/datum/psy_fear/vaoe/New(srcobj)
	for(var/mob/living/L in viewers(range,srcobj))
		trigger(L)
	qdel(src)

/datum/psy_fear/vaoe/blood
	psy_type = PSY_FEARTYPE_ABSTRACT | PSY_FEARTYPE_DEATH | PSY_FEARTYPE_PAIN
	power = 5
	impact = 5
	affect_message = "View of spilled blood sends shivers down your spine"

/datum/psy_fear/vaoe/death
	psy_type = PSY_FEARTYPE_DEATH
	power = 50
	impact = 75
	range = 5
	affect_message = "Death of nearby creature reminds you of impending end"

/datum/psy_fear/vaoe/changelingery
	psy_type = PSY_FEARTYPE_ABSTRACT | PSY_FEARTYPE_PARANORMAL
	power = 50
	impact = 25
	range = 7
	affect_message = "This is surely nonhuman"

/datum/psy_fear/vaoe/blood_cultery
	psy_type = PSY_FEARTYPE_PAIN | PSY_FEARTYPE_PARANORMAL
	power = 50
	impact = 25
	range = 7
	affect_message = "You're unable to comprehend this wicked witchery"

/datum/psy_fear/vaoe/magic
	psy_type = PSY_FEARTYPE_PARANORMAL | PSY_FEARTYPE_INFINITE
	power = 25
	impact = 25
	range = 4
	affect_message = "I'm running out of ideas for affect messages"
	indication_prob = 0

/datum/psy_fear/haoe
	var/range = 5

/datum/psy_fear/haoe/New(srcobj)
	for(var/mob/living/L in hearers(range))
		trigger(L)
	qdel(src)

/datum/psy_fear/haoe/changelingery
	psy_type = PSY_FEARTYPE_ABSTRACT | PSY_FEARTYPE_PARANORMAL
	power = 50
	impact = 40
	range = 7
	affect_message = "This is surely nonhuman"

/datum/psy_fear/haoe/sound
	psy_type = PSY_FEARTYPE_ABSTRACT
	power = 15
	impact = 5
	range = 3
	affect_message = "You twitch from a sudden sound"

/datum/psy_fear/direct/New(mob)
	var/mob/living/L = mob
	if(istype(L))
		trigger(L)
	qdel(src)

/datum/psy_fear/direct/blood
	psy_type = PSY_FEARTYPE_ABSTRACT | PSY_FEARTYPE_DEATH | PSY_FEARTYPE_PAIN
	power = 20
	impact = 10
	indication_prob = 0

/datum/psy_fear/direct/danger
	psy_type = PSY_FEARTYPE_ABSTRACT | PSY_FEARTYPE_DEATH | PSY_FEARTYPE_PAIN
	power = 30
	impact = 15
	indication_prob = 0

/datum/psy_fear/direct/space
	psy_type = PSY_FEARTYPE_INFINITE
	power = 15
	impact = 10
	indication_prob = 0

/datum/psy_fear/direct/death
	psy_type = PSY_FEARTYPE_DEATH
	power = 15
	impact = 10
	indication_prob = 0