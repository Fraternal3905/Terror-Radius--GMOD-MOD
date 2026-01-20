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

hook.Add("Think", "TerrorRadiusThink", function()
    if cachedEnts ~= #ents.GetAll() then
        for i, v in pairs(ents.GetAll()) do
            if (v:IsNextBot() or v:IsNPC()) then
                local className = v:GetClass()
                if not cachedClasses[className] then
                    cachedClasses[className] = true
                    table.insert(whitelisted, className)
                end
            end
        end
        cachedEnts = #ents.GetAll()
    end
    for i, v in ipairs(whitelisted) do
        local getAllClass = ents.FindByClass(v)
        for i, v2 in pairs(getAllClass) do
            if not v2.Whitelisted then
                v2:SetNWBool("TerrorRadiusWhitelisted", true)
                v2.Whitelisted = true 
            end
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