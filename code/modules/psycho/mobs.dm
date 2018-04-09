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
	for(var/i = rand(5,10),i > 0, i--)//horrors are longer than normal dreams
		var/horror_image = pick(horrors)
		horrors -= horror_image
		src << "<span class='danger'><i>... [horror_image] ...</i></span>"
		var/sleep_time = rand(30,60)
		PSY.instability += sqrt(PSY.instability)
		sleep(sleep_time)
		if(paralysis <= 0)
			dreaming = 0
			return 0
	Paralyse(10)
	AdjustSleeping(-30) //awaken after horror
	dreaming = 0
	return 1