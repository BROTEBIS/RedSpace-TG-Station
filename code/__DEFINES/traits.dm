#define SIGNAL_ADDTRAIT(trait_ref) "addtrait [trait_ref]"
#define SIGNAL_REMOVETRAIT(trait_ref) "removetrait [trait_ref]"

// trait accessor defines
#define ADD_TRAIT(target, trait, source) \
	do { \
		var/list/_L; \
		if (!target._status_traits) { \
			target._status_traits = list(); \
			_L = target._status_traits; \
			_L[trait] = list(source); \
			SEND_SIGNAL(target, SIGNAL_ADDTRAIT(trait), trait); \
		} else { \
			_L = target._status_traits; \
			if (_L[trait]) { \
				_L[trait] |= list(source); \
			} else { \
				_L[trait] = list(source); \
				SEND_SIGNAL(target, SIGNAL_ADDTRAIT(trait), trait); \
			} \
		} \
	} while (0)
#define REMOVE_TRAIT(target, trait, sources) \
	do { \
		var/list/_L = target._status_traits; \
		var/list/_S; \
		if (sources && !islist(sources)) { \
			_S = list(sources); \
		} else { \
			_S = sources\
		}; \
		if (_L?[trait]) { \
			for (var/_T in _L[trait]) { \
				if ((!_S && (_T != ROUNDSTART_TRAIT)) || (_T in _S)) { \
					_L[trait] -= _T \
				} \
			};\
			if (!length(_L[trait])) { \
				_L -= trait; \
				SEND_SIGNAL(target, SIGNAL_REMOVETRAIT(trait), trait); \
			}; \
			if (!length(_L)) { \
				target._status_traits = null \
			}; \
		} \
	} while (0)
#define REMOVE_TRAIT_NOT_FROM(target, trait, sources) \
	do { \
		var/list/_traits_list = target._status_traits; \
		var/list/_sources_list; \
		if (sources && !islist(sources)) { \
			_sources_list = list(sources); \
		} else { \
			_sources_list = sources\
		}; \
		if (_traits_list?[trait]) { \
			for (var/_trait_source in _traits_list[trait]) { \
				if (!(_trait_source in _sources_list)) { \
					_traits_list[trait] -= _trait_source \
				} \
			};\
			if (!length(_traits_list[trait])) { \
				_traits_list -= trait; \
				SEND_SIGNAL(target, SIGNAL_REMOVETRAIT(trait), trait); \
			}; \
			if (!length(_traits_list)) { \
				target._status_traits = null \
			}; \
		} \
	} while (0)
#define REMOVE_TRAITS_NOT_IN(target, sources) \
	do { \
		var/list/_L = target._status_traits; \
		var/list/_S = sources; \
		if (_L) { \
			for (var/_T in _L) { \
				_L[_T] &= _S;\
				if (!length(_L[_T])) { \
					_L -= _T; \
					SEND_SIGNAL(target, SIGNAL_REMOVETRAIT(_T), _T); \
					}; \
				};\
			if (!length(_L)) { \
				target._status_traits = null\
			};\
		}\
	} while (0)

#define REMOVE_TRAITS_IN(target, sources) \
	do { \
		var/list/_L = target._status_traits; \
		var/list/_S = sources; \
		if (sources && !islist(sources)) { \
			_S = list(sources); \
		} else { \
			_S = sources\
		}; \
		if (_L) { \
			for (var/_T in _L) { \
				_L[_T] -= _S;\
				if (!length(_L[_T])) { \
					_L -= _T; \
					SEND_SIGNAL(target, SIGNAL_REMOVETRAIT(_T)); \
					}; \
				};\
			if (!length(_L)) { \
				target._status_traits = null\
			};\
		}\
	} while (0)

#define HAS_TRAIT(target, trait) (target._status_traits?[trait] ? TRUE : FALSE)
#define HAS_TRAIT_FROM(target, trait, source) (HAS_TRAIT(target, trait) && (source in target._status_traits[trait]))
#define HAS_TRAIT_FROM_ONLY(target, trait, source) (HAS_TRAIT(target, trait) && (source in target._status_traits[trait]) && (length(target._status_traits[trait]) == 1))
#define HAS_TRAIT_NOT_FROM(target, trait, source) (HAS_TRAIT(target, trait) && (length(target._status_traits[trait] - source) > 0))
/// Returns a list of trait sources for this trait. Only useful for wacko cases and internal futzing
/// You should not be using this
#define GET_TRAIT_SOURCES(target, trait) (target._status_traits?[trait] || list())
/// Returns the amount of sources for a trait. useful if you don't want to have a "thing counter" stuck around all the time
#define COUNT_TRAIT_SOURCES(target, trait) length(GET_TRAIT_SOURCES(target, trait))
/// A simple helper for checking traits in a mob's mind
#define HAS_MIND_TRAIT(target, trait) (HAS_TRAIT(target, trait) || (target.mind ? HAS_TRAIT(target.mind, trait) : FALSE))

/*
Remember to update _globalvars/traits.dm if you're adding/removing/renaming traits.
*/

