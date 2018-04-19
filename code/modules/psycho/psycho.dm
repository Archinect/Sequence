//prototypes
/datum/psy_state
	var/instability = 0 //the more the worse
	var/stage = 0
	var/accumulated_instability = 0 //triggers consequences
	var/mob/living/holder

	var/vulnerability = 0 //bitfield showing which fears affects stronger
	var/resistance = 0 //bitfield showing which fears affect partially
	var/immunity = 0 //bitfield showing which fears have no effect

	var/list/consequence_cooldowns = list() //for targeted consequences

/proc/psy_give_vulnerability(var/mob/living/L,mask)
	if(!istype(L))
		return
	if(!L.PSY)
		L.PSY = new()
	L.PSY.vulnerability |= mask

/proc/psy_give_resistance(var/mob/living/L,mask)
	if(!istype(L))
		return
	if(!L.PSY)
		L.PSY = new()
	L.PSY.resistance |= mask

/proc/psy_give_immunity(var/mob/living/L,mask)
	if(!istype(L))
		return
	if(!L.PSY)
		L.PSY = new()
	L.PSY.immunity |= mask


/datum/psy_fear
	var/psy_type = PSY_FEARTYPE_ABSTRACT
	var/required_stage = 0
	var/power = 5 //how likely it is to affect
	var/impact = 10 //how much will it change
	var/indication_prob = 10
	var/affect_message = "You feel a sudden surge of primal fear"

/datum/psy_consequence
	var/psy_type = PSY_FEARTYPE_ABSTRACT //some are more/less susceptible to specific consequences
	var/required_stage = PSY_STAGE_STABLE
	var/acc_price = 10
	var/prob_mod = 1 //probability of happening if picked modificator

	//cooldown stuff to prevent screamer spam
	var/cooldown = 10
	var/next_available

//prepopulated for ease of access
var/list/datum/psy_consequence/psy_fear_consequences
var/list/datum/psy_consequence/psy_sign_consequences
var/list/datum/psy_consequence/psy_harbinger_consequences
var/list/datum/psy_consequence/psy_perdition_consequences

var/list/utility_consequences = list(
	/datum/psy_consequence/targeted,
	/datum/psy_consequence/mass
	)

/proc/psy_populate_consequences()
	psy_fear_consequences = list()
	psy_sign_consequences = list()
	psy_harbinger_consequences = list()
	psy_perdition_consequences = list()
	for(var/PSYCtype in subtypesof(/datum/psy_consequence))
		if(PSYCtype in utility_consequences)
			continue
		var/datum/psy_consequence/PSYC = new PSYCtype()
		if(PSYC.required_stage <= PSY_STAGE_FEARS)
			psy_fear_consequences |= PSYC
		if(PSYC.required_stage <= PSY_STAGE_SIGNS)
			psy_sign_consequences |= PSYC
		if(PSYC.required_stage <= PSY_STAGE_HARBINGER)
			psy_harbinger_consequences |= PSYC
		if(PSYC.required_stage <= PSY_STAGE_PERDITION)
			psy_perdition_consequences |= PSYC

var/list/psy_signs_suscepts = list()		//stores all who passed signs treshold
var/list/psy_harbinger_suscepts = list()	//stores all who passed harbinger treshold

var/list/psy_signs = list()

/datum/psy_state/New(mob/holder)
	src.holder = holder

/datum/psy_state/proc/life_tick()
	if(!istype(holder)) //wtf?
		qdel(src)
	if(holder.stat>=DEAD)
		return //undead are immune to psy effects lol
	if(!holder.mind)
		return //same here
	//even if unconscious
	handle_regeneration() //in almost every case it's stabilization

	if(holder.stat>=UNCONSCIOUS)
		return //nothing will haunt your dreams... probably

	handle_consequences()

	//handle affection after consequences to give them some time to realise they're fucked up
	handle_affection()

