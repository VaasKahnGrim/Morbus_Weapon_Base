local allbones
local hasGarryFixedBoneScalingYet = false
SWEP.wRenderOrder = nil
SWEP.vRenderOrder = nil

function SWEP:ViewModelDrawn()
	local vm = self.Owner:GetViewModel()
	if not IsValid(vm) then return end

	if not self.VElements then return end

	self:UpdateBonePositions(vm)

	if not self.vRenderOrder then
		-- // we build a render order because sprites need to be drawn after models
		self.vRenderOrder = {}

		local eleLen = #self.VElements

		for i = 1, eleLen do
			local v = self.VElements[i]

			local mdl, sprite quad = v.type == "Model", v.Type == "Sprite", v.Type == "Quad"

			if mdl then
				table.insert(self.vRenderOrder, 1, k)
			elseif sprite or quad then
				table.insert(self.vRenderOrder, k)
			end
		end
	end

	for k, name in ipairs( self.vRenderOrder ) do
		local v = self.VElements[name]
		if not v then self.vRenderOrder = nil break end
		if v.hide then continue end

		local model = v.modelEnt
		local sprite = v.spriteMaterial

		if not v.bone then continue end

		local pos, ang = self:GetBoneOrientation( self.VElements, v, vm )

		if not pos then continue end
		if v.type == "Model" and IsValid(model) then
			model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)

			model:SetAngles(ang)
			-- //model:SetModelScale(v.size)
			local matrix = Matrix()
			matrix:Scale(v.size)
			model:EnableMatrix( "RenderMultiply", matrix )

			model:SetMaterial(v.material == "" and "" or model:GetMaterial() ~= v.material and v.material)

			if v.skin and v.skin ~= model:GetSkin() then
				model:SetSkin(v.skin)
			end

			if v.bodygroup then
			local bodyLen = #v.bodygroup
				for i = 1, bodyLen do
					local d = v.bodygroup[i]
					if model:GetBodygroup(i) == d then continue end
					model:SetBodygroup(i, d)
				end
			end

			if v.surpresslightning then
				render.SuppressEngineLighting(true)
			end

			render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
			render.SetBlend(v.color.a/255)
			model:DrawModel()
			render.SetBlend(1)
			render.SetColorModulation(1, 1, 1)

			if v.surpresslightning then
				render.SuppressEngineLighting(false)
			end
		elseif v.type == "Sprite" and sprite then
			local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			render.SetMaterial(sprite)
			render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
		elseif v.type == "Quad" and v.draw_func then
			local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)

			cam.Start3D2D(drawpos, ang, v.size)
				v.draw_func( self )
			cam.End3D2D()
		end
	end
end

function SWEP:DrawWorldModel()
	if self.ShowWorldModel == nil or self.ShowWorldModel then
		self:DrawModel()
	end

	local tgt = LocalPlayer():GetObserverTarget()
	if self.Owner == tgt and LocalPlayer():GetObserverMode() == OBS_MODE_IN_EYE then return end

	if not self.WElements then return end

	if not self.wRenderOrder then
		self.wRenderOrder = {}

		local weleLen = #self.WElements
		for i = 1, weleLen do
			local v = self.WElements[i]

			local mdl, sprite, quad = v.type == "Model", v.type == "Sprite", v.type == "Quad"
			if mdl then
				table.insert(self.wRenderOrder, 1, i)
			elseif sprite or quad then
				table.insert(self.wRenderOrder, i)
			end
		end
	end

	bone_ent = IsValid(self.Owner) and self.Owner or self

	for k, name in pairs( self.wRenderOrder ) do
		local v = self.WElements[name]
		if not v then self.wRenderOrder = nil break end
		if v.hide then continue end

		local pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent, v.bone and "ValveBiped.Bip01_R_Hand" or nil )

		if not pos then continue end

		local model = v.modelEnt
		local sprite = v.spriteMaterial

		if v.type == "Model" and IsValid(model) then
			model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)

			model:SetAngles(ang)
			-- //model:SetModelScale(v.size)
			local matrix = Matrix()
			matrix:Scale(v.size)
			model:EnableMatrix( "RenderMultiply", matrix )

			model:SetMaterial(v.material == "" and "" or model:GetMaterial() ~= v.material and v.material)

			if v.skin and v.skin ~= model:GetSkin() then
				model:SetSkin(v.skin)
			end

			if v.bodygroup then
				local bodyLen = #v.bodygroup
				for i = 1, bodyLen do
					local d = v.bodygroup[i]
					if model:GetBodygroup(i) == d then continue end
					model:SetBodygroup(i, d)
				end
			end

			if v.surpresslightning then
				render.SuppressEngineLighting(true)
			end

			render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
			render.SetBlend(v.color.a/255)
			model:DrawModel()
			render.SetBlend(1)
			render.SetColorModulation(1, 1, 1)

			if v.surpresslightning then
				render.SuppressEngineLighting(false)
			end
		elseif v.type == "Sprite" and sprite then
			local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			render.SetMaterial(sprite)
			render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
		elseif v.type == "Quad" and v.draw_func then
			local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)

			cam.Start3D2D(drawpos, ang, v.size)
				v.draw_func( self )
			cam.End3D2D()
		end
	end
