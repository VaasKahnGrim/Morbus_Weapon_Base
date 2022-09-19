AddCSLuaFile("shared.lua")
AddCSLuaFile("sh_sounds.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_laser.lua")
AddCSLuaFile("cl_render.lua")
include("shared.lua")

SWEP.Weight = 5


function SWEP:Initialize()
	self.ThinkOffset = CurTime()+0.5
	util.PrecacheSound(self.Primary.Sound)
	self.Reloadaftershoot = 0 				-- Can't reload when firing
	self:SetWeaponHoldType(self.HoldType)
	self.Weapon:SetNetworkedBool("Reloading", false)
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
 		end
	end

	if ply:KeyReleased(IN_ATTACK2) and not ply:KeyDown(IN_USE) and not ply:KeyDown(IN_SPEED) then -- If the right click is released, then
		ply:SetFOV( 0, 0.3 )
		self.DrawCrosshair = false
		self:SetIronsights(false, ply) -- Set the ironsight false
	end

	self.SwayScale = ply:KeyDown(IN_ATTACK2) and not ply:KeyDown(IN_USE) and not ply:KeyDown(IN_SPEED) and 0.05 or 1.0
	self.BobScale = ply:KeyDown(IN_ATTACK2) and not ply:KeyDown(IN_USE) and not ply:KeyDown(IN_SPEED) and 0.05 or 1.0
end

function SWEP:Reload()
	local ply = self:GetOwner()
	local wep = self.Weapon

	wep:DefaultReload(self.Silenced and ACT_VM_RELOAD_SILENCED or ACT_VM_RELOAD)

	self.ResetSights = CurTime() + ply:GetViewModel():SequenceDuration()
	if wep ~= nil then
		if wep:Clip1() < self.Primary.ClipSize then
			-- When the current clip < full clip and the rest of your ammo > 0, then
			ply:SetFOV( 0, 0.3 )
			-- Zoom = 0
			self:SetIronsights(false)
			-- Set the ironsight to false
			wep:SetNetworkedBool("Reloading", true)
		end
		local waitdammit = (ply:GetViewModel():SequenceDuration())
		timer.Simple(waitdammit + .1, function() 
			if wep == nil then return end
			if not IsValid(ply) then return end
			if not ply.KeyDown then return end
			wep:SetNetworkedBool("Reloading", false)
			if ply:KeyDown(IN_ATTACK2) and wep:GetClass() == self.Gun then 
				if self.Scoped == false then
					ply:SetFOV( 0, 0.3 )
					self.IronSightsPos = self.SightsPos					-- Bring it up
					self.IronSightsAng = self.SightsAng					-- Bring it up
					self:SetIronsights(true, ply)
					self.DrawCrosshair = false
				else
					return
				end
			else
				return
			end
		end)
	end
end

function SWEP:PostReloadScopeCheck()
	local wep = self.Weapon
	if wep == nil then return end
	wep:SetNetworkedBool("Reloading", false)
	local ply = self:GetOwner()
	if ply:KeyDown(IN_ATTACK2) and wep:GetClass() == self.Gun then 
		if self.Scoped == false then
			ply:SetFOV( self.Secondary.IronFOV, 0.3 )
			self.IronSightsPos = self.SightsPos					-- Bring it up
			self.IronSightsAng = self.SightsAng					-- Bring it up
			self:SetIronsights(true, ply)
			self.DrawCrosshair = false
		else
			return
		end
	else
		return
	end
end

function SWEP:CanPrimaryAttack()
	if self.Weapon:Clip1() <= 0 and self.Primary.ClipSize > -1 then
		self.Weapon:SetNextPrimaryFire(CurTime() + 0.5)
		self.Weapon:EmitSound("Weapons/ClipEmpty_Pistol.wav")
		return false
	end

	return true
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
			self:BoltBack()
		end
	end
end

function SWEP:SecondaryAttack()
	return false
end

function SWEP:Holster()
	self.Weapon:SetNetworkedBool("Reloading", false)
	self.Weapon:SetNWBool( "IsLaserOn", false )

	return true
end

function SWEP:OnRemove()
	self.Weapon:SetNetworkedBool("Reloading", false)
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
		util.ScreenShake(tr.HitPos, 5, 0.1, 0.5, 64)
		sound.Play("Bullets.DefaultNearmiss", tr.HitPos, 250, math.random(110, 180))

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

function SWEP:BoltBack()
	local ply = self:GetOwner()
	local wep = self.Weapon

	if self.BoltAction and wep:Clip1() > 0 or ply:GetAmmoCount( wep:GetPrimaryAmmoType() ) > 0 then
		timer.Simple(.25, function() 
			if wep ~= nil then 
				if wep:GetClass() == self.Gun and self.BoltAction and self:GetIronsights() == true then
					ply:SetFOV( 0, 0.3 )
					self:SetIronsights(false)
					ply:DrawViewModel(true)
					local boltactiontime = (ply:GetViewModel():SequenceDuration())
					timer.Simple(boltactiontime + .1, function()
						if wep ~= nil then
							if sply:KeyDown(IN_ATTACK2) and wep:GetClass() == self.Gun then 
								ply:SetFOV( 75/self.Secondary.ScopeZoom, 0.15 )                      		
								self.IronSightsPos = self.SightsPos					-- Bring it up
								self.IronSightsAng = self.SightsAng					-- Bring it up
								self.DrawCrosshair = false
								self:SetIronsights(true, ply)
								ply:DrawViewModel(false)
							end
						end 
					end)
				end
			else
				return
			end
		end)
	end	
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
		Spread		= Vector(aimcone, aimcone, 0),	-- Aim Cone
		Tracer		= 1, 							-- Show a tracer on every x bullets
		TracerName	= "Ar2Tracer",
		Force		= damage * 0.5,					-- Amount of force to give to phys objects
		Damage		= damage,
		Callback	= function(attacker, tracedata, dmginfo) 
			return self:RicochetCallback(0, attacker, tracedata, dmginfo) 
		end
	})
end

function SWEP:PreDrop()
	if not IsValid(self.Owner) or self.Primary.Ammo == "none" then return end
	local ammo = self:Ammo1()

	-- Do not drop ammo if we have another gun that uses this type
	local wep = self:GetOwner():GetWeapons()
	local wepLen = #wep
	for i = 1, wepLen do
		local w = wep[i]
		if not IsValid(w) or w == self or w:GetPrimaryAmmoType() ~= self:GetPrimaryAmmoType() then continue end
		ammo = 0
	end

	self.StoredAmmo = ammo

	if ammo <= 0 then return end
	self.Owner:RemoveAmmo(ammo, self.Primary.Ammo)
end

function SWEP:Equip(newowner)
	if self:IsOnFire() then
		self:Extinguish()
	end

	if IsValid(newowner) and self.StoredAmmo > 0 and self.Primary.Ammo ~= "none" then
		local ammo = newowner:GetAmmoCount(self.Primary.Ammo)
		local given = math.min(self.StoredAmmo, (self.Primary.ClipSize*3) - ammo)

		newowner:GiveAmmo( given, self.Primary.Ammo)
		self.StoredAmmo = 0
	end
end