//natural psy regeneration
//almost 1 per process tick when not under psy affection
/datum/psy_state/proc/handle_regeneration()
	if(stage<3)
		instability-=0.125
	if(stage<2)
		instability-=0.25
	if(stage<1)
		instability-=0.5
	if(holder.stat>=UNCONSCIOUS)
		instability-=0.125
	var/mob/living/carbon/human/H = holder
	if(istype(H)&&H.drunkenness>51.01)
		instability+=0.25 //being drunk can't do any good to your mental state
	if(instability<0)
		instability=0

/datum/psy_state/proc/handle_affection()
	var/regeneration_treshold = 0
	var/degeneration_treshold = INFINITY
	switch(stage)
		if(PSY_STAGE_STABLE)
			degeneration_treshold = PSY_FEARS_TRESHOLD
		if(PSY_STAGE_FEARS)
			regeneration_treshold = PSY_FEARS_TRESHOLD * PSY_FORGIVING_MOD
			degeneration_treshold = PSY_SIGNS_TRESHOLD
		if(PSY_STAGE_SIGNS)
			regeneration_treshold = PSY_SIGNS_TRESHOLD * PSY_FORGIVING_MOD
			degeneration_treshold = PSY_HARBINGER_TRESHOLD
		if(PSY_STAGE_HARBINGER)
			regeneration_treshold = PSY_HARBINGER_TRESHOLD * PSY_FORGIVING_MOD
			degeneration_treshold = PSY_PERDITION_TRESHOLD
		if(PSY_STAGE_PERDITION)
			regeneration_treshold = PSY_PERDITION_TRESHOLD * PSY_FORGIVING_MOD
	if(instability < regeneration_treshold && prob(sqrt(regeneration_treshold - instability)))
		stage -= 1
	else if(instability > degeneration_treshold && prob(sqrt(instability - degeneration_treshold)))
		stage += 1
	else
		return //optimization

	if(stage>=PSY_STAGE_SIGNS)
		psy_signs_suscepts |= holder
	else
		psy_signs_suscepts -= holder
	if(stage>=PSY_STAGE_HARBINGER)
		psy_harbinger_suscepts |= holder
	else
		psy_harbinger_suscepts -= holder
	handle_signs()//update visibility

/datum/psy_state/proc/handle_signs()
	if(!holder || !holder.client)
		return
	if(stage>=PSY_STAGE_SIGNS)
		holder.client.images += psy_signs //see
	else
		holder.client.images -= psy_signs //don't see


/datum/psy_state/proc/handle_consequences()
	accumulated_instability = max(0,min(accumulated_instability+sqrt(instability),instability))
	var/degrade_coeff1 = 0
	var/degrade_coeff2 = 0
	var/list/chosen_list
	if(!psy_fear_consequences) //assuming there must be at least one for fear
		psy_populate_consequences()
	switch(stage)
		if(PSY_STAGE_FEARS)
			chosen_list = psy_fear_consequences
		if(PSY_STAGE_SIGNS)
			chosen_list = psy_sign_consequences
		if(PSY_STAGE_HARBINGER)
			chosen_list = psy_harbinger_consequences
		if(PSY_STAGE_PERDITION)
			chosen_list = psy_perdition_consequences
		else
			return

	while(prob(PSY_TRIGGER_PROB-degrade_coeff1*PSY_TRIGGER_COEFF1_MOD-degrade_coeff2*PSY_TRIGGER_COEFF2_MOD))
		var/datum/psy_consequence/chosen_consequence = pick(chosen_list)
		if(chosen_consequence.resolve(src))
			degrade_coeff1 += 1
		else
			degrade_coeff2 += 1

/datum/psy_fear/proc/trigger(mob/living/L)
	if(!L.PSY)
		return
	return resolve(L.PSY)

