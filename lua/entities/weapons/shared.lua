include("sh_sounds.lua")

SWEP.Category				= "Morbus Weapons"		-- Swep Categorie (You can type what your want)
SWEP.PrintName				= "Morbus Weapon Base"
SWEP.Author 				= "Remscar, Vaas Kahn Grim, Icemane;"				-- Author Name

SWEP.HoldType				= "ar2"		-- Hold type style ("ar2" "pistol" "shotgun" "rpg" "normal" "melee" "grenade" "smg")

SWEP.MuzzleAttachment		= "1" 		-- Should be "1" for CSS models or "muzzle" for hl2 models
SWEP.ShellEjectAttachment	= "2" 		-- Should be "2" for CSS models or "1" for hl2 models

SWEP.DrawWeaponInfoBox	 	= true					-- Should we draw a weapon info when you're selecting your swep?

SWEP.Contact 				= ""						-- Author E-Mail
SWEP.Purpose 				= ""						-- Author's Informations
SWEP.Instructions	 		= ""						-- Instructions of the sweps

SWEP.Spawnable 				= false					-- Everybody can spawn this swep
SWEP.AdminSpawnable 		= false					-- Admin can spawn this swep

SWEP.Weight 				= 5						-- Weight of the swep
SWEP.AutoSwitchTo 			= false
SWEP.AutoSwitchFrom 		= false

SWEP.Primary.Sound 			= Sound("")				-- Sound of the gun
SWEP.Primary.Round 			= ("")					-- What kind of bullet?
SWEP.Primary.Cone			= 0.2					-- Accuracy of NPCs
SWEP.Primary.Recoil			= 10
SWEP.Primary.Damage			= 10
SWEP.Primary.Spread			= .01					--define from-the-hip accuracy (1 is terrible, .0001 is exact)
SWEP.Primary.NumShots		= 1
SWEP.Primary.RPM			= 0					-- This is in Rounds Per Minute
SWEP.Primary.ClipSize		= 0					-- Size of a clip
SWEP.Primary.DefaultClip	= 0					-- Default number of bullets in a clip
SWEP.Primary.KickUp			= 0					-- Maximum up recoil (rise)
SWEP.Primary.KickDown		= 0					-- Maximum down recoil (skeet)
SWEP.Primary.KickHorizontal	= 0					-- Maximum side recoil (koolaid)
SWEP.Primary.Automatic		= true					-- Automatic/Semi Auto
SWEP.Primary.Ammo			= "none"
SWEP.Primary.IronFOV		= 65

SWEP.NeverRandom			= false

SWEP.Secondary.ClipSize		= 0					-- Size of a clip
SWEP.Secondary.DefaultClip	= 0					-- Default number of bullets in a clip
SWEP.Secondary.Automatic	= false					-- Automatic/Semi Auto
SWEP.Secondary.Ammo			= "none"
SWEP.Secondary.IronFOV		= 0	

SWEP.Penetration			= false
SWEP.Ricochet				= false
SWEP.MaxRicochet			= 1
SWEP.RicochetCoin			= 1
SWEP.BoltAction				= false
SWEP.Scoped					= false
SWEP.ShellTime				= .35
SWEP.Tracer					= 0	
SWEP.CanBeSilenced			= false
SWEP.Silenced				= false
SWEP.NextSilence	 		= 0

SWEP.Kind					= WEAPON_RIFLE
SWEP.KGWeight				= 0
SWEP.AllowDrop				= true
SWEP.StoredAmmo				= 0
SWEP.IsDropped				= false
SWEP.CanBeSilenced			= false
SWEP.AutoSpawnable			= false
SWEP.ThinkOffset			= 0

SWEP.VElements				= {}
SWEP.WElements				= {}

function SWEP:Think()
	if self.ThinkOffset < CurTime() then
		self.ThinkOffset = CurTime()+0.5

		local wep = self.Weapon
		wep:SetNWBool( "IsLaserOn", wep:GetNetworkedBool("Reloading") and false or true )
	end
	self:IronSight()
end

