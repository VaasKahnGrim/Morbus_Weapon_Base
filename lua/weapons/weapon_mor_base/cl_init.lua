include("shared.lua")
include("cl_laser.lua")
include("cl_render.lua")

SWEP.DrawAmmo			= false		-- Should we draw the number of ammos and clips?
SWEP.DrawCrosshair		= false		-- Should we draw the half life 2 crosshair?
SWEP.ViewModelFOV		= 70			-- "Y" position of the sweps
SWEP.ViewModelFlip		= true		-- Should we flip the sweps?
SWEP.CSMuzzleFlashes	= false		-- Should we add a CS Muzzle Flash?


local function FullCopy( tab )
	if not tab then return nil end

	local res = {}
	local tabLen = #tab
	for i = 1, tabLen do
		local v = tab[i]

		local tbl, vec, ang = type(v) == "table", type(v) == "Vector", type(v) == "Angle"
		res[k] = tbl and FullCopy(v) or vec and Vector(v.x,v.y,v.z) or ang and Angle(v.p,v.y,v.r) or v
	end

	return res
end

function SWEP:Initialize()
	self.ThinkOffset = CurTime()+0.5
	util.PrecacheSound(self.Primary.Sound)
	self.Reloadaftershoot = 0 				-- Can't reload when firing
	self:SetWeaponHoldType(self.HoldType)
	self.Weapon:SetNetworkedBool("Reloading", false)

	-- // Create a new table for every weapon instance
	self.VElements = FullCopy( self.VElements )
	self.WElements = FullCopy( self.WElements )
	self.ViewModelBoneMods = FullCopy( self.ViewModelBoneMods )

	self:CreateModels(self.VElements) -- create viewmodels
	self:CreateModels(self.WElements) -- create worldmodels

	-- // init view model bone build function
	local ply = self:GetOwner()
	if IsValid(ply) then
		if ply:Alive() then
			local vm = ply:GetViewModel()
			if IsValid(vm) then
				self:ResetBonePositions(vm)
				-- // Init viewmodel visibility
				if self.ShowViewModel == nil or self.ShowViewModel then
					vm:SetColor(Color(255,255,255,255))
				else
					-- // however for some reason the view model resets to render mode 0 every frame so we just apply a debug material to prevent it from drawing
					vm:SetMaterial("Debug/hsv")
				end
			end
		end
	end
end

function SWEP:IronSight()
	local ply = self:GetOwner()
	local wep = self.Weapon
	local isReloading = wep:GetNWBool("Reloading")
	local curt = CurTime()

	if self.ResetSights and curt >= self.ResetSights then
		self.ResetSights = nil
		self:SendWeaponAnim(self.Silenced and ACT_VM_IDLE_SILENCED or ACT_VM_IDLE)
	end

	if self.CanBeSilenced and self.NextSilence < curt then
		if ply:KeyDown(IN_USE) and ply:KeyPressed(IN_ATTACK2) then
			self:Silencer()
		end
	end

	if ply:KeyDown(IN_SPEED) and not isReloading then -- If you are running
		wep:SetNextPrimaryFire(curt+0.3) -- Make it so you can't shoot for another quarter second
		self.IronSightsPos = self.RunSightsPos -- Hold it down
		self.IronSightsAng = self.RunSightsAng -- Hold it down
		self:SetIronsights(true, ply) -- Set the ironsight true
		ply:SetFOV( 0, 0.3 )
	end

	if ply:KeyReleased(IN_SPEED) then -- If you release run then
		self:SetIronsights(false, ply) -- Set the ironsight true
		ply:SetFOV( 0, 0.3 )
	end -- Shoulder the gun

	if not ply:KeyDown(IN_USE) and not ply:KeyDown(IN_SPEED) then -- If the key E (Use Key) is not pressed, then
		if ply:KeyPressed(IN_ATTACK2) and not isReloading then 
			ply:SetFOV( self.Primary.IronFOV, 0.3 )
			self.IronSightsPos = self.SightsPos -- Bring it up
			self.IronSightsAng = self.SightsAng -- Bring it up
			self:SetIronsights(true, ply)
			self.DrawCrosshair = false -- Set the ironsight true

			return
 		end
	end

	if ply:KeyReleased(IN_ATTACK2) and not ply:KeyDown(IN_USE) and not ply:KeyDown(IN_SPEED) then -- If the right click is released, then
		ply:SetFOV( 0, 0.3 )
		self.DrawCrosshair = false
		self:SetIronsights(false, ply) -- Set the ironsight false

		return
	end

	self.SwayScale = ply:KeyDown(IN_ATTACK2) and not ply:KeyDown(IN_USE) and not ply:KeyDown(IN_SPEED) and 0.05 or 1.0
	self.BobScale = ply:KeyDown(IN_ATTACK2) and not ply:KeyDown(IN_USE) and not ply:KeyDown(IN_SPEED) and 0.05 or 1.0
end

function SWEP:Reload()
	local ply = self:GetOwner()
	local wep = self.Weapon

	wep:DefaultReload(self.Silenced and ACT_VM_RELOAD_SILENCED or ACT_VM_RELOAD) 

	self.ResetSights = CurTime() + ply:GetViewModel():SequenceDuration()
