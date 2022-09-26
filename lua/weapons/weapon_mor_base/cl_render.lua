local Player = FindMetaTable("Player")
local Entity = FindMetaTable("Entity")
local Weapon = FindMetaTable("Weapon")
local Angle = FindMetaTable("Angle")
local vMatrix = FindMetaTable("VMatrix")

local allbones
local hasGarryFixedBoneScalingYet = false
SWEP.wRenderOrder = nil
SWEP.vRenderOrder = nil

function SWEP:ViewModelDrawn()
	local vm = Player.GetViewModel(Entity.GetOwner(self))
	if not Entity.IsValid(vm) then return end
	
	if not self.VElements then return end
	
	self:UpdateBonePositions(vm)

	if not self.vRenderOrder then
		-- // we build a render order because sprites need to be drawn after models
		self.vRenderOrder = {}

		--for k, v in pairs( self.VElements ) do
		local eleLen = #self.VElements
		for i = 1, eleLen do
			local v = self.VElements[i]

			local mdl, sprite, quad = v.type == "Model", v.Type == "Sprite", v.Type == "Quad"

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

		if v.type == "Model" and Entity.IsValid(model) then
			Entity.SetPos(model, pos + Angle.Forward(ang) * v.pos.x + Angle.Right(ang) * v.pos.y + Angle.Up(ang) * v.pos.z )
			Angle.RotateAroundAxis(ang, Angle.Up(ang), v.angle.y)
			Angle.RotateAroundAxis(ang, Angle.Right(ang), v.angle.p)
			Angle.RotateAroundAxis(ang, Angle.Forward(ang), v.angle.r)

			Entity.SetAngles(model, ang)
			local matrix = Matrix()
			vMatrix.Scale(matrix, v.size)
			Entity.EnableMatrix(model, "RenderMultiply", matrix )
			
			Entity.SetMaterial(model, v.material == "" and "" or Entity.GetMaterial(model) ~= v.material and v.material)
			
			if v.skin and v.skin ~= Entity.GetSkin(model) then
				Entity.SetSkin(model, v.skin)
			end
			
			if v.bodygroup then
				local bodyLen = #v.bodygroup
				for i = 1, bodyLen do
					local d = v.bodygroup[i]
					if Entity.GetBodygroup(model, i) == d then continue end

					Entity.SetBodygroup(model, i, d)
				end
			end
			
			if v.surpresslightning then
				render.SuppressEngineLighting(true)
			end

			render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
			render.SetBlend(v.color.a/255)
			Entity.DrawModel(model)
			render.SetBlend(1)
			render.SetColorModulation(1, 1, 1)
			
			if v.surpresslightning then
				render.SuppressEngineLighting(false)
			end

		elseif v.type == "Sprite" and sprite then
			local drawpos = pos + Angle.Forward(ang) * v.pos.x + Angle.Right(ang) * v.pos.y + Angle.Up(ang) * v.pos.z
			render.SetMaterial(sprite)
			render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
		elseif v.type == "Quad" and v.draw_func then
			local drawpos = pos + Angle.Forward(ang) * v.pos.x + Angle.Right(ang) * v.pos.y + Angle.Up(ang) * v.pos.z
			Angle.RotateAroundAxis(ang, Angle.Up(ang), v.angle.y)
			Angle.RotateAroundAxis(ang, Angle.Right(ang), v.angle.p)
			Angle.RotateAroundAxis(ang, Angle.Forward(ang), v.angle.r)
			
			cam.Start3D2D(drawpos, ang, v.size)
				v.draw_func( self )
			cam.End3D2D()
		end
	end
end

