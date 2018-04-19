/mob/living/
	var/datum/psy_state/PSY

/mob/living/New()
	. = ..()
	PSY = new(src)

/mob/living/Life()
	. = ..()
	if(!PSY)
		PSY = new(src)
	PSY.life_tick()

	//here be psycho thingies
	var/ourview = oview()
	if(locate(/obj/effect/decal/cleanable/blood) in ourview)
		new /datum/psy_fear/direct/blood(src)
	for(var/mob/living/simple_animal/hostile/H in ourview)
		new /datum/psy_fear/direct/danger(src)
	if(locate(/turf/open/space) in ourview)
		new /datum/psy_fear/direct/space(src)
	for(var/mob/living/L in ourview)
		if(L.stat == DEAD)
			new /datum/psy_fear/direct/death(src)

/mob/living/death(gibbed)
	. = ..()
	new /datum/psy_fear/vaoe/death(src)

/mob/living/proc/psy_stabilize(amount, treshold = 0)
	if(!PSY)
		PSY = new(src)
	if(PSY.instability <= treshold)
		return
	PSY.instability = max(0, PSY.instability - amount)

/mob/living/adjustBrainLoss(amount)
	. = ..()
	if(amount<0)
		psy_stabilize(-amount/10)

/mob/living/carbon/handle_dreams()
	if(!PSY)
		PSY = new(src)
	if(dreaming)
		return
	if(prob(20)&&prob(sqrt(PSY.instability)*(1+PSY.stage)))
		. = horror_dream()
	else
		. = ..()

/mob/living/carbon/proc/horror_dream() 
	set waitfor = 0
	dreaming = 2
/*	var/list/dreams = list(
		"an ID card","a bottle","a familiar face","a crewmember","a toolbox","a security officer","the captain",
		"voices from all around","deep space","a doctor","the engine","a traitor","an ally","darkness",
		"light","a scientist","a monkey","a catastrophe","a loved one","a gun","warmth","freezing","the sun",
		"a hat","the Luna","a ruined station","a planet","plasma","air","the medical bay","the bridge","blinking lights",
		"a blue light","an abandoned laboratory","Nanotrasen","The Syndicate","blood","healing","power","respect",
		"riches","space","a crash","happiness","pride","a fall","water","flames","ice","melons","flying"
		)
*/
	var/list/horrors = list(
		"blood", "death", "extinction", "guilt", "pain", "suffering", "doom", "a catastrophe",
		"abandoned", "darkness", "your fault", "<b>them</b>", "it awakens", "you can't",
		"corpse", "plague", "pestilence", "taint", "corruption", "rot", "decay", "collapse", "downfall",
		"ancient god", "terror", "nowhere to run", "can't hide", "damnation", "anathema", "bane", "poison",
		"malice", "rancor", "menace", "ghost", "phantom", "zombies", "madman", "dark messiah" //of might&magic
	) //seems enough for now
	for(var/i = rand(10,15),i > 0, i--)//horrors are longer than normal dreams
		var/horror_image = pick(horrors)
		horrors -= horror_image
		src << "<span class='danger'><i>... [horror_image] ...</i></span>"
		var/sleep_time = rand(30,60)
		PSY.instability += rand(1,sqrt(PSY.instability))
		sleep(sleep_time)
		if(sleeping <= 0)
			dreaming = 0
			return 0
	Weaken(10)
	AdjustSleeping(-99) //awaken after horror
	dreaming = 0
	return 1

/mob/living/gain_antag_datum(datum_type)
	. = ..()
	if(.)
		switch(datum_type)
			if(/datum/antagonist/clockcultist,/datum/antagonist/cultist)
				psy_give_immunity(src, PSY_FEARTYPE_PAIN | PSY_FEARTYPE_PARANORMAL | PSY_FEARTYPE_DEATH)
				psy_give_resistance(src, PSY_FEARTYPE_ABSTRACT)

/mob/living/make_changeling()
	psy_give_immunity(src, PSY_FEARTYPE_ABSTRACT | PSY_FEARTYPE_PARANORMAL)
	psy_give_resistance(src, PSY_FEARTYPE_PAIN | PSY_FEARTYPE_DEATH)
	. = ..()

/datum/mind/make_Traitor() //midround traitor
	. = ..()
	var/mob/living/L = current
	if(istype(L))
		psy_give_immunity(L, PSY_FEARTYPE_DEATH)
		psy_give_resistance(L, PSY_FEARTYPE_PAIN | PSY_FEARTYPE_ABSTRACT)
