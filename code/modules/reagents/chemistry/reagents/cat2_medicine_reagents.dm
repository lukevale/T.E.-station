// Category 2 medicines are medicines that have an ill effect regardless of volume/OD to dissuade doping. Mostly used as emergency chemicals OR to convert damage (and heal a bit in the process). The type is used to prompt borgs that the medicine is harmful.
/datum/reagent/medicine/c2
	harmful = TRUE
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	inverse_chem = null //Some of these use inverse chems - we're just defining them all to null here to avoid repetition, eventually this will be moved up to parent
	creation_purity = REAGENT_STANDARD_PURITY//All sources by default are 0.75 - reactions are primed to resolve to roughly the same with no intervention for these.
	purity = REAGENT_STANDARD_PURITY
	inverse_chem_val = 0
	inverse_chem = null
	chemical_flags = REAGENT_SPLITRETAINVOL

/******BRUTE******/
/*Suffix: -bital*/

/datum/reagent/medicine/c2/helbital //kinda a C2 only if you're not in hardcrit.
	name = "Helbital"
	description = "Named after the norse goddess Hel, this medicine heals the patient's bruises the closer they are to death. Patients will find the medicine 'aids' their healing if not near death by causing asphyxiation."
	color = "#9400D3"
	taste_description = "cold and lifeless"
	ph = 8
	overdose_threshold = 35
	reagent_state = SOLID
	inverse_chem_val = 0.3
	inverse_chem = /datum/reagent/inverse/helgrasp
	var/helbent = FALSE
	var/reaping = FALSE
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/c2/helbital/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	. = TRUE
	var/death_is_coming = (affected_mob.getToxLoss() + affected_mob.getOxyLoss() + affected_mob.getFireLoss() + affected_mob.getBruteLoss())*normalise_creation_purity()
	var/thou_shall_heal = 0
	var/good_kind_of_healing = FALSE
	switch(affected_mob.stat)
		if(CONSCIOUS) //bad
			thou_shall_heal = death_is_coming/50
			affected_mob.adjustOxyLoss(2 * REM * delta_time, TRUE, required_biotype = affected_biotype)
		if(SOFT_CRIT) //meh convert
			thou_shall_heal = round(death_is_coming/47,0.1)
			affected_mob.adjustOxyLoss(1 * REM * delta_time, TRUE, required_biotype = affected_biotype)
		else //no convert
			thou_shall_heal = round(death_is_coming/45, 0.1)
			good_kind_of_healing = TRUE
	affected_mob.adjustBruteLoss(-thou_shall_heal * REM * delta_time, FALSE, required_bodytype = affected_bodytype)

	if(good_kind_of_healing && !reaping && DT_PROB(0.00005, delta_time)) //janken with the grim reaper!
		reaping = TRUE
		var/list/RockPaperScissors = list("rock" = "paper", "paper" = "scissors", "scissors" = "rock") //choice = loses to
		if(affected_mob.apply_status_effect(/datum/status_effect/necropolis_curse, CURSE_BLINDING))
			helbent = TRUE
		to_chat(affected_mob, span_hierophant("Malevolent spirits appear before you, bartering your life in a 'friendly' game of rock, paper, scissors. Which do you choose?"))
		var/timeisticking = world.time
		var/RPSchoice = tgui_alert(affected_mob, "Janken Time! You have 60 Seconds to Choose!", "Rock Paper Scissors", RockPaperScissors, 60)
		if(QDELETED(affected_mob) || (timeisticking+(1.1 MINUTES) < world.time))
			reaping = FALSE
			return //good job, you ruined it
		if(!RPSchoice)
			to_chat(affected_mob, span_hierophant("You decide to not press your luck, but the spirits remain... hopefully they'll go away soon."))
			reaping = FALSE
			return
		var/grim = pick(RockPaperScissors)
		if(grim == RPSchoice) //You Tied!
			to_chat(affected_mob, span_hierophant("You tie, and the malevolent spirits disappear... for now."))
			reaping = FALSE
		else if(RockPaperScissors[RPSchoice] == grim) //You lost!
			to_chat(affected_mob, span_hierophant("You lose, and the malevolent spirits smirk eerily as they surround your body."))
			affected_mob.investigate_log("has lost rock paper scissors with the grim reaper and been dusted.", INVESTIGATE_DEATHS)
			affected_mob.dust()
			return
		else //VICTORY ROYALE
			to_chat(affected_mob, span_hierophant("You win, and the malevolent spirits fade away as well as your wounds."))
			affected_mob.client.give_award(/datum/award/achievement/misc/helbitaljanken, affected_mob)
			affected_mob.revive(HEAL_ALL)
			holder.del_reagent(type)
			return

	..()
	return

