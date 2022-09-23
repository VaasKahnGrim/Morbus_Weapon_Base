--not fully implemented yet into the rest of the base
--Firemode ENUMs to easily recognize what firemode is instead of a number
FIREMODE_SEMI = 0
FIREMODE_AUTO = 1
FIREMODE_BURST = 2
FIREMODE_SAFETY = 3

--HoldTypes, we cache both the hold type for normally firing and the holdtype for when safety is turned on
--Thisway player weapons look like they are actually on safety or not
SWEP.DefaultHold = "ar2"
SWEP.SafetyHold = "passive"

SWEP.FireMode = 0	--Current firemode
SWEP.FireModes = {	--Avaiable firemodes
	[FIREMODE_SAFETY] = true  --All weapons have this firemode
}

function SWEP:SetFireMode(mode)
	self.FireModes = self.FireModes[mode] and mode or self.FireModes	--Set the firemode if it is an available firemode
	self:SetHoldType(mode == 3 and self.SafetyHold or self.DefaultHold)	--Set the holdtype if we enter safety or keep it the same
end

function SWEP:GetFireMode()	--Return the current firemode
	return self.FireMode or 0
end

function SWEP:IsSafetyOn()	--A quick function to check if we are in safety mode without having to call GetFireMode and then compare it ourself
	return (self.FireMode == 3) or false
end