function SWEP:DrawWorldModel()
	if self.ShowWorldModel == nil or self.ShowWorldModel then
		Entity.DrawModel(self)
	end

	local tgt = Player.GetObserverTarget(localPlayer)
	if Entity.GetOwner(self) == tgt and Player.GetObserverMode(localPlayer) == OBS_MODE_IN_EYE then return end

	if not self.WElements then return end

	if not self.wRenderOrder then
		self.wRenderOrder = {}

		local weleLen = #self.WElements
		for i = 1, weleLen do
			local v = self.WElemets[i]
			
			local mdl, sprite, quad = v.type == "Model", v.type == "Sprite", v.type == "Quad"

			if mdl then
				table.insert(self.wRenderOrder, 1, k)
			elseif sprite or quad then
				table.insert(self.wRenderOrder, k)
			end
		end
	end
	
	bone_ent = Entity.IsValid(Entity.GetOwner(self)) and Entity.GetOwner(self) or self
	
	for k, name in pairs( self.wRenderOrder ) do
		local v = self.WElements[name]
		if not v then self.wRenderOrder = nil break end
		if v.hide then continue end
		
		local pos, ang
		--this should™ work
		pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent, v.bone and "ValveBiped.Bip01_R_Hand" or nil )

		if not pos then continue end

		local model = v.modelEnt
		local sprite = v.spriteMaterial

		if v.type == "Model" and Entity.IsValid(model) then
			Entity.SetPos(model, pos + Angle.Forward(ang) * v.pos.x + Angle.Right(ang) * v.pos.y + Angle.Up(ang) * v.pos.z )
			Angle.RotateAroundAxis(ang, Angle.Up(ang), v.angle.y)
			Angle.RotateAroundAxis(ang, Angle.Right(ang), v.angle.p)
			Angle.RotateAroundAxis(ang, Angle.Forward(ang), v.angle.r)

			Entity.SetAngles(model, ang)
			local matrix = Matrix()
			vMatrix.Scale(matrix, v.size)
			Entity.EnableMatrix( model, "RenderMultiply", matrix )

			Entity.SetMaterial(model, v.material == "" and "" or Entity.GetMaterial(model) ~= v.material and v.material)

			if v.skin and v.skin ~= Entity.GetSkin(model) then
				Entity.SetSkin(model, v.skin)
			end

			if v.bodygroup then
				local bodyLen = #v.bodygroup
				for i = bodyLen do
					local d = v.bodygroup[i]

					if Entity.GetBodygroup(model, i) == d then continue end

					Entity.SetBodygroup(model, i, d)
				end
			end

			if v.surpresslightning then
				render.SuppressEngineLighting(true)
			end

			render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
			render.SetBlend(v.color.a/255)
			Entity.DrawModel(model)
			render.SetBlend(1)
			render.SetColorModulation(1, 1, 1)

			if v.surpresslightning then
				render.SuppressEngineLighting(false)
			end
		elseif v.type == "Sprite" and sprite then
			local drawpos = pos + Angle.Forward(ang) * v.pos.x + Angle.Right(ang) * v.pos.y + Angle.Up(ang) * v.pos.z
			render.SetMaterial(sprite)
			render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
		elseif v.type == "Quad" and v.draw_func then
			local drawpos = pos + Angle.Forward(ang) * v.pos.x + Angle.Right(ang) * v.pos.y + Angle.Up(ang) * v.pos.z
			Angle.RotateAroundAxis(ang, Angle.Up(ang), v.angle.y)
			Angle.RotateAroundAxis(ang, Angle.Right(ang), v.angle.p)
			Angle.RotateAroundAxis(ang, Angle.Forward(ang), v.angle.r)

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

		pos, ang = self:GetBoneOrientation( basetab, v, ent )

		if not pos then return end

		pos = pos + Angle.Forward(ang) * v.pos.x + Angle.Right(ang) * v.pos.y + Angle.Up(ang) * v.pos.z
		Angle.RotateAroundAxis(ang, Angle.Up(ang), v.angle.y)
		Angle.RotateAroundAxis(ang, Angle.Right(ang), v.angle.p)
		Angle.RotateAroundAxis(ang, Angle.Forward(ang), v.angle.r)
	else
		bone = Entity.LookupBone(ent, bone_override or tab.bone)

		if not bone then return end

		pos, ang = Vector(0,0,0), Angle(0,0,0)
		local m = Entity.GetBoneMatrix(ent, bone)

		if m then
			pos, ang = vMatrix.GetTranslation(m), vMatrix.GetAngles(m)
		end

		if Entity.IsValid(Entity.GetOwner(self)) and Entity.IsPlayer(Entity.GetOwner(self)) and ent == Player.GetViewModel(Entity.GetOwner(self)) and self.ViewModelFlip then
			ang.r = -ang.r --// Fixes mirrored models
		end
	end

	return pos, ang
