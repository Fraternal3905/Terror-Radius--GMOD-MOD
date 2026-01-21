
TOOL.Name = "#whitelisttoolterrorradius.name"
TOOL.Category = "Terror Radius"
TOOL.Desc = "#whitelisttoolterrorradius.desc"
TOOL.Author = "Fraternal3905"
TOOL.ConfigName = ""

TOOL.ClientConVar["string"] = "value"
TOOL.ClientConVar["number"] = 1

if CLIENT then
    TOOL.Information = {
        {name = "left", stage = 0 },
        {name = "right", stage = 0 },
    }

    language.Add("tool.whitelisttoolterrorradius.name", "Whitelister")
    language.Add("tool.whitelisttoolterrorradius.desc", "Whitelist for terror radius")
    language.Add("tool.whitelisttoolterrorradius.left", "Whitelist/Unwhitelist an entity")
    language.Add("tool.whitelisttoolterrorradius.right", "Whitelist/Unwhitelist self")

    function TOOL:LeftClick(tr) return true end
    function TOOL:RightClick(tr) return true end
    function TOOL:Reload(tr) return true end

    --[[function TOOL.BuildCPanel(CPanel)
        CPanel:CheckBox("Force Whitelisted Entities to use Selected Chase Theme", "terrorradius_ent_force_chase")
    end]]

    return
end

function TOOL:LeftClick(tr)
    local ent = tr.Entity
    if not IsValid(ent) then return false end
    return TerrorRadius_WhitelistEnt(ent)
end

function TOOL:RightClick(tr)

end

function TOOL:Reload(tr)

end
