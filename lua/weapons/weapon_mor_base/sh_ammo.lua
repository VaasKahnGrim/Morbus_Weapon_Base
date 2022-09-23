--not fully implemented yet
local AmmoTypes = {
	["Default"] = 10,
	["9mm"] = 5,
	["5.56"] = 15,
	["10mm"] = 8,
	["7.62"] = 10,
	["Electic"] = 8,
	["Electric+"] = 20,
	["Fire"] = 8
}

function SWEP:SetupDamage()
	self.Primary.Damage = AmmoTypes[self.Round] or AmmoTypes.Default or 10
end