end

function SWEP:CreateModels( tab )
	if not tab then return end
	local tabLen = #tab
	for i = 1, tabLen do 
		local v = tab[i]

		if v.type == "Model" and v.model and v.model ~= "" and (not Entity.IsValid(v.modelEnt) or v.createdModel ~= v.model) and string.find(v.model, ".mdl") and file.Exists(v.model, "GAME") then
			v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE) --here
			if Entity.IsValid(v.modelEnt) then
				Entity.SetPos(v.modelEnt, Entity.GetPos(self))
				Entity.SetAngles(v.modelEnt, Entity.GetAngles(self))
				Entity.SetParent(v.modelEnt, self)
				Entity.SetNoDraw(v.modelEnt, true)
				v.createdModel = v.model
			else
				v.modelEnt = nil
			end
		elseif v.type == "Sprite" and v.sprite and v.sprite ~= "" and (not v.spriteMaterial or v.createdSprite ~= v.sprite) and file.Exists("materials/"..v.sprite..".vmt", "GAME") then
			local name = v.sprite.."-"
			local params = { ["$basetexture"] = v.sprite }
			local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
			--for i, j in pairs( tocheck ) do
			local checkLen = #tocheck
			for e = 1, checkLen do
				local j = tocheck[e]
				-- should™ work
				if (not v[j]) then name = name .. "0" continue end
				params["$"..j] = 1
				name = name .. "1"
			end

			v.createdSprite = v.sprite
			v.spriteMaterial = CreateMaterial(name, "UnlitGeneric", params)
		end
	end
end

function SWEP:UpdateBonePositions(vm)
	if self.ViewModelBoneMods then
		if not Entity.GetBoneCount(vm) then return end

		local loopthrough = self.ViewModelBoneMods
		if not hasGarryFixedBoneScalingYet then
			allbones = {}
			local boneCount = Entity.GetBoneCount(vm)
			for i = 0, boneCount do
				local bonename = Entity.GetBoneName(vm, i)
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

			local bone = Entity.LookupBone(vm, i)
			if not bone then continue end

			local s = Vector(v.scale.x,v.scale.y,v.scale.z)
			local p = Vector(v.pos.x,v.pos.y,v.pos.z)
			local ms = Vector(1,1,1)

			if not hasGarryFixedBoneScalingYet then
				local cur = Entity.GetBoneParent(vm, bone)
				while(cur >= 0) do
					local pscale = loopthrough[Entity.GetBoneName(vm, cur)].scale
					ms = ms * pscale
					cur = Entity.GetBoneParent(vm, cur)
				end
			end
			
			s = s * ms

			if Entity.GetManipulateBoneScale(vm, bone) ~= s then
				Entity.ManipulateBoneScale( vm, bone, s )
			end
			if Entity.GetManipulateBoneAngles(vm, bone) ~= v.angle then
				Entity.ManipulateBoneAngles( vm, bone, v.angle )
			end
			if Entity.GetManipulateBonePosition(vm, bone) ~= p then
				Entity.ManipulateBonePosition( vm, bone, p )
			end
		end
	else
		self:ResetBonePositions(vm)
	end
end

function SWEP:ResetBonePositions(vm)
	if not Entity.GetBoneCount(vm) then return end
	local boneCount = Entity.GetBoneCount(vm)
	for i = 0, boneCount do
		Entity.ManipulateBoneScale( vm, i, Vector(1, 1, 1) )
		Entity.ManipulateBoneAngles( vm, i, Angle(0, 0, 0) )
		Entity.ManipulateBonePosition( vm, i, Vector(0, 0, 0) )
	end
end


