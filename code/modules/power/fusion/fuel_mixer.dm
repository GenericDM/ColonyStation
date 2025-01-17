/obj/machinery/power/fuel_mixer
	name = "fusion fuel mix controller"
	desc = "This little thing can customize fuel mixes."
	icon = 'goon/icons/obj/fusion_control.dmi'
	icon_state = "cab1"

	density = TRUE


	use_power = IDLE_POWER_USE

	idle_power_usage = 10
	active_power_usage = 500

	var/obj/item/disk/fuel_mix/mix
	var/possibleAdditives = list()

/obj/machinery/power/fuel_mixer/Initialize()
	for(var/A in subtypesof(/datum/fuel_additive))
		possibleAdditives += new A()
	..()

/obj/machinery/power/fuel_mixer/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/disk/fuel_mix))
		mix = W
		W.forceMove(src)

/obj/machinery/power/fuel_mixer/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
									datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "fuel_mixer", name, 475, 800, master_ui, state)
		ui.open()

/obj/machinery/power/fuel_mixer/ui_data()
	var/list/data = list()

	data["mix"] = mix
	data["deu"] = mix.deuteriumMix
	data["tri"] = mix.tritiumMix

	data["possibleAdditives"] = list()

	for(var/datum/fuel_additive/A in possibleAdditives)
		data["possibleAdditives"] += list(list("aName" = A.name, "aDesc" = A.desc))

	data["additives"] = list()

	for(var/datum/fuel_additive/A in mix.additives)
		data["additives"] += list(list("aName" = A.name, "aDesc" = A.desc))

	return data

/obj/machinery/power/fuel_mixer/ui_act(action, params)
	if(..())
		return
	if(!mix)
		return
	switch(action)
		if("deu1")
			mix.deuteriumMix++
			mix.tritiumMix--
			if(mix.deuteriumMix > 100)
				mix.deuteriumMix = 100
				mix.tritiumMix = 0

			. = TRUE
		if("deu10")
			mix.deuteriumMix += 10
			mix.tritiumMix -= 10
			if(mix.deuteriumMix > 100)
				mix.deuteriumMix = 100
				mix.tritiumMix = 0
			. = TRUE
		if("tri1")
			mix.deuteriumMix -= 1
			mix.tritiumMix += 1
			if(mix.tritiumMix > 100)
				mix.deuteriumMix = 0
				mix.tritiumMix = 100
			. = TRUE
		if("tri10")
			mix.deuteriumMix -= 10
			mix.tritiumMix += 10
			if(mix.tritiumMix > 100)
				mix.deuteriumMix = 0
				mix.tritiumMix = 100
			. = TRUE
		if("eject")
			mix.forceMove(get_turf(src))
			mix = null
			. = TRUE
		if("remove")
			for(var/datum/fuel_additive/A in mix.additives)
				if(A.name == params["additive"])
					mix.additives -= A
		if("add")
			for(var/datum/fuel_additive/A in possibleAdditives)
				if(A.name == params["additive"])
					mix.additives += A