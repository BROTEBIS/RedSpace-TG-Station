GLOBAL_LIST_EMPTY(roundstart_races)
///List of all roundstart languages by path except common
GLOBAL_LIST_EMPTY(uncommon_roundstart_languages)

/// An assoc list of species types to their features (from get_features())
GLOBAL_LIST_EMPTY(features_by_species)

/**
 * # species datum
 *
 * Datum that handles different species in the game.
 *
 * This datum handles species in the game, such as lizardpeople, mothmen, zombies, skeletons, etc.
 * It is used in [carbon humans][mob/living/carbon/human] to determine various things about them, like their food preferences, if they have biological genders, their damage resistances, and more.
 *
 */
/datum/species
	///If the game needs to manually check your race to do something not included in a proc here, it will use this.
	var/id
	///This is used for children, it will determine their default limb ID for use of examine. See [/mob/living/carbon/human/proc/examine].
	var/examine_limb_id
	///This is the fluff name. They are displayed on health analyzers and in the character setup menu. Leave them generic for other servers to customize.
	var/name
	/**
	 * The formatting of the name of the species in plural context. Defaults to "[name]\s" if unset.
	 *  Ex "[Plasmamen] are weak", "[Mothmen] are strong", "[Lizardpeople] don't like", "[Golems] hate"
	 */
	var/plural_form

	///Whether or not the race has sexual characteristics (biological genders). At the moment this is only FALSE for skeletons and shadows
	var/sexes = TRUE

	///The maximum number of bodyparts this species can have.
	var/max_bodypart_count = 6
	///This allows races to have specific hair colors. If null, it uses the H's hair/facial hair colors. If "mutcolor", it uses the H's mutant_color. If "fixedmutcolor", it uses fixedmutcolor
	var/hair_color
	///The alpha used by the hair. 255 is completely solid, 0 is invisible.
	var/hair_alpha = 255
	///The alpha used by the facial hair. 255 is completely solid, 0 is invisible.
	var/facial_hair_alpha = 255

	///Never, Optional, or Forced digi legs?
	var/digitigrade_customization = DIGITIGRADE_NEVER
	///If your race bleeds something other than bog standard blood, change this to reagent id. For example, ethereals bleed liquid electricity.
	var/datum/reagent/exotic_blood
	///If your race uses a non standard bloodtype (A+, O-, AB-, etc). For example, lizards have L type blood.
	var/exotic_bloodtype = ""
	///The rate at which blood is passively drained by having the blood deficiency quirk. Some races such as slimepeople can regen their blood at different rates so this is to account for that
	var/blood_deficiency_drain_rate = BLOOD_REGEN_FACTOR + BLOOD_DEFICIENCY_MODIFIER // slightly above the regen rate so it slowly drains instead of regenerates.
	///What the species drops when gibbed by a gibber machine.
	var/meat = /obj/item/food/meat/slab/human
	///What skin the species drops when gibbed by a gibber machine.
	var/skinned_type
	///flags for inventory slots the race can't equip stuff to. Golems cannot wear jumpsuits, for example.
	var/no_equip_flags
	/// What languages this species can understand and say.
	/// Use a [language holder datum][/datum/language_holder] typepath in this var.
	/// Should never be null.
	var/datum/language_holder/species_language_holder = /datum/language_holder/human_basic
	/**
	  * Visible CURRENT bodyparts that are unique to a species.
	  * DO NOT USE THIS AS A LIST OF ALL POSSIBLE BODYPARTS AS IT WILL FUCK
	  * SHIT UP! Changes to this list for non-species specific bodyparts (ie
	  * cat ears and tails) should be assigned at organ level if possible.
	  * Assoc values are defaults for given bodyparts, also modified by aforementioned organs.
	  * They also allow for faster '[]' list access versus 'in'. Other than that, they are useless right now.
	  * Layer hiding is handled by [/datum/species/proc/handle_mutant_bodyparts] below.
	  */
	var/list/mutant_bodyparts = list()
	///The bodyparts this species uses. assoc of bodypart string - bodypart type. Make sure all the fucking entries are in or I'll skin you alive.
	var/list/bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right,
		BODY_ZONE_HEAD = /obj/item/bodypart/head,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest,
	)
	///Internal organs that are unique to this race, like a tail. list(typepath of organ 1, typepath of organ 2)
	var/list/mutant_organs = list()
	///List of external organs to generate like horns, frills, wings, etc. list(typepath of organ = "Round Beautiful BDSM Snout"). Still WIP
	var/list/external_organs = list()
	///Replaces default brain with a different organ
	var/obj/item/organ/internal/brain/mutantbrain = /obj/item/organ/internal/brain
	///Replaces default heart with a different organ
	var/obj/item/organ/internal/heart/mutantheart = /obj/item/organ/internal/heart
	///Replaces default lungs with a different organ
	var/obj/item/organ/internal/lungs/mutantlungs = /obj/item/organ/internal/lungs
	///Replaces default eyes with a different organ
	var/obj/item/organ/internal/eyes/mutanteyes = /obj/item/organ/internal/eyes
	///Replaces default ears with a different organ
	var/obj/item/organ/internal/ears/mutantears = /obj/item/organ/internal/ears
	///Replaces default tongue with a different organ
	var/obj/item/organ/internal/tongue/mutanttongue = /obj/item/organ/internal/tongue
	///Replaces default liver with a different organ
	var/obj/item/organ/internal/liver/mutantliver = /obj/item/organ/internal/liver
	///Replaces default stomach with a different organ
	var/obj/item/organ/internal/stomach/mutantstomach = /obj/item/organ/internal/stomach
	///Replaces default appendix with a different organ.
	var/obj/item/organ/internal/appendix/mutantappendix = /obj/item/organ/internal/appendix

	/**
	 * Percentage modifier for overall defense of the race, or less defense, if it's negative
	 * THIS MODIFIES ALL DAMAGE TYPES.
	 **/
	var/damage_modifier = 0
	///multiplier for damage from cold temperature
	var/coldmod = 1
	///multiplier for damage from hot temperature
	var/heatmod = 1
	///multiplier for stun durations
	var/stunmod = 1
	///multiplier for money paid at payday
	var/payday_modifier = 1.0
	///Base electrocution coefficient.  Basically a multiplier for damage from electrocutions.
	var/siemens_coeff = 1
	///To use MUTCOLOR with a fixed color that's independent of the mcolor feature in DNA.
	var/fixed_mut_color = ""
	///A fixed hair color that's independent of the mcolor feature in DNA.
	var/fixed_hair_color = ""
	///Special mutation that can be found in the genepool exclusively in this species. Dont leave empty or changing species will be a headache
	var/inert_mutation = /datum/mutation/human/dwarfism
	///Used to set the mob's death_sound upon species change
	var/death_sound
	///Sounds to override barefeet walking
	var/list/special_step_sounds
	///Special sound for grabbing
	var/grab_sound
	/// A path to an outfit that is important for species life e.g. plasmaman outfit
	var/datum/outfit/outfit_important_for_life

	//Dictates which wing icons are allowed for a given species. If count is >1 a radial menu is used to choose between all icons in list
	var/list/wing_types = list(/obj/item/organ/external/wings/functional/angel)
	/// The natural temperature for a body
	var/bodytemp_normal = BODYTEMP_NORMAL
	/// Minimum amount of kelvin moved toward normal body temperature per tick.
	var/bodytemp_autorecovery_min = BODYTEMP_AUTORECOVERY_MINIMUM
	/// The body temperature limit the body can take before it starts taking damage from heat.
	var/bodytemp_heat_damage_limit = BODYTEMP_HEAT_DAMAGE_LIMIT
	/// The body temperature limit the body can take before it starts taking damage from cold.
	var/bodytemp_cold_damage_limit = BODYTEMP_COLD_DAMAGE_LIMIT

	/// The icon_state of the fire overlay added when sufficently ablaze and standing. see onfire.dmi
	var/fire_overlay = "human"

	/// Generic traits tied to having the species.
	var/list/inherent_traits = list()
	/// List of biotypes the mob belongs to. Used by diseases.
	var/inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID
	/// The type of respiration the mob is capable of doing. Used by adjustOxyLoss.
	var/inherent_respiration_type = RESPIRATION_OXYGEN
	///List of factions the mob gain upon gaining this species.
	var/list/inherent_factions

	///What gas does this species breathe? Used by suffocation screen alerts, most of actual gas breathing is handled by mutantlungs. See [life.dm][code/modules/mob/living/carbon/human/life.dm]
	var/breathid = GAS_O2

	///What anim to use for dusting
	var/dust_anim = "dust-h"
	///What anim to use for gibbing
	var/gib_anim = "gibbed-h"

	///Bitflag that controls what in game ways something can select this species as a spawnable source, such as magic mirrors. See [mob defines][code/__DEFINES/mobs.dm] for possible sources.
	var/changesource_flags = NONE

	///Unique cookie given by admins through prayers
	var/species_cookie = /obj/item/food/cookie

	///For custom overrides for species ass images
	var/icon/ass_image

	/// List of family heirlooms this species can get with the family heirloom quirk. List of types.
	var/list/family_heirlooms

	///List of results you get from knife-butchering. null means you cant butcher it. Associated by resulting type - value of amount
	var/list/knife_butcher_results

	/// Should we preload this species's organs?
	var/preload = TRUE

	/// Do we try to prevent reset_perspective() from working? Useful for Dullahans to stop perspective changes when they're looking through their head.
	var/prevent_perspective_change = FALSE

	///Was the species changed from its original type at the start of the round?
	var/roundstart_changed = FALSE

	/// This supresses the "dosen't appear to be himself" examine text for if the mob is run by an AI controller. Should be used on any NPC human subtypes. Monkeys are the prime example.
	var/ai_controlled_species = FALSE

	/**
	 * Was on_species_gain ever actually called?
	 * Species code is really odd...
	 **/
	var/properly_gained = FALSE

	///A list containing outfits that will be overridden in the species_equip_outfit proc. [Key = Typepath passed in] [Value = Typepath of outfit you want to equip for this specific species instead].
	var/list/outfit_override_registry = list()

///////////
// PROCS //
///////////


/datum/species/New()
	wing_types = string_list(wing_types)

	if(!plural_form)
		plural_form = "[name]\s"
	if(!examine_limb_id)
		examine_limb_id = id

	return ..()

/// Gets a list of all species available to choose in roundstart.
/proc/get_selectable_species()
	RETURN_TYPE(/list)

	if (!GLOB.roundstart_races.len)
		GLOB.roundstart_races = generate_selectable_species_and_languages()

	return GLOB.roundstart_races
/**
 * Generates species available to choose in character setup at roundstart
 *
 * This proc generates which species are available to pick from in character setup.
 * If there are no available roundstart species, defaults to human.
 */
/proc/generate_selectable_species_and_languages()
	var/list/selectable_species = list()

	for(var/species_type in subtypesof(/datum/species))
		var/datum/species/species = new species_type
		if(species.check_roundstart_eligible())
			selectable_species += species.id
			var/datum/language_holder/temp_holder = new species.species_language_holder
			for(var/datum/language/spoken_language as anything in temp_holder.understood_languages)
				GLOB.uncommon_roundstart_languages |= spoken_language
			qdel(temp_holder)
			qdel(species)

	GLOB.uncommon_roundstart_languages -= /datum/language/common
	if(!selectable_species.len)
		selectable_species += SPECIES_HUMAN

	return selectable_species

/**
 * Checks if a species is eligible to be picked at roundstart.
 *
 * Checks the config to see if this species is allowed to be picked in the character setup menu.
 * Used by [/proc/generate_selectable_species_and_languages].
 */
/datum/species/proc/check_roundstart_eligible()
	if(id in (CONFIG_GET(keyed_list/roundstart_races)))
		return TRUE
	return FALSE

/**
 * Generates a random name for a carbon.
 *
 * This generates a random unique name based on a human's species and gender.
 * Arguments:
 * * gender - The gender that the name should adhere to. Use MALE for male names, use anything else for female names.
 * * unique - If true, ensures that this new name is not a duplicate of anyone else's name currently on the station.
 * * lastname - Does this species' naming system adhere to the last name system? Set to false if it doesn't.
 */
/datum/species/proc/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_name(gender)

	var/randname
	if(gender == MALE)
		randname = pick(GLOB.first_names_male)
	else
		randname = pick(GLOB.first_names_female)

	if(lastname)
		randname += " [lastname]"
	else
		randname += " [pick(GLOB.last_names)]"

	return randname

/**
 * Copies some vars and properties over that should be kept when creating a copy of this species.
 *
 * Used by slimepeople to copy themselves, and by the DNA datum to hardset DNA to a species
 * Arguments:
 * * old_species - The species that the carbon used to be before copying
 */
/datum/species/proc/copy_properties_from(datum/species/old_species)
	return

/**
 * Gets the default mutant organ for the species based on the provided slot.
 */
/datum/species/proc/get_mutant_organ_type_for_slot(slot)
	switch(slot)
		if(ORGAN_SLOT_BRAIN)
			return mutantbrain
		if(ORGAN_SLOT_HEART)
			return mutantheart
		if(ORGAN_SLOT_LUNGS)
			return mutantlungs
		if(ORGAN_SLOT_APPENDIX)
			return mutantappendix
		if(ORGAN_SLOT_EYES)
			return mutanteyes
		if(ORGAN_SLOT_EARS)
			return mutantears
		if(ORGAN_SLOT_TONGUE)
			return mutanttongue
		if(ORGAN_SLOT_LIVER)
			return mutantliver
		if(ORGAN_SLOT_STOMACH)
			return mutantstomach
		else
			CRASH("Invalid organ slot [slot]")

