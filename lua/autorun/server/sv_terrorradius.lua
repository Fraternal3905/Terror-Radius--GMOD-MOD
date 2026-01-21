local chaseTheme = CreateConVar("terrorradius_chase_theme", "1x1x1x1", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Sets the chase themes for the terror radius.")

local distance = CreateConVar("terrorradius_distance", "2000", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Sets the distance at which the terror radius music will start playing.")
local distanceSqr = 1

local fullChaseDistance = CreateConVar("terrorradius_full_chase_distance", "500", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Sets the distance at which the terror radius music will be in full chase mode.")

local lowHPChase = CreateConVar("terrorradius_low_hp_chase_multiplier", "0.5", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Sets the health multiplier at which Low HP chase music will start playing.")

local dontSetTime = CreateConVar("terrorradius_dont_set_time", "1", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "If enabled, the terror radius music will not reset to the beginning when entering chase mode.")  

local TOOL_EntForceChase = CreateConVar("terrorradius_ent_force_chase", "0", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "If enabled, the whitelisted entities will always have the selected chase theme and won't change from the global chase theme.")

local cachedClasses = {}
_G.whitelisted = {}
_G.whitelistedForceChase = {}

local cachedEnts = nil

local function GetClosestPlayer(pos)
    distanceSqr = distance:GetFloat() * distance:GetFloat()
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

function TerrorRadius_WhitelistEnt(ent)
    if not IsValid(ent) then return false end

    local className = ent:GetClass()
    if not className then return false end

    if table.HasValue(_G.whitelisted, className) then
        for i, v in pairs(_G.whitelisted) do
            if v == className then
                table.remove(_G.whitelisted, i)
                for i, v in pairs(ents.FindByClass(className)) do
                    v:SetNWBool("TerrorRadiusWhitelisted", false)
                    v:SetNWString("TerrorRadiusMusic", nil)
                    _G.whitelistedForceChase[className] = nil
                    v.Whitelisted = false 
                end
            end
        end
        return true
    else
        table.insert(_G.whitelisted, className)
        _G.whitelistedForceChase[className] = chaseTheme:GetString()
        return true
    end
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
    for i, v in ipairs(_G.whitelisted) do
        local getAllClass = ents.FindByClass(v)
        for i, v2 in pairs(getAllClass) do
            if not v2.Whitelisted then
                v2:SetNWBool("TerrorRadiusWhitelisted", true)
                v2.Whitelisted = true 
                if _G.whitelistedForceChase[v] then
                    v2:SetNWString("TerrorRadiusMusic", _G.whitelistedForceChase[v])
                end
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