end

function SWEP:GetBoneOrientation( basetab, tab, ent, bone_override )
	local bone, pos, ang
	if tab.rel and tab.rel ~= "" then
		local v = basetab[tab.rel]

		if not v then return end

		-- // Technically, if there exists an element with the same name as a bone
		-- // you can get in an infinite loop. Let's just hope nobody's that stupid.
		pos, ang = self:GetBoneOrientation( basetab, v, ent )

		if not pos then return end

		pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
		ang:RotateAroundAxis(ang:Up(), v.angle.y)
		ang:RotateAroundAxis(ang:Right(), v.angle.p)
		ang:RotateAroundAxis(ang:Forward(), v.angle.r)
	else
		bone = ent:LookupBone(bone_override or tab.bone)

		if not bone then return end

		pos, ang = Vector(0,0,0), Angle(0,0,0)
		local m = ent:GetBoneMatrix(bone)
		if m then
			pos, ang = m:GetTranslation(), m:GetAngles()
		end

		if IsValid(self.Owner) and ent == self.Owner:GetViewModel() and self.ViewModelFlip then
			ang.r = -ang.r --// Fixes mirrored models
		end
	end

	return pos, ang
end

function SWEP:CreateModels( tab )
	if not tab then return end

	-- // Create the clientside models here because Garry says we can't do it in the render hook
	local tabLen = #tab
	for i = 1, tabLen do
		local v = tab[i]
		if v.type == "Model" and v.model and v.model ~= "" and (not IsValid(v.modelEnt) or v.createdModel ~= v.model) and string.find(v.model, ".mdl") and file.Exists (v.model, "GAME") then
			v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
			if IsValid(v.modelEnt) then
				v.modelEnt:SetPos(self:GetPos())
				v.modelEnt:SetAngles(self:GetAngles())
				v.modelEnt:SetParent(self)
				v.modelEnt:SetNoDraw(true)
				v.createdModel = v.model
			else
				v.modelEnt = nil
			end
		elseif v.type == "Sprite" and v.sprite and v.sprite ~= "" and (not v.spriteMaterial or v.createdSprite ~= v.sprite) and file.Exists ("materials/"..v.sprite..".vmt", "GAME") then
			local name = v.sprite.."-"
			local params = { ["$basetexture"] = v.sprite }
			-- // make sure we create a unique name based on the selected options
			local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
			local checkLen = #tocheck
			for e = 1, checkLen do
				local j = tocheck[e]
				if not v[j] then name = name .. "0" continue end
				params["$"..j] = 1
				name = name.."1"
			end

			v.createdSprite = v.sprite
			v.spriteMaterial = CreateMaterial(name,"UnlitGeneric",params)
		end
	end
end

function SWEP:UpdateBonePositions(vm)
	if self.ViewModelBoneMods then
		if not vm:GetBoneCount() then return end

		local loopthrough = self.ViewModelBoneMods
		if not hasGarryFixedBoneScalingYet then
			allbones = {}
			for i=0, vm:GetBoneCount() do
				local bonename = vm:GetBoneName(i)
				if self.ViewModelBoneMods[bonename] then 
					allbones[bonename] = self.ViewModelBoneMods[bonename]
				else
					allbones[bonename] = { 
						scale = Vector(1,1,1),
						pos = Vector(0,0,0),
						angle = Angle(0,0,0)
					}
				end
			end

			loopthrough = allbones
		end

		local loopLen = #loopthrough
		for i = 1, loopLen do
			local v = loopthrough[i]

			local bone = vm:LookupBone(k)
			if not bone then continue end

			local s = Vector(v.scale.x,v.scale.y,v.scale.z)
			local p = Vector(v.pos.x,v.pos.y,v.pos.z)
			local ms = Vector(1,1,1)

			if not hasGarryFixedBoneScalingYet then
				local cur = vm:GetBoneParent(bone)
				while (cur >= 0) do
					local pscale = loopthrough[vm:GetBoneName(cur)].scale
					ms = ms * pscale
					cur = vm:GetBoneParent(cur)
				end
			end

			s = s * ms

			if vm:GetManipulateBoneScale(bone) ~= s then
				vm:ManipulateBoneScale( bone, s )
			end
			if vm:GetManipulateBoneAngles(bone) ~= v.angle then
				vm:ManipulateBoneAngles( bone, v.angle )
			end
			if vm:GetManipulateBonePosition(bone) ~= p then
				vm:ManipulateBonePosition( bone, p )
			end
		end
	else
		self:ResetBonePositions(vm)
	end
end

function SWEP:ResetBonePositions(vm)
	if not vm:GetBoneCount() then return end
	for i=0, vm:GetBoneCount() do
		vm:ManipulateBoneScale( i, Vector(1, 1, 1) )
		vm:ManipulateBoneAngles( i, Angle(0, 0, 0) )
		vm:ManipulateBonePosition( i, Vector(0, 0, 0) )
	end
end


