local LaserDot = Material( "Sprites/light_glow02_add" )
local color_red = Color(255,0,0,255)

hook.Add( "RenderScreenspaceEffects", "LaserSight", function()
	local Size = 4 + ( math.random() * 10 )
	local plys = player.GetAll()
	local len = #plys

	for i = 1, len do
		local v = plys[i]
		local wep = v:GetActiveWeapon()

		if wep:IsValid() and wep:GetNWBool( "IsLaserOn", false ) then
			local shootpos = v:GetShootPos()

			local trace = util.TraceLine({
				start = shootpos,
				endpos = shootpos + ( v:GetAimVector() * 100000 ),
				filter = v,
				mask = MASK_SHOT
			})

			local beamendpos = trace.HitPos
			local HitNormal = trace.HitNormal
			local bPos = beamendpos + HitNormal * 0.5

			cam.Start3D( EyePos(), EyeAngles() )
				render.SetMaterial( LaserDot )
				render.DrawQuadEasy( bPos, HitNormal, Size, Size, color_red, 0 )
				render.DrawQuadEasy( bPos, HitNormal * -1, Size, Size, color_red, 0 )
			cam.End3D()
		end
	end
end)