function SWEP:GetCapabilities()
	return CAP_WEAPON_RANGE_ATTACK1, CAP_INNATE_RANGE_ATTACK1
end

function SWEP:Precache()
	util.PrecacheSound(self.Primary.Sound)
	util.PrecacheSound("Buttons.snd14")
end

function SWEP:CanPrimaryAttack()
	if self.Weapon:Clip1() <= 0 and self.Primary.ClipSize > -1 then
		self.Weapon:SetNextPrimaryFire(CurTime() + 0.5)
		self.Weapon:EmitSound("Weapons/ClipEmpty_Pistol.wav")
		return false
	end

	return true
end

function SWEP:Deploy()
	self.Weapon:SetNetworkedBool("Reloading", false)

	self:SetIronsights(false, self.Owner)					-- Set the ironsight false
	self.Weapon:SetNWBool( "IsLaserOn", true )

	self.Weapon:SendWeaponAnim( self.Silenced and ACT_VM_DRAW_SILENCED or ACT_VM_DRAW )
	self.ResetSights = CurTime() + self.Owner:GetViewModel():SequenceDuration()

	return true
end

function SWEP:ShootBulletInformation(ply)
	local CurrentDamage
	local CurrentRecoil
	local CurrentCone
	local useIronSights = (self:GetIronsights() == true and ply:KeyDown(IN_ATTACK2)) or false

	CurrentCone = useIronSights and self.Primary.Cone / 2 or self.PrimaryCone

	local damagedice = math.Rand(.85,1.15)

	CurrentDamage = self.Primary.Damage * damagedice
	CurrentRecoil = self.Primary.Recoil

	CurrentRecoil = ply:KeyDown(IN_FORWARD or IN_BACK or IN_MOVELEFT or IN_MOVERIGHT) and self.Primary.Recoil * 2 or CurrentRecoil

	self:ShootBullet(CurrentDamage, useIronSights and CurrentRecoil / 4 or CurrentRecoil, self.Primary.NumShots, CurrentCone)
end

function SWEP:GetViewModelPosition(pos, ang)
	if not self.IronSightsPos then return pos, ang end

	local bIron = self.Weapon:GetNWBool("Ironsights")

	if bIron ~= self.bLastIron then
		self.bLastIron = bIron
		self.fIronTime = CurTime()
	end

	local fIronTime = self.fIronTime or 0

	if not bIron and fIronTime < CurTime() - 0.35 then
		return pos, ang
	end

	local Mul = 1.0

	if fIronTime > CurTime() - 0.35 then
		Mul = math.Clamp((CurTime() - fIronTime) / 0.35, 0, 1)

		if not bIron then Mul = 1 - Mul end
	end

	local Offset	= self.IronSightsPos

	if self.IronSightsAng then
		ang = ang * 1
		ang:RotateAroundAxis(ang:Right(), 		self.IronSightsAng.x * Mul)
		ang:RotateAroundAxis(ang:Up(), 		self.IronSightsAng.y * Mul)
		ang:RotateAroundAxis(ang:Forward(), 	self.IronSightsAng.z * Mul)
	end

	local Right 	= ang:Right()
	local Up 		= ang:Up()
	local Forward 	= ang:Forward()

	pos = pos + Offset.x * Right * Mul
	pos = pos + Offset.y * Forward * Mul
	pos = pos + Offset.z * Up * Mul

	return pos, ang
end

function SWEP:SetIronsights(b)
	self.Weapon:SetNetworkedBool("Ironsights", b)
end

function SWEP:GetIronsights()
	return self.Weapon:GetNWBool("Ironsights")
end

function SWEP:Ammo1()
	return IsValid(self.Owner) and self.Owner:GetAmmoCount(self.Primary.Ammo) or false
end

function SWEP:DampenDrop()
	local phys = self:GetPhysicsObject()
	if not IsValid(phys) then return end
	phys:SetVelocityInstantaneous(Vector(0,0,-75) + phys:GetVelocity() * 0.001)
	phys:AddAngleVelocity(phys:GetAngleVelocity() * -0.99)
end

function SWEP:IsEquipment()
	return WEPS.IsEquipment(self)
end


