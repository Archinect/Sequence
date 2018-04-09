/datum/psy_consequence/targeted/grim_world //fiddles with client colors
	required_stage = PSY_STAGE_SIGNS
	cooldown_id = "grim_world"
	cooldown = 6000 //10 minutes
	acc_price = 15
	var/time_in = 150 //15 secs
	var/time_out = 1200 //2 minutes, seems enough
	var/color_matrix = list(0.5,-0.4,-0.4, 0.2,0.2,0.2, 0.2,0.2,0.2)


/datum/psy_consequence/targeted/grim_world/trigger(datum/psy_state/PSY)
	if(!PSY.holder || !PSY.holder.client)
		return
	. = ..()
	var/client/CL = PSY.holder.client
	PSY.holder << "<span class='danger'>You feel world around you losing it colors</span>"
	var/prev_color = CL.color
	if(istype(prev_color,/list))
		var/list/L = prev_color
		prev_color = L.Copy() //from reference to local copy
	if(!CL.color)
		CL.color = "#ffffff"
	animate(CL,color = color_matrix, time = time_in, easing = SINE_EASING|EASE_IN,flags = ANIMATION_PARALLEL)
	animate(CL,color = prev_color, time = time_out, easing = SINE_EASING|EASE_IN, flags = ANIMATION_PARALLEL)