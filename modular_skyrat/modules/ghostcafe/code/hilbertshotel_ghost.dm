/obj/item/hilbertshotel/ghostdojo
	name = "infinite dormitories"
	anchored = TRUE

/obj/item/hilbertshotel/ghostdojo/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	return promptAndCheckIn(user, user)

/datum/map_template/ghost_cafe_rooms
	name = "Apartment"
	mappath = "modular_skyrat/modules/hotel_rooms/apartment.dmm"


/datum/map_template/miyako_apartment
	name = "Miyako's Apartment"
	mappath = "modular_skyrat/modules/hotel_rooms/miyako_apartment.dmm"
	var/landingZoneRelativeX = 15
	var/landingZoneRelativeY = 23

/obj/item/hilbertshotel/miyako
	name = "Apartment Orb"