//mob traits
/// Forces the user to stay unconscious.
#define TRAIT_KNOCKEDOUT "knockedout"
/// Prevents voluntary movement.
#define TRAIT_IMMOBILIZED "immobilized"
/// Prevents voluntary standing or staying up on its own.
#define TRAIT_FLOORED "floored"
/// Forces user to stay standing
#define TRAIT_FORCED_STANDING "forcedstanding"
/// Prevents usage of manipulation appendages (picking, holding or using items, manipulating storage).
#define TRAIT_HANDS_BLOCKED "handsblocked"
/// Inability to access UI hud elements. Turned into a trait from [MOBILITY_UI] to be able to track sources.
#define TRAIT_UI_BLOCKED "uiblocked"
/// Inability to pull things. Turned into a trait from [MOBILITY_PULL] to be able to track sources.
#define TRAIT_PULL_BLOCKED "pullblocked"
/// Abstract condition that prevents movement if being pulled and might be resisted against. Handcuffs and straight jackets, basically.
#define TRAIT_RESTRAINED "restrained"
/// Apply this to make a mob not dense, and remove it when you want it to no longer make them undense, other sorces of undesity will still apply. Always define a unique source when adding a new instance of this!
#define TRAIT_UNDENSE "undense"
/// Expands our FOV by 30 degrees if restricted
#define TRAIT_EXPANDED_FOV "expanded_fov"
/// Doesn't miss attacks
#define TRAIT_PERFECT_ATTACKER "perfect_attacker"
///Recolored by item/greentext
#define TRAIT_GREENTEXT_CURSED "greentext_curse"
#define TRAIT_INCAPACITATED "incapacitated"
/// In some kind of critical condition. Is able to succumb.
#define TRAIT_CRITICAL_CONDITION "critical-condition"
/// Whitelist for mobs that can read or write
#define TRAIT_LITERATE "literate"
/// Blacklist for mobs that can't read or write
#define TRAIT_ILLITERATE "illiterate"
/// Mute. Can't talk.
#define TRAIT_MUTE "mute"
/// Softspoken. Always whisper.
#define TRAIT_SOFTSPOKEN "softspoken"
/// Gibs on death and slips like ice.
#define TRAIT_CURSED "cursed"
/// Emotemute. Can't... emote.
#define TRAIT_EMOTEMUTE "emotemute"
#define TRAIT_DEAF "deaf"
#define TRAIT_FAT "fat"
#define TRAIT_HUSK "husk"
///Blacklisted from being revived via defibrilator
#define TRAIT_DEFIB_BLACKLISTED "defib_blacklisted"
#define TRAIT_BADDNA "baddna"
#define TRAIT_CLUMSY "clumsy"
/// Trait that means you are capable of holding items in some form
#define TRAIT_CAN_HOLD_ITEMS "can_hold_items"
/// Trait which lets you clamber over a barrier
#define TRAIT_FENCE_CLIMBER "can_climb_fences"
/// means that you can't use weapons with normal trigger guards.
#define TRAIT_CHUNKYFINGERS "chunkyfingers"
#define TRAIT_CHUNKYFINGERS_IGNORE_BATON "chunkyfingers_ignore_baton"
/// Allows you to mine with your bare hands
#define TRAIT_FIST_MINING "fist_mining"
#define TRAIT_DUMB "dumb"
/// Whether a mob is dexterous enough to use machines and certain items or not.
#define TRAIT_ADVANCEDTOOLUSER "advancedtooluser"
// Antagonizes the above.
#define TRAIT_DISCOORDINATED_TOOL_USER "discoordinated_tool_user"
#define TRAIT_PACIFISM "pacifism"
#define TRAIT_IGNORESLOWDOWN "ignoreslow"
#define TRAIT_IGNOREDAMAGESLOWDOWN "ignoredamageslowdown"
/// Makes it so the mob can use guns regardless of tool user status
#define TRAIT_GUN_NATURAL "gunnatural"
/// Causes death-like unconsciousness
#define TRAIT_DEATHCOMA "deathcoma"
/// The mob has the stasis effect.
/// Does nothing on its own, applied via status effect.
#define TRAIT_STASIS "in_stasis"
/// Makes the owner appear as dead to most forms of medical examination
#define TRAIT_FAKEDEATH "fakedeath"
#define TRAIT_DISFIGURED "disfigured"
/// "Magic" trait that blocks the mob from moving or interacting with anything. Used for transient stuff like mob transformations or incorporality in special cases.
/// Will block movement, `Life()` (!!!), and other stuff based on the mob.
#define TRAIT_NO_TRANSFORM "block_transformations"
/// Tracks whether we're gonna be a baby alien's mummy.
#define TRAIT_XENO_HOST "xeno_host"
/// This mob is immune to stun causing status effects and stamcrit.
/// Prefer to use [/mob/living/proc/check_stun_immunity] over checking for this trait exactly.
#define TRAIT_STUNIMMUNE "stun_immunity"
#define TRAIT_BATON_RESISTANCE "baton_resistance"
/// Anti Dual-baton cooldown bypass exploit.
#define TRAIT_IWASBATONED "iwasbatoned"
#define TRAIT_SLEEPIMMUNE "sleep_immunity"
#define TRAIT_PUSHIMMUNE "push_immunity"
/// Are we immune to shocks?
#define TRAIT_SHOCKIMMUNE "shock_immunity"
/// Are we immune to specifically tesla / SM shocks?
#define TRAIT_TESLA_SHOCKIMMUNE "tesla_shock_immunity"
#define TRAIT_AIRLOCK_SHOCKIMMUNE "airlock_shock_immunity"
/// Is this atom being actively shocked? Used to prevent repeated shocks.
#define TRAIT_BEING_SHOCKED "shocked"
#define TRAIT_STABLEHEART "stable_heart"
/// Prevents you from leaving your corpse
#define TRAIT_CORPSELOCKED "corpselocked"
#define TRAIT_STABLELIVER "stable_liver"
#define TRAIT_VATGROWN "vatgrown"
#define TRAIT_RESISTHEAT "resist_heat"
///For when you've gotten a power from a dna vault
#define TRAIT_USED_DNA_VAULT "used_dna_vault"
/// For when you want to be able to touch hot things, but still want fire to be an issue.
#define TRAIT_RESISTHEATHANDS "resist_heat_handsonly"
#define TRAIT_RESISTCOLD "resist_cold"
#define TRAIT_RESISTHIGHPRESSURE "resist_high_pressure"
#define TRAIT_RESISTLOWPRESSURE "resist_low_pressure"
/// This human is immune to the effects of being exploded. (ex_act)
#define TRAIT_BOMBIMMUNE "bomb_immunity"
/// Immune to being irradiated
#define TRAIT_RADIMMUNE "rad_immunity"
/// This mob won't get gibbed by nukes going off
#define TRAIT_NUKEIMMUNE "nuke_immunity"
/// Can't be given viruses
#define TRAIT_VIRUSIMMUNE "virus_immunity"
/// Reduces the chance viruses will spread to this mob, and if the mob has a virus, slows its advancement
#define TRAIT_VIRUS_RESISTANCE "virus_resistance"
#define TRAIT_GENELESS "geneless"
#define TRAIT_PIERCEIMMUNE "pierce_immunity"
#define TRAIT_NODISMEMBER "dismember_immunity"
#define TRAIT_NOFIRE "nonflammable"
#define TRAIT_NOFIRE_SPREAD "no_fire_spreading"
/// Prevents plasmamen from self-igniting if only their helmet is missing
#define TRAIT_NOSELFIGNITION_HEAD_ONLY "no_selfignition_head_only"
#define TRAIT_NOGUNS "no_guns"
/// Species with this trait are genderless
#define TRAIT_AGENDER "agender"
/// Species with this trait have a blood clan mechanic
#define TRAIT_BLOOD_CLANS "blood_clans"
/// Species with this trait have markings (this SUCKS, remove this later in favor of bodypart overlays)
#define TRAIT_HAS_MARKINGS "has_markings"
/// Species with this trait use skin tones for coloration
#define TRAIT_USES_SKINTONES "uses_skintones"
/// Species with this trait use mutant colors for coloration
#define TRAIT_MUTANT_COLORS "mutcolors"
/// Species with this trait have mutant colors that cannot be chosen by the player, nor altered ingame by external means
#define TRAIT_FIXED_MUTANT_COLORS "fixed_mutcolors"
/// Species with this trait have a haircolor that cannot be chosen by the player, nor altered ingame by external means
#define TRAIT_FIXED_HAIRCOLOR "fixed_haircolor"
/// Humans with this trait won't get bloody hands, nor bloody feet
#define TRAIT_NO_BLOOD_OVERLAY "no_blood_overlay"
/// Humans with this trait cannot have underwear
#define TRAIT_NO_UNDERWEAR "no_underwear"
/// This carbon doesn't show an overlay when they have no brain
#define TRAIT_NO_DEBRAIN_OVERLAY "no_debrain_overlay"
/// Humans with this trait cannot get augmentation surgery
#define TRAIT_NO_AUGMENTS "no_augments"
/// This carbon doesn't get hungry
#define TRAIT_NOHUNGER "no_hunger"
/// This carbon doesn't bleed
#define TRAIT_NOBLOOD "noblood"
/// This just means that the carbon will always have functional liverless metabolism
#define TRAIT_LIVERLESS_METABOLISM "liverless_metabolism"
/// Humans with this trait cannot be turned into zombies
#define TRAIT_NO_ZOMBIFY "no_zombify"
/// Carbons with this trait can't have their DNA copied by diseases nor changelings
#define TRAIT_NO_DNA_COPY "no_dna_copy"
/// Carbons with this trait can eat blood to regenerate their own blood volume, instead of injecting it
#define TRAIT_DRINKS_BLOOD "drinks_blood"
/// Mob is immune to clone (cellular) damage
#define TRAIT_NOCLONELOSS "no_cloneloss"
/// Mob is immune to toxin damage
#define TRAIT_TOXIMMUNE "toxin_immune"
/// Mob is immune to oxygen damage, does not need to breathe
#define TRAIT_NOBREATH "no_breath"
/// Mob is currently disguised as something else (like a morph being another mob or an object). Holds a reference to the thing that applied the trait.
#define TRAIT_DISGUISED "disguised"
/// Use when you want a mob to be able to metabolize plasma temporarily (e.g. plasma fixation disease symptom)
#define TRAIT_PLASMA_LOVER_METABOLISM "plasma_lover_metabolism"
#define TRAIT_EASYDISMEMBER "easy_dismember"
#define TRAIT_LIMBATTACHMENT "limb_attach"
#define TRAIT_NOLIMBDISABLE "no_limb_disable"
#define TRAIT_EASILY_WOUNDED "easy_limb_wound"
#define TRAIT_HARDLY_WOUNDED "hard_limb_wound"
#define TRAIT_NEVER_WOUNDED "never_wounded"
#define TRAIT_TOXINLOVER "toxinlover"
/// Doesn't get overlays from being in critical.
#define TRAIT_NOCRITOVERLAY "no_crit_overlay"
/// Gets a mood boost from being in the hideout.
#define TRAIT_VAL_CORRIN_MEMBER "val_corrin_member"
/// reduces the use time of syringes, pills, patches and medigels but only when using on someone
#define TRAIT_FASTMED "fast_med_use"
/// The mob is holy and resistance to cult magic
#define TRAIT_HOLY "holy"
/// This mob is antimagic, and immune to spells / cannot cast spells
#define TRAIT_ANTIMAGIC "anti_magic"
/// This allows a person who has antimagic to cast spells without getting blocked
#define TRAIT_ANTIMAGIC_NO_SELFBLOCK "anti_magic_no_selfblock"
/// This mob recently blocked magic with some form of antimagic
#define TRAIT_RECENTLY_BLOCKED_MAGIC "recently_blocked_magic"
/// The user can do things like use magic staffs without penalty
#define TRAIT_MAGICALLY_GIFTED "magically_gifted"
/// This object innately spawns with fantasy variables already applied (the magical component is given to it on initialize), and thus we never want to give it the component again.
#define TRAIT_INNATELY_FANTASTICAL_ITEM "innately_fantastical_item"
#define TRAIT_DEPRESSION "depression"
#define TRAIT_BLOOD_DEFICIENCY "blood_deficiency"
#define TRAIT_JOLLY "jolly"
#define TRAIT_NOCRITDAMAGE "no_crit"
///Added to mob or mind, changes the icons of the fish shown in the minigame UI depending on the possible reward.
#define TRAIT_REVEAL_FISH "reveal_fish"

/// Stops the mob from slipping on water, or banana peels, or pretty much anything that doesn't have [GALOSHES_DONT_HELP] set
#define TRAIT_NO_SLIP_WATER "noslip_water"
/// Stops the mob from slipping on permafrost ice (not any other ice) (but anything with [SLIDE_ICE] set)
#define TRAIT_NO_SLIP_ICE "noslip_ice"
/// Stop the mob from sliding around from being slipped, but not the slip part.
/// DOES NOT include ice slips.
#define TRAIT_NO_SLIP_SLIDE "noslip_slide"
/// Stops all slipping and sliding from ocurring
#define TRAIT_NO_SLIP_ALL "noslip_all"

/// Unlinks gliding from movement speed, meaning that there will be a delay between movements rather than a single move movement between tiles
#define TRAIT_NO_GLIDE "no_glide"