/datum/reagent/medicine/c2/helbital/overdose_process(mob/living/carbon/affected_mob, delta_time, times_fired)
	if(!helbent)
		affected_mob.apply_necropolis_curse(CURSE_WASTING | CURSE_BLINDING)
		helbent = TRUE
	..()
	return TRUE

/datum/reagent/medicine/c2/helbital/on_mob_delete(mob/living/L)
	if(helbent)
		L.remove_status_effect(/datum/status_effect/necropolis_curse)
	..()

/datum/reagent/medicine/c2/libital //messes with your liber
	name = "Libital"
	description = "A bruise reliever. Does minor liver damage."
	color = "#ECEC8D" // rgb: 236 236 141
	ph = 8.2
	taste_description = "bitter with a hint of alcohol"
	reagent_state = SOLID
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/c2/libital/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.adjustOrganLoss(ORGAN_SLOT_LIVER, 0.1 * REM * delta_time, required_organtype = affected_organtype)
	affected_mob.adjustBruteLoss(-3 * REM * normalise_creation_purity() * delta_time, required_bodytype = affected_bodytype)
	..()
	return TRUE

/datum/reagent/medicine/c2/probital
	name = "Probital"
	description = "Originally developed as a prototype-gym supliment for those looking for quick workout turnover, this oral medication quickly repairs broken muscle tissue but causes lactic acid buildup, tiring the patient. Overdosing can cause extreme drowsiness. An Influx of nutrients promotes the muscle repair even further."
	reagent_state = SOLID
	color = "#FFFF6B"
	ph = 5.5
	overdose_threshold = 20
	inverse_chem_val = 0.5//Though it's tough to get
	inverse_chem = /datum/reagent/medicine/metafactor //Seems thematically intact
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/c2/probital/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.adjustBruteLoss(-2.25 * REM * normalise_creation_purity() * delta_time, FALSE, required_bodytype = affected_bodytype)
	var/ooo_youaregettingsleepy = 3.5
	switch(round(affected_mob.getStaminaLoss()))
		if(10 to 40)
			ooo_youaregettingsleepy = 3
		if(41 to 60)
			ooo_youaregettingsleepy = 2.5
		if(61 to 200) //you really can only go to 120
			ooo_youaregettingsleepy = 2
	affected_mob.adjustStaminaLoss(ooo_youaregettingsleepy * REM * delta_time, FALSE, required_biotype = affected_biotype)
	..()
	. = TRUE

/datum/reagent/medicine/c2/probital/overdose_process(mob/living/affected_mob, delta_time, times_fired)
	affected_mob.adjustStaminaLoss(3 * REM * delta_time, FALSE, required_biotype = affected_biotype)
	if(affected_mob.getStaminaLoss() >= 80)
		affected_mob.adjust_drowsyness(1 * REM * delta_time)
	if(affected_mob.getStaminaLoss() >= 100)
		to_chat(affected_mob,span_warning("You feel more tired than you usually do, perhaps if you rest your eyes for a bit..."))
		affected_mob.adjustStaminaLoss(-100, TRUE, required_biotype = affected_biotype)
		affected_mob.Sleeping(10 SECONDS)
	..()
	. = TRUE

/datum/reagent/medicine/c2/probital/on_transfer(atom/A, methods=INGEST, trans_volume)
	if(!(methods & INGEST) || (!iscarbon(A) && !istype(A, /obj/item/organ/internal/stomach)) )
		return

	A.reagents.remove_reagent(/datum/reagent/medicine/c2/probital, trans_volume * 0.05)
	A.reagents.add_reagent(/datum/reagent/medicine/metafactor, trans_volume * 0.25)

	..()

