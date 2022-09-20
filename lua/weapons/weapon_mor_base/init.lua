AddCSLuaFile("shared.lua")
AddCSLuaFile("sh_sounds.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_laser.lua")
AddCSLuaFile("cl_render.lua")
include("shared.lua")

local Player = FindMetaTable("Player")
local Entity = FindMetaTable("Entity")
local Weapon = FindMetaTable("Weapon")
local Vector = FindMetaTable("Vector")
local CTakeDamageInfo = FindMetaTable("CTakeDamageInfo")
local CEffectData = FindMetaTable("CEffectData")

SWEP.Weight = 5

function SWEP:Initialize()
	self.ThinkOffset = CurTime() + 0.5
	util.PrecacheSound(self.Primary.Sound)
	self.Reloadaftershoot = 0 				-- Can't reload when firing
	self:SetWeaponHoldType(self.HoldType)
	Entity.SetNetworkedBool( self.Weapon, "Reloading", false)
end

function SWEP:IronSight()
	local ply = Entity.GetOwner(self)
	local wep = self.Weapon
	local isReloading = Entity.GetNWBool(wep, "Reloading")
	local curt = CurTime()

	if self.ResetSights and curt >= self.ResetSights then
		self.ResetSights = nil
		Weapon.SendWeaponAnim(self, self.Silenced and ACT_VM_IDLE_SILENCED or ACT_VM_IDLE)
	end
	
	if self.CanBeSilenced and self.NextSilence < curt then
		if Player.KeyDown(ply, IN_USE) and Player.KeyPressed(ply, IN_ATTACK2) then
			self:Silencer()
		end
	end

	if Player.KeyDown(ply, IN_SPEED) and not isReloading then -- If you are running
		Weapon.SetNextPrimaryFire(wep, curt + 0.3) -- Make it so you can't shoot for another quarter second
		self.IronSightsPos = self.RunSightsPos -- Hold it down
		self.IronSightsAng = self.RunSightsAng -- Hold it down
		self:SetIronsights(true, ply) -- Set the ironsight true
		Player.SetFOV( ply, 0, 0.3 )
	end

	if Player.KeyReleased(ply, IN_SPEED) then -- If you release run then
		self:SetIronsights(false, ply) -- Set the ironsight true
		Player.SetFOV( ply, 0, 0.3 )
	end -- Shoulder the gun

	if not Player.KeyDown(ply, IN_USE) and not Player.KeyDown(ply, IN_SPEED) then -- If the key E (Use Key) is not pressed, then
		if Player.KeyPressed(ply, IN_ATTACK2) and not isReloading then 
			Player.SetFOV( ply, self.Primary.IronFOV, 0.3 )
			self.IronSightsPos = self.SightsPos -- Bring it up
			self.IronSightsAng = self.SightsAng -- Bring it up
			self:SetIronsights(true, ply)
			self.DrawCrosshair = false -- Set the ironsight true
 		end
	end

	if Player.KeyReleased(ply, IN_ATTACK2) and not Player.KeyDown(ply, IN_USE) and not Player.KeyDown(ply, IN_SPEED) then -- If the right click is released, then
		Player.SetFOV( ply, 0, 0.3 )
		self.DrawCrosshair = false
		self:SetIronsights(false, ply) -- Set the ironsight false
	end

	self.SwayScale = Player.KeyDown(ply, IN_ATTACK2) and not Player.KeyDown(ply, IN_USE) and not Player.KeyDown(ply, IN_SPEED) and 0.05 or 1.0
    self.BobScale = Player.KeyDown(ply, IN_ATTACK2) and not Player.KeyDown(ply, IN_USE) and not Player.KeyDown(ply, IN_SPEED) and 0.05 or 1.0
end