#define TRAIT_NODEATH "nodeath"
#define TRAIT_NOHARDCRIT "nohardcrit"
#define TRAIT_NOSOFTCRIT "nosoftcrit"
#define TRAIT_MINDSHIELD "mindshield"
#define TRAIT_DISSECTED "dissected"
#define TRAIT_SURGICALLY_ANALYZED "surgically_analyzed"
/// Lets the user succumb even if they got NODEATH
#define TRAIT_SUCCUMB_OVERRIDE "succumb_override"
/// Can hear observers
#define TRAIT_SIXTHSENSE "sixth_sense"
#define TRAIT_FEARLESS "fearless"
/// Ignores darkness for hearing
#define TRAIT_HEAR_THROUGH_DARKNESS "hear_through_darkness"
/// These are used for brain-based paralysis, where replacing the limb won't fix it
#define TRAIT_PARALYSIS_L_ARM "para-l-arm"
#define TRAIT_PARALYSIS_R_ARM "para-r-arm"
#define TRAIT_PARALYSIS_L_LEG "para-l-leg"
#define TRAIT_PARALYSIS_R_LEG "para-r-leg"
#define TRAIT_CANNOT_OPEN_PRESENTS "cannot-open-presents"
#define TRAIT_PRESENT_VISION "present-vision"
#define TRAIT_DISK_VERIFIER "disk-verifier"
#define TRAIT_NOMOBSWAP "no-mob-swap"
/// Can examine IDs to see if they are roundstart.
#define TRAIT_ID_APPRAISER "id_appraiser"
/// Gives us turf, mob and object vision through walls
#define TRAIT_XRAY_VISION "xray_vision"
/// Gives us mob vision through walls and slight night vision
#define TRAIT_THERMAL_VISION "thermal_vision"
/// Gives us turf vision through walls and slight night vision
#define TRAIT_MESON_VISION "meson_vision"
/// Gives us Night vision
#define TRAIT_TRUE_NIGHT_VISION "true_night_vision"
/// Negates our gravity, letting us move normally on floors in 0-g
#define TRAIT_NEGATES_GRAVITY "negates_gravity"
/// We are ignoring gravity
#define TRAIT_IGNORING_GRAVITY "ignores_gravity"
/// Sources for TRAIT_IGNORING_GRAVITY
#define IGNORING_GRAVITY_NEGATION "ignoring_gravity_negation"
/// We have some form of forced gravity acting on us
#define TRAIT_FORCED_GRAVITY "forced_gravity"
/// Makes whispers clearly heard from seven tiles away, the full hearing range
#define TRAIT_GOOD_HEARING "good_hearing"
/// Allows you to hear speech through walls
#define TRAIT_XRAY_HEARING "xray_hearing"

/// Lets us scan reagents
#define TRAIT_REAGENT_SCANNER "reagent_scanner"
/// Lets us scan machine parts and tech unlocks
#define TRAIT_RESEARCH_SCANNER "research_scanner"
/// Can weave webs into cloth
#define TRAIT_WEB_WEAVER "web_weaver"
/// Can navigate the web without getting stuck
#define TRAIT_WEB_SURFER "web_surfer"
/// A web is being spun on this turf presently
#define TRAIT_SPINNING_WEB_TURF "spinning_web_turf"
#define TRAIT_ABDUCTOR_TRAINING "abductor-training"
#define TRAIT_ABDUCTOR_SCIENTIST_TRAINING "abductor-scientist-training"
#define TRAIT_SURGEON "surgeon"
#define TRAIT_STRONG_GRABBER "strong_grabber"
#define TRAIT_SOOTHED_THROAT "soothed-throat"
#define TRAIT_BOOZE_SLIDER "booze-slider"
/// We place people into a fireman carry quicker than standard
#define TRAIT_QUICK_CARRY "quick-carry"
/// We place people into a fireman carry especially quickly compared to quick_carry
#define TRAIT_QUICKER_CARRY "quicker-carry"
#define TRAIT_QUICK_BUILD "quick-build"
/// We can handle 'dangerous' plants in botany safely
#define TRAIT_PLANT_SAFE "plant_safe"
/// Prevents the overlay from nearsighted
#define TRAIT_NEARSIGHTED_CORRECTED "fixes_nearsighted"
#define TRAIT_UNINTELLIGIBLE_SPEECH "unintelligible-speech"
#define TRAIT_UNSTABLE "unstable"
#define TRAIT_OIL_FRIED "oil_fried"
#define TRAIT_MEDICAL_HUD "med_hud"
#define TRAIT_SECURITY_HUD "sec_hud"
/// for something granting you a diagnostic hud
#define TRAIT_DIAGNOSTIC_HUD "diag_hud"
/// Is a medbot healing you
#define TRAIT_MEDIBOTCOMINGTHROUGH "medbot"
#define TRAIT_PASSTABLE "passtable"
/// Makes you immune to flashes
#define TRAIT_NOFLASH "noflash"
/// prevents xeno huggies implanting skeletons
#define TRAIT_XENO_IMMUNE "xeno_immune"
/// Allows the species to equip items that normally require a jumpsuit without having one equipped. Used by golems.
#define TRAIT_NO_JUMPSUIT "no_jumpsuit"
#define TRAIT_NAIVE "naive"
/// always detect storms on icebox
#define TRAIT_DETECT_STORM "detect_storm"
#define TRAIT_PRIMITIVE "primitive"
#define TRAIT_GUNFLIP "gunflip"
/// Increases chance of getting special traumas, makes them harder to cure
#define TRAIT_SPECIAL_TRAUMA_BOOST "special_trauma_boost"
#define TRAIT_SPACEWALK "spacewalk"
/// Sanity trait to keep track of when we're in hyperspace and add the appropriate element if we werent
#define TRAIT_HYPERSPACED "hyperspaced"
///Gives the movable free hyperspace movement without being pulled during shuttle transit
#define TRAIT_FREE_HYPERSPACE_MOVEMENT "free_hyperspace_movement"
///Lets the movable move freely in the soft-cordon area of transit space, which would otherwise teleport them away just before they got to see the true cordon
#define TRAIT_FREE_HYPERSPACE_SOFTCORDON_MOVEMENT "free_hyperspace_softcordon_movement"
///Deletes the object upon being dumped into space, usually from exiting hyperspace. Useful if you're spawning in a lot of stuff for hyperspace events that dont need to flood the entire game
#define TRAIT_DEL_ON_SPACE_DUMP "del_on_hyperspace_leave"
/// We can walk up or around cliffs, or at least we don't fall off of it
#define TRAIT_CLIFF_WALKER "cliff_walker"
/// Gets double arcade prizes
#define TRAIT_GAMERGOD "gamer-god"
#define TRAIT_GIANT "giant"
#define TRAIT_DWARF "dwarf"
/// makes your footsteps completely silent
#define TRAIT_SILENT_FOOTSTEPS "silent_footsteps"
/// hnnnnnnnggggg..... you're pretty good....
#define TRAIT_NICE_SHOT "nice_shot"
/// prevents the damage done by a brain tumor
#define TRAIT_TUMOR_SUPPRESSED "brain_tumor_suppressed"
/// Prevents hallucinations from the hallucination brain trauma (RDS)
#define TRAIT_RDS_SUPPRESSED "rds_suppressed"
/// overrides the update_fire proc to always add fire (for lava)
#define TRAIT_PERMANENTLY_ONFIRE "permanently_onfire"
/// Indicates if the mob is currently speaking with sign language
#define TRAIT_SIGN_LANG "sign_language"
/// This mob is able to use sign language over the radio.
#define TRAIT_CAN_SIGN_ON_COMMS "can_sign_on_comms"
/// nobody can use martial arts on this mob
#define TRAIT_MARTIAL_ARTS_IMMUNE "martial_arts_immune"
/// Immune to being afflicted by time stop (spell)
#define TRAIT_TIME_STOP_IMMUNE "time_stop_immune"
/// Revenants draining you only get a very small benefit.
#define TRAIT_WEAK_SOUL "weak_soul"
/// This mob has no soul
#define TRAIT_NO_SOUL "no_soul"
/// Prevents mob from riding mobs when buckled onto something
#define TRAIT_CANT_RIDE "cant_ride"
/// Prevents a mob from being unbuckled, currently only used to prevent people from falling over on the tram
#define TRAIT_CANNOT_BE_UNBUCKLED "cannot_be_unbuckled"
/// from heparin and nitrous oxide, makes open bleeding wounds rapidly spill more blood
#define TRAIT_BLOODY_MESS "bloody_mess"
/// from coagulant reagents, this doesn't affect the bleeding itself but does affect the bleed warning messages
#define TRAIT_COAGULATING "coagulating"
/// From anti-convulsant medication against seizures.
#define TRAIT_ANTICONVULSANT "anticonvulsant"
/// The holder of this trait has antennae or whatever that hurt a ton when noogied
#define TRAIT_ANTENNAE "antennae"
/// Blowing kisses actually does damage to the victim
#define TRAIT_KISS_OF_DEATH "kiss_of_death"
/// Used to activate french kissing
#define TRAIT_GARLIC_BREATH "kiss_of_garlic_death"
/// Addictions don't tick down, basically they're permanently addicted
#define TRAIT_HOPELESSLY_ADDICTED "hopelessly_addicted"
/// This mob has a cult halo.
#define TRAIT_CULT_HALO "cult_halo"
/// Their eyes glow an unnatural red colour. Currently used to set special examine text on humans. Does not guarantee the mob's eyes are coloured red, nor that there is any visible glow on their character sprite.
#define TRAIT_UNNATURAL_RED_GLOWY_EYES "unnatural_red_glowy_eyes"
/// Their eyes are bloodshot. Currently used to set special examine text on humans. Examine text is overridden by TRAIT_UNNATURAL_RED_GLOWY_EYES.
#define TRAIT_BLOODSHOT_EYES "bloodshot_eyes"
/// This mob should never close UI even if it doesn't have a client
#define TRAIT_PRESERVE_UI_WITHOUT_CLIENT "preserve_ui_without_client"
/// Lets the mob use flight potions
#define TRAIT_CAN_USE_FLIGHT_POTION "can_use_flight_potion"
/// This mob overrides certian SSlag_switch measures with this special trait
#define TRAIT_BYPASS_MEASURES "bypass_lagswitch_measures"
/// Someone can safely be attacked with honorbound with ONLY a combat mode check, the trait is assuring holding a weapon and hitting won't hurt them..
#define TRAIT_ALLOWED_HONORBOUND_ATTACK "allowed_honorbound_attack"
/// The user is sparring
#define TRAIT_SPARRING "sparring"
/// The user is currently challenging an elite mining mob. Prevents him from challenging another until he's either lost or won.
#define TRAIT_ELITE_CHALLENGER "elite_challenger"
/// For living mobs. It signals that the mob shouldn't have their data written in an external json for persistence.
#define TRAIT_DONT_WRITE_MEMORY "dont_write_memory"
/// This mob can be painted with the spraycan
#define TRAIT_SPRAY_PAINTABLE "spray_paintable"
/// This atom can ignore the "is on a turf" check for simple AI datum attacks, allowing them to attack from bags or lockers as long as any other conditions are met
#define TRAIT_AI_BAGATTACK "bagattack"
/// This mobs bodyparts are invisible but still clickable.
#define TRAIT_INVISIBLE_MAN "invisible_man"
/// Don't draw external organs/species features like wings, horns, frills and stuff
#define TRAIT_HIDE_EXTERNAL_ORGANS "hide_external_organs"
///When people are floating from zero-grav or something, we can move around freely!
#define TRAIT_FREE_FLOAT_MOVEMENT "free_float_movement"
// You can stare into the abyss, but it does not stare back.
// You're immune to the hallucination effect of the supermatter, either
// through force of will, or equipment. Present on /mob or /datum/mind
#define TRAIT_MADNESS_IMMUNE "supermatter_madness_immune"
// You can stare into the abyss, and it turns pink.
// Being close enough to the supermatter makes it heal at higher temperatures
// and emit less heat. Present on /mob or /datum/mind
#define TRAIT_SUPERMATTER_SOOTHER "supermatter_soother"

