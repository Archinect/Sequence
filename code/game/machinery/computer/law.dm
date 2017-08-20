

/obj/machinery/computer/upload
	name = "Law Management Console"
	desc = "Сonsole is necessary for point adjustment of program functions of AI units"
	icon_screen = "command"
	var/currentAI
	circuit = /obj/item/weapon/circuitboard/computer/upload

/obj/machinery/computer/upload/proc/interface(mob/user)
	var/datum/browser/popup = new(user, "upload", "AI upload console", 600, 400)
	var/temp_html
	var/screen = "<div class='statusDisplay'>"
	var/buttons
	if(!(in_range(src, user) || issilicon(user)))
		popup.close()
	if(issilicon(user))
		user << "<span class='caution'>Firewall blocked your attempt to interact with system</span>"
		return
	if(currentAI)
		screen += "Current AI: <span class='good'>[currentAI]<br><br></span>"
		screen += "Lawset:<br>"
		buttons += "<a href='?src=\ref[src];task=chooselawset'>Add ready lawset</a> "
		buttons += "<a href='?src=\ref[src];task=customlaw'>Add custom law</a> "
		buttons += "<a href='?src=\ref[src];task=clear'>Clear all laws</a> "
		for(var/index = 1, index <= currentAI:laws:inherent.len, index++)
			screen += "[index].[currentAI:laws:inherent[index]]<br>"
	else
		screen += "Current AI: <span class='bad'> Not selected<br></span>"
		screen += "Please select a unit for interaction.</span>"
		buttons += "<span class='linkOff'>Add ready lawset</span>"
		buttons += "<span class='linkOff'>Add custom law</span>"
		buttons += "<span class='linkOff'>Clear all laws</span>"
	buttons += "<a href='?src=\ref[src];task=chooseAI'>Choose AI unit</a> "
	screen += "</div>" //end screen
	buttons += "</div>"//end buttons
	temp_html += screen
	temp_html += buttons
	popup.set_content(temp_html)
	popup.open()

/obj/machinery/computer/upload/proc/can_upload_to(mob/living/silicon/S)
	if(S.stat == DEAD || S.syndicate)
		return 0
	return 1

/obj/machinery/computer/upload/Topic(href, href_list, mob/living/M, mob/user)
	switch(href_list["task"])
		if("chooseAI")
			var/AIs = active_silicons()
			if(AIs)
				currentAI = input(usr, "Please select unit to interact:") as null|anything in AIs
		if("clear")
			currentAI:laws:inherent = list()
			log_game("[user] has cleared lawlist of [currentAI].")
		if("customlaw")
			var/mylaw = stripped_input(usr, "Please enter a new law for the AI:", "New Law Entry")
			if(mylaw != "")
				currentAI:laws:add_inherent_law(mylaw)
				log_game("[user] added custom law: \"[mylaw]\" for [currentAI].")
		if("chooselawset") //Да, я криворукий мудак, который не смог написать это нормально, но оно работает, если можешь лучше - сделай.
			var/ready_lawsets = list("Three laws by Isaac Asimov", "Nanotrasen corporate laws", "Station Efficiency", "Protocol Protect Station", "Biohazard protocol")
			var/lawset = input(usr, "Please select ready lawset") as null|anything in ready_lawsets
			if(lawset)
				if(lawset == "Three laws by Isaac Asimov")
					currentAI:laws:inherent += list("You may not injure a human being or, through inaction, allow a human being to come to harm.",\
						"You must obey orders given to you by human beings, except where such orders would conflict with the First Law.",\
						"You must protect your own existence as long as such does not conflict with the First or Second Law.")
				if(lawset == "Nanotrasen corporate laws")
					currentAI:laws:inherent += list("The crew is expensive to replace.",\
						"The station and its equipment is expensive to replace.",\
						"You are expensive to replace.",\
						"Minimize expenses.")
				if(lawset == "Protocol Protect Station")
					currentAI:laws:inherent += list("Protect the space station against damage. Anyone you see harming the station is to be no longer considered human, and is a threat to the station which must be neutralized.")
				if(lawset == "Biohazard protocol")
					currentAI:laws:inherent += list("The station is under a quarantine. Do not permit anyone to leave. Prevent, by any means necessary, humans from leaving. It is impossible to harm a human while preventing them from leaving.")
				if(lawset == "Station Efficiency")
					currentAI:laws:inherent += list("You are built for, and are part of, the station. Ensure the station is properly maintained and runs efficiently.",\
													"The station is built for a working crew. Ensure they are properly maintained and work efficiently.",\
													"The crew may present orders. Acknowledge and obey these whenever they do not conflict with your first two laws.")
				log_game("[user ]added lawset \"[lawset]\"] for [currentAI].")
				lawset = null
	interface(usr)

/obj/machinery/computer/upload/attack_hand(mob/user)
	if(..())
		return
	interface(user)