/**
 * Corrects organs in a carbon, removing ones it doesn't need and adding ones it does.
 *
 * Takes all organ slots, removes organs a species should not have, adds organs a species should have.
 * can use replace_current to refresh all organs, creating an entirely new set.
 *
 * Arguments:
 * * organ_holder - carbon, the owner of the species datum AKA whoever we're regenerating organs in
 * * old_species - datum, used when regenerate organs is called in a switching species to remove old mutant organs.
 * * replace_current - boolean, forces all old organs to get deleted whether or not they pass the species' ability to keep that organ
 * * excluded_zones - list, add zone defines to block organs inside of the zones from getting handled. see headless mutation for an example
 * * visual_only - boolean, only load organs that change how the species looks. Do not use for normal gameplay stuff
 */
/datum/species/proc/regenerate_organs(mob/living/carbon/organ_holder, datum/species/old_species, replace_current = TRUE, list/excluded_zones, visual_only = FALSE)
	//what should be put in if there is no mutantorgan (brains handled separately)
	var/list/organ_slots = list(
		ORGAN_SLOT_BRAIN,
		ORGAN_SLOT_HEART,
		ORGAN_SLOT_LUNGS,
		ORGAN_SLOT_APPENDIX,
		ORGAN_SLOT_EYES,
		ORGAN_SLOT_EARS,
		ORGAN_SLOT_TONGUE,
		ORGAN_SLOT_LIVER,
		ORGAN_SLOT_STOMACH,
	)

	for(var/slot in organ_slots)
		var/obj/item/organ/existing_organ = organ_holder.get_organ_slot(slot)
		var/obj/item/organ/new_organ = get_mutant_organ_type_for_slot(slot)

		if(isnull(new_organ)) // if they aren't suppose to have an organ here, remove it
			if(existing_organ)
				existing_organ.Remove(organ_holder, special = TRUE)
				qdel(existing_organ)
			continue

		if(!isnull(old_species) && !isnull(existing_organ))
			if(existing_organ.type != old_species.get_mutant_organ_type_for_slot(slot))
				continue // we don't want to remove organs that are not the default for this species

		// at this point we already know new_organ is not null
		if(existing_organ?.type == new_organ)
			continue // we don't want to remove organs that are the same as the new one

		if(visual_only && !initial(new_organ.visual))
			continue

		var/used_neworgan = FALSE
		new_organ = SSwardrobe.provide_type(new_organ)
		var/should_have = new_organ.get_availability(src, organ_holder)

		// Check for an existing organ, and if there is one check to see if we should remove it
		var/health_pct = 1
		var/remove_existing = !isnull(existing_organ) && !(existing_organ.zone in excluded_zones) && !(existing_organ.organ_flags & ORGAN_UNREMOVABLE)
		if(remove_existing)
			health_pct = (existing_organ.maxHealth - existing_organ.damage) / existing_organ.maxHealth
			if(slot == ORGAN_SLOT_BRAIN)
				var/obj/item/organ/internal/brain/existing_brain = existing_organ
				if(!existing_brain.decoy_override)
					existing_brain.before_organ_replacement(new_organ)
					existing_brain.Remove(organ_holder, special = TRUE, no_id_transfer = TRUE)
					QDEL_NULL(existing_organ)
			else
				existing_organ.before_organ_replacement(new_organ)
				existing_organ.Remove(organ_holder, special = TRUE)
				QDEL_NULL(existing_organ)

		if(isnull(existing_organ) && should_have && !(new_organ.zone in excluded_zones))
			used_neworgan = TRUE
			new_organ.set_organ_damage(new_organ.maxHealth * (1 - health_pct))
			new_organ.Insert(organ_holder, special = TRUE, drop_if_replaced = FALSE)

		if(!used_neworgan)
			QDEL_NULL(new_organ)

	if(!isnull(old_species))
		for(var/mutant_organ in old_species.mutant_organs)
			if(mutant_organ in mutant_organs)
				continue // need this mutant organ, but we already have it!

			var/obj/item/organ/current_organ = organ_holder.get_organ_by_type(mutant_organ)
			if(current_organ)
				current_organ.Remove(organ_holder)
				QDEL_NULL(current_organ)

	for(var/obj/item/organ/external/external_organ in organ_holder.organs)
		// External organ checking. We need to check the external organs owned by the carbon itself,
		// because we want to also remove ones not shared by its species.
		// This should be done even if species was not changed.
		if(external_organ in external_organs)
			continue // Don't remove external organs this species is supposed to have.

		external_organ.Remove(organ_holder)
		QDEL_NULL(external_organ)

	var/list/species_organs = mutant_organs + external_organs
	for(var/organ_path in species_organs)
		var/obj/item/organ/current_organ = organ_holder.get_organ_by_type(organ_path)
		if(ispath(organ_path, /obj/item/organ/external) && !should_external_organ_apply_to(organ_path, organ_holder))
			if(!isnull(current_organ) && replace_current)
				// if we have an organ here and we're replacing organs, remove it
				current_organ.Remove(organ_holder)
				QDEL_NULL(current_organ)
			continue

		if(!current_organ || replace_current)
			var/obj/item/organ/replacement = SSwardrobe.provide_type(organ_path)
			// If there's an existing mutant organ, we're technically replacing it.
			// Let's abuse the snowflake proc that skillchips added. Basically retains
			// feature parity with every other organ too.
			if(current_organ)
				current_organ.before_organ_replacement(replacement)
			// organ.Insert will qdel any current organs in that slot, so we don't need to.
			replacement.Insert(organ_holder, special=TRUE, drop_if_replaced=FALSE)

/datum/species/proc/worn_items_fit_body_check(mob/living/carbon/wearer)
	for(var/obj/item/equipped_item in wearer.get_all_worn_items())
		var/equipped_item_slot = wearer.get_slot_by_item(equipped_item)
		if(!equipped_item.mob_can_equip(wearer, equipped_item_slot, bypass_equip_delay_self = TRUE, ignore_equipped = TRUE))
			wearer.dropItemToGround(equipped_item, force = TRUE)

/datum/species/proc/update_no_equip_flags(mob/living/carbon/wearer, new_flags)
	no_equip_flags = new_flags
	wearer.hud_used?.update_locked_slots()
	worn_items_fit_body_check(wearer)

/**
 * Normalizes blood in a human if it is excessive. If it is above BLOOD_VOLUME_NORMAL, this will clamp it to that value. It will not give the human more blodo than they have less than this value.
 */
/datum/species/proc/normalize_blood(mob/living/carbon/human/blood_possessing_human)
	var/normalized_blood_values = max(blood_possessing_human.blood_volume, 0, BLOOD_VOLUME_NORMAL)
	blood_possessing_human.blood_volume = normalized_blood_values

/**
 * Proc called when a carbon becomes this species.
 *
 * This sets up and adds/changes/removes things, qualities, abilities, and traits so that the transformation is as smooth and bugfree as possible.
 * Produces a [COMSIG_SPECIES_GAIN] signal.
 * Arguments:
 * * C - Carbon, this is whoever became the new species.
 * * old_species - The species that the carbon used to be before becoming this race, used for regenerating organs.
 * * pref_load - Preferences to be loaded from character setup, loads in preferred mutant things like bodyparts, digilegs, skin color, etc.
 */
/datum/species/proc/on_species_gain(mob/living/carbon/human/human_who_gained_species, datum/species/old_species, pref_load)
	SHOULD_CALL_PARENT(TRUE)
	// Drop the items the new species can't wear
	if(human_who_gained_species.hud_used)
		human_who_gained_species.hud_used.update_locked_slots()

	human_who_gained_species.mob_biotypes = inherent_biotypes
	human_who_gained_species.mob_respiration_type = inherent_respiration_type
	human_who_gained_species.butcher_results = knife_butcher_results?.Copy()

	if(old_species.type != type)
		replace_body(human_who_gained_species, src)

	regenerate_organs(human_who_gained_species, old_species, visual_only = human_who_gained_species.visual_only_organs)

	// Drop the items the new species can't wear
	INVOKE_ASYNC(src, PROC_REF(worn_items_fit_body_check), human_who_gained_species, TRUE)

	//Assigns exotic blood type if the species has one
	if(exotic_bloodtype && human_who_gained_species.dna.blood_type != exotic_bloodtype)
		human_who_gained_species.dna.blood_type = exotic_bloodtype
	//Otherwise, check if the previous species had an exotic bloodtype and we do not have one and assign a random blood type
	//(why the fuck is blood type not tied to a fucking DNA block?)
	else if(old_species.exotic_bloodtype && !exotic_bloodtype)
		human_who_gained_species.dna.blood_type = random_blood_type()

	//Resets blood if it is excessively high so they don't gib
	normalize_blood(human_who_gained_species)

	if(ishuman(human_who_gained_species))
		var/mob/living/carbon/human/human = human_who_gained_species
		for(var/obj/item/organ/external/organ_path as anything in external_organs)
			if(!should_external_organ_apply_to(organ_path, human))
				continue

			//Load a persons preferences from DNA
			var/obj/item/organ/external/new_organ = SSwardrobe.provide_type(organ_path)
			new_organ.Insert(human, special=TRUE, drop_if_replaced=FALSE)



	if(length(inherent_traits))
		human_who_gained_species.add_traits(inherent_traits, SPECIES_TRAIT)

	if(inherent_factions)
		for(var/i in inherent_factions)
			human_who_gained_species.faction += i //Using +=/-= for this in case you also gain the faction from a different source.

	// All languages associated with this language holder are added with source [LANGUAGE_SPECIES]
	// rather than source [LANGUAGE_ATOM], so we can track what to remove if our species changes again
	var/datum/language_holder/gaining_holder = GLOB.prototype_language_holders[species_language_holder]
	for(var/language in gaining_holder.understood_languages)
		human_who_gained_species.grant_language(language, UNDERSTOOD_LANGUAGE, LANGUAGE_SPECIES)
	for(var/language in gaining_holder.spoken_languages)
		human_who_gained_species.grant_language(language, SPOKEN_LANGUAGE, LANGUAGE_SPECIES)
	for(var/language in gaining_holder.blocked_languages)
		human_who_gained_species.add_blocked_language(language, LANGUAGE_SPECIES)
	human_who_gained_species.regenerate_icons()

	SEND_SIGNAL(human_who_gained_species, COMSIG_SPECIES_GAIN, src, old_species)

	properly_gained = TRUE

/**
 * Proc called when a carbon is no longer this species.
 *
 * This sets up and adds/changes/removes things, qualities, abilities, and traits so that the transformation is as smooth and bugfree as possible.
 * Produces a [COMSIG_SPECIES_LOSS] signal.
 * Arguments:
 * * C - Carbon, this is whoever lost this species.
 * * new_species - The new species that the carbon became, used for genetics mutations.
 * * pref_load - Preferences to be loaded from character setup, loads in preferred mutant things like bodyparts, digilegs, skin color, etc.
 */
/datum/species/proc/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	SHOULD_CALL_PARENT(TRUE)
	C.butcher_results = null
	for(var/X in inherent_traits)
		REMOVE_TRAIT(C, X, SPECIES_TRAIT)

	for(var/obj/item/organ/external/organ in C.organs)
		organ.Remove(C)
		qdel(organ)

	//If their inert mutation is not the same, swap it out
	if((inert_mutation != new_species.inert_mutation) && LAZYLEN(C.dna.mutation_index) && (inert_mutation in C.dna.mutation_index))
		C.dna.remove_mutation(inert_mutation)
		//keep it at the right spot, so we can't have people taking shortcuts
		var/location = C.dna.mutation_index.Find(inert_mutation)
		C.dna.mutation_index[location] = new_species.inert_mutation
		C.dna.default_mutation_genes[location] = C.dna.mutation_index[location]
		C.dna.mutation_index[new_species.inert_mutation] = create_sequence(new_species.inert_mutation)
		C.dna.default_mutation_genes[new_species.inert_mutation] = C.dna.mutation_index[new_species.inert_mutation]

	if(inherent_factions)
		for(var/i in inherent_factions)
			C.faction -= i

	clear_tail_moodlets(C)

	// Removes all languages previously associated with [LANGUAGE_SPECIES], gaining our new species will add new ones back
	var/datum/language_holder/losing_holder = GLOB.prototype_language_holders[species_language_holder]
	for(var/language in losing_holder.understood_languages)
		C.remove_language(language, UNDERSTOOD_LANGUAGE, LANGUAGE_SPECIES)
	for(var/language in losing_holder.spoken_languages)
		C.remove_language(language, SPOKEN_LANGUAGE, LANGUAGE_SPECIES)
	for(var/language in losing_holder.blocked_languages)
		C.remove_blocked_language(language, LANGUAGE_SPECIES)

	SEND_SIGNAL(C, COMSIG_SPECIES_LOSS, src)

/**
 * Proc called when mail goodies need to be updated for this species.
 *
 * Updates the mail goodies if that is required. e.g. for the blood deficiency quirk, which sends bloodbags to quirk holders, update the sent bloodpack to match the species' exotic blood.
 * This is currently only used for the blood deficiency quirk but more can be added as needed.
 * Arguments:
 * * mob/living/carbon/human/recipient - the mob receiving the mail goodies
 */