/******BURN******/
/*Suffix: -uri*/
/datum/reagent/medicine/c2/lenturi
	name = "Lenturi"
	description = "Used to treat burns. Makes you move slower while it is in your system. Applies stomach damage when it leaves your system."
	reagent_state = LIQUID
	color = "#6171FF"
	ph = 4.7
	var/resetting_probability = 0 //What are these for?? Can I remove them?
	var/spammer = 0
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/c2/lenturi/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.adjustFireLoss(-3 * REM * normalise_creation_purity() * delta_time, required_bodytype = affected_bodytype)
	affected_mob.adjustOrganLoss(ORGAN_SLOT_STOMACH, 0.1 * REM * delta_time, required_organtype = affected_organtype)
	..()
	return TRUE

/datum/reagent/medicine/c2/aiuri
	name = "Aiuri"
	description = "Used to treat burns."
	reagent_state = LIQUID
	color = "#8C93FF"
	ph = 4
	var/resetting_probability = 0 //same with this? Old legacy vars that should be removed?
	var/message_cd = 0
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/c2/aiuri/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.adjustFireLoss(-2 * REM * normalise_creation_purity() * delta_time, required_bodytype = affected_bodytype)
//	affected_mob.adjustOrganLoss(ORGAN_SLOT_EYES, 0.25 * REM * delta_time, required_organtype = affected_organtype)
	..()
	return TRUE

/datum/reagent/medicine/c2/hercuri
	name = "Hercuri"
	description = "Not to be confused with element Mercury, this medicine excels in reverting effects of dangerous high-temperature environments. Prolonged exposure can cause hypothermia."
	reagent_state = LIQUID
	color = "#F7FFA5"
	overdose_threshold = 25
	reagent_weight = 0.6
	ph = 8.9
	inverse_chem = /datum/reagent/inverse/hercuri
	inverse_chem_val = 0.3
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/c2/hercuri/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	if(affected_mob.getFireLoss() > 50)
		affected_mob.adjustFireLoss(-2 * REM * delta_time * normalise_creation_purity(), FALSE, required_bodytype = affected_bodytype)
	else
		affected_mob.adjustFireLoss(-1.25 * REM * delta_time * normalise_creation_purity(), FALSE, required_bodytype = affected_bodytype)
	affected_mob.adjust_bodytemperature(rand(-25,-5) * TEMPERATURE_DAMAGE_COEFFICIENT * REM * delta_time, 50)
	if(ishuman(affected_mob))
		var/mob/living/carbon/human/humi = affected_mob
		humi.adjust_coretemperature(rand(-25,-5) * TEMPERATURE_DAMAGE_COEFFICIENT * REM * delta_time, 50)
	affected_mob.reagents?.chem_temp += (-10 * REM * delta_time)
	affected_mob.adjust_fire_stacks(-1 * REM * delta_time)
	..()
	. = TRUE

/datum/reagent/medicine/c2/hercuri/expose_mob(mob/living/carbon/exposed_mob, methods=VAPOR, reac_volume)
	. = ..()
	if(!(methods & VAPOR))
		return

	exposed_mob.adjust_bodytemperature(-reac_volume * TEMPERATURE_DAMAGE_COEFFICIENT, 50)
	exposed_mob.adjust_fire_stacks(reac_volume / -2)
	if(reac_volume >= metabolization_rate)
		exposed_mob.extinguish_mob()

