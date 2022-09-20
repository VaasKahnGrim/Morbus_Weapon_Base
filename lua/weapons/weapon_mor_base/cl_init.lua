include("shared.lua")
include("cl_laser.lua")
include("cl_render.lua")

local Player = FindMetaTable("Player")
local Entity = FindMetaTable("Entity")
local Weapon = FindMetaTable("Weapon")
local Vector = FindMetaTable("Vector")
local Angle = FindMetaTable("Angle")
local CTakeDamageInfo = FindMetaTable("CTakeDamageInfo")
local CEffectData = FindMetaTable("CEffectData")

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
	Entity.SetNetworkedBool( self.Weapon, "Reloading", false)

	self.VElements = FullCopy( self.VElements )
	self.WElements = FullCopy( self.WElements )
	self.ViewModelBoneMods = FullCopy( self.ViewModelBoneMods )

	self:CreateModels(self.VElements) -- create viewmodels
	self:CreateModels(self.WElements) -- create worldmodels
	

	local ply = Entity.GetOwner(self)

	if not Entity.IsValid(ply) or not ply:IsPlayer() then return end
	if not Player.Alive(ply) then return end
	local vm = Player.GetViewModel(ply)
	if not Entity.IsValid(vm) then return end
	self:ResetBonePositions(vm)

	if (self.ShowViewModel == nil or self.ShowViewModel) then
		Entity.SetColor(vm, Color(255,255,255,255))
	else
		Entity.SetMaterial(vm, "Debug/hsv")
	end
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

			return
 		end
	end

	if Player.KeyReleased(ply, IN_ATTACK2) and not Player.KeyDown(ply, IN_USE) and not Player.KeyDown(ply, IN_SPEED) then -- If the right click is released, then
		Player.SetFOV( ply, 0, 0.3 )
		self.DrawCrosshair = false
		self:SetIronsights(false, ply) -- Set the ironsight false

		return
	end

	self.SwayScale = Player.KeyDown(ply, IN_ATTACK2) and not Player.KeyDown(ply, IN_USE) and not Player.KeyDown(ply, IN_SPEED) and 0.05 or 1.0
    self.BobScale = Player.KeyDown(ply, IN_ATTACK2) and not Player.KeyDown(ply, IN_USE) and not Player.KeyDown(ply, IN_SPEED) and 0.05 or 1.0
end

function SWEP:Reload()
	local ply = Entity.GetOwner(self)
	local wep = self.Weapon

	Weapon.DefaultReload(wep, self.Silenced and ACT_VM_RELOAD_SILENCED or ACT_VM_RELOAD)
	self.ResetSights = CurTime() + Entity.SequenceDuration(ply, Player.GetViewModel(ply))
end

function SWEP:PostReloadScopeCheck()
	local wep = self.Weapon
	if wep == nil then return end
	Entity.SetNetworkedBool(wep, "Reloading", false)
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
		end
	end
end

function SWEP:SecondaryAttack()
	return false
end

function SWEP:Holster()
	Entity.SetNetworkedBool(self.Weapon, "Reloading", false)
	
	if Entity.IsValid(self.Owner) then
		local vm = Player.GetViewModel(self.Owner)
		if not Entity.IsValid(vm) then return end
		self:ResetBonePositions(vm)
	end
	Entity.SetNWBool( self.Weapon, "IsLaserOn", false )

	return true
end

function SWEP:OnRemove()
	Entity.SetNetworkedBool(self.Weapon, "Reloading", false)

	if Entity.IsValid(self.Owner) then
		local vm = Player.GetViewModel(self.Owner)
		if not Entity.IsValid(vm) then return end 
		self:ResetBonePositions(vm)
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

	local anglo = Angle(math.Rand(-self.Primary.KickDown,self.Primary.KickUp)*recoil, math.Rand(-self.Primary.KickHorizontal,self.Primary.KickHorizontal)*recoil, 0)
	Player.ViewPunch(ply, anglo)

	local eyeang = Entity.EyeAngles(ply)
	eyeang.pitch = eyeang.pitch - anglo.pitch
	eyeang.yaw = eyeang.yaw - anglo.yaw
	Player.SetEyeAngles(ply, eyeang)
end