local sounds = {
	["zx9.Single"] = {
		chan = CHAN_USER_BASE+10,
		vol = 1.0,
		file = "weapons/Bianachi/bian-2.wav"
	},
	["m20.Single"] = {
		chan = CHAN_USER_BASE+10,
		vol = 1.0,
		file = "weapons/xamas/xamas-1.wav"
	},
	["r22.Single"] = {
		chan = CHAN_USER_BASE+10,
		vol = 1.0,
		file = "weapons/zamas/zamas-1.wav"
	},
	["kriss_vector.Single"] = {
		chan = CHAN_USER_BASE+10,
		vol = 1.0,
		file = "weapons/Kriss/ump45-1.wav"
	},
	["kriss_vector.Magrelease"] = {
		chan = CHAN_ITEM,
		vol = 1.0,
		file = "weapons/Kriss/magrel.wav"
	},
	["kriss_vector.Clipout"] = {
		chan = CHAN_ITEM,
		vol = 1.0,
		file = "weapons/Kriss/clipout.wav"
	},
	["kriss_vector.Dropclip"] = {
		chan = CHAN_ITEM,
		vol = 1.0,
		file = "weapons/Kriss/dropclip.wav"
	},
	["kriss_vector.Clipin"] = {
		chan = CHAN_ITEM,
		vol = 1.0,
		file = "weapons/Kriss/clipin.wav"
	},
	["kriss_vector.Boltpull"] = {
		chan = CHAN_ITEM,
		vol = 1.0,
		file = "weapons/Kriss/boltpull.wav"
	},
	["kriss_vector.unfold"] = {
		chan = CHAN_ITEM,
		vol = 1.0,
		file = "weapons/Kriss/unfold.wav"
	},
	["Weapon_uzi.single"] = {
		chan = CHAN_USER_BASE+10,
		vol = 1.0,
		file = "weapons/uzi/mac10-1.wav"
	},
	["imi_uzi_09mm.boltpull"] = {
		chan = CHAN_ITEM,
		vol = 1.0,
		file = "weapons/uzi/mac10_boltpull.wav"
	},
	["imi_uzi_09mm.clipin"] = {
		chan = CHAN_ITEM,
		vol = 1.0,
		file = "weapons/uzi/mac10_clipin.wav"
	},
	["imi_uzi_09mm.clipout"] = {
		chan = CHAN_ITEM,
		vol = 1.0,
		file = "weapons/uzi/mac10_clipout.wav"
	},
	["Wep_fnscarh.Single"] = {
		chan = CHAN_USER_BASE+10,
		vol = 1.0,
		file = {
			"weapons/fnscarh/aug-1.wav",
			"weapons/fnscarh/aug-2.wav",
			"weapons/fnscarh/aug-3.wav"
		}
	},
	["spas_12_shoty.Single"] = {
		chan = CHAN_USER_BASE+10,
		vol = 1.0,
		file = "weapons/spas_12/xm1014-1.wav"
	},
	["spas_12_shoty.insert"] = {
		chan = CHAN_ITEM,
		vol = 1.0,
		file = "weapons/spas_12/xm_insert.wav"
	},
	["spas_12_shoty.cock"] = {
		chan = CHAN_ITEM,
		vol = 1.0,
		file = "weapons/spas_12/xm_cock.wav"
	},
	["Wep_fnscar.Boltpull"] = {
		chan = CHAN_ITEM,
		vol = 1.0,
		file = "weapons/fnscarh/aug_boltpull.wav"
	},
	["Wep_fnscar.Boltslap"] = {
		chan = CHAN_ITEM,
		vol = 1.0,
		file = "weapons/fnscarh/aug_boltslap.wav"
	},
	["Wep_fnscar.Clipout"] = {
		chan = CHAN_ITEM,
		vol = 1.0,
		file = "weapons/fnscarh/aug_clipout.wav"
	},
	["Wep_fnscar.Clipin"] = {
		chan = CHAN_ITEM,
		vol = 1.0,
		file = "weapons/fnscarh/aug_clipin.wav"
	},
	["Weapon_usas.Single"] = {
		chan = CHAN_USER_BASE+10,
		vol = 1.0,
		file = "weapons/usas12/xm1014-1.wav"
	},
	["Weapon_usas.clipin"] = {
		chan = CHAN_ITEM,
		vol = 1.0,
		file = "weapons/usas12/magin.wav"
	},
	["Weapon_usas.clipout"] = {
		chan = CHAN_ITEM,
		vol = 1.0,
		file = "weapons/usas12/magout.wav"
	},
	["Weapon_usas.draw"] = {
		chan = CHAN_ITEM,
		vol = 1.0,
		file = "weapons/usas12/draw.wav"
	},
	["hk416weapon.SilencedSingle"] = {
		chan = CHAN_USER_BASE+10,
		vol = 1.0,
		file = "weapons/twinkie_hk416/m4a1-1.wav"
	},
	["hk416weapon.UnsilSingle"] = {
		chan = CHAN_USER_BASE+10,
		vol = 1.0,
		file = "weapons/twinkie_hk416/m4a1_unsil-1.wav"
	},
	["hk416weapon.Clipout"] = {
		chan = CHAN_ITEM,
		vol = 1.0,
		file = "weapons/twinkie_hk416/m4a1_clipout.wav"
	},
	["hk416weapon.Magtap"] = {
		chan = CHAN_ITEM,
		vol = 1.0,
		file = "weapons/twinkie_hk416/m4a1_tap.wav"
	},
	["hk416weapon.Clipin"] = {
		chan = CHAN_ITEM,
		vol = 1.0,
		file = "weapons/twinkie_hk416/m4a1_clipin.wav"
	},
	["hk416weapon.Boltpull"] = {
		chan = CHAN_ITEM,
		vol = 1.0,
		file = "weapons/twinkie_hk416/m4a1_boltpull.wav"
	},
	["hk416weapon.Boltrelease"] = {
		chan = CHAN_ITEM,
		vol = 1.0,
		file = "weapons/twinkie_hk416/m4a1_boltrelease.wav"
	},
	["hk416weapon.Deploy"] = {
		chan = CHAN_ITEM,
		vol = 1.0,
		file = "weapons/twinkie_hk416/m4a1_deploy.wav"
	},
	["hk416weapon.Silencer_On"] = {
		chan = CHAN_ITEM,
		vol = 1.0,
		file = "weapons/twinkie_hk416/m4a1_silencer_on.wav"
	},
	["hk416weapon.Silencer_Off"] = {
		chan = CHAN_ITEM,
		vol = 1.0,
		file = "weapons/twinkie_hk416/m4a1_silencer_off.wav"
	},
	["KAC_PDW.Single"] = {
		chan = CHAN_USER_BASE+10,
		vol = 1.0,
		file = "weapons/kac_pdw/m4a1_unsil-1.wav"
	},
	["KAC_PDW.SilentSingle"] = {
		chan = CHAN_USER_BASE+10,
		vol = 1.0,
		file = "weapons/kac_pdw/m4a1-1.wav"
	},
	["kac_pdw_001.Clipout"] = {
		chan = CHAN_ITEM,
		vol = 1.0,
		file = "weapons/kac_pdw/m4a1_clipout.wav"
	},
	["kac_pdw_001.Clipin"] = {
		chan = CHAN_ITEM,
		vol = 1.0,
		file = "weapons/kac_pdw/m4a1_clipin.wav"
	},
	["kac_pdw_001.Boltpull"] = {
		chan = CHAN_ITEM,
		vol = 1.0,
		file = "weapons/kac_pdw/m4a1_boltpull.wav"
	},
	["kac_pdw_001.Deploy"] = {
		chan = CHAN_ITEM,
		vol = 1.0,
		file = "weapons/kac_pdw/m4a1_deploy.wav"
	},
	["kac_pdw_001.Silencer_On"] = {
		chan = CHAN_ITEM,
		vol = 1.0,
		file = "weapons/kac_pdw/m4a1_silencer_on.wav"
	},
	["kac_pdw_001.Silencer_Off"] = {
		chan = CHAN_ITEM,
		vol = 1.0,
		file = "weapons/kac_pdw/m4a1_silencer_off.wav"
	},
	["hk_g3_weapon.Single"] = {
		chan = CHAN_USER_BASE+10,
		vol = 1.0,
		file = "weapons/hk_g3/galil-1.wav"
	},
	["hk_g3_weapon.Clipout"] = {
		chan = CHAN_ITEM,
		vol = 1.0,
		file = "weapons/hk_g3/galil_clipout.wav"
	},
	["hk_g3_weapon.Clipin"] = {
		chan = CHAN_ITEM,
		vol = 1.0,
		file = "weapons/hk_g3/galil_clipin.wav"
	},
	["hk_g3_weapon.Boltpull"] = {
		chan = CHAN_ITEM,
		vol = 1.0,
		file = "weapons/hk_g3/boltpull.wav"
	},
	["hk_g3_weapon.Boltforward"] = {
		chan = CHAN_ITEM,
		vol = 1.0,
		file = "weapons/hk_g3/boltforward.wav"
	},
	["hk_g3_weapon.cloth"] = {
		chan = CHAN_ITEM,
		vol = 1.0,
		file = "weapons/hk_g3/Cloth.wav"
	},
	["hk_g3_weapon.draw"] = {
		chan = CHAN_ITEM,
		vol = 1.0,
		file = "weapons/hk_g3/draw.wav"
	},
	["92FS.single"] = {
		chan = CHAN_WEAPON,
		vol = 1.0,
		level = SNDLVL_GUNFIRE,
		pitch = {90,110},
		file = "GDC/TRH_92FS/92FS-1.wav"
	},
	["92FS.Deploy"] = {
		chan = CHAN_USER_BASE+1,
		vol = 1.0,
		level = SNDLVL_IDLE,
		file = "GDC/TRH_92FS/deploy.wav"
	},
	["92FS.Foley"] = {
		chan = CHAN_USER_BASE+1,
		vol = 1.0,
		level = SNDLVL_IDLE,
		file = "GDC/TRH_92FS/foley.wav"
	},
	["92FS.ClipOut"] = {
		chan = CHAN_WEAPON,
		vol = 1.0,
		level = SNDLVL_NORM,
		file = "GDC/TRH_92FS/clip_out.wav"
	},
	["Weapon.MagDropPistol"] = {
		chan = CHAN_ITEM,
		vol = 0.1,
		level = SNDLVL_IDLE,
		file = {
			"GDC/Universal/magdrop_pistol1.wav",
			"GDC/Universal/magdrop_pistol2.wav",
			"GDC/Universal/magdrop_pistol3.wav"
		}
	},
	["92FS.ClipIn"] = {
		chan = CHAN_WEAPON,
		vol = 1.0,
		level = SNDLVL_NORM,
		file = "GDC/TRH_92FS/clip_in.wav"
	},
	["92FS.ClipLocked"] = {
		chan = CHAN_ITEM,
		vol = 1.0,
		level = SNDLVL_NORM,
		file = "GDC/TRH_92FS/clip_locked.wav"
	},
	["92FS.SlideBack"] = {
		chan = CHAN_WEAPON,
		vol = 1.0,
		level = SNDLVL_NORM,
		file = "GDC/TRH_92FS/slide_back.wav"
	},
	["92FS.SlideForward"] = {
		chan = CHAN_ITEM,
		vol = 1.0,
		level = SNDLVL_NORM,
		file = "GDC/TRH_92FS/slide_forward.wav"
	}
}

for k, v in pairs(sounds) do
	local obj = {
		name = k,
		channel = v.chan,
		volume = v.vol,
		sound = v.file
	}
	if v.level then
		obj.soundlevel = v.level
	end
	if v.pitch then
		obj.pitchstart = v.pitch[1]
		obj.pitchend = v.pitch[2]
	end
	sound.Add(obj)
end