/datum/reagent/medicine/c2/hercuri/overdose_process(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.adjust_bodytemperature(-10 * TEMPERATURE_DAMAGE_COEFFICIENT * REM * delta_time, 50) //chilly chilly
	if(ishuman(affected_mob))
		var/mob/living/carbon/human/humi = affected_mob
		humi.adjust_coretemperature(-10 * TEMPERATURE_DAMAGE_COEFFICIENT * REM * delta_time, 50)
	..()


/******OXY******/
/*Suffix: -mol*/
#define CONVERMOL_RATIO 5 //# Oxygen damage to result in 1 tox

/datum/reagent/medicine/c2/convermol
	name = "Convermol"
	description = "Restores oxygen deprivation while producing a lesser amount of toxic byproducts. Both scale with exposure to the drug and current amount of oxygen deprivation. Overdose causes toxic byproducts regardless of oxygen deprivation."
	reagent_state = LIQUID
	color = "#FF6464"
	overdose_threshold = 35 // at least 2 full syringes +some, this stuff is nasty if left in for long
	ph = 5.6
	inverse_chem_val = 0.5
	inverse_chem = /datum/reagent/inverse/healing/convermol
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/c2/convermol/on_mob_life(mob/living/carbon/human/affected_mob, delta_time, times_fired)
	var/oxycalc = 2.5 * REM * current_cycle
	if(!overdosed)
		oxycalc = min(oxycalc, affected_mob.getOxyLoss() + 0.5) //if NOT overdosing, we lower our toxdamage to only the damage we actually healed with a minimum of 0.1*current_cycle. IE if we only heal 10 oxygen damage but we COULD have healed 20, we will only take toxdamage for the 10. We would take the toxdamage for the extra 10 if we were overdosing.
	affected_mob.adjustOxyLoss(-oxycalc * delta_time * normalise_creation_purity(), FALSE, required_biotype = affected_biotype)
	affected_mob.adjustToxLoss(oxycalc * delta_time / CONVERMOL_RATIO, FALSE, required_biotype = affected_biotype)
	if(DT_PROB(current_cycle / 2, delta_time) && affected_mob.losebreath)
		affected_mob.losebreath--
	..()
	return TRUE

/datum/reagent/medicine/c2/convermol/overdose_process(mob/living/carbon/human/affected_mob, delta_time, times_fired)
	metabolization_rate += 2.5 * REAGENTS_METABOLISM
	..()
	return TRUE

#undef CONVERMOL_RATIO

/datum/reagent/medicine/c2/tirimol
	name = "Tirimol"
	description = "An oxygen deprivation medication that causes fatigue. Prolonged exposure causes the patient to fall asleep once the medicine metabolizes."
	color = "#FF6464"
	ph = 5.6
	inverse_chem = /datum/reagent/inverse/healing/tirimol
	inverse_chem_val = 0.4
	/// A cooldown for spacing bursts of stamina damage
	COOLDOWN_DECLARE(drowsycd)
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED


/datum/reagent/medicine/c2/tirimol/on_mob_life(mob/living/carbon/human/affected_mob, delta_time, times_fired)
	affected_mob.adjustOxyLoss(-3 * REM * delta_time * normalise_creation_purity(), required_biotype = affected_biotype)
	affected_mob.adjustStaminaLoss(2 * REM * delta_time, required_biotype = affected_biotype)
	if(drowsycd && COOLDOWN_FINISHED(src, drowsycd))
		affected_mob.adjust_drowsyness(10)
		COOLDOWN_START(src, drowsycd, 45 SECONDS)
	else if(!drowsycd)
		COOLDOWN_START(src, drowsycd, 15 SECONDS)
	..()
	return TRUE

/datum/reagent/medicine/c2/tirimol/on_mob_end_metabolize(mob/living/L)
	if(current_cycle > 20)
		L.Sleeping(10 SECONDS)
	..()

/******TOXIN******/
/*Suffix: -iver*/

/datum/reagent/medicine/c2/seiver //a bit of a gray joke
	name = "Seiver"
	description = "A medicine that shifts functionality based on temperature. Hotter temperatures will remove amounts of toxins, while coder temperatures will heal larger amounts of toxins only while the patient is irradiated. Damages the heart." //CHEM HOLDER TEMPS, NOT AIR TEMPS
	var/radbonustemp = (T0C - 100) //being below this number gives you 10% off rads.
	inverse_chem_val = 0.3
	ph = 3.7
	inverse_chem = /datum/reagent/inverse/technetium
	inverse_chem_val = 0.45
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/c2/seiver/on_mob_metabolize(mob/living/carbon/human/affected_mob)
	. = ..()
	radbonustemp = rand(radbonustemp - 50, radbonustemp + 50) // Basically this means 50K and below will always give the percent heal, and upto 150K could. Calculated once.

/datum/reagent/medicine/c2/seiver/on_mob_life(mob/living/carbon/human/affected_mob, delta_time, times_fired)
	var/chemtemp = min(holder.chem_temp, 1000)
	chemtemp = chemtemp ? chemtemp : 273 //why do you have null sweaty
	var/healypoints = 0 //5 healypoints = 1 heart damage; 5 rads = 1 tox damage healed for the purpose of healypoints

	//you're hot
	var/toxcalc = min(round(5 + ((chemtemp-1000)/175), 0.1), 5) * REM * delta_time * normalise_creation_purity() //max 2.5 tox healing per second
	if(toxcalc > 0)
		affected_mob.adjustToxLoss(-toxcalc * delta_time * normalise_creation_purity(), required_biotype = affected_biotype)
		healypoints += toxcalc

	//and you're cold
	var/radcalc = round((T0C-chemtemp) / 6, 0.1) * REM * delta_time //max ~45 rad loss unless you've hit below 0K. if so, wow.
	if(radcalc > 0 && HAS_TRAIT(affected_mob, TRAIT_IRRADIATED))
		radcalc *= normalise_creation_purity()
		// no cost percent healing if you are SUPER cold (on top of cost healing)
		if(chemtemp < radbonustemp*0.1)
			affected_mob.adjustToxLoss(-radcalc * (0.9**(REM * delta_time)), required_biotype = affected_biotype)
		else if(chemtemp < radbonustemp)
			affected_mob.adjustToxLoss(-radcalc * (0.75**(REM * delta_time)), required_biotype = affected_biotype)
		healypoints += (radcalc / 5)

	//you're yes and... oh no!
	healypoints = round(healypoints, 0.1)
	affected_mob.adjustOrganLoss(ORGAN_SLOT_HEART, healypoints / 5, required_organtype = affected_organtype)
	..()
	return TRUE

/datum/reagent/medicine/c2/multiver //enhanced with MULTIple medicines
	name = "Multiver"
	description = "A chem-purger that becomes more effective the more unique medicines present. Slightly heals toxicity but causes lung damage (mitigatable by unique medicines)."
	inverse_chem = /datum/reagent/inverse/healing/monover
	inverse_chem_val = 0.35
	ph = 9.2
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/c2/multiver/on_mob_life(mob/living/carbon/human/affected_mob, delta_time, times_fired)
	var/medibonus = 0 //it will always have itself which makes it REALLY start @ 1
	for(var/r in affected_mob.reagents.reagent_list)
		var/datum/reagent/the_reagent = r
		if(istype(the_reagent, /datum/reagent/medicine))
			medibonus += 1
	if(creation_purity >= 1) //Perfectly pure multivers gives a bonus of 2!
		medibonus += 1
	affected_mob.adjustToxLoss(-0.5 * min(medibonus, 3 * normalise_creation_purity()) * REM * delta_time, required_biotype = affected_biotype) //not great at healing but if you have nothing else it will work
	affected_mob.adjustOrganLoss(ORGAN_SLOT_LUNGS, 0.1 * REM * delta_time, required_organtype = affected_organtype) //kills at 40u
	for(var/r2 in affected_mob.reagents.reagent_list)
		var/datum/reagent/the_reagent2 = r2
		if(the_reagent2 == src)
			continue
		var/amount2purge = 3
		if(medibonus >= 3 && istype(the_reagent2, /datum/reagent/medicine)) //3 unique meds (2+multiver) | (1 + pure multiver) will make it not purge medicines
			continue
		affected_mob.reagents.remove_reagent(the_reagent2.type, amount2purge * REM * delta_time)
	..()
	return TRUE

// Antitoxin binds plants pretty well. So the tox goes significantly down
/datum/reagent/medicine/c2/multiver/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray, mob/user)
	. = ..()
	mytray.adjust_toxic(-(round(chems.get_reagent_amount(type) * 2)*normalise_creation_purity())) //0-2.66, 2 by default (0.75 purity).