/// Trait added when a revenant is visible.
#define TRAIT_REVENANT_REVEALED "revenant_revealed"
/// Trait added when a revenant has been inhibited (typically by the bane of a holy weapon)
#define TRAIT_REVENANT_INHIBITED "revenant_inhibited"

/// Trait which prevents you from becoming overweight
#define TRAIT_NOFAT "cant_get_fat"

/// Trait which allows you to eat rocks
#define TRAIT_ROCK_EATER "rock_eater"
/// Trait which allows you to gain bonuses from consuming rocks
#define TRAIT_ROCK_METAMORPHIC "rock_metamorphic"

/// `do_teleport` will not allow this atom to teleport
#define TRAIT_NO_TELEPORT "no-teleport"
/// This atom is a secluded location, which is counted as out of bounds.
/// Anything that enters this atom's contents should react if it wants to stay in bounds.
#define TRAIT_SECLUDED_LOCATION "secluded_loc"

/// Trait used by fugu glands to avoid double buffing
#define TRAIT_FUGU_GLANDED "fugu_glanded"

/// When someone with this trait fires a ranged weapon, their fire delays and click cooldowns are halved
#define TRAIT_DOUBLE_TAP "double_tap"

/// Trait applied to [/datum/mind] to stop someone from using the cursed hot springs to polymorph more than once.
#define TRAIT_HOT_SPRING_CURSED "hot_spring_cursed"

/// If something has been engraved/cannot be engraved
#define TRAIT_NOT_ENGRAVABLE "not_engravable"

/// Whether or not orbiting is blocked or not
#define TRAIT_ORBITING_FORBIDDEN "orbiting_forbidden"
/// Trait applied to mob/living to mark that spiders should not gain further enriched eggs from eating their corpse.
#define TRAIT_SPIDER_CONSUMED "spider_consumed"
/// Whether we're sneaking, from the creature sneak ability.
#define TRAIT_SNEAK "sneaking_creatures"

/// Item still allows you to examine items while blind and actively held.
#define TRAIT_BLIND_TOOL "blind_tool"

/// The person with this trait always appears as 'unknown'.
#define TRAIT_UNKNOWN "unknown"

/// If the mob has this trait and die, their bomb implant doesn't detonate automatically. It must be consciously activated.
#define TRAIT_PREVENT_IMPLANT_AUTO_EXPLOSION "prevent_implant_auto_explosion"

/// If applied to a mob, nearby dogs will have a small chance to nonharmfully harass said mob
#define TRAIT_HATED_BY_DOGS "hated_by_dogs"
/// Mobs with this trait will not be immobilized when held up
#define TRAIT_NOFEAR_HOLDUPS "no_fear_holdup"
/// Mob has gotten an armor buff from adamantine extract
#define TRAIT_ADAMANTINE_EXTRACT_ARMOR "adamantine_extract_armor"
/// Mobs with this trait won't be able to dual wield guns.
#define TRAIT_NO_GUN_AKIMBO "no_gun_akimbo"

/// Projectile with this trait will always hit the defined zone of a struck living mob.
#define TRAIT_ALWAYS_HIT_ZONE "always_hit_zone"

/// Mobs with this trait do care about a few grisly things, such as digging up graves. They also really do not like bringing people back to life or tending wounds, but love autopsies and amputations.
#define TRAIT_MORBID "morbid"

/// Whether or not the user is in a MODlink call, prevents making more calls
#define TRAIT_IN_CALL "in_call"

// METABOLISMS
// Various jobs on the station have historically had better reactions
// to various drinks and foodstuffs. Security liking donuts is a classic
// example. Through years of training/abuse, their livers have taken
// a liking to those substances. Steal a sec officer's liver, eat donuts good.

// These traits are applied to /obj/item/organ/internal/liver
#define TRAIT_LAW_ENFORCEMENT_METABOLISM "law_enforcement_metabolism"
#define TRAIT_CULINARY_METABOLISM "culinary_metabolism"
#define TRAIT_COMEDY_METABOLISM "comedy_metabolism"
#define TRAIT_MEDICAL_METABOLISM "medical_metabolism"
#define TRAIT_ENGINEER_METABOLISM "engineer_metabolism"
#define TRAIT_ROYAL_METABOLISM "royal_metabolism"
#define TRAIT_PRETENDER_ROYAL_METABOLISM "pretender_royal_metabolism"
#define TRAIT_BALLMER_SCIENTIST "ballmer_scientist"
#define TRAIT_MAINTENANCE_METABOLISM "maintenance_metabolism"
#define TRAIT_CORONER_METABOLISM "coroner_metabolism"

//LUNG TRAITS
/// Lungs always breathe normally when in vacuum/space.
#define TRAIT_SPACEBREATHING "spacebreathing"

/// This mob can strip other mobs.
#define TRAIT_CAN_STRIP "can_strip"
/// Can use the nuclear device's UI, regardless of a lack of hands
#define TRAIT_CAN_USE_NUKE "can_use_nuke"

// If present on a mob or mobmind, allows them to "suplex" an immovable rod
// turning it into a glorified potted plant, and giving them an
// achievement. Can also be used on rod-form wizards.
// Normally only present in the mind of a Research Director.
#define TRAIT_ROD_SUPLEX "rod_suplex"
/// The mob has an active mime vow of silence, and thus is unable to speak and has other mime things going on
#define TRAIT_MIMING "miming"

/// This mob is phased out of reality from magic, either a jaunt or rod form
#define TRAIT_MAGICALLY_PHASED "magically_phased"

//SKILLS
#define TRAIT_UNDERWATER_BASKETWEAVING_KNOWLEDGE "underwater_basketweaving"
#define TRAIT_WINE_TASTER "wine_taster"
#define TRAIT_BONSAI "bonsai"
#define TRAIT_LIGHTBULB_REMOVER "lightbulb_remover"
#define TRAIT_KNOW_ROBO_WIRES "know_robo_wires"
#define TRAIT_KNOW_ENGI_WIRES "know_engi_wires"
#define TRAIT_ENTRAILS_READER "entrails_reader"
#define TRAIT_SABRAGE_PRO "sabrage_pro"
/// this skillchip trait lets you wash brains in washing machines to heal them
#define TRAIT_BRAINWASHING "brainwashing"
/// Allows chef's to chefs kiss their food, to make them with love
#define TRAIT_CHEF_KISS "chefs_kiss"