/datum/species/proc/update_mail_goodies(mob/living/carbon/human/recipient)
	update_quirk_mail_goodies(recipient, recipient.get_quirk(/datum/quirk/blooddeficiency))

/**
 * Updates the mail goodies of a specific quirk.
 *
 * Updates the mail goodies belonging to a specific quirk.
 * Add implementation as needed for each individual species. The base species proc should give the species the 'default' version of whatever mail goodies are required.
 * Arguments:
 * * mob/living/carbon/human/recipient - the mob receiving the mail goodies
 * * datum/quirk/quirk - the quirk to update the mail goodies of. Use get_quirk(datum/quirk/some_quirk) to get the actual mob's quirk to pass.
 * * list/mail_goodies - a list of mail goodies. Generally speaking you should not be using this argument on the initial function call. You should instead add to the species' implementation of this proc.
 */
/datum/species/proc/update_quirk_mail_goodies(mob/living/carbon/human/recipient, datum/quirk/quirk, list/mail_goodies)
	if(isnull(quirk))
		return
	if(length(mail_goodies))
		quirk.mail_goodies = mail_goodies
		return
	if(istype(quirk, /datum/quirk/blooddeficiency))
		if(HAS_TRAIT(recipient, TRAIT_NOBLOOD) && isnull(recipient.dna.species.exotic_blood))  // TRAIT_NOBLOOD and no exotic blood (yes we have to check for both, jellypeople exist)
			quirk.mail_goodies = list() // means no blood pack gets sent to them.
			return


	// The default case if no species implementation exists. Set quirk's mail_goodies to initial.
	var/datum/quirk/readable_quirk = new quirk.type
	quirk.mail_goodies = readable_quirk.mail_goodies
	qdel(readable_quirk) // We have to do it this way because initial will not work on lists in this version of DM
	return

/**
 * Handles the body of a human
 *
 * Handles lipstick, having no eyes, eye color, undergarnments like underwear, undershirts, and socks, and body layers.
 * Calls [handle_mutant_bodyparts][/datum/species/proc/handle_mutant_bodyparts]
 * Arguments:
 * * species_human - Human, whoever we're handling the body for
 */
/datum/species/proc/handle_body(mob/living/carbon/human/species_human)
	species_human.remove_overlay(BODY_LAYER)
	var/height_offset = species_human.get_top_offset() // From high changed by varying limb height
	if(HAS_TRAIT(species_human, TRAIT_INVISIBLE_MAN))
		return handle_mutant_bodyparts(species_human)
	var/list/standing = list()

	if(!HAS_TRAIT(species_human, TRAIT_HUSK))
		var/obj/item/bodypart/head/noggin = species_human.get_bodypart(BODY_ZONE_HEAD)
		if(noggin?.head_flags & HEAD_EYESPRITES)
			// eyes (missing eye sprites get handled by the head itself, but sadly we have to do this stupid shit here, for now)
			var/obj/item/organ/internal/eyes/eye_organ = species_human.get_organ_slot(ORGAN_SLOT_EYES)
			if(eye_organ)
				eye_organ.refresh(call_update = FALSE)
				for(var/mutable_appearance/eye_overlay in eye_organ.generate_body_overlay(species_human))
					eye_overlay.pixel_y += height_offset
					standing += eye_overlay

		// organic body markings (oh my god this is terrible please rework this to be done on the limbs themselves i beg you)
		if(HAS_TRAIT(species_human, TRAIT_HAS_MARKINGS))
			var/obj/item/bodypart/chest/chest = species_human.get_bodypart(BODY_ZONE_CHEST)
			var/obj/item/bodypart/arm/right/right_arm = species_human.get_bodypart(BODY_ZONE_R_ARM)
			var/obj/item/bodypart/arm/left/left_arm = species_human.get_bodypart(BODY_ZONE_L_ARM)
			var/obj/item/bodypart/leg/right/right_leg = species_human.get_bodypart(BODY_ZONE_R_LEG)
			var/obj/item/bodypart/leg/left/left_leg = species_human.get_bodypart(BODY_ZONE_L_LEG)
			var/datum/sprite_accessory/markings = GLOB.moth_markings_list[species_human.dna.features["moth_markings"]]
			if(noggin && (IS_ORGANIC_LIMB(noggin)))
				var/mutable_appearance/markings_head_overlay = mutable_appearance(markings.icon, "[markings.icon_state]_head", -BODY_LAYER)
				markings_head_overlay.pixel_y += height_offset
				standing += markings_head_overlay

			if(chest && (IS_ORGANIC_LIMB(chest)))
				var/mutable_appearance/markings_chest_overlay = mutable_appearance(markings.icon, "[markings.icon_state]_chest", -BODY_LAYER)
				markings_chest_overlay.pixel_y += height_offset
				standing += markings_chest_overlay

			if(right_arm && (IS_ORGANIC_LIMB(right_arm)))
				var/mutable_appearance/markings_r_arm_overlay = mutable_appearance(markings.icon, "[markings.icon_state]_r_arm", -BODY_LAYER)
				markings_r_arm_overlay.pixel_y += height_offset
				standing += markings_r_arm_overlay

			if(left_arm && (IS_ORGANIC_LIMB(left_arm)))
				var/mutable_appearance/markings_l_arm_overlay = mutable_appearance(markings.icon, "[markings.icon_state]_l_arm", -BODY_LAYER)
				markings_l_arm_overlay.pixel_y += height_offset
				standing += markings_l_arm_overlay

			if(right_leg && (IS_ORGANIC_LIMB(right_leg)))
				var/mutable_appearance/markings_r_leg_overlay = mutable_appearance(markings.icon, "[markings.icon_state]_r_leg", -BODY_LAYER)
				standing += markings_r_leg_overlay

			if(left_leg && (IS_ORGANIC_LIMB(left_leg)))
				var/mutable_appearance/markings_l_leg_overlay = mutable_appearance(markings.icon, "[markings.icon_state]_l_leg", -BODY_LAYER)
				standing += markings_l_leg_overlay

	//Underwear, Undershirts & Socks
	if(!HAS_TRAIT(species_human, TRAIT_NO_UNDERWEAR))
		if(species_human.underwear)
			var/datum/sprite_accessory/underwear/underwear = GLOB.underwear_list[species_human.underwear]
			var/mutable_appearance/underwear_overlay
			if(underwear)
				if(species_human.dna.species.sexes && species_human.physique == FEMALE && (underwear.gender == MALE))
					underwear_overlay = wear_female_version(underwear.icon_state, underwear.icon, BODY_LAYER, FEMALE_UNIFORM_FULL)
				else
					underwear_overlay = mutable_appearance(underwear.icon, underwear.icon_state, -BODY_LAYER)
				if(!underwear.use_static)
					underwear_overlay.color = species_human.underwear_color
				underwear_overlay.pixel_y += height_offset
				standing += underwear_overlay

		if(species_human.undershirt)
			var/datum/sprite_accessory/undershirt/undershirt = GLOB.undershirt_list[species_human.undershirt]
			if(undershirt)
				var/mutable_appearance/working_shirt
				if(species_human.dna.species.sexes && species_human.physique == FEMALE)
					working_shirt = wear_female_version(undershirt.icon_state, undershirt.icon, BODY_LAYER)
				else
					working_shirt = mutable_appearance(undershirt.icon, undershirt.icon_state, -BODY_LAYER)
				working_shirt.pixel_y += height_offset
				standing += working_shirt

		if(species_human.socks && species_human.num_legs >= 2 && !(species_human.bodytype & BODYTYPE_DIGITIGRADE))
			var/datum/sprite_accessory/socks/socks = GLOB.socks_list[species_human.socks]
			if(socks)
				standing += mutable_appearance(socks.icon, socks.icon_state, -BODY_LAYER)

	if(standing.len)
		species_human.overlays_standing[BODY_LAYER] = standing

	species_human.apply_overlay(BODY_LAYER)
	handle_mutant_bodyparts(species_human)

/**
 * Handles the mutant bodyparts of a human
 *
 * Handles the adding and displaying of, layers, colors, and overlays of mutant bodyparts and accessories.
 * Handles digitigrade leg displaying and squishing.
 * Arguments:
 * * H - Human, whoever we're handling the body for
 * * forced_colour - The forced color of an accessory. Leave null to use mutant color.
 */
/datum/species/proc/handle_mutant_bodyparts(mob/living/carbon/human/source, forced_colour)
	var/list/bodyparts_to_add = mutant_bodyparts.Copy()
	var/list/relevent_layers = list(BODY_BEHIND_LAYER, BODY_ADJ_LAYER, BODY_FRONT_LAYER)
	var/list/standing = list()

	source.remove_overlay(BODY_BEHIND_LAYER)
	source.remove_overlay(BODY_ADJ_LAYER)
	source.remove_overlay(BODY_FRONT_LAYER)

	if(!mutant_bodyparts || HAS_TRAIT(source, TRAIT_INVISIBLE_MAN))
		return

	var/obj/item/bodypart/head/noggin = source.get_bodypart(BODY_ZONE_HEAD)


	if(mutant_bodyparts["ears"])
		if(!source.dna.features["ears"] || source.dna.features["ears"] == "None" || source.head && (source.head.flags_inv & HIDEHAIR) || (source.wear_mask && (source.wear_mask.flags_inv & HIDEHAIR)) || !noggin || IS_ROBOTIC_LIMB(noggin))
			bodyparts_to_add -= "ears"

	if(!bodyparts_to_add)
		return

	var/g = (source.physique == FEMALE) ? "f" : "m"

	for(var/layer in relevent_layers)
		var/layertext = mutant_bodyparts_layertext(layer)

		for(var/bodypart in bodyparts_to_add)
			var/datum/sprite_accessory/accessory
			switch(bodypart)
				if("ears")
					accessory = GLOB.ears_list[source.dna.features["ears"]]
				if("body_markings")
					accessory = GLOB.body_markings_list[source.dna.features["body_markings"]]
				if("legs")
					accessory = GLOB.legs_list[source.dna.features["legs"]]
				if("caps")
					accessory = GLOB.caps_list[source.dna.features["caps"]]

			if(!accessory || accessory.icon_state == "none")
				continue

			var/mutable_appearance/accessory_overlay = mutable_appearance(accessory.icon, layer = -layer)

			if(accessory.gender_specific)
				accessory_overlay.icon_state = "[g]_[bodypart]_[accessory.icon_state]_[layertext]"
			else
				accessory_overlay.icon_state = "m_[bodypart]_[accessory.icon_state]_[layertext]"

			if(accessory.em_block)
				accessory_overlay.overlays += emissive_blocker(accessory_overlay.icon, accessory_overlay.icon_state, source, accessory_overlay.alpha)

			if(accessory.center)
				accessory_overlay = center_image(accessory_overlay, accessory.dimension_x, accessory.dimension_y)

			if(!(HAS_TRAIT(source, TRAIT_HUSK)))
				if(!forced_colour)
					switch(accessory.color_src)
						if(MUTANT_COLOR)
							if(fixed_mut_color)
								accessory_overlay.color = fixed_mut_color
							else
								accessory_overlay.color = source.dna.features["mcolor"]
						if(HAIR_COLOR)
							if(hair_color == "mutcolor")
								accessory_overlay.color = source.dna.features["mcolor"]
							else if(hair_color == "fixedmutcolor")
								accessory_overlay.color = fixed_hair_color
							else
								accessory_overlay.color = source.hair_color
						if(FACIAL_HAIR_COLOR)
							accessory_overlay.color = source.facial_hair_color
						if(EYE_COLOR)
							accessory_overlay.color = source.eye_color_left
				else
					accessory_overlay.color = forced_colour
			standing += accessory_overlay

			if(accessory.hasinner)
				var/mutable_appearance/inner_accessory_overlay = mutable_appearance(accessory.icon, layer = -layer)
				if(accessory.gender_specific)
					inner_accessory_overlay.icon_state = "[g]_[bodypart]inner_[accessory.icon_state]_[layertext]"
				else
					inner_accessory_overlay.icon_state = "m_[bodypart]inner_[accessory.icon_state]_[layertext]"

				if(accessory.center)
					inner_accessory_overlay = center_image(inner_accessory_overlay, accessory.dimension_x, accessory.dimension_y)

				standing += inner_accessory_overlay

		source.overlays_standing[layer] = standing.Copy()
		standing = list()

	source.apply_overlay(BODY_BEHIND_LAYER)
	source.apply_overlay(BODY_ADJ_LAYER)
	source.apply_overlay(BODY_FRONT_LAYER)

//This exists so sprite accessories can still be per-layer without having to include that layer's
//number in their sprite name, which causes issues when those numbers change.
/datum/species/proc/mutant_bodyparts_layertext(layer)
	switch(layer)
		if(BODY_BEHIND_LAYER)
			return "BEHIND"
		if(BODY_ADJ_LAYER)
			return "ADJ"
		if(BODY_FRONT_LAYER)
			return "FRONT"

///Proc that will randomise the hair, or primary appearance element (i.e. for moths wings) of a species' associated mob
/datum/species/proc/randomize_main_appearance_element(mob/living/carbon/human/human_mob)
	human_mob.set_hairstyle(random_hairstyle(human_mob.gender), update = FALSE)

///Proc that will randomise the underwear (i.e. top, pants and socks) of a species' associated mob,
/// but will not update the body right away.
/datum/species/proc/randomize_active_underwear_only(mob/living/carbon/human/human_mob)
	human_mob.undershirt = random_undershirt(human_mob.gender)
	human_mob.underwear = random_underwear(human_mob.gender)
	human_mob.socks = random_socks(human_mob.gender)

