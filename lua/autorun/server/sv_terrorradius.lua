local distance = 2000
local distanceSqr = distance * distance

local whitelisted = {}
local cachedClasses = {}

local cachedEnts = nil

function GetClosestPlayer(pos)
    local distance = distanceSqr
    local ent
    for i, v in pairs(player.GetAll()) do
        local dist = v:GetPos():DistToSqr(pos)
        if dist < distance then
            distance = dist
            ent = v
        end
    end
    return ent
end

local function OnStuck(self)
    print("ee")
	if self:IsClimbing() then return end
	if self:IsPossessed() then return end
	if self.CanExitFromStuck == false then return end
	if not navmesh.IsLoaded() then return end
    print("checks out")
	self.LastStuck = CurTime()

	-- Don't warp across the whole map.
	-- Besides, if we try to warp onto a player, it doesn't work.
	-- Not sure why, but it might have something to do with the hook we're in.
	if self.StuckTries > 10 then
		self.StuckTries = 0
	end

	-- Jump forward a bit on the path.
	local newCursor = self:GetPath():GetCursorPosition()
		+ 40*self:GetScale() * math.pow(2, self.StuckTries)
	local newPos = self:GetPath():GetPositionOnPath(newCursor)
	self.StuckTries = self.StuckTries + 1

	-- Some malformed navmeshes have climb junctions that pass through the
	-- void. We'll check for those and try not to fall out of the map.
	if not util.IsInWorld(newPos) then
		-- The next stuck check will retry this.
		return
	end
	if self:HasEnemy() and IsValid(self:GetEnemy()) then
		if not (newPos:IsEqualTol(self:GetEnemy():GetPos(), self.StuckEnemyDistanceTolerance )) then
			self:SetPos(newPos)
		end
	else
		self:SetPos(newPos)
	end
	-- Hope that we're not stuck anymore.
	self.loco:ClearStuck()
	--self:OnStuck_Monster()
end

local terrorRadiusMusic = "musics/terrorradiusmusic/"
local chaseTheme = "classicx"

hook.Add("Think", "TerrorRadiusThink", function()
    if cachedEnts ~= #ents.GetAll() then
        for i, v in pairs(ents.GetAll()) do
            if (v:IsNextBot() or v:IsNPC()) then
                local className = v:GetClass()
                if not cachedClasses[className] then
                    cachedClasses[className] = true
                    table.insert(whitelisted, className)
                end
                if v:IsNextBot() then
                    --[[v.StuckTries = 0
                    v.StuckEnemyDistanceTolerance = 250]]
                    --[[function v:OnStuck()
                        OnStuck(self)
                    end]]
                end
            end
        end
        cachedEnts = #ents.GetAll()
    end
    for i, v in ipairs(whitelisted) do
        local getAllClass = ents.FindByClass(v)
        for i, v2 in pairs(getAllClass) do
            if not v2.Whitelisted then
                --v2:SetNWBool("TerrorRadiusWhitelisted", true)
                v2.Whitelisted = true 
                if math.random(1, 2) == 1 then
                    --v2:SetNWString("TerrorRadiusMusic", "classicx")
                end
            end
            local e = v2.lastThing or 0
            if CurTime() - e <= 1 then
                continue 
            end
            v2.lastThing = CurTime()
            --hook.Call( "OnNPCKilled", GAMEMODE, v2, nil, nil )
            --[[local loco = v2.loco
            local ray = util.TraceLine({
                start = v2:GetPos(),
                endpos = v2:GetPos() + (v2:GetVelocity() * FrameTime()),
                filter = {v2}
            })
            local pos = ray.HitPos
            local ray = util.TraceLine({
                start = pos,
                endpos = pos + Vector(0, 0, 1000),
                filter = {v2}
            })
            local distance = (pos:Distance(ray.HitPos))
            --[[loco:SetAcceleration(5000)
            loco:SetDeceleration(5000)]]
            --[[print(distance)
            loco:SetStepHeight(math.Clamp(distance, 18, 100) / 2)
            loco:SetJumpHeight(100)
            loco:SetClimbAllowed(true)
            loco:SetDeathDropHeight(math.huge)]]
            --terminator_Extras.dynamicallyPatchPos( v2:GetPos() ) print("yeah")
            local pos = v2:GetPos()
            local closestPlayer = GetClosestPlayer(pos)
            if IsValid(closestPlayer) and closestPlayer:GetPos():DistToSqr(pos) <= distanceSqr then
                v2:SetNWVector("ServerPos", pos)
            else
                v2:SetNWVector("ServerPos", nil)
            end
        end
    end
end)