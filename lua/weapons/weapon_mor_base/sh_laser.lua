--not 100% tested
hook.Add( "PlayerButtonDown", "TogleLaser", function( ply, button )
		if IsFirstTimePredicted() and button == KEY_L then
        local wep = ply:GetActiveWeapon()
        if wep.ToggleLaser then
            wep:ToggleLaser()
        end
    end
end)