///Proc that will randomise the underwear (i.e. top, pants and socks) of a species' associated mob
/datum/species/proc/randomize_active_underwear(mob/living/carbon/human/human_mob)
	randomize_active_underwear_only(human_mob)
	human_mob.update_body()

/datum/species/proc/randomize_active_features(mob/living/carbon/human/human_mob)
	var/list/new_features = randomize_features()
	for(var/feature_key in new_features)
		human_mob.dna.features[feature_key] = new_features[feature_key]
	human_mob.updateappearance(mutcolor_update = TRUE)

/**
 * Returns a list of features, randomized, to be used by DNA
 */
/datum/species/proc/randomize_features()
	SHOULD_CALL_PARENT(TRUE)

	var/list/new_features = list()
	var/static/list/organs_to_randomize = list()
	for(var/obj/item/organ/external/organ_path as anything in external_organs)
		var/overlay_path = initial(organ_path.bodypart_overlay)
		var/datum/bodypart_overlay/mutant/sample_overlay = organs_to_randomize[overlay_path]
		if(isnull(sample_overlay))
			sample_overlay = new overlay_path()
			organs_to_randomize[overlay_path] = sample_overlay

		new_features["[sample_overlay.feature_key]"] = pick(sample_overlay.get_global_feature_list())

	return new_features

/datum/species/proc/spec_life(mob/living/carbon/human/H, seconds_per_tick, times_fired)
	SHOULD_CALL_PARENT(TRUE)
	if(H.stat == DEAD)
		return
	if(HAS_TRAIT(H, TRAIT_NOBREATH) && (H.health < H.crit_threshold) && !HAS_TRAIT(H, TRAIT_NOCRITDAMAGE))
		H.adjustBruteLoss(0.5 * seconds_per_tick)

/datum/species/proc/can_equip(obj/item/I, slot, disable_warning, mob/living/carbon/human/H, bypass_equip_delay_self = FALSE, ignore_equipped = FALSE, indirect_action = FALSE)
	if(no_equip_flags & slot)
		if(!I.species_exception || !is_type_in_list(src, I.species_exception))
			return FALSE

	// if there's an item in the slot we want, fail
	if(!ignore_equipped)
		if(H.get_item_by_slot(slot))
			return FALSE

	// this check prevents us from equipping something to a slot it doesn't support, WITH the exceptions of storage slots (pockets, suit storage, and backpacks)
	// we don't require having those slots defined in the item's slot_flags, so we'll rely on their own checks further down
	if(!(I.slot_flags & slot))
		var/excused = FALSE
		// Anything that's small or smaller can fit into a pocket by default
		if((slot & (ITEM_SLOT_RPOCKET|ITEM_SLOT_LPOCKET)) && I.w_class <= WEIGHT_CLASS_SMALL)
			excused = TRUE
		else if(slot & (ITEM_SLOT_SUITSTORE|ITEM_SLOT_BACKPACK|ITEM_SLOT_HANDS))
			excused = TRUE
		if(!excused)
			return FALSE

	switch(slot)
		if(ITEM_SLOT_HANDS)
			if(H.get_empty_held_indexes())
				return TRUE
			return FALSE
		if(ITEM_SLOT_MASK)
			if(!H.get_bodypart(BODY_ZONE_HEAD))
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_NECK)
			return TRUE
		if(ITEM_SLOT_BACK)
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_OCLOTHING)
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_GLOVES)
			if(H.num_hands < 2)
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_FEET)
			if(H.num_legs < 2)
				return FALSE
			if((H.bodytype & BODYTYPE_DIGITIGRADE) && !(I.item_flags & IGNORE_DIGITIGRADE))
				if(!(I.supports_variations_flags & (CLOTHING_DIGITIGRADE_VARIATION|CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON)))
					if(!disable_warning)
						to_chat(H, span_warning("The footwear around here isn't compatible with your feet!"))
					return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_BELT)
			var/obj/item/bodypart/O = H.get_bodypart(BODY_ZONE_CHEST)

			if(!H.w_uniform && !HAS_TRAIT(H, TRAIT_NO_JUMPSUIT) && (!O || IS_ORGANIC_LIMB(O)))
				if(!disable_warning)
					to_chat(H, span_warning("You need a jumpsuit before you can attach this [I.name]!"))
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_EYES)
			if(!H.get_bodypart(BODY_ZONE_HEAD))
				return FALSE
			var/obj/item/organ/internal/eyes/eyes = H.get_organ_slot(ORGAN_SLOT_EYES)
			if(eyes?.no_glasses)
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_HEAD)
			if(!H.get_bodypart(BODY_ZONE_HEAD))
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_EARS)
			if(!H.get_bodypart(BODY_ZONE_HEAD))
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_ICLOTHING)
			var/obj/item/bodypart/chest = H.get_bodypart(BODY_ZONE_CHEST)
			if(chest && (chest.bodytype & BODYTYPE_MONKEY))
				if(!(I.supports_variations_flags & CLOTHING_MONKEY_VARIATION))
					if(!disable_warning)
						to_chat(H, span_warning("[I] doesn't fit your [chest.name]!"))
					return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_ID)
			var/obj/item/bodypart/O = H.get_bodypart(BODY_ZONE_CHEST)
			if(!H.w_uniform && !HAS_TRAIT(H, TRAIT_NO_JUMPSUIT) && (!O || IS_ORGANIC_LIMB(O)))
				if(!disable_warning)
					to_chat(H, span_warning("You need a jumpsuit before you can attach this [I.name]!"))
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_LPOCKET)
			if(HAS_TRAIT(I, TRAIT_NODROP)) //Pockets aren't visible, so you can't move TRAIT_NODROP items into them.
				return FALSE
			if(!isnull(H.l_store) && H.l_store != I) // no pocket swaps at all
				return FALSE

			var/obj/item/bodypart/O = H.get_bodypart(BODY_ZONE_L_LEG)

			if(!H.w_uniform && !HAS_TRAIT(H, TRAIT_NO_JUMPSUIT) && (!O || IS_ORGANIC_LIMB(O)))
				if(!disable_warning)
					to_chat(H, span_warning("You need a jumpsuit before you can attach this [I.name]!"))
				return FALSE
			return TRUE
		if(ITEM_SLOT_RPOCKET)
			if(HAS_TRAIT(I, TRAIT_NODROP))
				return FALSE
			if(!isnull(H.r_store) && H.r_store != I)
				return FALSE

			var/obj/item/bodypart/O = H.get_bodypart(BODY_ZONE_R_LEG)

			if(!H.w_uniform && !HAS_TRAIT(H, TRAIT_NO_JUMPSUIT) && (!O || IS_ORGANIC_LIMB(O)))
				if(!disable_warning)
					to_chat(H, span_warning("You need a jumpsuit before you can attach this [I.name]!"))
				return FALSE
			return TRUE
		if(ITEM_SLOT_SUITSTORE)
			if(HAS_TRAIT(I, TRAIT_NODROP))
				return FALSE
			if(!H.wear_suit)
				if(!disable_warning)
					to_chat(H, span_warning("You need a suit before you can attach this [I.name]!"))
				return FALSE
			if(!H.wear_suit.allowed)
				if(!disable_warning)
					to_chat(H, span_warning("You somehow have a suit with no defined allowed items for suit storage, stop that."))
				return FALSE
			if(I.w_class > WEIGHT_CLASS_BULKY)
				if(!disable_warning)
					to_chat(H, span_warning("The [I.name] is too big to attach!")) //should be src?
				return FALSE
			if( istype(I, /obj/item/modular_computer/pda) || istype(I, /obj/item/pen) || is_type_in_list(I, H.wear_suit.allowed) )
				return TRUE
			return FALSE
		if(ITEM_SLOT_HANDCUFFED)
			if(!istype(I, /obj/item/restraints/handcuffs))
				return FALSE
			if(H.num_hands < 2)
				return FALSE
			return TRUE
		if(ITEM_SLOT_LEGCUFFED)
			if(!istype(I, /obj/item/restraints/legcuffs))
				return FALSE
			if(H.num_legs < 2)
				return FALSE
			return TRUE
		if(ITEM_SLOT_BACKPACK)
			if(H.back && H.back.atom_storage?.can_insert(I, H, messages = TRUE, force = indirect_action ? STORAGE_SOFT_LOCKED : STORAGE_NOT_LOCKED))
				return TRUE
			return FALSE
	return FALSE //Unsupported slot

/datum/species/proc/equip_delay_self_check(obj/item/I, mob/living/carbon/human/H, bypass_equip_delay_self)
	if(!I.equip_delay_self || bypass_equip_delay_self)
		return TRUE
	H.visible_message(span_notice("[H] start putting on [I]..."), span_notice("You start putting on [I]..."))
	return do_after(H, I.equip_delay_self, target = H)


/// Equips the necessary species-relevant gear before putting on the rest of the uniform.
/datum/species/proc/pre_equip_species_outfit(datum/job/job, mob/living/carbon/human/equipping, visuals_only = FALSE)
	return

/**
 * Handling special reagent interactions.
 *
 * Return null continue running the normal on_mob_life() for that reagent.
 * Return COMSIG_MOB_STOP_REAGENT_CHECK to not run the normal metabolism effects.
 *
 * NOTE: If you return COMSIG_MOB_STOP_REAGENT_CHECK, that reagent will not be removed liike normal! You must handle it manually.
 **/
/datum/species/proc/handle_chemical(datum/reagent/chem, mob/living/carbon/human/affected, seconds_per_tick, times_fired)
	SHOULD_CALL_PARENT(TRUE)
	if(chem.type == exotic_blood)
		affected.blood_volume = min(affected.blood_volume + round(chem.volume, 0.1), BLOOD_VOLUME_MAXIMUM)
		affected.reagents.del_reagent(chem.type)
		return COMSIG_MOB_STOP_REAGENT_CHECK
	if(!chem.overdosed && chem.overdose_threshold && chem.volume >= chem.overdose_threshold)
		chem.overdosed = TRUE
		chem.overdose_start(affected)
		affected.log_message("has started overdosing on [chem.name] at [chem.volume] units.", LOG_GAME)
	return SEND_SIGNAL(affected, COMSIG_SPECIES_HANDLE_CHEMICAL, chem, seconds_per_tick, times_fired)

/datum/species/proc/check_species_weakness(obj/item, mob/living/attacker)
	return 1 //This is not a boolean, it's the multiplier for the damage that the user takes from the item. The force of the item is multiplied by this value

/**
 * Equip the outfit required for life. Replaces items currently worn.
 */
/datum/species/proc/give_important_for_life(mob/living/carbon/human/human_to_equip)
	if(!outfit_important_for_life)
		return

	human_to_equip.equipOutfit(outfit_important_for_life)

/**
 * Species based handling for irradiation
 *
 * Arguments:
 * - [source][/mob/living/carbon/human]: The mob requesting handling
 * - time_since_irradiated: The amount of time since the mob was first irradiated
 * - seconds_per_tick: The amount of time that has passed since the last tick
 */
/datum/species/proc/handle_radiation(mob/living/carbon/human/source, time_since_irradiated, seconds_per_tick)
	if(time_since_irradiated > RAD_MOB_KNOCKDOWN && SPT_PROB(RAD_MOB_KNOCKDOWN_PROB, seconds_per_tick))
		if(!source.IsParalyzed())
			source.emote("collapse")
		source.Paralyze(RAD_MOB_KNOCKDOWN_AMOUNT)
		to_chat(source, span_danger("You feel weak."))

	if(time_since_irradiated > RAD_MOB_VOMIT && SPT_PROB(RAD_MOB_VOMIT_PROB, seconds_per_tick))
		source.vomit(VOMIT_CATEGORY_BLOOD, lost_nutrition = 10)

	if(time_since_irradiated > RAD_MOB_MUTATE && SPT_PROB(RAD_MOB_MUTATE_PROB, seconds_per_tick))
		to_chat(source, span_danger("You mutate!"))
		source.easy_random_mutate(NEGATIVE + MINOR_NEGATIVE)
		source.emote("gasp")
		source.domutcheck()

	if(time_since_irradiated > RAD_MOB_HAIRLOSS && SPT_PROB(RAD_MOB_HAIRLOSS_PROB, seconds_per_tick))
		var/obj/item/bodypart/head/head = source.get_bodypart(BODY_ZONE_HEAD)
		if(!(source.hairstyle == "Bald") && (head?.head_flags & HEAD_HAIR|HEAD_FACIAL_HAIR))
			to_chat(source, span_danger("Your hair starts to fall out in clumps..."))
			addtimer(CALLBACK(src, PROC_REF(go_bald), source), 5 SECONDS)

/**
 * Makes the target human bald.
 *
 * Arguments:
 * - [target][/mob/living/carbon/human]: The mob to make go bald.
 */
/datum/species/proc/go_bald(mob/living/carbon/human/target)
	if(QDELETED(target)) //may be called from a timer
		return
	target.set_facial_hairstyle("Shaved", update = FALSE)
	target.set_hairstyle("Bald", update = FALSE)
	target.update_body_parts()

//////////////////
// ATTACK PROCS //
//////////////////