end

function SWEP:PostReloadScopeCheck()
	local wep = self.Weapon
	if wep == nil then return end
	wep:SetNetworkedBool("Reloading", false)
end

function SWEP:PrimaryAttack()
	local ply = self:GetOwner()

	if self:CanPrimaryAttack() and ply:WaterLevel() < 3 then
		if not ply:KeyDown(IN_SPEED) and not ply:KeyDown(IN_RELOAD) then
			local wep = self.Weapon
			local silenced = self.Silenced

			self:ShootBulletInformation(ply)
			wep:TakePrimaryAmmo(1)

			self.Weapon:SendWeaponAnim(silenced and ACT_VM_PRIMARYATTACK_SILENCED or ACT_VM_PRIMARYATTACK )
			self.Weapon:EmitSound(silenced and self.Primary.SilencedSound or self.Primary.Sound, silenced and 75 or 135, 100)

			ply:SetAnimation( PLAYER_ATTACK1 )
			ply:MuzzleFlash()
			wep:SetNextPrimaryFire(CurTime()+1/(self.Primary.RPM/60))
			self.RicochetCoin = (math.random(1,4))
		end
	end
end

function SWEP:SecondaryAttack()
	return false
end

function SWEP:Holster()
	self.Weapon:SetNetworkedBool("Reloading", false)

	if IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			self:ResetBonePositions(vm)
		end
	end
	self.Weapon:SetNWBool( "IsLaserOn", false )

	return true
end

function SWEP:OnRemove()
	self.Weapon:SetNetworkedBool("Reloading", false)

	if IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			self:ResetBonePositions(vm)
		end
	end
end

local ricoJump = {
	SniperPenetratedRound = 20,
	pistol = 2,
	["357"] = 4,
	smg1 = 5,
	ar2 = 8,
	buckshot = 3,
	slam = 3,
	AirboatGun = 20
}

function SWEP:RicochetCallback(bouncenum, attacker, tr, dmginfo)
	local DoDefaultEffect = true
	if tr.HitSky then return end

	-- Your screen will shake and you'll hear the savage hiss of an approaching bullet which passing if someone is shooting at you.
	if tr.MatType ~= MAT_METAL then
		local effectdata = EffectData()
			effectdata:SetOrigin(tr.HitPos)
			effectdata:SetNormal(tr.HitNormal)
			effectdata:SetScale(20)
			util.Effect(self.Tracer ~= 3 and "StunstickImpact" or "AR2Impact", effectdata)

		return 
	end

	if self.Ricochet == false then
		return {
			damage = true,
			effects = DoDefaultEffect
		}
	end

	self.MaxRicochet = ricoJump[self.Primary.Ammo]

	if bouncenum > self.MaxRicochet then return end

	local DotProduct = tr.HitNormal:Dot(tr.Normal * -1) 

	timer.Simple(0.05, function()
		attacker:FireBullets({
			Num 		= 1,
			Src 		= tr.HitPos + (tr.HitNormal * 5),
			Dir 		= ((2 * tr.HitNormal * DotProduct) + tr.Normal) + (VectorRand() * 0.05),
			Spread 		= Vector(0, 0, 0),
			Tracer		= 1,
			TracerName 	= "m9k_effect_mad_ricochet_trace",
			Force		= dmginfo:GetDamage() * 0.25,
			Damage		= dmginfo:GetDamage() * 0.5,
			Callback  	= function(a, b, c)
				if self.Ricochet then  
					local impactnum = tr.MatType == MAT_GLASS and 0 or 1

					return self:RicochetCallback(bouncenum + impactnum, a, b, c)
				end
			end
		})
	end)

	return {damage = true, effects = DoDefaultEffect}
end

function SWEP:ShootBullet(damage, recoil, num_bullets, aimcone)
	local ply = self:GetOwner()

	num_bullets = num_bullets or 1
	aimcone = aimcone or 0

	self:ShootEffects()

	ply:FireBullets({
		Num 		= num_bullets,
		Src 		= ply:GetShootPos(),			-- Source
		Dir 		= ply:GetAimVector(),			-- Dir of bullet
		Spread		= Vector(aimcone, aimcone, 0),			-- Aim Cone
		Tracer		= 1, 						-- Show a tracer on every x bullets
		TracerName	= "Ar2Tracer",
		Force		= damage * 0.5,					-- Amount of force to give to phys objects
		Damage		= damage,
		Callback	= function(attacker, tracedata, dmginfo) 
			return self:RicochetCallback(0, attacker, tracedata, dmginfo) 
		end
	})

	--local anglo = Angle(math.Rand(-self.Primary.KickDown,-self.Primary.KickUp), 0, 0)
	local anglo = Angle(math.Rand(-self.Primary.KickDown,self.Primary.KickUp)*recoil, math.Rand(-self.Primary.KickHorizontal,self.Primary.KickHorizontal)*recoil, 0)
	ply:ViewPunch(anglo)

	local eyeang = ply:EyeAngles()
		eyeang.pitch = eyeang.pitch - anglo.pitch
		eyeang.yaw = eyeang.yaw - anglo.yaw
	ply:SetEyeAngles(eyeang)
end


