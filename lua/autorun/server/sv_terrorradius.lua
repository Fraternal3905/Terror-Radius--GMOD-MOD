local chaseTheme = CreateConVar("terrorradius_chase_theme", "1x1x1x1", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Sets the chase themes for the terror radius.")

local distance = CreateConVar("terrorradius_distance", "2000", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Sets the distance at which the terror radius music will start playing.")
local distanceSqr = distance * distance

local fullChaseDistance = CreateConVar("terrorradius_full_chase_distance", "500", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Sets the distance at which the terror radius music will be in full chase mode.")

local lowHPChase = CreateConVar("terrorradius_low_hp_chase_multiplier", "0.5", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Sets the health multiplier at which Low HP chase music will start playing.")

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
    --[[if cachedEnts ~= #ents.GetAll() then
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
    end]] -- This was just for testing purposes to auto whitelist NPCs and NextBots
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