///Movement type traits for movables. See elements/movetype_handler.dm
#define TRAIT_MOVE_GROUND "move_ground"
#define TRAIT_MOVE_FLYING "move_flying"
#define TRAIT_MOVE_VENTCRAWLING "move_ventcrawling"
#define TRAIT_MOVE_FLOATING "move_floating"
#define TRAIT_MOVE_PHASING "move_phasing"
/// Disables the floating animation. See above.
#define TRAIT_NO_FLOATING_ANIM "no-floating-animation"

/// Weather immunities, also protect mobs inside them.
#define TRAIT_LAVA_IMMUNE "lava_immune" //Used by lava turfs and The Floor Is Lava.
#define TRAIT_ASHSTORM_IMMUNE "ashstorm_immune"
#define TRAIT_SNOWSTORM_IMMUNE "snowstorm_immune"
#define TRAIT_RADSTORM_IMMUNE "radstorm_immune"
#define TRAIT_VOIDSTORM_IMMUNE "voidstorm_immune"
#define TRAIT_WEATHER_IMMUNE "weather_immune" //Immune to ALL weather effects.

/// Cannot be grabbed by goliath tentacles
#define TRAIT_TENTACLE_IMMUNE "tentacle_immune"
/// Currently under the effect of overwatch
#define TRAIT_OVERWATCHED "watcher_overwatched"
/// Cannot be targetted by watcher overwatch
#define TRAIT_OVERWATCH_IMMUNE "overwatch_immune"

//non-mob traits
/// Used for limb-based paralysis, where replacing the limb will fix it.
#define TRAIT_PARALYSIS "paralysis"
/// Used for limbs.
#define TRAIT_DISABLED_BY_WOUND "disabled-by-wound"
/// This movable atom has the explosive block element
#define TRAIT_BLOCKING_EXPLOSIVES "blocking_explosives"

///Lava will be safe to cross while it has this trait.
#define TRAIT_LAVA_STOPPED "lava_stopped"
///Chasms will be safe to cross while they've this trait.
#define TRAIT_CHASM_STOPPED "chasm_stopped"
///The effects of the immerse element will be halted while this trait is present.
#define TRAIT_IMMERSE_STOPPED "immerse_stopped"
/// The effects of hyperspace drift are blocked when the tile has this trait
#define TRAIT_HYPERSPACE_STOPPED "hyperspace_stopped"

///Turf slowdown will be ignored when this trait is added to a turf.
#define TRAIT_TURF_IGNORE_SLOWDOWN "turf_ignore_slowdown"
///Mobs won't slip on a wet turf while it has this trait
#define TRAIT_TURF_IGNORE_SLIPPERY "turf_ignore_slippery"

/// Mobs with this trait can't send the mining shuttle console when used outside the station itself
#define TRAIT_FORBID_MINING_SHUTTLE_CONSOLE_OUTSIDE_STATION "forbid_mining_shuttle_console_outside_station"

//important_recursive_contents traits
/*
 * Used for movables that need to be updated, via COMSIG_ENTER_AREA and COMSIG_EXIT_AREA, when transitioning areas.
 * Use [/atom/movable/proc/become_area_sensitive(trait_source)] to properly enable it. How you remove it isn't as important.
 */
#define TRAIT_AREA_SENSITIVE "area-sensitive"
///every hearing sensitive atom has this trait
#define TRAIT_HEARING_SENSITIVE "hearing_sensitive"
///every object that is currently the active storage of some client mob has this trait
#define TRAIT_ACTIVE_STORAGE "active_storage"

/// Climbable trait, given and taken by the climbable element when added or removed. Exists to be easily checked via HAS_TRAIT().
#define TRAIT_CLIMBABLE "trait_climbable"

/// Used by the honkspam element to avoid spamming the sound. Amusing considering its name.
#define TRAIT_HONKSPAMMING "trait_honkspamming"

///Used for managing KEEP_TOGETHER in [/atom/var/appearance_flags]
#define TRAIT_KEEP_TOGETHER "keep-together"

///Marks the item as having been transmuted. Functionally blacklists the item from being recycled or sold for materials.
#define TRAIT_MAT_TRANSMUTED "transmuted"

// cargo traits
///If the item will block the cargo shuttle from flying to centcom
#define TRAIT_BANNED_FROM_CARGO_SHUTTLE "banned_from_cargo_shuttle"
///If the item's contents are immune to the missing item manifest error
#define TRAIT_NO_MISSING_ITEM_ERROR "no_missing_item_error"

///SSeconomy trait, if the market is crashing and people can't withdraw credits from ID cards.
#define TRAIT_MARKET_CRASHING "market_crashing"

// item traits
#define TRAIT_NODROP "nodrop"
/// cannot be inserted in a storage.
#define TRAIT_NO_STORAGE_INSERT "no_storage_insert"
/// Visible on t-ray scanners if the atom/var/level == 1
#define TRAIT_T_RAY_VISIBLE "t-ray-visible"
/// If this item's been grilled
#define TRAIT_FOOD_GRILLED "food_grilled"
/// If this item's been fried
#define TRAIT_FOOD_FRIED "food_fried"
/// This is a silver slime created item
#define TRAIT_FOOD_SILVER "food_silver"
/// If this item's been made by a chef instead of being map-spawned or admin-spawned or such
#define TRAIT_FOOD_CHEF_MADE "food_made_by_chef"
/// The items needs two hands to be carried
#define TRAIT_NEEDS_TWO_HANDS "needstwohands"
/// Can't be catched when thrown
#define TRAIT_UNCATCHABLE "uncatchable"
/// Fish in this won't die
#define TRAIT_FISH_SAFE_STORAGE "fish_case"
/// Stuff that can go inside fish cases
#define TRAIT_FISH_CASE_COMPATIBILE "fish_case_compatibile"
/// If the item can be used as a bit.
#define TRAIT_FISHING_BAIT "fishing_bait"
/// The quality of the bait. It influences odds of catching fish
#define TRAIT_BASIC_QUALITY_BAIT "baic_quality_bait"
#define TRAIT_GOOD_QUALITY_BAIT "good_quality_bait"
#define TRAIT_GREAT_QUALITY_BAIT "great_quality_bait"
/// Baits with this trait will ignore bait preferences and related fish traits.
#define OMNI_BAIT_TRAIT "omni_bait"
/// Plants that were mutated as a result of passive instability, not a mutation threshold.
#define TRAIT_PLANT_WILDMUTATE "wildmutation"
/// If you hit an APC with exposed internals with this item it will try to shock you
#define TRAIT_APC_SHOCKING "apc_shocking"
/// Properly wielded two handed item
#define TRAIT_WIELDED "wielded"
/// A transforming item that is actively extended / transformed
#define TRAIT_TRANSFORM_ACTIVE "active_transform"
/// Buckling yourself to objects with this trait won't immobilize you
#define TRAIT_NO_IMMOBILIZE "no_immobilize"
/// Prevents stripping this equipment
#define TRAIT_NO_STRIP "no_strip"
/// Disallows this item from being pricetagged with a barcode
#define TRAIT_NO_BARCODES "no_barcode"
/// Allows heretics to cast their spells.
#define TRAIT_ALLOW_HERETIC_CASTING "allow_heretic_casting"
/// Designates a heart as a living heart for a heretic.
#define TRAIT_LIVING_HEART "living_heart"
/// Prevents the same person from being chosen multiple times for kidnapping objective
#define TRAIT_HAS_BEEN_KIDNAPPED "has_been_kidnapped"
/// An item still plays its hitsound even if it has 0 force, instead of the tap
#define TRAIT_CUSTOM_TAP_SOUND "no_tap_sound"
/// Makes the feedback message when someone else is putting this item on you more noticeable
#define TRAIT_DANGEROUS_OBJECT "dangerous_object"
/// determines whether or not objects are haunted and teleport/attack randomly
#define TRAIT_HAUNTED "haunted"

//quirk traits
#define TRAIT_ALCOHOL_TOLERANCE "alcohol_tolerance"
#define TRAIT_HEAVY_DRINKER "heavy_drinker"
#define TRAIT_AGEUSIA "ageusia"
#define TRAIT_HEAVY_SLEEPER "heavy_sleeper"
#define TRAIT_NIGHT_VISION "night_vision"
#define TRAIT_LIGHT_STEP "light_step"
#define TRAIT_SPIRITUAL "spiritual"
#define TRAIT_CLOWN_ENJOYER "clown_enjoyer"
#define TRAIT_MIME_FAN "mime_fan"
#define TRAIT_VORACIOUS "voracious"
#define TRAIT_SELF_AWARE "self_aware"
#define TRAIT_FREERUNNING "freerunning"
#define TRAIT_SKITTISH "skittish"
#define TRAIT_PROSOPAGNOSIA "prosopagnosia"
#define TRAIT_TAGGER "tagger"
#define TRAIT_PHOTOGRAPHER "photographer"
#define TRAIT_MUSICIAN "musician"
#define TRAIT_LIGHT_DRINKER "light_drinker"
#define TRAIT_EMPATH "empath"
#define TRAIT_FRIENDLY "friendly"
#define TRAIT_GRABWEAKNESS "grab_weakness"
#define TRAIT_SNOB "snob"
#define TRAIT_BALD "bald"
#define TRAIT_SHAVED "shaved"
#define TRAIT_BADTOUCH "bad_touch"
#define TRAIT_EXTROVERT "extrovert"
#define TRAIT_INTROVERT "introvert"
#define TRAIT_ANXIOUS "anxious"
#define TRAIT_SMOKER "smoker"
#define TRAIT_POSTERBOY "poster_boy"
#define TRAIT_THROWINGARM "throwing_arm"
#define TRAIT_SETTLER "settler"

