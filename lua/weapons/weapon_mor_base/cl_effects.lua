--Not Fully implemented
--Need to get material type and use that to implement impact effects when hitting an object or player
local ImpactTypes = {	--Change these asap
	["Default"] = "fadingscorch",
	["9mm"] = "fadingscorch",
	["5.56"] = "fadingscorch",
	["10mm"] = "fadingscorch",
	["7.62"] = "fadingscorch",
	["Electic"] = "fadingscorch",
	["Electric+"] = "fadingscorch",
	["Fire"] = "fadingscorch"
}

function SWEP:DoImpactEffect(tr, dmgtype)
	if tr.HitSky then return true end
	util.Decal(ImpactTypes[self.Round] or ImpactTypes.Default, tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
	return true
end


