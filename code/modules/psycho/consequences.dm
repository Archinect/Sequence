/datum/psy_consequence/targeted/grim_world //fiddles with client colors
	required_stage = PSY_STAGE_SIGNS
	cooldown_id = "grim_world"
	cooldown = 6000 //10 minutes
	acc_price = 200
	prob_mod = 0.125 // ->0.25 base prob of happening if picked
	var/time_in = 150 //15 secs
	var/time_active = 150 //15 secs
	var/time_out = 1200 //2 minutes, seems enough
	var/color_matrix = list(rgb(47,47,47), rgb(33,33,33), rgb(20,20,20), rgb(0,0,0))

/datum/psy_consequence/targeted/grim_world/trigger(datum/psy_state/PSY)
	if(!PSY.holder || !PSY.holder.client)
		return
	. = ..()
	var/client/CL = PSY.holder.client
	PSY.holder << "<span class='danger'>You feel world around you losing it colors</span>"
	if(!CL.color || CL.color == "")
		CL.color = list(1,0,0,0,1,0,0,0,1,0,0,0) //functionally equivalent
	var/prev_color = CL.color
	if(istype(prev_color,/list))
		var/list/L = prev_color
		prev_color = L.Copy() //from reference to local copy
	animate(CL,color = color_matrix, time = time_in, easing = SINE_EASING, flags = ANIMATION_PARALLEL)
	sleep(time_in+time_active)
	animate(CL,color = prev_color, time = time_out, easing = SINE_EASING, flags = ANIMATION_PARALLEL)
	sleep(time_out)

/datum/psy_consequence/targeted/notice_abstract
	required_stage = PSY_STAGE_STABLE
	cooldown_id = "notice"
	cooldown = 300 //30 secs
	acc_price = 15
	var/list/notices_list = list("Something appears in your peripheral vision, then winks out.",
	 "You hear a faint whispher with no source.",
	 "You feel air vibrate, but see no cause for it",
	 "Something doesn't feels alright at all",
	 "Sudden gleam catches your eye, but you can't determine it's source",
	 "You feel your DETERMINATION weaken",
	 "You feel there's someone unfamiliar behind you, but as you turn around you don't see anything strange",
	 "You recall seeing all this in recent bad dream")

/datum/psy_consequence/targeted/notice_abstract/trigger(datum/psy_state/PSY)
	if(!PSY.holder || !PSY.holder.client)
		return
	. = ..()
	PSY.holder << "<span class='warning'>[pick(notices_list)]</span>"

/datum/psy_consequence/targeted/notice_stare
	required_stage = PSY_STAGE_FEARS
	cooldown_id = "notice_stare"
	cooldown = 100 //10 secs
	var/list/template_stares = list("stares","glares","gazes")
	var/list/template_suffixes = list(" menacingly"," fiercely"," with missing expression",", seeing you through")

/datum/psy_consequence/targeted/notice_stare/trigger(datum/psy_state/PSY)
	if(!PSY.holder || !PSY.holder.client)
		return
	var/M = locate(/mob/living) in oview(5,PSY.holder)
	if(!M)
		return
	. = ..()
	PSY.holder << "<span class='danger'>[M] [pick(template_stares)] at you[pick(template_suffixes)]</span>"

/datum/psy_consequence/targeted/fatality
	required_stage = PSY_STAGE_PERDITION
	cooldown_id = "fatality"
	cooldown = 300 //30 secs
	acc_price = 600 //pretty high

/datum/psy_consequence/targeted/fatality/trigger(datum/psy_state/PSY)
	if(!PSY.holder || !PSY.holder.client)
		return
	var/mob/living/carbon/human/H = PSY.holder
	if(!istype(H))
		return
	if(H.can_heartattack() && !H.undergoing_cardiac_arrest())
		. = ..()
		if(!H.stat)
			H.visible_message("<span class='warning'>[H] thrashes wildly, clutching at their chest!</span>",
				"<span class='userdanger'>You feel a horrible agony in your chest!</span>")
			H.set_heartattack(TRUE)

/datum/psy_consequence/targeted/sound //for one at a time
	required_stage = PSY_STAGE_FEARS
	acc_price = 50
	cooldown = 100
	cooldown_id = "hallu_sound"
	
	var/sound_list = list('sound/effects/ghost.ogg', 'sound/effects/ghost2.ogg', 'sound/effects/Heart Beat.ogg', 'sound/effects/screech.ogg',\
		'sound/hallucinations/behind_you1.ogg', 'sound/hallucinations/behind_you2.ogg', 'sound/hallucinations/far_noise.ogg', 'sound/hallucinations/growl1.ogg', 'sound/hallucinations/growl2.ogg',\
		'sound/hallucinations/growl3.ogg', 'sound/hallucinations/im_here1.ogg', 'sound/hallucinations/im_here2.ogg', 'sound/hallucinations/i_see_you1.ogg', 'sound/hallucinations/i_see_you2.ogg',\
		'sound/hallucinations/look_up1.ogg', 'sound/hallucinations/look_up2.ogg', 'sound/hallucinations/over_here1.ogg', 'sound/hallucinations/over_here2.ogg', 'sound/hallucinations/over_here3.ogg',\
		'sound/hallucinations/turn_around1.ogg', 'sound/hallucinations/turn_around2.ogg', 'sound/hallucinations/veryfar_noise.ogg', 'sound/hallucinations/wail.ogg',
		'sound/effects/adminhelp.ogg')
	var/max_dist = 10
	var/falloff_fraction = 0.66

/datum/psy_consequence/targeted/sound/trigger(datum/psy_state/PSY)
	. = ..()
	var/sound/S = sound(pick(sound_list))
	S.x = rand(-max_dist,max_dist)
	S.y = rand(-max_dist,max_dist)
	S.falloff = max_dist*falloff_fraction
	PSY.holder << S


/datum/psy_consequence/mass/sound
	required_stage = PSY_STAGE_SIGNS
	acc_price = 150
	prob_mod = 0.16
	cooldown = 150

	var/sound_list = list('sound/spookoween/scary_horn3.ogg','sound/spookoween/ghost_whisper.ogg',
		'sound/spookoween/ghosty_wind.ogg','sound/spookoween/insane_low_laugh.ogg','sound/spookoween/scary_clown_appear.ogg',
		'sound/creatures/legion_spawn.ogg','sound/creatures/legion_death_far.ogg','sound/creatures/legion_death.ogg')
	var/max_dist = 50
	var/falloff_fraction = 0.33

/datum/psy_consequence/mass/sound/trigger(datum/psy_state/PSY)
	if(!PSY.holder.x || !PSY.holder.y) //that motherfucker somehow got into nullspace
		return
	. = ..()
	var/eff_x = rand(-max_dist,max_dist) + PSY.holder.x
	var/eff_y = rand(-max_dist,max_dist) + PSY.holder.y
	var/sound/S = sound(pick(sound_list))
	S.falloff = max_dist*falloff_fraction
	for(var/mob/R in psy_signs_suscepts)
		if(R.x && R.y)
			S.x = eff_x-R.x
			S.y = eff_y-R.y
			R << S