///if the atom has a sticker attached to it
#define TRAIT_STICKERED "stickered"

// Debug traits
/// This object has light debugging tools attached to it
#define TRAIT_LIGHTING_DEBUGGED "lighting_debugged"

/// Gives you the Shifty Eyes quirk, rarely making people who examine you think you examined them back even when you didn't
#define TRAIT_SHIFTY_EYES "shifty_eyes"

///Trait for the gamer quirk.
#define TRAIT_GAMER "gamer"

///Trait for dryable items
#define TRAIT_DRYABLE "trait_dryable"
///Trait for dried items
#define TRAIT_DRIED "trait_dried"
/// Trait for customizable reagent holder
#define TRAIT_CUSTOMIZABLE_REAGENT_HOLDER "customizable_reagent_holder"
/// Trait for allowing an item that isn't food into the customizable reagent holder
#define TRAIT_ODD_CUSTOMIZABLE_FOOD_INGREDIENT "odd_customizable_food_ingredient"

/// Used to prevent multiple floating blades from triggering over the same target
#define TRAIT_BEING_BLADE_SHIELDED "being_blade_shielded"

/// This mob doesn't count as looking at you if you can only act while unobserved
#define TRAIT_UNOBSERVANT "trait_unobservant"

/* Traits for ventcrawling.
 * Both give access to ventcrawling, but *_NUDE requires the user to be
 * wearing no clothes and holding no items. If both present, *_ALWAYS
 * takes precedence.
 */
#define TRAIT_VENTCRAWLER_ALWAYS "ventcrawler_always"
#define TRAIT_VENTCRAWLER_NUDE "ventcrawler_nude"

/// Minor trait used for beakers, or beaker-ishes. [/obj/item/reagent_containers], to show that they've been used in a reagent grinder.
#define TRAIT_MAY_CONTAIN_BLENDED_DUST "may_contain_blended_dust"

/// Trait put on [/mob/living/carbon/human]. If that mob has a crystal core, also known as an ethereal heart, it will not try to revive them if the mob dies.
#define TRAIT_CANNOT_CRYSTALIZE "cannot_crystalize"

///Trait applied to turfs when an atmos holosign is placed on them. It will stop firedoors from closing.
#define TRAIT_FIREDOOR_STOP "firedoor_stop"

/// Trait applied when the MMI component is added to an [/obj/item/integrated_circuit]
#define TRAIT_COMPONENT_MMI "component_mmi"

/// Trait applied when an integrated circuit/module becomes undupable
#define TRAIT_CIRCUIT_UNDUPABLE "circuit_undupable"

/// Hearing trait that is from the hearing component
#define CIRCUIT_HEAR_TRAIT "circuit_hear"

/// PDA Traits. This one makes PDAs explode if the user opens the messages menu
#define TRAIT_PDA_MESSAGE_MENU_RIGGED "pda_message_menu_rigged"
/// This one denotes a PDA has received a rigged message and will explode when the user tries to reply to a rigged PDA message
#define TRAIT_PDA_CAN_EXPLODE "pda_can_explode"

/// If present on a [/mob/living/carbon], will make them appear to have a medium level disease on health HUDs.
#define TRAIT_DISEASELIKE_SEVERITY_MEDIUM "diseaselike_severity_medium"

/// trait denoting someone will crawl faster in soft crit
#define TRAIT_TENACIOUS "tenacious"

/// trait denoting someone will sometimes recover out of crit
#define TRAIT_UNBREAKABLE "unbreakable"

/// trait that prevents AI controllers from planning detached from ai_status to prevent weird state stuff.
#define TRAIT_AI_PAUSED "TRAIT_AI_PAUSED"

/// this is used to bypass tongue language restrictions but not tongue disabilities
#define TRAIT_TOWER_OF_BABEL "tower_of_babel"

/// This target has recently been shot by a marksman coin and is very briefly immune to being hit by one again to prevent recursion
#define TRAIT_RECENTLY_COINED "recently_coined"

/// Receives echolocation images.
#define TRAIT_ECHOLOCATION_RECEIVER "echolocation_receiver"
/// Echolocation has a higher range.
#define TRAIT_ECHOLOCATION_EXTRA_RANGE "echolocation_extra_range"

/// Trait given to a living mob and any observer mobs that stem from them if they suicide.
/// For clarity, this trait should always be associated/tied to a reference to the mob that suicided- not anything else.
#define TRAIT_SUICIDED "committed_suicide"

/// Trait given to a living mob to prevent wizards from making it immortal
#define TRAIT_PERMANENTLY_MORTAL "permanently_mortal"

///Trait given to a mob with a ckey currently in a temporary body, allowing people to know someone will re-enter the round later.
#define TRAIT_MIND_TEMPORARILY_GONE "temporarily_gone"

/// Similar trait given to temporary bodies inhabited by players
#define TRAIT_TEMPORARY_BODY "temporary_body"

/// Trait given to mechs that can have orebox functionality on movement
#define TRAIT_OREBOX_FUNCTIONAL "orebox_functional"

///fish traits
#define TRAIT_RESIST_EMULSIFY "resist_emulsify"
#define TRAIT_FISH_SELF_REPRODUCE "fish_self_reproduce"
#define TRAIT_FISH_NO_MATING "fish_no_mating"
#define TRAIT_YUCKY_FISH "yucky_fish"
#define TRAIT_FISH_TOXIN_IMMUNE "fish_toxin_immune"
#define TRAIT_FISH_CROSSBREEDER "fish_crossbreeder"
#define TRAIT_FISH_AMPHIBIOUS "fish_amphibious"
///Trait needed for the lubefish evolution
#define TRAIT_FISH_FED_LUBE "fish_fed_lube"
#define TRAIT_FISH_NO_HUNGER "fish_no_hunger"

// common trait sources
#define TRAIT_GENERIC "generic"
#define UNCONSCIOUS_TRAIT "unconscious"
#define EYE_DAMAGE "eye_damage"
#define EAR_DAMAGE "ear_damage"
#define GENETIC_MUTATION "genetic"
#define OBESITY "obesity"
#define MAGIC_TRAIT "magic"
#define TRAUMA_TRAIT "trauma"
#define FLIGHTPOTION_TRAIT "flightpotion"
/// Trait inherited by experimental surgeries
#define EXPERIMENTAL_SURGERY_TRAIT "experimental_surgery"
#define DISEASE_TRAIT "disease"
#define SPECIES_TRAIT "species"
#define ORGAN_TRAIT "organ"
/// Trait given by augmented limbs
#define AUGMENTATION_TRAIT "augments"
/// Trait given by organ gained via abductor surgery
#define ABDUCTOR_GLAND_TRAIT "abductor_gland"
/// cannot be removed without admin intervention
#define ROUNDSTART_TRAIT "roundstart"
#define JOB_TRAIT "job"
#define CYBORG_ITEM_TRAIT "cyborg-item"
/// Any traits granted by quirks.
#define QUIRK_TRAIT "quirk_trait"
/// (B)admins only.
#define ADMIN_TRAIT "admin"
/// Any traits given through a smite.
#define SMITE_TRAIT "smite"
#define CHANGELING_TRAIT "changeling"
#define CULT_TRAIT "cult"
#define LICH_TRAIT "lich"
/// The item is magically cursed
#define CURSED_ITEM_TRAIT(item_type) "cursed_item_[item_type]"
#define ABSTRACT_ITEM_TRAIT "abstract-item"
/// A trait given by any status effect
#define STATUS_EFFECT_TRAIT "status-effect"
/// A trait given by a specific status effect (not sure why we need both but whatever!)
#define TRAIT_STATUS_EFFECT(effect_id) "[effect_id]-trait"
/// Trait from light debugging
#define LIGHT_DEBUG_TRAIT "light-debug"

#define CLOTHING_TRAIT "clothing"
#define HELMET_TRAIT "helmet"
/// inherited from the mask
#define MASK_TRAIT "mask"
/// inherited from your sweet kicks
#define SHOES_TRAIT "shoes"
/// Trait inherited by implants
#define IMPLANT_TRAIT "implant"
#define GLASSES_TRAIT "glasses"
/// inherited from riding vehicles
#define VEHICLE_TRAIT "vehicle"
#define INNATE_TRAIT "innate"
#define CRIT_HEALTH_TRAIT "crit_health"
#define OXYLOSS_TRAIT "oxyloss"
/// Trait sorce for "was recently shocked by something"
#define WAS_SHOCKED "was_shocked"
#define TURF_TRAIT "turf"
/// trait associated to being buckled
#define BUCKLED_TRAIT "buckled"
/// trait associated to being held in a chokehold
#define CHOKEHOLD_TRAIT "chokehold"
/// trait associated to resting
#define RESTING_TRAIT "resting"
/// trait associated to a stat value or range of
#define STAT_TRAIT "stat"
#define STATION_TRAIT "station-trait"
/// obtained from mapping helper
#define MAPPING_HELPER_TRAIT "mapping-helper"
/// Trait associated to wearing a suit
#define SUIT_TRAIT "suit"
/// Trait associated to lying down (having a [lying_angle] of a different value than zero).
#define LYING_DOWN_TRAIT "lying-down"
/// A trait gained by leaning against a wall
#define LEANING_TRAIT "leaning"
/// Trait associated to lacking electrical power.
#define POWER_LACK_TRAIT "power-lack"
/// Trait associated to lacking motor movement
#define MOTOR_LACK_TRAIT "motor-lack"
/// Trait associated with mafia
#define MAFIA_TRAIT "mafia"
/// Trait associated with ctf
#define CTF_TRAIT "ctf"
/// Trait associated with highlander
#define HIGHLANDER_TRAIT "highlander"
/// Trait given from playing pretend with baguettes
#define SWORDPLAY_TRAIT "swordplay"
/// Trait given by being recruited as a nuclear operative
#define NUKE_OP_MINION_TRAIT "nuke-op-minion"
/// Trait given by mech equipment
#define TRAIT_MECH_EQUIPMENT(equipment_type) "mech_equipment_[equipment_type]"
/// Trait given to you by shapeshifting
#define SHAPESHIFT_TRAIT "shapeshift_trait"