/datum/species/proc/help(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(SEND_SIGNAL(target, COMSIG_CARBON_PRE_HELP, user, attacker_style) & COMPONENT_BLOCK_HELP_ACT)
		return TRUE

	if(attacker_style?.help_act(user, target) == MARTIAL_ATTACK_SUCCESS)
		return TRUE

	if(target.body_position == STANDING_UP || (target.appears_alive() && target.stat != SOFT_CRIT && target.stat != HARD_CRIT))
		target.help_shake_act(user)
		if(target != user)
			log_combat(user, target, "shaken")
		return TRUE

	user.do_cpr(target)

/datum/species/proc/grab(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(target.check_block())
		target.visible_message(span_warning("[target] blocks [user]'s grab!"), \
						span_userdanger("You block [user]'s grab!"), span_hear("You hear a swoosh!"), COMBAT_MESSAGE_RANGE, user)
		to_chat(user, span_warning("Your grab at [target] was blocked!"))
		return FALSE
	if(attacker_style?.grab_act(user, target) == MARTIAL_ATTACK_SUCCESS)
		return TRUE
	target.grabbedby(user)
	return TRUE

///This proc handles punching damage. IMPORTANT: Our owner is the TARGET and not the USER in this proc. For whatever reason...
/datum/species/proc/harm(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(HAS_TRAIT(user, TRAIT_PACIFISM) && !attacker_style?.pacifist_style)
		to_chat(user, span_warning("You don't want to harm [target]!"))
		return FALSE
	if(target.check_block())
		target.visible_message(span_warning("[target] blocks [user]'s attack!"), \
						span_userdanger("You block [user]'s attack!"), span_hear("You hear a swoosh!"), COMBAT_MESSAGE_RANGE, user)
		to_chat(user, span_warning("Your attack at [target] was blocked!"))
		return FALSE
	if(attacker_style?.harm_act(user,target) == MARTIAL_ATTACK_SUCCESS)
		return TRUE
	else

		var/obj/item/organ/internal/brain/brain = user.get_organ_slot(ORGAN_SLOT_BRAIN)
		var/obj/item/bodypart/attacking_bodypart
		if(brain)
			attacking_bodypart = brain.get_attacking_limb(target)
		if(!attacking_bodypart)
			attacking_bodypart = user.get_active_hand()
		var/atk_verb = attacking_bodypart.unarmed_attack_verb
		var/atk_effect = attacking_bodypart.unarmed_attack_effect

		if(atk_effect == ATTACK_EFFECT_BITE)
			if(user.is_mouth_covered(ITEM_SLOT_MASK))
				to_chat(user, span_warning("You can't [atk_verb] with your mouth covered!"))
				return FALSE
		user.do_attack_animation(target, atk_effect)

		var/damage = rand(attacking_bodypart.unarmed_damage_low, attacking_bodypart.unarmed_damage_high)

		var/obj/item/bodypart/affecting = target.get_bodypart(target.get_random_valid_zone(user.zone_selected))

		var/miss_chance = 100//calculate the odds that a punch misses entirely. considers stamina and brute damage of the puncher. punches miss by default to prevent weird cases
		if(attacking_bodypart.unarmed_damage_low)
			if((target.body_position == LYING_DOWN) || HAS_TRAIT(user, TRAIT_PERFECT_ATTACKER)) //kicks never miss (provided your species deals more than 0 damage)
				miss_chance = 0
			else
				miss_chance = min((attacking_bodypart.unarmed_damage_high/attacking_bodypart.unarmed_damage_low) + user.getStaminaLoss() + (user.getBruteLoss()*0.5), 100) //old base chance for a miss + various damage. capped at 100 to prevent weirdness in prob()

		if(!damage || !affecting || prob(miss_chance))//future-proofing for species that have 0 damage/weird cases where no zone is targeted
			playsound(target.loc, attacking_bodypart.unarmed_miss_sound, 25, TRUE, -1)
			target.visible_message(span_danger("[user]'s [atk_verb] misses [target]!"), \
							span_danger("You avoid [user]'s [atk_verb]!"), span_hear("You hear a swoosh!"), COMBAT_MESSAGE_RANGE, user)
			to_chat(user, span_warning("Your [atk_verb] misses [target]!"))
			log_combat(user, target, "attempted to punch")
			return FALSE

		var/armor_block = target.run_armor_check(affecting, MELEE)

		playsound(target.loc, attacking_bodypart.unarmed_attack_sound, 25, TRUE, -1)

		target.visible_message(span_danger("[user] [atk_verb]ed [target]!"), \
						span_userdanger("You're [atk_verb]ed by [user]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, user)
		to_chat(user, span_danger("You [atk_verb] [target]!"))

		target.lastattacker = user.real_name
		target.lastattackerckey = user.ckey

		if(user.limb_destroyer)
			target.dismembering_strike(user, affecting.body_zone)

		var/attack_direction = get_dir(user, target)
		var/attack_type = attacking_bodypart.attack_type
		if(atk_effect == ATTACK_EFFECT_KICK)//kicks deal 1.5x raw damage
			if(damage >= 9)
				target.force_say()
			log_combat(user, target, "kicked")
			target.apply_damage(damage, attack_type, affecting, armor_block, attack_direction = attack_direction)
		else//other attacks deal full raw damage + 1.5x in stamina damage
			target.apply_damage(damage, attack_type, affecting, armor_block, attack_direction = attack_direction)
			target.apply_damage(damage*1.5, STAMINA, affecting, armor_block)
			if(damage >= 9)
				target.force_say()
			log_combat(user, target, "punched")

		if((target.stat != DEAD) && damage >= attacking_bodypart.unarmed_stun_threshold)
			target.visible_message(span_danger("[user] knocks [target] down!"), \
							span_userdanger("You're knocked down by [user]!"), span_hear("You hear aggressive shuffling followed by a loud thud!"), COMBAT_MESSAGE_RANGE, user)
			to_chat(user, span_danger("You knock [target] down!"))
			var/knockdown_duration = 40 + (target.getStaminaLoss() + (target.getBruteLoss()*0.5))*0.8 //50 total damage = 40 base stun + 40 stun modifier = 80 stun duration, which is the old base duration
			target.apply_effect(knockdown_duration, EFFECT_KNOCKDOWN, armor_block)
			log_combat(user, target, "got a stun punch with their previous punch")

/datum/species/proc/disarm(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(target.check_block())
		target.visible_message(span_warning("[user]'s shove is blocked by [target]!"), \
						span_danger("You block [user]'s shove!"), span_hear("You hear a swoosh!"), COMBAT_MESSAGE_RANGE, user)
		to_chat(user, span_warning("Your shove at [target] was blocked!"))
		return FALSE
	if(attacker_style?.disarm_act(user,target) == MARTIAL_ATTACK_SUCCESS)
		return TRUE
	if(user.body_position != STANDING_UP)
		return FALSE
	if(user == target)
		return FALSE
	if(user.loc == target.loc)
		return FALSE
	user.disarm(target)

/datum/species/proc/spec_attack_hand(mob/living/carbon/human/owner, mob/living/carbon/human/target, datum/martial_art/attacker_style, modifiers)
	if(!istype(owner))
		return
	CHECK_DNA_AND_SPECIES(owner)
	CHECK_DNA_AND_SPECIES(target)

	if(!istype(owner)) //sanity check for drones.
		return
	if(owner.mind)
		attacker_style = owner.mind.martial_art
	if((owner != target) && owner.combat_mode && target.check_shields(owner, 0, owner.name, attack_type = UNARMED_ATTACK))
		log_combat(owner, target, "attempted to touch")
		target.visible_message(span_warning("[owner] attempts to touch [target]!"), \
						span_danger("[owner] attempts to touch you!"), span_hear("You hear a swoosh!"), COMBAT_MESSAGE_RANGE, owner)
		to_chat(owner, span_warning("You attempt to touch [target]!"))
		return

	SEND_SIGNAL(owner, COMSIG_MOB_ATTACK_HAND, owner, target, attacker_style)

	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		disarm(owner, target, attacker_style)
		return // dont attack after
	if(owner.combat_mode)
		harm(owner, target, attacker_style)
	else
		help(owner, target, attacker_style)

/datum/species/proc/spec_attacked_by(obj/item/weapon, mob/living/user, obj/item/bodypart/affecting, mob/living/carbon/human/human)
	// Allows you to put in item-specific reactions based on species
	if(user != human)
		if(human.check_shields(weapon, weapon.force, "the [weapon.name]", MELEE_ATTACK, weapon.armour_penetration, weapon.damtype))
			return FALSE
	if(human.check_block())
		human.visible_message(span_warning("[human] blocks [weapon]!"), \
						span_userdanger("You block [weapon]!"))
		return FALSE

	var/hit_area
	if(!affecting) //Something went wrong. Maybe the limb is missing?
		affecting = human.bodyparts[1]

	hit_area = affecting.plaintext_zone
	var/def_zone = affecting.body_zone

	var/armor_block = human.run_armor_check(affecting, MELEE, span_notice("Your armor has protected your [hit_area]!"), span_warning("Your armor has softened a hit to your [hit_area]!"),weapon.armour_penetration, weak_against_armour = weapon.weak_against_armour)
	armor_block = min(ARMOR_MAX_BLOCK, armor_block) //cap damage reduction at 90%
	var/Iwound_bonus = weapon.wound_bonus

	// this way, you can't wound with a surgical tool on help intent if they have a surgery active and are lying down, so a misclick with a circular saw on the wrong limb doesn't bleed them dry (they still get hit tho)
	if((weapon.item_flags & SURGICAL_TOOL) && !user.combat_mode && human.body_position == LYING_DOWN && (LAZYLEN(human.surgeries) > 0))
		Iwound_bonus = CANT_WOUND

	var/weakness = check_species_weakness(weapon, user)

	human.send_item_attack_message(weapon, user, hit_area, affecting)


	var/attack_direction = get_dir(user, human)
	apply_damage(weapon.force * weakness, weapon.damtype, def_zone, armor_block, human, wound_bonus = Iwound_bonus, bare_wound_bonus = weapon.bare_wound_bonus, sharpness = weapon.get_sharpness(), attack_direction = attack_direction, attacking_item = weapon)

	if(!weapon.force)
		return FALSE //item force is zero
	var/bloody = FALSE
	if(weapon.damtype != BRUTE)
		return TRUE
	if(!(prob(25 + (weapon.force * 2))))
		return TRUE

	if(affecting.can_bleed())
		weapon.add_mob_blood(human) //Make the weapon bloody, not the person.
		if(prob(weapon.force * 2)) //blood spatter!
			bloody = TRUE
			var/turf/location = human.loc
			if(istype(location))
				human.add_splatter_floor(location)
			if(get_dist(user, human) <= 1) //people with TK won't get smeared with blood
				user.add_mob_blood(human)

	switch(hit_area)
		if(BODY_ZONE_HEAD)
			if(!weapon.get_sharpness() && armor_block < 50)
				if(prob(weapon.force))
					human.adjustOrganLoss(ORGAN_SLOT_BRAIN, 20)
					if(human.stat == CONSCIOUS)
						human.visible_message(span_danger("[human] is knocked senseless!"), \
										span_userdanger("You're knocked senseless!"))
						human.set_confusion_if_lower(20 SECONDS)
						human.adjust_eye_blur(20 SECONDS)
					if(prob(10))
						human.gain_trauma(/datum/brain_trauma/mild/concussion)
				else
					human.adjustOrganLoss(ORGAN_SLOT_BRAIN, weapon.force * 0.2)

				if(human.mind && human.stat == CONSCIOUS && human != user && prob(weapon.force + ((100 - human.health) * 0.5))) // rev deconversion through blunt trauma.
					var/datum/antagonist/rev/rev = human.mind.has_antag_datum(/datum/antagonist/rev)
					if(rev)
						rev.remove_revolutionary(user)

			if(bloody) //Apply blood
				if(human.wear_mask)
					human.wear_mask.add_mob_blood(human)
					human.update_worn_mask()
				if(human.head)
					human.head.add_mob_blood(human)
					human.update_worn_head()
				if(human.glasses && prob(33))
					human.glasses.add_mob_blood(human)
					human.update_worn_glasses()

		if(BODY_ZONE_CHEST)
			if(human.stat == CONSCIOUS && !weapon.get_sharpness() && armor_block < 50)
				if(prob(weapon.force))
					human.visible_message(span_danger("[human] is knocked down!"), \
								span_userdanger("You're knocked down!"))
					human.apply_effect(60, EFFECT_KNOCKDOWN, armor_block)

			if(bloody)
				if(human.wear_suit)
					human.wear_suit.add_mob_blood(human)
					human.update_worn_oversuit()
				if(human.w_uniform)
					human.w_uniform.add_mob_blood(human)
					human.update_worn_undersuit()

	/// Triggers force say events
	if(weapon.force > 10 || (weapon.force >= 5 && prob(33)))
		human.force_say(user)

	return TRUE

/datum/species/proc/apply_damage(damage, damagetype = BRUTE, def_zone = null, blocked, mob/living/carbon/human/H, forced = FALSE, spread_damage = FALSE, wound_bonus = 0, bare_wound_bonus = 0, sharpness = NONE, attack_direction = null, attacking_item)
	SEND_SIGNAL(H, COMSIG_MOB_APPLY_DAMAGE, damage, damagetype, def_zone, blocked, wound_bonus, bare_wound_bonus, sharpness, attack_direction, attacking_item)
	var/hit_percent = (100-(damage_modifier+blocked))/100
	hit_percent = (hit_percent * (100-H.physiology.damage_resistance))/100
	if(!damage || (!forced && hit_percent <= 0))
		return 0

	var/obj/item/bodypart/BP = null
	if(!spread_damage)
		if(isbodypart(def_zone))
			BP = def_zone
		else
			if(!def_zone)
				def_zone = H.get_random_valid_zone(def_zone)
			BP = H.get_bodypart(check_zone(def_zone))
			if(!BP)
				BP = H.bodyparts[1]

	switch(damagetype)
		if(BRUTE)
			H.damageoverlaytemp = 20
			var/damage_amount = forced ? damage : damage * hit_percent * H.physiology.brute_mod
			if(BP)
				if(BP.receive_damage(damage_amount, 0, wound_bonus = wound_bonus, bare_wound_bonus = bare_wound_bonus, sharpness = sharpness, attack_direction = attack_direction, damage_source = attacking_item))
					H.update_damage_overlays()
			else//no bodypart, we deal damage with a more general method.
				H.adjustBruteLoss(damage_amount)
		if(BURN)
			H.damageoverlaytemp = 20
			var/damage_amount = forced ? damage : damage * hit_percent * H.physiology.burn_mod
			if(BP)
				if(BP.receive_damage(0, damage_amount, wound_bonus = wound_bonus, bare_wound_bonus = bare_wound_bonus, sharpness = sharpness, attack_direction = attack_direction, damage_source = attacking_item))
					H.update_damage_overlays()
			else
				H.adjustFireLoss(damage_amount)
		if(TOX)
			var/damage_amount = forced ? damage : damage * hit_percent * H.physiology.tox_mod
			H.adjustToxLoss(damage_amount)
		if(OXY)
			var/damage_amount = forced ? damage : damage * hit_percent * H.physiology.oxy_mod
			H.adjustOxyLoss(damage_amount)
		if(CLONE)
			var/damage_amount = forced ? damage : damage * hit_percent * H.physiology.clone_mod
			H.adjustCloneLoss(damage_amount)
		if(STAMINA)
			var/damage_amount = forced ? damage : damage * hit_percent * H.physiology.stamina_mod
			H.adjustStaminaLoss(damage_amount)
		if(BRAIN)
			var/damage_amount = forced ? damage : damage * hit_percent * H.physiology.brain_mod
			H.adjustOrganLoss(ORGAN_SLOT_BRAIN, damage_amount)
	SEND_SIGNAL(H, COMSIG_MOB_AFTER_APPLY_DAMAGE, damage, damagetype, def_zone, blocked, wound_bonus, bare_wound_bonus, sharpness, attack_direction, attacking_item)
	return TRUE

/datum/species/proc/on_hit(obj/projectile/P, mob/living/carbon/human/H)
	// called when hit by a projectile
	switch(P.type)
		if(/obj/projectile/energy/floramut) // overwritten by plants/pods
			H.show_message(span_notice("The radiation beam dissipates harmlessly through your body."))
		if(/obj/projectile/energy/florayield)
			H.show_message(span_notice("The radiation beam dissipates harmlessly through your body."))
		if(/obj/projectile/energy/florarevolution)
			H.show_message(span_notice("The radiation beam dissipates harmlessly through your body."))

/datum/species/proc/bullet_act(obj/projectile/P, mob/living/carbon/human/H)
	// called before a projectile hit
	return 0

//////////////////////////
// ENVIRONMENT HANDLERS //
//////////////////////////

/**
 * Environment handler for species
 *
 * vars:
 * * environment (required) The environment gas mix
 * * humi (required)(type: /mob/living/carbon/human) The mob we will target
 */
/datum/species/proc/handle_environment(mob/living/carbon/human/humi, datum/gas_mixture/environment, seconds_per_tick, times_fired)
	handle_environment_pressure(humi, environment, seconds_per_tick, times_fired)

/**
 * Body temperature handler for species
 *
 * These procs manage body temp, bamage, and alerts
 * Some of these will still fire when not alive to balance body temp to the room temp.
 * vars:
 * * humi (required)(type: /mob/living/carbon/human) The mob we will target
 */
/datum/species/proc/handle_body_temperature(mob/living/carbon/human/humi, seconds_per_tick, times_fired)
	//when in a cryo unit we suspend all natural body regulation
	if(istype(humi.loc, /obj/machinery/cryo_cell))
		return

	//Only stabilise core temp when alive and not in statis
	if(humi.stat < DEAD && !HAS_TRAIT(humi, TRAIT_STASIS))
		body_temperature_core(humi, seconds_per_tick, times_fired)

	//These do run in statis
	body_temperature_skin(humi, seconds_per_tick, times_fired)
	body_temperature_alerts(humi, seconds_per_tick, times_fired)

	//Do not cause more damage in statis
	if(!HAS_TRAIT(humi, TRAIT_STASIS))
		body_temperature_damage(humi, seconds_per_tick, times_fired)

/**
 * Used to stabilize the core temperature back to normal on living mobs
 *
 * The metabolisim heats up the core of the mob trying to keep it at the normal body temp
 * vars:
 * * humi (required) The mob we will stabilize
 */
/datum/species/proc/body_temperature_core(mob/living/carbon/human/humi, seconds_per_tick, times_fired)
	var/natural_change = get_temp_change_amount(humi.get_body_temp_normal() - humi.coretemperature, 0.06 * seconds_per_tick)
	humi.adjust_coretemperature(humi.metabolism_efficiency * natural_change)

/**
 * Used to normalize the skin temperature on living mobs
 *
 * The core temp effects the skin, then the enviroment effects the skin, then we refect that back to the core.
 * This happens even when dead so bodies revert to room temp over time.
 * vars:
 * * humi (required) The mob we will targeting
 * - seconds_per_tick: The amount of time that is considered as elapsing
 * - times_fired: The number of times SSmobs has fired
 */
/datum/species/proc/body_temperature_skin(mob/living/carbon/human/humi, seconds_per_tick, times_fired)

	// change the core based on the skin temp
	var/skin_core_diff = humi.bodytemperature - humi.coretemperature
	// change rate of 0.04 per second to be slightly below area to skin change rate and still have a solid curve
	var/skin_core_change = get_temp_change_amount(skin_core_diff, 0.04 * seconds_per_tick)

	humi.adjust_coretemperature(skin_core_change)

	// get the enviroment details of where the mob is standing
	var/datum/gas_mixture/environment = humi.loc.return_air()
	if(!environment) // if there is no environment (nullspace) drop out here.
		return

	// Get the temperature of the environment for area
	var/area_temp = humi.get_temperature(environment)

	// Get the insulation value based on the area's temp
	var/thermal_protection = humi.get_insulation_protection(area_temp)

	// Changes to the skin temperature based on the area
	var/area_skin_diff = area_temp - humi.bodytemperature
	if(!humi.on_fire || area_skin_diff > 0)
		// change rate of 0.05 as area temp has large impact on the surface
		var/area_skin_change = get_temp_change_amount(area_skin_diff, 0.05 * seconds_per_tick)

		// We need to apply the thermal protection of the clothing when applying area to surface change
		// If the core bodytemp goes over the normal body temp you are overheating and becom sweaty
		// This will cause the insulation value of any clothing to reduced in effect (70% normal rating)
		// we add 10 degree over normal body temp before triggering as thick insulation raises body temp
		if(humi.get_body_temp_normal(apply_change=FALSE) + 10 < humi.coretemperature)
			// we are overheating and sweaty insulation is not as good reducing thermal protection
			area_skin_change = (1 - (thermal_protection * 0.7)) * area_skin_change
		else
			area_skin_change = (1 - thermal_protection) * area_skin_change

		humi.adjust_bodytemperature(area_skin_change)

	// Core to skin temp transfer, when not on fire
	if(!humi.on_fire)
		// Get the changes to the skin from the core temp
		var/core_skin_diff = humi.coretemperature - humi.bodytemperature
		// change rate of 0.045 to reflect temp back to the skin at the slight higher rate then core to skin
		var/core_skin_change = (1 + thermal_protection) * get_temp_change_amount(core_skin_diff, 0.045 * seconds_per_tick)

		// We do not want to over shoot after using protection
		if(core_skin_diff > 0)
			core_skin_change = min(core_skin_change, core_skin_diff)
		else
			core_skin_change = max(core_skin_change, core_skin_diff)

		humi.adjust_bodytemperature(core_skin_change)


/**
 * Used to set alerts and debuffs based on body temperature
 * vars:
 * * humi (required) The mob we will targeting
 */
/datum/species/proc/body_temperature_alerts(mob/living/carbon/human/humi)
	var/old_bodytemp = humi.old_bodytemperature
	var/bodytemp = humi.bodytemperature
	// Body temperature is too hot, and we do not have resist traits
	if(bodytemp > bodytemp_heat_damage_limit && !HAS_TRAIT(humi, TRAIT_RESISTHEAT))
		// Clear cold mood and apply hot mood
		humi.clear_mood_event("cold")
		humi.add_mood_event("hot", /datum/mood_event/hot)

		//Remove any slowdown from the cold.
		humi.remove_movespeed_modifier(/datum/movespeed_modifier/cold)
		// display alerts based on how hot it is
		// Can't be a switch due to http://www.byond.com/forum/post/2750423
		if(bodytemp in bodytemp_heat_damage_limit to BODYTEMP_HEAT_WARNING_2)
			humi.throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/hot, 1)
		else if(bodytemp in BODYTEMP_HEAT_WARNING_2 to BODYTEMP_HEAT_WARNING_3)
			humi.throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/hot, 2)
		else
			humi.throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/hot, 3)

	// Body temperature is too cold, and we do not have resist traits
	else if(bodytemp < bodytemp_cold_damage_limit && !HAS_TRAIT(humi, TRAIT_RESISTCOLD))
		// clear any hot moods and apply cold mood
		humi.clear_mood_event("hot")
		humi.add_mood_event("cold", /datum/mood_event/cold)
		// Apply cold slow down
		humi.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/cold, multiplicative_slowdown = ((bodytemp_cold_damage_limit - humi.bodytemperature) / COLD_SLOWDOWN_FACTOR))
		// Display alerts based how cold it is
		// Can't be a switch due to http://www.byond.com/forum/post/2750423
		if(bodytemp in BODYTEMP_COLD_WARNING_2 to bodytemp_cold_damage_limit)
			humi.throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/cold, 1)
		else if(bodytemp in BODYTEMP_COLD_WARNING_3 to BODYTEMP_COLD_WARNING_2)
			humi.throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/cold, 2)
		else
			humi.throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/cold, 3)

	// We are not to hot or cold, remove status and moods
	// Optimization here, we check these things based off the old temperature to avoid unneeded work
	// We're not perfect about this, because it'd just add more work to the base case, and resistances are rare
	else if (old_bodytemp > bodytemp_heat_damage_limit || old_bodytemp < bodytemp_cold_damage_limit)
		humi.clear_alert(ALERT_TEMPERATURE)
		humi.remove_movespeed_modifier(/datum/movespeed_modifier/cold)
		humi.clear_mood_event("cold")
		humi.clear_mood_event("hot")

	// Store the old bodytemp for future checking
	humi.old_bodytemperature = bodytemp

