--not fully implemented yet
--Firemode ENUMs
FIREMODE_SEMI = 0
FIREMODE_AUTO = 1
FIREMODE_BURST = 2
FIREMODE_SAFETY = 3

SWEP.FireMode = 0
SWEP.FireModes = {
	[FIREMODE_SAFETY] = true  --All weapons have this firemode
}

function SWEP:SetFireMode(mode)
	self.FireModes = self.FireModes[mode] and mode or self.FireModes
end

function SWEP:GetFireMode()
	return self.FireMode or 0
end

function SWEP:IsSafetyOn()
	return (self.FireMode == 3) or false
end