///generic atom traits
/// Trait from [/datum/element/rust]. Its rusty and should be applying a special overlay to denote this.
#define TRAIT_RUSTY "rust_trait"
/// Stops someone from splashing their reagent_container on an object with this trait
#define TRAIT_DO_NOT_SPLASH "do_not_splash"
/// Marks an atom when the cleaning of it is first started, so that the cleaning overlay doesn't get removed prematurely
#define TRAIT_CURRENTLY_CLEANING "currently_cleaning"
/// Objects with this trait are deleted if they fall into chasms, rather than entering abstract storage
#define TRAIT_CHASM_DESTROYED "chasm_destroyed"
/// Trait from being under the floor in some manner
#define TRAIT_UNDERFLOOR "underfloor"
/// If the movable shouldn't be reflected by mirrors.
#define TRAIT_NO_MIRROR_REFLECTION "no_mirror_reflection"
/// If this movable is currently treading in a turf with the immerse element.
#define TRAIT_IMMERSED "immersed"
/**
 * With this, the immerse overlay will give the atom its own submersion visual overlay
 * instead of one that's also shared with other movables, thus making editing its appearance possible.
 */
#define TRAIT_UNIQUE_IMMERSE "unique_immerse"


// unique trait sources, still defines
#define EMP_TRAIT "emp_trait"
#define STATUE_MUTE "statue"
#define CHANGELING_DRAIN "drain"
/// changelings with this trait can no longer talk over the hivemind
#define CHANGELING_HIVEMIND_MUTE "ling_mute"
#define TRAIT_HULK "hulk"
#define STASIS_MUTE "stasis"
#define GENETICS_SPELL "genetics_spell"
#define EYES_COVERED "eyes_covered"
#define NO_EYES "no_eyes"
#define HYPNOCHAIR_TRAIT "hypnochair"
#define FLASHLIGHT_EYES "flashlight_eyes"
#define IMPURE_OCULINE "impure_oculine"
#define HAUNTIUM_REAGENT_TRAIT "hauntium_reagent_trait"
#define TRAIT_SANTA "santa"
#define SCRYING_ORB "scrying-orb"
#define ABDUCTOR_ANTAGONIST "abductor-antagonist"
#define JUNGLE_FEVER_TRAIT "jungle_fever"
#define MEGAFAUNA_TRAIT "megafauna"
#define CLOWN_NUKE_TRAIT "clown-nuke"
#define STICKY_MOUSTACHE_TRAIT "sticky-moustache"
#define CHAINSAW_FRENZY_TRAIT "chainsaw-frenzy"
#define CHRONO_GUN_TRAIT "chrono-gun"
#define REVERSE_BEAR_TRAP_TRAIT "reverse-bear-trap"
#define CURSED_MASK_TRAIT "cursed-mask"
#define HIS_GRACE_TRAIT "his-grace"
#define HAND_REPLACEMENT_TRAIT "magic-hand"
#define HOT_POTATO_TRAIT "hot-potato"
#define SABRE_SUICIDE_TRAIT "sabre-suicide"
#define ABDUCTOR_VEST_TRAIT "abductor-vest"
#define CAPTURE_THE_FLAG_TRAIT "capture-the-flag"
#define BASKETBALL_MINIGAME_TRAIT "basketball-minigame"
#define EYE_OF_GOD_TRAIT "eye-of-god"
#define SHAMEBRERO_TRAIT "shamebrero"
#define CHRONOSUIT_TRAIT "chronosuit"
#define LOCKED_HELMET_TRAIT "locked-helmet"
#define NINJA_SUIT_TRAIT "ninja-suit"
#define SLEEPING_CARP_TRAIT "sleeping_carp"
#define TIMESTOP_TRAIT "timestop"
#define LIFECANDLE_TRAIT "lifecandle"
#define VENTCRAWLING_TRAIT "ventcrawling"
#define SPECIES_FLIGHT_TRAIT "species-flight"
#define FROSTMINER_ENRAGE_TRAIT "frostminer-enrage"
#define NO_GRAVITY_TRAIT "no-gravity"
/// A trait gained from a mob's leap action, like the leaper
#define LEAPING_TRAIT "leaping"
/// A trait gained from a mob's vanish action, like the herophant
#define VANISHING_TRAIT "vanishing"
/// A trait gained from a mob's swoop action, like the ash drake
#define SWOOPING_TRAIT "swooping"
/// A trait gained from a mob's mimic ability, like the mimic
#define MIMIC_TRAIT "mimic"
#define SHRUNKEN_TRAIT "shrunken"
#define LEAPER_BUBBLE_TRAIT "leaper-bubble"
#define DNA_VAULT_TRAIT "dna_vault"
/// sticky nodrop sounds like a bad soundcloud rapper's name
#define STICKY_NODROP "sticky-nodrop"
#define SKILLCHIP_TRAIT "skillchip"
#define SKILL_TRAIT "skill"
#define BUSY_FLOORBOT_TRAIT "busy-floorbot"
#define PULLED_WHILE_SOFTCRIT_TRAIT "pulled-while-softcrit"
#define LOCKED_BORG_TRAIT "locked-borg"
/// trait associated to not having locomotion appendages nor the ability to fly or float
#define LACKING_LOCOMOTION_APPENDAGES_TRAIT "lacking-locomotion-appengades"
#define CRYO_TRAIT "cryo"
/// trait associated to not having fine manipulation appendages such as hands
#define LACKING_MANIPULATION_APPENDAGES_TRAIT "lacking-manipulation-appengades"
#define HANDCUFFED_TRAIT "handcuffed"
/// Trait granted by [/obj/item/warp_whistle]
#define WARPWHISTLE_TRAIT "warpwhistle"
///Turf trait for when a turf is transparent
#define TURF_Z_TRANSPARENT_TRAIT "turf_z_transparent"
/// Trait applied by [/datum/component/soulstoned]
#define SOULSTONE_TRAIT "soulstone"
/// Trait applied to slimes by low temperature
#define SLIME_COLD "slime-cold"
/// Trait applied to mobs by being tipped over
#define TIPPED_OVER "tipped-over"
/// Trait applied to PAIs by being folded
#define PAI_FOLDED "pai-folded"
/// Trait applied to brain mobs when they lack external aid for locomotion, such as being inside a mech.
#define BRAIN_UNAIDED "brain-unaided"
/// Trait applied to a mob when it gets a required "operational datum" (components/elements). Sends out the source as the type of the element.
#define TRAIT_SUBTREE_REQUIRED_OPERATIONAL_DATUM "element-required"
/// Trait applied by MODsuits.
#define MOD_TRAIT "mod"
/// Trait applied by element
#define ELEMENT_TRAIT(source) "element_trait_[source]"
/// Trait granted by the berserker hood.
#define BERSERK_TRAIT "berserk_trait"
/// Trait granted by [/obj/item/rod_of_asclepius]
#define HIPPOCRATIC_OATH_TRAIT "hippocratic_oath"
/// Trait granted by [/datum/status_effect/blooddrunk]
#define BLOODDRUNK_TRAIT "blooddrunk"
/// Trait granted by lipstick
#define LIPSTICK_TRAIT "lipstick_trait"
/// Self-explainatory.
#define BEAUTY_ELEMENT_TRAIT "beauty_element"
#define MOOD_DATUM_TRAIT "mood_datum"
#define DRONE_SHY_TRAIT "drone_shy"
/// Trait given by stabilized light pink extracts
#define STABILIZED_LIGHT_PINK_EXTRACT_TRAIT "stabilized_light_pink"
/// Trait given by adamantine extracts
#define ADAMANTINE_EXTRACT_TRAIT "adamantine_extract"
/// Given by the multiple_lives component to the previous body of the mob upon death.
#define EXPIRED_LIFE_TRAIT "expired_life"
/// Trait given to an atom/movable when they orbit something.
#define ORBITING_TRAIT "orbiting"
/// From the item_scaling element
#define ITEM_SCALING_TRAIT "item_scaling"
/// Trait given by choking
#define CHOKING_TRAIT "choking_trait"
/// Trait given by hallucinations
#define HALLUCINATION_TRAIT "hallucination_trait"
/// Trait given by simple/basic mob death
#define BASIC_MOB_DEATH_TRAIT "basic_mob_death"
/// Trait given by your current speed
#define SPEED_TRAIT "speed_trait"
/// Trait given to mobs that have been autopsied
#define AUTOPSY_TRAIT "autopsy_trait"
/// Trait given by [/datum/status_effect/blessing_of_insanity]
#define MAD_WIZARD_TRAIT "mad_wizard_trait"
/// Isn't attacked harmfully by blob structures
#define TRAIT_BLOB_ALLY "blob_ally"