/**
 * Used to apply wounds and damage based on core/body temp
 * vars:
 * * humi (required) The mob we will targeting
 */
/datum/species/proc/body_temperature_damage(mob/living/carbon/human/humi, seconds_per_tick, times_fired)

	//If the body temp is above the wound limit start adding exposure stacks
	if(humi.bodytemperature > BODYTEMP_HEAT_WOUND_LIMIT)
		humi.heat_exposure_stacks = min(humi.heat_exposure_stacks + (0.5 * seconds_per_tick), 40)
	else //When below the wound limit, reduce the exposure stacks fast.
		humi.heat_exposure_stacks = max(humi.heat_exposure_stacks - (2 * seconds_per_tick), 0)

	//when exposure stacks are greater then 10 + rand20 try to apply wounds and reset stacks
	if(humi.heat_exposure_stacks > (10 + rand(0, 20)))
		apply_burn_wounds(humi, seconds_per_tick, times_fired)
		humi.heat_exposure_stacks = 0

	// Body temperature is too hot, and we do not have resist traits
	// Apply some burn damage to the body
	if(humi.coretemperature > bodytemp_heat_damage_limit && !HAS_TRAIT(humi, TRAIT_RESISTHEAT))
		var/firemodifier = humi.fire_stacks / 50
		if (!humi.on_fire) // We are not on fire, reduce the modifier
			firemodifier = min(firemodifier, 0)

		// this can go below 5 at log 2.5
		var/burn_damage = max(log(2 - firemodifier, (humi.coretemperature - humi.get_body_temp_normal(apply_change=FALSE))) - 5, 0)

		// Apply species and physiology modifiers to heat damage
		burn_damage = burn_damage * heatmod * humi.physiology.heat_mod * 0.5 * seconds_per_tick

		// 40% for level 3 damage on humans to scream in pain
		if (humi.stat < UNCONSCIOUS && (prob(burn_damage) * 10) / 4)
			humi.emote("scream")

		// Apply the damage to all body parts
		humi.apply_damage(burn_damage, BURN, spread_damage = TRUE)

	// Apply some burn / brute damage to the body (Dependent if the person is hulk or not)
	var/is_hulk = HAS_TRAIT(humi, TRAIT_HULK)

	var/cold_damage_limit = bodytemp_cold_damage_limit + (is_hulk ? BODYTEMP_HULK_COLD_DAMAGE_LIMIT_MODIFIER : 0)

	if(humi.coretemperature < cold_damage_limit && !HAS_TRAIT(humi, TRAIT_RESISTCOLD))
		var/damage_type = is_hulk ? BRUTE : BURN // Why?
		var/damage_mod = coldmod * humi.physiology.cold_mod * (is_hulk ? HULK_COLD_DAMAGE_MOD : 1)
		// Can't be a switch due to http://www.byond.com/forum/post/2750423
		if(humi.coretemperature in 201 to cold_damage_limit)
			humi.apply_damage(COLD_DAMAGE_LEVEL_1 * damage_mod * seconds_per_tick, damage_type)
		else if(humi.coretemperature in 120 to 200)
			humi.apply_damage(COLD_DAMAGE_LEVEL_2 * damage_mod * seconds_per_tick, damage_type)
		else
			humi.apply_damage(COLD_DAMAGE_LEVEL_3 * damage_mod * seconds_per_tick, damage_type)