/datum/psy_fear/proc/resolve(datum/psy_state/PSY)
	if(PSY.stage < required_stage)
		return
	var/affecting_power = power
	if(PSY.vulnerability & psy_type)
		affecting_power *= PSY_FEAR_VULNERABLE_COEFF
	if(PSY.resistance & psy_type)
		affecting_power *= PSY_FEAR_RESISTANT_COEFF
	if(PSY.immunity & psy_type == psy_type) //immunity only works if it covers all subtypes
		affecting_power *= PSY_FEAR_IMMUNE_COEFF
	affecting_power *= PSY_FEAR_INSTABILITY_EFFECT(PSY.instability)
	if(prob(affecting_power))
		return affect(PSY)

/datum/psy_fear/proc/affect(datum/psy_state/PSY)
	var/affecting_impact = PSY_FEAR_INSTABILITY_EFFECT(PSY.instability)*impact
	PSY.instability += affecting_impact
	if(prob(affecting_impact))
		if(prob(indication_prob))
			PSY.holder << "<span class='danger'>[affect_message]</span>"
		return 1
	return

/datum/psy_consequence/proc/cooldown_check(datum/psy_state/PSY)
	return !next_available || world.time > next_available

/datum/psy_consequence/proc/cooldown_trigger(datum/psy_state/PSY)
	if(cooldown)
		next_available = world.time + cooldown

/datum/psy_consequence/proc/resolve(datum/psy_state/PSY)
	if(required_stage > PSY.stage)
		return
	if(!cooldown_check(PSY))
		return
	if(PSY.accumulated_instability < acc_price)
		return
	var/affecting_power = acc_price
	if(PSY.vulnerability & psy_type)
		affecting_power *= PSY_FEAR_VULNERABLE_COEFF
	if(PSY.resistance & psy_type)
		affecting_power *= PSY_FEAR_RESISTANT_COEFF
	if(PSY.immunity & psy_type == psy_type) //immunity only works if it covers all subtypes
		affecting_power *= PSY_FEAR_IMMUNE_COEFF
	affecting_power *= PSY_FEAR_INSTABILITY_EFFECT(PSY.instability)
	affecting_power *= prob_mod
	if(prob(affecting_power))
		return trigger(PSY)

/datum/psy_consequence/proc/trigger(datum/psy_state/PSY)
	cooldown_trigger(PSY)
	PSY.accumulated_instability -= acc_price
	return 1


/datum/psy_consequence/targeted
	var/cooldown_id = "generic" //will prevent all consequences with same id from triggering for specifit psystate

/datum/psy_consequence/targeted/cooldown_check(datum/psy_state/PSY)
	return !PSY.consequence_cooldowns[cooldown_id] || PSY.consequence_cooldowns[cooldown_id] < world.time

/datum/psy_consequence/targeted/cooldown_trigger(datum/psy_state/PSY)
	PSY.consequence_cooldowns[cooldown_id] = world.time + cooldown

/atom
	var/PSYcon
	var/PSYcon_state

	var/PSYname
	var/PSYdesc
	var/PSYcolor
	var/PSYalpha
	var/PSYappearance
	var/PSYlayer
	var/PSYplane //OMFG
	
	var/image/PSYmage

/atom/New()
	. = ..()
	add_psymage()

/atom/proc/add_psymage()
	if(PSYmage)
		remove_psymage()
	if(PSYcon)
		PSYmage = image(DEFAULTPICK(PSYcon,PSYcon),src,DEFAULTPICK(PSYcon_state,PSYcon_state))
		PSYmage.override = 1
		//it's totally ok if those below are null
		PSYmage.name = PSYname
		PSYmage.desc = PSYdesc
		PSYmage.color = PSYcolor
		PSYmage.alpha = PSYalpha
		PSYmage.appearance_flags = PSYappearance
		PSYmage.layer = PSYlayer
		PSYmage.plane = PSYplane
		psy_signs += PSYmage
		for(var/mob/living/L in psy_signs_suscepts)
			if(L.client)
				L.client.images += PSYmage

/atom/proc/remove_psymage()
	psy_signs -= PSYmage
	qdel(PSYmage)

/client/New() //logged in
	. = ..()
	var/mob/living/L = mob
	if(istype(L) && L.PSY)
		L.PSY.handle_signs() //show them ~~da way~~ overriding images