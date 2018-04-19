/obj/structure/closet/debug_pandora
	name = "pandora closet"
	desc = "You must be insane if you want to open it. Or at least you'll surely get"
	color = "#333333"
	var/datum/psy_fear/pandora/payload

/obj/structure/closet/debug_pandora/New()
	. = ..()
	payload = new()

/obj/structure/closet/debug_pandora/open(mob/living/user)
	. = ..()
	if(!.) return
	if(payload)
		payload.trigger(user)
		QDEL_NULL(payload)
		color = ""