function SWEP:Reload()
	local ply = Entity.GetOwner(self)
	local wep = self.Weapon

	Weapon.DefaultReload(wep, self.Silenced and ACT_VM_RELOAD_SILENCED or ACT_VM_RELOAD) 

	self.ResetSights = CurTime() + Entity.SequenceDuration(ply, Player.GetViewModel(ply))

	if wep ~= nil then
		if Weapon.Clip1(wep) < self.Primary.ClipSize then
		-- When the current clip < full clip and the rest of your ammo > 0, then
			Player.SetFOV( ply, 0, 0.3 )
			-- Zoom = 0
			self:SetIronsights(false)
			-- Set the ironsight to false
			Entity.SetNetworkedBool(wep, "Reloading", true)
		end

		local waitdammit = Entity.SequenceDuration(ply, Player.GetViewModel(ply))
		timer.Simple(waitdammit + .1, function() 
			if wep == nil then return end --why.. this is already being checked, whatever
			if not Entity.IsValid(ply) then return end
			if not ply.KeyDown then return end
			Entity.SetNetworkedBool(wep, "Reloading", false)
			if Player.KeyDown(ply, IN_ATTACK2) and Entity.GetClass(wep) == self.Gun then 
				if CLIENT then return end
				if self.Scoped == false then
					Player.SetFOV( ply, 0, 0.3 )
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
	if self.Weapon == nil then return end
	Entity.SetNetworkedBool(self.Weapon, "Reloading", false)
	if Player.KeyDown(self.Owner, IN_ATTACK2) and Entity.GetClass(self.Weapon) == self.Gun then 
		if CLIENT then return end
		if self.Scoped == false then
			Player.SetFOV( self.Owner, self.Secondary.IronFOV, 0.3 )
			self.IronSightsPos = self.SightsPos					-- Bring it up
			self.IronSightsAng = self.SightsAng					-- Bring it up
			self:SetIronsights(true, self.Owner)
			self.DrawCrosshair = false
		else
			return
		end
	else
		return
	end
end

function SWEP:CanPrimaryAttack()
	if Weapon.Clip1(self.Weapon) <= 0 and self.Primary.ClipSize > -1 then
		Weapon.SetNextPrimaryFire(self.Weapon, CurTime() + 0.5)
		Entity.EmitSound(self.Weapon, "Weapons/ClipEmpty_Pistol.wav")
		return false
	end

	return true
end

function SWEP:PrimaryAttack()
	local ply = Entity.GetOwner(self)

	if self:CanPrimaryAttack() and Entity.WaterLevel(ply) < 3 then
		if not Player.KeyDown(ply, IN_SPEED) and not Player.KeyDown(ply, IN_RELOAD) then
			local wep = self.Weapon
			local silenced = self.Silenced
		
			self:ShootBulletInformation(ply)
			wep:TakePrimaryAmmo(1)
			
			Weapon.SendWeaponAnim(self.Weapon, silenced and ACT_VM_PRIMARYATTACK_SILENCED or ACT_VM_PRIMARYATTACK )
			Entity.EmitSound(self.Weapon, silenced and self.Primary.SilencedSound or self.Primary.Sound, silenced and 75 or 135, 100)

			Entity.SetAnimation( ply, PLAYER_ATTACK1 )
			Entity.MuzzleFlash(ply)
			Weapon.SetNextPrimaryFire(wep, CurTime()+1/(self.Primary.RPM/60))
			self.RicochetCoin = (math.random(1,4))
			self:BoltBack()
		end
	end
end

function SWEP:SecondaryAttack()
	return false
end

function SWEP:Holster()
	Entity.SetNetworkedBool(self.Weapon, "Reloading", false)
	Entity.SetNWBool( self.Weapon, "IsLaserOn", false )

	return true
end

function SWEP:OnRemove()
	Entity.SetNetworkedBool(self.Weapon, "Reloading", false)
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
		CEffectData.SetOrigin(effectdata, tr.HitPos)
		CEffectData.SetNormal(effectdata, tr.HitNormal)
		CEffectData.SetScale(effectdata, 20)
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

 	local DotProduct = Vector.Dot(tr.HitNormal, tr.Normal * -1) 

	timer.Simple(0.05, function()
		Entity.FireBullets(attacker, {
			Num 		= 1,
			Src 		= tr.HitPos + (tr.HitNormal * 5),
			Dir 		= ((2 * tr.HitNormal * DotProduct) + tr.Normal) + (VectorRand() * 0.05),
			Spread 		= Vector(0, 0, 0),
			Tracer		= 1,
			TracerName 	= "m9k_effect_mad_ricochet_trace",
			Force		= CTakeDamageInfo.GetDamage(dmginfo) * 0.25,
			Damage		= CTakeDamageInfo.GetDamage(dmginfo) * 0.5,
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
	local ply = Entity.GetOwner(self)
	local wep = self.Weapon

	if self.BoltAction and Weapon.Clip1(wep) > 0 or Player.GetAmmoCount( ply, Weapon.GetPrimaryAmmoType(wep) ) > 0 then
		timer.Simple(.25, function() 
			if wep ~= nil then 
				if Entity.GetClass(wep) == self.Gun and self.BoltAction and (self:GetIronsights() == true) then
					Player.SetFOV( ply, 0, 0.3 )
					self:SetIronsights(false)
					Player.DrawViewModel( ply, true )
					local boltactiontime = Entity.SequenceDuration(ply, Player.GetViewModel(ply))
					timer.Simple(boltactiontime + .1, function()
						if wep ~= nil then
							if Player.KeyDown(ply, IN_ATTACK2) and Entity.GetClass(wep) == self.Gun then 
								Player.SetFOV( ply, 75/self.Secondary.ScopeZoom, 0.15 )                      		
								self.IronSightsPos = self.SightsPos					-- Bring it up
								self.IronSightsAng = self.SightsAng					-- Bring it up
								self.DrawCrosshair = false
								self:SetIronsights(true, ply)
								Player.DrawViewModel(ply, false)
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
	local ply = Entity.GetOwner(self)

	num_bullets = num_bullets or 1
	aimcone = aimcone or 0

	self:ShootEffects()

	Entity.FireBullets(ply, {
		Num 		= num_bullets,
		Src 		= Player.GetShootPos(ply),			-- Source
		Dir 		= Player.GetAimVector(ply),			-- Dir of bullet
		Spread		= Vector(aimcone, aimcone, 0),			-- Aim Cone
		Tracer		= 1, 						-- Show a tracer on every x bullets
		TracerName	= "Ar2Tracer",
		Force		= damage * 0.5,					-- Amount of force to give to phys objects
		Damage		= damage,
		Callback	= function(attacker, tracedata, dmginfo) 
			return self:RicochetCallback(0, attacker, tracedata, dmginfo) 
		end
	})
end

function SWEP:PreDrop()
	if not Entity.IsValid(self.Owner) or self.Primary.Ammo == "none" then
		return
	end

	local ammo = self:Ammo1()

	-- Do not drop ammo if we have another gun that uses this type
	local wep = Player.GetWeapons(self.Owner)
	local wepLen = #wep

	for i = 1, wepLen do
		local w = wep[i]
		if not Entity.IsValid(w) or w == self or Weapon.GetPrimaryAmmoType(w) ~= Weapon.GetPrimaryAmmoType(self) then continue end
		ammo = 0
	end

	self.StoredAmmo = ammo

	if ammo <= 0 then return end

	Player.RemoveAmmo(self.Owner, ammo, self.Primary.Ammo)
end

function SWEP:Equip(newowner)
	if Entity.IsOnFire(self) then
		Entity.Extinguish(self)
	end

	if Entity.IsValid(newowner) and self.StoredAmmo > 0 and self.Primary.Ammo ~= "none" then
		local ammo = Player.GetAmmoCount(newowner, self.Primary.Ammo)
		local given = math.min(self.StoredAmmo, (self.Primary.ClipSize*3) - ammo)

		Player.GiveAmmo(newammo, given, self.Primary.Ammo)
		self.StoredAmmo = 0
	end
end