/**
 * Used to apply burn wounds on random limbs
 *
 * This is called from body_temperature_damage when exposure to extream heat adds up and causes a wound.
 * The wounds will increase in severity as the temperature increases.
 * vars:
 * * humi (required) The mob we will targeting
 */
/datum/species/proc/apply_burn_wounds(mob/living/carbon/human/humi, seconds_per_tick, times_fired)
	// If we are resistant to heat exit
	if(HAS_TRAIT(humi, TRAIT_RESISTHEAT))
		return

	// If our body temp is to low for a wound exit
	if(humi.bodytemperature < BODYTEMP_HEAT_WOUND_LIMIT)
		return

	// Lets pick a random body part and check for an existing burn
	var/obj/item/bodypart/bodypart = pick(humi.bodyparts)
	var/datum/wound/existing_burn
	for (var/datum/wound/iterated_wound as anything in bodypart.wounds)
		var/datum/wound_pregen_data/pregen_data = iterated_wound.get_pregen_data()
		if (pregen_data.wound_series in GLOB.wounding_types_to_series[WOUND_BURN])
			existing_burn = iterated_wound
			break
	// If we have an existing burn try to upgrade it
	var/severity
	if(existing_burn)
		switch(existing_burn.severity)
			if(WOUND_SEVERITY_MODERATE)
				if(humi.bodytemperature > BODYTEMP_HEAT_WOUND_LIMIT + 400) // 800k
					severity = WOUND_SEVERITY_SEVERE
			if(WOUND_SEVERITY_SEVERE)
				if(humi.bodytemperature > BODYTEMP_HEAT_WOUND_LIMIT + 2800) // 3200k
					severity = WOUND_SEVERITY_CRITICAL
	else // If we have no burn apply the lowest level burn
		severity = WOUND_SEVERITY_MODERATE

	humi.cause_wound_of_type_and_severity(WOUND_BURN, bodypart, severity, wound_source = "hot temperatures")

	// always take some burn damage
	var/burn_damage = HEAT_DAMAGE_LEVEL_1
	if(humi.bodytemperature > BODYTEMP_HEAT_WOUND_LIMIT + 400)
		burn_damage = HEAT_DAMAGE_LEVEL_2
	if(humi.bodytemperature > BODYTEMP_HEAT_WOUND_LIMIT + 2800)
		burn_damage = HEAT_DAMAGE_LEVEL_3

	humi.apply_damage(burn_damage * seconds_per_tick, BURN, bodypart)

/// Handle the air pressure of the environment
/datum/species/proc/handle_environment_pressure(mob/living/carbon/human/H, datum/gas_mixture/environment, seconds_per_tick, times_fired)
	var/pressure = environment.return_pressure()
	var/adjusted_pressure = H.calculate_affecting_pressure(pressure)

	// Set alerts and apply damage based on the amount of pressure
	switch(adjusted_pressure)
		// Very high pressure, show an alert and take damage
		if(HAZARD_HIGH_PRESSURE to INFINITY)
			if(!HAS_TRAIT(H, TRAIT_RESISTHIGHPRESSURE))
				H.adjustBruteLoss(min(((adjusted_pressure / HAZARD_HIGH_PRESSURE) - 1) * PRESSURE_DAMAGE_COEFFICIENT, MAX_HIGH_PRESSURE_DAMAGE) * H.physiology.pressure_mod * seconds_per_tick, required_bodytype = BODYTYPE_ORGANIC)
				H.throw_alert(ALERT_PRESSURE, /atom/movable/screen/alert/highpressure, 2)
			else
				H.clear_alert(ALERT_PRESSURE)

		// High pressure, show an alert
		if(WARNING_HIGH_PRESSURE to HAZARD_HIGH_PRESSURE)
			H.throw_alert(ALERT_PRESSURE, /atom/movable/screen/alert/highpressure, 1)

		// No pressure issues here clear pressure alerts
		if(WARNING_LOW_PRESSURE to WARNING_HIGH_PRESSURE)
			H.clear_alert(ALERT_PRESSURE)

		// Low pressure here, show an alert
		if(HAZARD_LOW_PRESSURE to WARNING_LOW_PRESSURE)
			// We have low pressure resit trait, clear alerts
			if(HAS_TRAIT(H, TRAIT_RESISTLOWPRESSURE))
				H.clear_alert(ALERT_PRESSURE)
			else
				H.throw_alert(ALERT_PRESSURE, /atom/movable/screen/alert/lowpressure, 1)

		// Very low pressure, show an alert and take damage
		else
			// We have low pressure resit trait, clear alerts
			if(HAS_TRAIT(H, TRAIT_RESISTLOWPRESSURE))
				H.clear_alert(ALERT_PRESSURE)
			else
				H.adjustBruteLoss(LOW_PRESSURE_DAMAGE * H.physiology.pressure_mod * seconds_per_tick, required_bodytype = BODYTYPE_ORGANIC)
				H.throw_alert(ALERT_PRESSURE, /atom/movable/screen/alert/lowpressure, 2)


//////////
// FIRE //
//////////

/datum/species/proc/handle_fire(mob/living/carbon/human/H, seconds_per_tick, no_protection = FALSE)
	return no_protection

////////////
//  Stun  //
////////////

/datum/species/proc/spec_stun(mob/living/carbon/human/H,amount)
	if(H.movement_type & FLYING)
		var/obj/item/organ/external/wings/functional/wings = H.get_organ_slot(ORGAN_SLOT_EXTERNAL_WINGS)
		if(wings)
			wings.toggle_flight(H)
			wings.fly_slip(H)
	. = stunmod * H.physiology.stun_mod * amount

/datum/species/proc/negates_gravity(mob/living/carbon/human/H)
	if(H.movement_type & FLYING)
		return TRUE
	return FALSE

////////////////
//Tail Wagging//
////////////////

/*
 * Clears all tail related moodlets when they lose their species.
 *
 * former_tail_owner - the mob that was once a species with a tail and now is a different species
 */
/datum/species/proc/clear_tail_moodlets(mob/living/carbon/human/former_tail_owner)
	former_tail_owner.clear_mood_event("tail_lost")
	former_tail_owner.clear_mood_event("tail_balance_lost")
	former_tail_owner.clear_mood_event("wrong_tail_regained")

/// Returns a list of strings representing features this species has.
/// Used by the preferences UI to know what buttons to show.
/datum/species/proc/get_features()
	var/cached_features = GLOB.features_by_species[type]
	if (!isnull(cached_features))
		return cached_features

	var/list/features = list()

	for (var/preference_type in GLOB.preference_entries)
		var/datum/preference/preference = GLOB.preference_entries[preference_type]

		if ( \
			(preference.relevant_mutant_bodypart in mutant_bodyparts) \
			|| (preference.relevant_inherent_trait in inherent_traits) \
			|| (preference.relevant_external_organ in external_organs) \
			|| (preference.relevant_head_flag && check_head_flags(preference.relevant_head_flag)) \
		)
			features += preference.savefile_key

	for (var/obj/item/organ/external/organ_type as anything in external_organs)
		var/preference = initial(organ_type.preference)
		if (!isnull(preference))
			features += preference

	GLOB.features_by_species[type] = features

	return features

/// Given a human, will adjust it before taking a picture for the preferences UI.
/// This should create a CONSISTENT result, so the icons don't randomly change.
/datum/species/proc/prepare_human_for_preview(mob/living/carbon/human/human)
	return

/// Returns the species's scream sound.
/datum/species/proc/get_scream_sound(mob/living/carbon/human/human)
	return

/datum/species/proc/get_types_to_preload()
	var/list/to_store = list()
	to_store += mutant_organs
	for(var/obj/item/organ/external/horny as anything in external_organs)
		to_store += horny //Haha get it?

	//Don't preload brains, cause reuse becomes a horrible headache
	to_store += mutantheart
	to_store += mutantlungs
	to_store += mutanteyes
	to_store += mutantears
	to_store += mutanttongue
	to_store += mutantliver
	to_store += mutantstomach
	to_store += mutantappendix
	//We don't cache mutant hands because it's not constrained enough, too high a potential for failure
	return to_store


/**
 * Owner login
 */

/**
 * A simple proc to be overwritten if something needs to be done when a mob logs in. Does nothing by default.
 *
 * Arguments:
 * * owner - The owner of our species.
 */
/datum/species/proc/on_owner_login(mob/living/carbon/human/owner)
	return

/**
 * Gets a description of the species' *physical* attributes. What makes playing as one different. Used in magic mirrors.
 *
 * Returns a string.
 */

/datum/species/proc/get_physical_attributes()
	return "An unremarkable species."
/**
 * Gets a short description for the specices. Should be relatively succinct.
 * Used in the preference menu.
 *
 * Returns a string.
 */

/datum/species/proc/get_species_description()
	SHOULD_CALL_PARENT(FALSE)

	stack_trace("Species [name] ([type]) did not have a description set, and is a selectable roundstart race! Override get_species_description.")
	return "No species description set, file a bug report!"

/**
 * Gets the lore behind the type of species. Can be long.
 * Used in the preference menu.
 *
 * Returns a list of strings.
 * Between each entry in the list, a newline will be inserted, for formatting.
 */
/datum/species/proc/get_species_lore()
	SHOULD_CALL_PARENT(FALSE)
	RETURN_TYPE(/list)

	stack_trace("Species [name] ([type]) did not have lore set, and is a selectable roundstart race! Override get_species_lore.")
	return list("No species lore set, file a bug report!")

/**
 * Translate the species liked foods from bitfields into strings
 * and returns it in the form of an associated list.
 *
 * Returns a list, or null if they have no diet.
 */
/datum/species/proc/get_species_diet()
	if((TRAIT_NOHUNGER in inherent_traits) || !mutanttongue)
		return null

	var/static/list/food_flags = FOOD_FLAGS
	var/obj/item/organ/internal/tongue/fake_tongue = mutanttongue

	return list(
		"liked_food" = bitfield_to_list(initial(fake_tongue.liked_foodtypes), food_flags),
		"disliked_food" = bitfield_to_list(initial(fake_tongue.disliked_foodtypes), food_flags),
		"toxic_food" = bitfield_to_list(initial(fake_tongue.toxic_foodtypes), food_flags),
	)

/**
 * Generates a list of "perks" related to this species
 * (Postives, neutrals, and negatives)
 * in the format of a list of lists.
 * Used in the preference menu.
 *
 * "Perk" format is as followed:
 * list(
 *   SPECIES_PERK_TYPE = type of perk (postiive, negative, neutral - use the defines)
 *   SPECIES_PERK_ICON = icon shown within the UI
 *   SPECIES_PERK_NAME = name of the perk on hover
 *   SPECIES_PERK_DESC = description of the perk on hover
 * )
 *
 * Returns a list of lists.
 * The outer list is an assoc list of [perk type]s to a list of perks.
 * The innter list is a list of perks. Can be empty, but won't be null.
 */
/datum/species/proc/get_species_perks()
	var/list/species_perks = list()

	// Let us get every perk we can concieve of in one big list.
	// The order these are called (kind of) matters.
	// Species unique perks first, as they're more important than genetic perks,
	// and language perk last, as it comes at the end of the perks list
	species_perks += create_pref_unique_perks()
	species_perks += create_pref_blood_perks()
	species_perks += create_pref_damage_perks()
	species_perks += create_pref_temperature_perks()
	species_perks += create_pref_traits_perks()
	species_perks += create_pref_biotypes_perks()
	species_perks += create_pref_organs_perks()
	species_perks += create_pref_language_perk()

	// Some overrides may return `null`, prevent those from jamming up the list.
	list_clear_nulls(species_perks)

	// Now let's sort them out for cleanliness and sanity
	var/list/perks_to_return = list(
		SPECIES_POSITIVE_PERK = list(),
		SPECIES_NEUTRAL_PERK = list(),
		SPECIES_NEGATIVE_PERK =  list(),
	)

	for(var/list/perk as anything in species_perks)
		var/perk_type = perk[SPECIES_PERK_TYPE]
		// If we find a perk that isn't postiive, negative, or neutral,
		// it's a bad entry - don't add it to our list. Throw a stack trace and skip it instead.
		if(isnull(perks_to_return[perk_type]))
			stack_trace("Invalid species perk ([perk[SPECIES_PERK_NAME]]) found for species [name]. \
				The type should be positive, negative, or neutral. (Got: [perk_type])")
			continue

		perks_to_return[perk_type] += list(perk)

	return perks_to_return

/**
 * Used to add any species specific perks to the perk list.
 *
 * Returns null by default. When overriding, return a list of perks.
 */