/**
* Trait granted by [/mob/living/carbon/Initialize] and
* granted/removed by [/obj/item/organ/internal/tongue]
* Used for ensuring that carbons without tongues cannot taste anything
* so it is added in Initialize, and then removed when a tongue is inserted
* and readded when a tongue is removed.
*/
#define NO_TONGUE_TRAIT "no_tongue_trait"

/// Trait granted by [/mob/living/silicon/robot]
/// Traits applied to a silicon mob by their model.
#define MODEL_TRAIT "model_trait"

/// Trait granted by [mob/living/silicon/ai]
/// Applied when the ai anchors itself
#define AI_ANCHOR_TRAIT "ai_anchor"
/// Trait from [/datum/antagonist/nukeop/clownop]
#define CLOWNOP_TRAIT "clownop"

///Traits given by station traits
#define STATION_TRAIT_BANANIUM_SHIPMENTS "station_trait_bananium_shipments"
#define STATION_TRAIT_UNNATURAL_ATMOSPHERE "station_trait_unnatural_atmosphere"
#define STATION_TRAIT_UNIQUE_AI "station_trait_unique_ai"
#define STATION_TRAIT_CARP_INFESTATION "station_trait_carp_infestation"
#define STATION_TRAIT_PREMIUM_INTERNALS "station_trait_premium_internals"
#define STATION_TRAIT_LATE_ARRIVALS "station_trait_late_arrivals"
#define STATION_TRAIT_RANDOM_ARRIVALS "station_trait_random_arrivals"
#define STATION_TRAIT_HANGOVER "station_trait_hangover"
#define STATION_TRAIT_FILLED_MAINT "station_trait_filled_maint"
#define STATION_TRAIT_EMPTY_MAINT "station_trait_empty_maint"
#define STATION_TRAIT_PDA_GLITCHED "station_trait_pda_glitched"
#define STATION_TRAIT_BOTS_GLITCHED "station_trait_bot_glitch"
#define STATION_TRAIT_CYBERNETIC_REVOLUTION "station_trait_cybernetic_revolution"
#define STATION_TRAIT_BIGGER_PODS "station_trait_bigger_pods"
#define STATION_TRAIT_SMALLER_PODS "station_trait_smaller_pods"
#define STATION_TRAIT_BIRTHDAY "station_trait_birthday"
#define STATION_TRAIT_SPIDER_INFESTATION "station_trait_spider_infestation"
#define STATION_TRAIT_REVOLUTIONARY_TRASHING "station_trait_revolutionary_trashing"
#define STATION_TRAIT_RADIOACTIVE_NEBULA "station_trait_radioactive_nebula"
#define STATION_TRAIT_FORESTED "station_trait_forested"
#define STATION_TRAIT_VENDING_SHORTAGE "station_trait_vending_shortage"
#define STATION_TRAIT_MEDBOT_MANIA "station_trait_medbot_mania"
#define STATION_TRAIT_LOANER_SHUTTLE "station_trait_loaner_shuttle"
#define STATION_TRAIT_SHUTTLE_SALE "station_trait_shuttle_sale"

///From the market_crash event
#define MARKET_CRASH_EVENT_TRAIT "crashed_market_event"

/// Denotes that this id card was given via the job outfit, aka the first ID this player got.
#define TRAIT_JOB_FIRST_ID_CARD "job_first_id_card"
/// ID cards with this trait will attempt to forcibly occupy the front-facing ID card slot in wallets.
#define TRAIT_MAGNETIC_ID_CARD "magnetic_id_card"
/// ID cards with this trait have special appraisal text.
#define TRAIT_TASTEFULLY_THICK_ID_CARD "impressive_very_nice"
/// things with this trait are treated as having no access in /obj/proc/check_access(obj/item)
#define TRAIT_ALWAYS_NO_ACCESS "alwaysnoaccess"

/// Traits granted to items due to their chameleon properties.
#define CHAMELEON_ITEM_TRAIT "chameleon_item_trait"

/// This human wants to see the color of their glasses, for some reason
#define TRAIT_SEE_GLASS_COLORS "see_glass_colors"

/// this mob is under the effects of the power chord
#define TRAIT_POWER_CHORD "power_chord"

// Radiation defines

/// Marks that this object is irradiated
#define TRAIT_IRRADIATED "iraddiated"

/// Harmful radiation effects, the toxin damage and the burns, will not occur while this trait is active
#define TRAIT_HALT_RADIATION_EFFECTS "halt_radiation_effects"

/// This clothing protects the user from radiation.
/// This should not be used on clothing_traits, but should be applied to the clothing itself.
#define TRAIT_RADIATION_PROTECTED_CLOTHING "radiation_protected_clothing"

/// Whether or not this item will allow the radiation SS to go through standard
/// radiation processing as if this wasn't already irradiated.
/// Basically, without this, COMSIG_IN_RANGE_OF_IRRADIATION won't fire once the object is irradiated.
#define TRAIT_BYPASS_EARLY_IRRADIATED_CHECK "radiation_bypass_early_irradiated_check"

/// Simple trait that just holds if we came into growth from a specific mob type. Should hold a REF(src) to the type of mob that caused the growth, not anything else.
#define TRAIT_WAS_EVOLVED "was_evolved_from_the_mob_we_hold_a_textref_to"

// Traits to heal for

/// This mob heals from carp rifts.
#define TRAIT_HEALS_FROM_CARP_RIFTS "heals_from_carp_rifts"

/// This mob heals from cult pylons.
#define TRAIT_HEALS_FROM_CULT_PYLONS "heals_from_cult_pylons"

/// Ignore Crew monitor Z levels
#define TRAIT_MULTIZ_SUIT_SENSORS "multiz_suit_sensors"

/// Ignores body_parts_covered during the add_fingerprint() proc. Works both on the person and the item in the glove slot.
#define TRAIT_FINGERPRINT_PASSTHROUGH "fingerprint_passthrough"

/// this object has been frozen
#define TRAIT_FROZEN "frozen"

/// Currently fishing
#define TRAIT_GONE_FISHING "fishing"

/// Makes a species be better/worse at tackling depending on their wing's status
#define TRAIT_TACKLING_WINGED_ATTACKER "tacking_winged_attacker"

/// Makes a species be frail and more likely to roll bad results if they hit a wall
#define TRAIT_TACKLING_FRAIL_ATTACKER "tackling_frail_attacker"

/// Makes a species be better/worse at defending against tackling depending on their tail's status
#define TRAIT_TACKLING_TAILED_DEFENDER "tackling_tailed_defender"

/// Is runechat for this atom/movable currently disabled, regardless of prefs or anything?
#define TRAIT_RUNECHAT_HIDDEN "runechat_hidden"

/// the object has a label applied
#define TRAIT_HAS_LABEL "labeled"

///coming from a fish trait datum.
#define FISH_TRAIT_DATUM "fish_trait_datum"
///coming from a fish evolution datum
#define FISH_EVOLUTION "fish_evolution"

/// some trait sorces dirived from bodyparts BODYPART_TRAIT is generic.
#define BODYPART_TRAIT "bodypart"
#define HEAD_TRAIT "head"
#define CHEST_TRAIT "chest"
#define RIGHT_ARM_TRAIT "right_arm"
#define LEFT_ARM_TRAIT "left_arm"
#define RIGHT_LEG_TRAIT "right_leg"
#define LEFT_LEG_TRAIT "left_leg"

/// Trait given by echolocation component.
#define ECHOLOCATION_TRAIT "echolocation"

///without a human having this trait, they speak as if they have no tongue.
#define TRAIT_SPEAKS_CLEARLY "speaks_clearly"

// specific sources for TRAIT_SPEAKS_CLEARLY

///trait source that tongues should use
#define SPEAKING_FROM_TONGUE "tongue"
///trait source that sign language should use
#define SPEAKING_FROM_HANDS "hands"

///Trait given by /datum/component/germ_sensitive
#define TRAIT_GERM_SENSITIVE "germ_sensitive"

/// This atom can have spells cast from it if a mob is within it
/// This means the "caster" of the spell is changed to the mob's loc
/// Note this doesn't mean all spells are guaranteed to work or the mob is guaranteed to cast
#define TRAIT_CASTABLE_LOC "castable_loc"

///Trait given by /datum/element/relay_attacker
#define TRAIT_RELAYING_ATTACKER "relaying_attacker"

/// Trait given while using /datum/action/cooldown/mob_cooldown/wing_buffet
#define TRAIT_WING_BUFFET "wing_buffet"
/// Trait given while tired after using /datum/action/cooldown/mob_cooldown/wing_buffet
#define TRAIT_WING_BUFFET_TIRED "wing_buffet_tired"
/// Trait given to a dragon who fails to defend their rifts
#define TRAIT_RIFT_FAILURE "fail_dragon_loser"
