FlippedRunes = RegisterMod("Flipped Runes", 1)
local mod = FlippedRunes

mod.RuneColor = Color(0.355/2,.601/2,.554/2)

--Init
include("code.essentials")

--Helpers
include("code.unstackable_vanilla_items")
include("code.coroutines")
include("code.overlays")

--Rune Logic
include("code.runes.flipped_hagalaz")
include("code.runes.flipped_jera")
include("code.runes.flipped_ehwaz")
include("code.runes.flipped_dagaz")
include("code.runes.flipped_ansuz")
include("code.runes.flipped_perthro")
include("code.runes.flipped_berkano")
include("code.runes.flipped_algiz")
include("code.runes.flipped_black")
include("code.runes.flipped_blank")

--Mod Compat
include("code.eid_support")