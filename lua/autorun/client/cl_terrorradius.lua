local terrorRadiusMusic = "musics/terrorradiusmusic/"
local chaseTheme = "bluududd"

local distance = 2000
local fullChaseDistance = 500 -- 1238
local lowHPChase = 0.5
local chased = false 
local outro
local playingLayer
local introPlayed = false 
local dontSetTime = true  
local layers = {}

local chaseThemeStations = {}
local chaseThemeStationsMeta = {}

function ReloadChaseThemeStations()
    local searchDir = terrorRadiusMusic
    local chaseThemeFiles2, dir = file.Find("sound/".. searchDir.. "*", "GAME")
    for i, v2 in pairs(dir) do
        local chaseThemeFiles = file.Find("sound/".. searchDir.. v2.. "/*", "GAME")
        for i, v in pairs(chaseThemeFiles) do
            local currentStation
            local vlower = string.lower(v)
            local v2lower = string.lower(v2)
            local vlowernowav = string.Replace(vlower, ".wav", "")
            local dataName = v2lower.. vlowernowav
            sound.PlayFile("sound/".. terrorRadiusMusic.. v2.. "/".. v, "noplay", function(station, errCode, errStr)
                if station then
                    if not string.find(vlower, "intro") and not string.find(vlower, "outro") then
                        station:EnableLooping(true)
                    end
                    currentStation = station
                    chaseThemeStations[dataName] = currentStation
                    chaseThemeStationsMeta[currentStation] = {}
                    if string.StartsWith(vlower, "layer") and not string.find(vlower, "intro") then
                        if not layers[v2lower] then
                            layers[v2lower] = 0
                        end
                        layers[v2lower] = layers[v2lower] + 1
                    end
                end
            end)
        end
    end
end
ReloadChaseThemeStations()
timer.Simple(1, function()
    PrintTable(chaseThemeStations) 
end)

local distanceSq = distance * distance
local fullChaseDistanceSq = fullChaseDistance * fullChaseDistance

function GetClosestEnt(pos)
    local distance = distanceSq
    local ent
    for i, v in pairs(ents.GetAll()) do
        if v:GetNWBool("TerrorRadiusWhitelisted", false) then
            local dist = v:GetNWVector("ServerPos", Vector(99999, 99999, 99999)):DistToSqr(pos)
            if dist < distance then
                distance = dist
                ent = v
            end
        end
    end
    return ent
end

function fadeOut(station)
    station:SetVolume(station:GetVolume() - FrameTime() * 2)
    if station:GetVolume() <= 0.1 then
        station:Pause()
    end
end

function fadeIn(station)
    station:SetVolume(station:GetVolume() + FrameTime() * 2)
end

hook.Add("Think", "TerrorRadiusThinkClient", function()
    local ply = LocalPlayer()
    if not ply:IsValid() then return end

    local plyPos = ply:GetPos()
    local v = GetClosestEnt(plyPos)
    if IsValid(v) and ply:Health() > 0 then
        local dist = v:GetNWVector("ServerPos", Vector(99999, 99999, 99999)):DistToSqr(plyPos)
        if dist <= distanceSq then
            local chaseTheme = chaseTheme
            if v:GetNWString("TerrorRadiusMusic", nil) then
                chaseTheme = v:GetNWString("TerrorRadiusMusic", chaseTheme)
            end
            local layers = layers[chaseTheme]
            local currentLayer = math.Round((distanceSq - dist) / (distanceSq - fullChaseDistanceSq) * layers)
            if currentLayer == 0 then
                currentLayer = 1
            end
            local musicName = "layer".. tostring(currentLayer)
            local musicStation
            if dist <= fullChaseDistanceSq or chased then
                musicName = "chase"
            end
            musicName = chaseTheme.. musicName
            if ply:Health() <= lowHPChase * ply:GetMaxHealth() and chaseThemeStations[musicName.. "low"] then
                musicName = musicName.. "low"
            end
            musicStation = chaseThemeStations[musicName]
            if dist <= fullChaseDistanceSq and not chased then
                chased = true
                if not dontSetTime then
                    musicStation:SetTime(0)
                end 
            end
            local introName = musicName.. "intro"
            local outroName = musicName.. "outro"
            local introStation = chaseThemeStations[introName]
            local outroStation = chaseThemeStations[outroName]
            if IsValid(outroStation) then
                outro = outroStation
            end
            for i, v in pairs(chaseThemeStations) do
                if v ~= musicStation and v ~= introStation and v:GetVolume() > 0.1 then
                    fadeOut(v)
                end
            end
            if playingLayer ~= musicStation and IsValid(playingLayer) then
                if not dontSetTime then
                    chaseThemeStationsMeta[playingLayer].IntroPlayed = false 
                end
                if not chased then
                    musicStation:SetTime(playingLayer:GetTime()) 
                end
            end
            playingLayer = musicStation
            if IsValid(introStation) and (not chaseThemeStationsMeta[musicStation] or not chaseThemeStationsMeta[musicStation].IntroPlayed) then
                introStation:Play()
                introStation:SetVolume(1)
                introStation:SetTime(0)
                chaseThemeStationsMeta[musicStation].IntroPlayed = true
            elseif (not IsValid(introStation) or introStation:GetState() ~= GMOD_CHANNEL_PLAYING) and musicStation:GetState() ~= GMOD_CHANNEL_PLAYING then
                playingLayer = musicStation
                musicStation:Play()
            elseif IsValid(musicStation) and musicStation:GetVolume() <= 1 then
                if chaseThemeStationsMeta[musicStation].IntroPlayed then
                    fadeIn(musicStation)
                elseif musicStation:GetVolume() < 1 then
                    fadeIn(musicStation)
                end
            end
        end
    else
        chased = false 
        for i, v in pairs(chaseThemeStations) do
            if string.find(tostring(v), "outro") then
                continue 
            end
            if not dontSetTime then
                chaseThemeStationsMeta[v].IntroPlayed = false 
            end
            fadeOut(v)
        end
        if ply:Health() <= 0 then
            if IsValid(outro) and outro:GetState() ~= GMOD_CHANNEL_PLAYING then
                outro:SetTime(0)
                outro:SetVolume(1)
                outro:Play()
            end 
            outro = nil
            for i, v in pairs(chaseThemeStations) do
                if v:GetState() == GMOD_CHANNEL_PLAYING then
                    continue 
                end
                v:SetTime(0)
                chaseThemeStationsMeta[v].IntroPlayed = false 
            end
        end
    end
end)