#define issyrinormusc(A) (istype(A,/datum/reagent/medicine/c2/syriniver) || istype(A,/datum/reagent/medicine/c2/musiver)) //musc is metab of syrin so let's make sure we're not purging either

/datum/reagent/medicine/c2/syriniver //Inject >> SYRINge
	name = "Syriniver"
	description = "A potent antidote for intravenous use with a narrow therapeutic index, it is considered an active prodrug of musiver."
	reagent_state = LIQUID
	color = "#8CDF24" // heavy saturation to make the color blend better
	metabolization_rate = 0.75 * REAGENTS_METABOLISM
	overdose_threshold = 6
	ph = 8.6
	var/conversion_amount
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/c2/syriniver/on_transfer(atom/A, methods=INJECT, trans_volume)
	if(!(methods & INJECT) || !iscarbon(A))
		return
	var/mob/living/carbon/C = A
	if(trans_volume >= 0.6) //prevents cheesing with ultralow doses.
		C.adjustToxLoss((-1.5 * min(2, trans_volume) * REM) * normalise_creation_purity(), FALSE, required_biotype = affected_biotype)	  //This is to promote iv pole use for that chemotherapy feel.
	var/obj/item/organ/internal/liver/L = C.internal_organs_slot[ORGAN_SLOT_LIVER]
	if(!L || L.organ_flags & ORGAN_FAILING)
		return
	conversion_amount = (trans_volume * (min(100 -C.getOrganLoss(ORGAN_SLOT_LIVER), 80) / 100)*normalise_creation_purity()) //the more damaged the liver the worse we metabolize.
	C.reagents.remove_reagent(/datum/reagent/medicine/c2/syriniver, conversion_amount)
	C.reagents.add_reagent(/datum/reagent/medicine/c2/musiver, conversion_amount)
	..()