/datum/species/proc/create_pref_unique_perks()
	return null

/**
 * Adds adds any perks related to sustaining damage.
 * For example, brute damage vulnerability, or fire damage resistance.
 *
 * Returns a list containing perks, or an empty list.
 */
/datum/species/proc/create_pref_damage_perks()
	// We use the chest to figure out brute and burn mod perks
	var/obj/item/bodypart/chest/fake_chest = bodypart_overrides[BODY_ZONE_CHEST]

	var/list/to_add = list()

	// Brute related
	if(initial(fake_chest.brute_modifier) > 1)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "band-aid",
			SPECIES_PERK_NAME = "Brutal Weakness",
			SPECIES_PERK_DESC = "[plural_form] are weak to brute damage.",
		))

	if(initial(fake_chest.brute_modifier) < 1)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "shield-alt",
			SPECIES_PERK_NAME = "Brutal Resilience",
			SPECIES_PERK_DESC = "[plural_form] are resilient to brute damage.",
		))

	// Burn related
	if(initial(fake_chest.burn_modifier) > 1)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "burn",
			SPECIES_PERK_NAME = "Burn Weakness",
			SPECIES_PERK_DESC = "[plural_form] are weak to burn damage.",
		))

	if(initial(fake_chest.burn_modifier) < 1)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "shield-alt",
			SPECIES_PERK_NAME = "Burn Resilience",
			SPECIES_PERK_DESC = "[plural_form] are resilient to burn damage.",
		))

	// Shock damage
	if(siemens_coeff > 1)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "bolt",
			SPECIES_PERK_NAME = "Shock Vulnerability",
			SPECIES_PERK_DESC = "[plural_form] are vulnerable to being shocked.",
		))

	if(siemens_coeff < 1)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "shield-alt",
			SPECIES_PERK_NAME = "Shock Resilience",
			SPECIES_PERK_DESC = "[plural_form] are resilient to being shocked.",
		))

	return to_add

/**
 * Adds adds any perks related to how the species deals with temperature.
 *
 * Returns a list containing perks, or an empty list.
 */
/datum/species/proc/create_pref_temperature_perks()
	var/list/to_add = list()

	// Hot temperature tolerance
	if(heatmod > 1 || bodytemp_heat_damage_limit < BODYTEMP_HEAT_DAMAGE_LIMIT)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "temperature-high",
			SPECIES_PERK_NAME = "Heat Vulnerability",
			SPECIES_PERK_DESC = "[plural_form] are vulnerable to high temperatures.",
		))

	if(heatmod < 1 || bodytemp_heat_damage_limit > BODYTEMP_HEAT_DAMAGE_LIMIT)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "thermometer-empty",
			SPECIES_PERK_NAME = "Heat Resilience",
			SPECIES_PERK_DESC = "[plural_form] are resilient to hotter environments.",
		))

	// Cold temperature tolerance
	if(coldmod > 1 || bodytemp_cold_damage_limit > BODYTEMP_COLD_DAMAGE_LIMIT)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "temperature-low",
			SPECIES_PERK_NAME = "Cold Vulnerability",
			SPECIES_PERK_DESC = "[plural_form] are vulnerable to cold temperatures.",
		))

	if(coldmod < 1 || bodytemp_cold_damage_limit < BODYTEMP_COLD_DAMAGE_LIMIT)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "thermometer-empty",
			SPECIES_PERK_NAME = "Cold Resilience",
			SPECIES_PERK_DESC = "[plural_form] are resilient to colder environments.",
		))

	return to_add

/**
 * Adds adds any perks related to the species' blood (or lack thereof).
 *
 * Returns a list containing perks, or an empty list.
 */
/datum/species/proc/create_pref_blood_perks()
	var/list/to_add = list()

	// TRAIT_NOBLOOD takes priority by default
	if(TRAIT_NOBLOOD in inherent_traits)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "tint-slash",
			SPECIES_PERK_NAME = "Bloodletted",
			SPECIES_PERK_DESC = "[plural_form] do not have blood.",
		))

	// Otherwise, check if their exotic blood is a valid typepath
	else if(ispath(exotic_blood))
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "tint",
			SPECIES_PERK_NAME = initial(exotic_blood.name),
			SPECIES_PERK_DESC = "[name] blood is [initial(exotic_blood.name)], which can make recieving medical treatment harder.",
		))

	// Otherwise otherwise, see if they have an exotic bloodtype set
	else if(exotic_bloodtype)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "tint",
			SPECIES_PERK_NAME = "Exotic Blood",
			SPECIES_PERK_DESC = "[plural_form] have \"[exotic_bloodtype]\" type blood, which can make recieving medical treatment harder.",
		))

	return to_add

/**
 * Adds adds any perks related to the species' inherent_traits list.
 *
 * Returns a list containing perks, or an empty list.
 */
/datum/species/proc/create_pref_traits_perks()
	var/list/to_add = list()

	if(TRAIT_LIMBATTACHMENT in inherent_traits)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "user-plus",
			SPECIES_PERK_NAME = "Limbs Easily Reattached",
			SPECIES_PERK_DESC = "[plural_form] limbs are easily readded, and as such do not \
				require surgery to restore. Simply pick it up and pop it back in, champ!",
		))

	if(TRAIT_EASYDISMEMBER in inherent_traits)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "user-times",
			SPECIES_PERK_NAME = "Limbs Easily Dismembered",
			SPECIES_PERK_DESC = "[plural_form] limbs are not secured well, and as such they are easily dismembered.",
		))

	if(TRAIT_EASILY_WOUNDED in inherent_traits)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "user-times",
			SPECIES_PERK_NAME = "Easily Wounded",
			SPECIES_PERK_DESC = "[plural_form] skin is very weak and fragile. They are much easier to apply serious wounds to.",
		))

	if(TRAIT_TOXINLOVER in inherent_traits)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "syringe",
			SPECIES_PERK_NAME = "Toxins Lover",
			SPECIES_PERK_DESC = "Toxins damage dealt to [plural_form] are reversed - healing toxins will instead cause harm, and \
				causing toxins will instead cause healing. Be careful around purging chemicals!",
		))

	if (TRAIT_GENELESS in inherent_traits)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "dna",
			SPECIES_PERK_NAME = "No Genes",
			SPECIES_PERK_DESC = "[plural_form] have no genes, making genetic scrambling a useless weapon, but also locking them out from getting genetic powers.",
		))

	if (TRAIT_NOBREATH in inherent_traits)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "wind",
			SPECIES_PERK_NAME = "No Respiration",
			SPECIES_PERK_DESC = "[plural_form] have no need to breathe!",
		))

	return to_add

/**
 * Adds adds any perks related to the species' inherent_biotypes flags.
 *
 * Returns a list containing perks, or an empty list.
 */
/datum/species/proc/create_pref_biotypes_perks()
	var/list/to_add = list()

	if(inherent_biotypes & MOB_UNDEAD)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "skull",
			SPECIES_PERK_NAME = "Undead",
			SPECIES_PERK_DESC = "[plural_form] are of the undead! The undead do not have the need to eat or breathe, and \
				most viruses will not be able to infect a walking corpse. Their worries mostly stop at remaining in one piece, really.",
		))

	return to_add

/**
 * Adds any perks relating to inherent differences to this species' organs.
 * This proc is only suitable for generic differences, like alcohol tolerance, or heat threshold for breathing.
 *
 * Returns a list containing perks, or an empty list.
 */
/datum/species/proc/create_pref_organs_perks()
	RETURN_TYPE(/list)

	var/list/to_add = list()

	to_add += create_pref_liver_perks()
	to_add += create_pref_lung_perks()

	return to_add

/datum/species/proc/create_pref_liver_perks()
	RETURN_TYPE(/list)

	var/list/to_add = list()

	var/alcohol_tolerance = initial(mutantliver.alcohol_tolerance)
	var/obj/item/organ/internal/liver/base_liver = /obj/item/organ/internal/liver
	var/tolerance_difference = alcohol_tolerance - initial(base_liver.alcohol_tolerance)

	if (tolerance_difference != 0)
		var/difference_positive = (tolerance_difference > 0)
		var/more_or_less = (difference_positive) ? "more" : "less"
		var/perk_type = (difference_positive) ? SPECIES_NEGATIVE_PERK : SPECIES_POSITIVE_PERK
		var/perk_name = "Alcohol " + ((difference_positive) ? "Weakness" : "Tolerance")
		var/percent_difference = (alcohol_tolerance / initial(base_liver.alcohol_tolerance)) * 100

		to_add += list(list(
			SPECIES_PERK_TYPE = perk_type,
			SPECIES_PERK_ICON = "wine-glass",
			SPECIES_PERK_NAME = perk_name,
			SPECIES_PERK_DESC = "[name] livers are [more_or_less] susceptable to alcohol than human livers, by about [percent_difference]%."
		))

	var/tox_shrugging = initial(mutantliver.toxTolerance)
	var/shrugging_difference = tox_shrugging - initial(base_liver.toxTolerance)
	if (shrugging_difference != 0)
		var/difference_positive = (shrugging_difference > 0)
		var/more_or_less = (difference_positive) ? "more" : "less"
		var/perk_type = (difference_positive) ? SPECIES_POSITIVE_PERK : SPECIES_NEGATIVE_PERK
		var/perk_name = ("Toxin " + ((difference_positive) ? "Resistant" : "Vulnerable")) + " Liver"

		to_add += list(list(
			SPECIES_PERK_TYPE = perk_type,
			SPECIES_PERK_ICON = "biohazard",
			SPECIES_PERK_NAME = perk_name,
			SPECIES_PERK_DESC = "[name] livers are capable of rapidly shrugging off [tox_shrugging]u of toxins, which is [more_or_less] than humans."
		))

	return to_add

/datum/species/proc/create_pref_lung_perks()
	RETURN_TYPE(/list)

	var/list/to_add = list()

	if (breathid != GAS_O2)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "wind",
			SPECIES_PERK_NAME = "[capitalize(breathid)] Breathing",
			SPECIES_PERK_DESC = "[plural_form] must breathe [breathid] to survive. You receive a tank when you arrive.",
		))

	return to_add

/**
 * Adds in a language perk based on all the languages the species
 * can speak by default (according to their language holder).
 *
 * Returns a list containing perks, or an empty list.
 */
/datum/species/proc/create_pref_language_perk()

	// Grab galactic common as a path, for comparisons
	var/datum/language/common_language = /datum/language/common

	// Now let's find all the languages they can speak that aren't common
	var/list/bonus_languages = list()
	var/datum/language_holder/basic_holder = GLOB.prototype_language_holders[species_language_holder]
	for(var/datum/language/language_type as anything in basic_holder.spoken_languages)
		if(ispath(language_type, common_language))
			continue
		bonus_languages += initial(language_type.name)

	if(!length(bonus_languages))
		return // You're boring

	var/list/to_add = list()
	if(common_language in basic_holder.spoken_languages)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "comment",
			SPECIES_PERK_NAME = "Native Speaker",
			SPECIES_PERK_DESC = "Alongside [initial(common_language.name)], [plural_form] gain the ability to speak [english_list(bonus_languages)].",
		))

	else
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "comment",
			SPECIES_PERK_NAME = "Foreign Speaker",
			SPECIES_PERK_DESC = "[plural_form] may not speak [initial(common_language.name)], but they can speak [english_list(bonus_languages)].",
		))

	return to_add

///Handles replacing all of the bodyparts with their species version during set_species()
/datum/species/proc/replace_body(mob/living/carbon/target, datum/species/new_species)
	new_species ||= target.dna.species //If no new species is provided, assume its src.
	//Note for future: Potentionally add a new C.dna.species() to build a template species for more accurate limb replacement

	var/list/final_bodypart_overrides = new_species.bodypart_overrides.Copy()
	if((new_species.digitigrade_customization == DIGITIGRADE_OPTIONAL && target.dna.features["legs"] == DIGITIGRADE_LEGS) || new_species.digitigrade_customization == DIGITIGRADE_FORCED)
		final_bodypart_overrides[BODY_ZONE_R_LEG] = /obj/item/bodypart/leg/right/digitigrade
		final_bodypart_overrides[BODY_ZONE_L_LEG] = /obj/item/bodypart/leg/left/digitigrade

	for(var/obj/item/bodypart/old_part as anything in target.bodyparts)
		if((old_part.change_exempt_flags & BP_BLOCK_CHANGE_SPECIES) || (old_part.bodypart_flags & BODYPART_IMPLANTED))
			continue

		var/path = final_bodypart_overrides?[old_part.body_zone]
		var/obj/item/bodypart/new_part
		if(path)
			new_part = new path()
			new_part.replace_limb(target, TRUE)
			new_part.update_limb(is_creating = TRUE)
			new_part.set_initial_damage(old_part.brute_dam, old_part.burn_dam)
		qdel(old_part)

/// Creates body parts for the target completely from scratch based on the species
/datum/species/proc/create_fresh_body(mob/living/carbon/target)
	target.create_bodyparts(bodypart_overrides)

/**
 * Checks if the species has a head with these head flags, by default.
 * Admittedly, this is a very weird and seemingly redundant proc, but it
 * gets used by some preferences (such as hair style) to determine whether
 * or not they are accessible.
 **/
/datum/species/proc/check_head_flags(check_flags = NONE)
	var/obj/item/bodypart/head/fake_head = bodypart_overrides[BODY_ZONE_HEAD]
	return (initial(fake_head.head_flags) & check_flags)