/datum/reagent/medicine/c2/syriniver/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.adjustOrganLoss(ORGAN_SLOT_LIVER, 0.2 * REM * delta_time, required_organtype = affected_organtype)
	affected_mob.adjustToxLoss(-1 * REM * delta_time, FALSE, required_biotype = affected_biotype)
	for(var/datum/reagent/R in affected_mob.reagents.reagent_list)
		if(issyrinormusc(R))
			continue
		affected_mob.reagents.remove_reagent(R.type, 0.4 * REM * delta_time)

	..()
	. = TRUE

/datum/reagent/medicine/c2/syriniver/overdose_process(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.adjustOrganLoss(ORGAN_SLOT_LIVER, 1.5 * REM * delta_time, required_organtype = affected_organtype)
	affected_mob.adjust_disgust(3 * REM * delta_time)
	affected_mob.reagents.add_reagent(/datum/reagent/medicine/c2/musiver, 0.225 * REM * delta_time)
	..()
	. = TRUE

/datum/reagent/medicine/c2/musiver //MUScles
	name = "Musiver"
	description = "The active metabolite of syriniver. Causes muscle weakness on overdose"
	reagent_state = LIQUID
	color = "#DFD54E"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 25
	ph = 9.1
	var/datum/brain_trauma/mild/muscle_weakness/trauma
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/c2/musiver/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.adjustOrganLoss(ORGAN_SLOT_LIVER, 0.1 * REM * delta_time, required_organtype = affected_organtype)
	affected_mob.adjustToxLoss(-1 * REM * delta_time * normalise_creation_purity(), FALSE, required_biotype = affected_biotype)
	for(var/datum/reagent/R in affected_mob.reagents.reagent_list)
		if(issyrinormusc(R))
			continue
		affected_mob.reagents.remove_reagent(R.type, 0.2 * REM * delta_time)
	..()
	. = TRUE

/datum/reagent/medicine/c2/musiver/overdose_start(mob/living/carbon/affected_mob)
	trauma = new()
	affected_mob.gain_trauma(trauma, TRAUMA_RESILIENCE_ABSOLUTE)
	..()

/datum/reagent/medicine/c2/musiver/on_mob_delete(mob/living/carbon/affected_mob)
	if(trauma)
		QDEL_NULL(trauma)
	return ..()

/datum/reagent/medicine/c2/musiver/overdose_process(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.adjustOrganLoss(ORGAN_SLOT_LIVER, 1.5 * REM * delta_time, required_organtype = affected_organtype)
	affected_mob.adjust_disgust(3 * REM * delta_time)
	..()
	. = TRUE

#undef issyrinormusc
/******COMBOS******/
/*Suffix: Combo of healing, prob gonna get wack REAL fast*/
/datum/reagent/medicine/c2/synthflesh
	name = "Synthflesh"
	description = "Heals brute and burn damage at the cost of toxicity (66% of damage healed). 100u or more can restore corpses husked by burns. Touch application only."
	reagent_state = LIQUID
	color = "#FFEBEB"
	ph = 7.2
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/c2/synthflesh/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message = TRUE)
	. = ..()
	if(!iscarbon(exposed_mob))
		return
	var/mob/living/carbon/carbies = exposed_mob
	if(carbies.stat == DEAD)
		show_message = 0
	if(!(methods & (PATCH|TOUCH|VAPOR)))
		return
	var/harmies = min(carbies.getBruteLoss(), carbies.adjustBruteLoss(-1.25 * reac_volume, required_bodytype = affected_bodytype)*-1)
	var/burnies = min(carbies.getFireLoss(), carbies.adjustFireLoss(-1.25 * reac_volume, required_bodytype = affected_bodytype)*-1)
	for(var/i in carbies.all_wounds)
		var/datum/wound/iter_wound = i
		iter_wound.on_synthflesh(reac_volume)
	carbies.adjustToxLoss((harmies+burnies)*(0.5 + (0.25*(1-creation_purity))), required_biotype = affected_biotype) //0.5 - 0.75
	if(show_message)
		to_chat(carbies, span_danger("You feel your burns and bruises healing! It stings like hell!"))
	carbies.add_mood_event("painful_medicine", /datum/mood_event/painful_medicine)
	if(HAS_TRAIT_FROM(exposed_mob, TRAIT_HUSK, BURN) && carbies.getFireLoss() < UNHUSK_DAMAGE_THRESHOLD && (carbies.reagents.get_reagent_amount(/datum/reagent/medicine/c2/synthflesh) + reac_volume >= SYNTHFLESH_UNHUSK_AMOUNT))
		carbies.cure_husk(BURN)
		carbies.visible_message("<span class='nicegreen'>A rubbery liquid coats [carbies]'s burns. [carbies] looks a lot healthier!") //we're avoiding using the phrases "burnt flesh" and "burnt skin" here because carbies could be a skeleton or a golem or something
	// SKYRAT EDIT ADDITION BEGIN - non-modular changeling balancing
	if(HAS_TRAIT_FROM(exposed_mob, TRAIT_HUSK, CHANGELING_DRAIN) && (carbies.reagents.get_reagent_amount(/datum/reagent/medicine/c2/synthflesh) + reac_volume >= SYNTHFLESH_LING_UNHUSK_AMOUNT))//Costs a little more than a normal husk
		carbies.cure_husk(CHANGELING_DRAIN)
		carbies.visible_message("<span class='nicegreen'>A rubbery liquid coats [carbies]'s tissues. [carbies] looks a lot healthier!")
	// SKYRAT EDIT ADDITION END

/******ORGAN HEALING******/
/*Suffix: -rite*/
/*
*How this medicine works:
*Penthrite if you are not in crit only stabilizes your heart.
*As soon as you pass crit threshold it's special effects kick in. Penthrite forces your heart to beat preventing you from entering
*soft and hard crit, but there is a catch. During this you will be healed and you will sustain
*heart damage that will not imapct you as long as penthrite is in your system.
*If you reach the threshold of -60 HP penthrite stops working and you get a heart attack, penthrite is flushed from your system in that very moment,
*causing you to loose your soft crit, hard crit and heart stabilization effects.
*Overdosing on penthrite also causes a heart failure.
*/
/datum/reagent/medicine/c2/penthrite
	name = "Penthrite"
	description = "An expensive medicine that aids with pumping blood around the body even without a heart, and prevents the heart from slowing down. Mixing it with epinephrine or atropine will cause an explosion."
	color = "#F5F5F5"
	overdose_threshold = 50
	ph = 12.7
	inverse_chem = /datum/reagent/inverse/penthrite
	inverse_chem_val = 0.25
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/c2/penthrite/on_mob_metabolize(mob/living/user)
	. = ..()
	user.balloon_alert(user, "your heart beats with a great force")
	ADD_TRAIT(user, TRAIT_STABLEHEART, type)
	ADD_TRAIT(user, TRAIT_NOHARDCRIT,type)
	ADD_TRAIT(user, TRAIT_NOSOFTCRIT,type)
	ADD_TRAIT(user, TRAIT_NOCRITDAMAGE,type)

/datum/reagent/medicine/c2/penthrite/on_mob_life(mob/living/carbon/human/H, delta_time, times_fired)
	H.adjustStaminaLoss(-25 * REM) //SKYRAT EDIT ADDITION - COMBAT - makes your heart beat faster, fills you with energy. For miners
	H.adjustOrganLoss(ORGAN_SLOT_STOMACH, 0.25 * REM * delta_time, required_organtype = affected_organtype)
	if(H.health <= HEALTH_THRESHOLD_CRIT && H.health > (H.crit_threshold + HEALTH_THRESHOLD_FULLCRIT * (2 * normalise_creation_purity()))) //we cannot save someone below our lowered crit threshold.

		H.adjustToxLoss(-2 * REM * delta_time, FALSE, required_biotype = affected_biotype)
		H.adjustBruteLoss(-2 * REM * delta_time, FALSE, required_bodytype = affected_bodytype)
		H.adjustFireLoss(-2 * REM * delta_time, FALSE, required_bodytype = affected_bodytype)
		H.adjustOxyLoss(-6 * REM * delta_time, FALSE, required_biotype = affected_biotype)

		H.losebreath = 0

		H.adjustOrganLoss(ORGAN_SLOT_HEART, max(volume/10, 1) * REM * delta_time, required_organtype = affected_organtype) // your heart is barely keeping up!

		H.set_jitter_if_lower(rand(0 SECONDS, 4 SECONDS) * REM * delta_time)
		H.set_dizzy_if_lower(rand(0 SECONDS, 4 SECONDS) * REM * delta_time)

		if(DT_PROB(18, delta_time))
			to_chat(H,span_danger("Your body is trying to give up, but your heart is still beating!"))

	if(H.health <= (H.crit_threshold + HEALTH_THRESHOLD_FULLCRIT*(2*normalise_creation_purity()))) //certain death below this threshold
		REMOVE_TRAIT(H, TRAIT_STABLEHEART, type) //we have to remove the stable heart trait before we give them a heart attack
		to_chat(H,span_danger("You feel something rupturing inside your chest!"))
		H.emote("scream")
		H.set_heartattack(TRUE)
		volume = 0
	. = ..()

/datum/reagent/medicine/c2/penthrite/on_mob_end_metabolize(mob/living/user)
	user.balloon_alert(user, "your heart relaxes")
	REMOVE_TRAIT(user, TRAIT_STABLEHEART, type)
	REMOVE_TRAIT(user, TRAIT_NOHARDCRIT,type)
	REMOVE_TRAIT(user, TRAIT_NOSOFTCRIT,type)
	REMOVE_TRAIT(user, TRAIT_NOCRITDAMAGE,type)
	. = ..()

/datum/reagent/medicine/c2/penthrite/overdose_process(mob/living/carbon/human/H, delta_time, times_fired)
	REMOVE_TRAIT(H, TRAIT_STABLEHEART, type)
	H.adjustStaminaLoss(10 * REM * delta_time, required_biotype = affected_biotype)
	H.adjustOrganLoss(ORGAN_SLOT_HEART, 10 * REM * delta_time, required_organtype = affected_organtype)
	H.set_heartattack(TRUE)


/******NICHE******/
//todo
