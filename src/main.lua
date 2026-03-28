local mods = rom.mods
mods['SGG_Modding-ENVY'].auto()

---@diagnostic disable: lowercase-global
rom = rom
_PLUGIN = _PLUGIN
game = rom.game
modutil = mods['SGG_Modding-ModUtil']
chalk = mods['SGG_Modding-Chalk']
reload = mods['SGG_Modding-ReLoad']
local lib = mods['adamant-ModpackLib']

config = chalk.auto('config.lua')
public.config = config

local backup, revert = lib.createBackupSystem()

-- =============================================================================
-- MODULE DEFINITION
-- =============================================================================

public.definition = {
    id       = "ShimmeringFix",
    name     = "Shimmering Moonshot Fix",
    category = "Bug Fixes",
    group    = "Boons & Hammers",
    tooltip  = "Fixes Shimmering Moonshot not applying damage bonus to omega special.",
    default  = true,
    dataMutation = true,
    modpack = "speedrun",
}

-- =============================================================================
-- MODULE LOGIC
-- =============================================================================

local function apply()
    if not TraitData.StaffJumpSpecialTrait then return end
    backup(TraitData.StaffJumpSpecialTrait.AddOutgoingDamageModifiers, "ProjectileName")
    backup(TraitData.StaffJumpSpecialTrait.AddOutgoingDamageModifiers, "ValidProjectiles")
    backup(TraitData.StaffJumpSpecialTrait, "PropertyChanges")
    TraitData.StaffJumpSpecialTrait.AddOutgoingDamageModifiers.ProjectileName = nil
    TraitData.StaffJumpSpecialTrait.AddOutgoingDamageModifiers.ValidProjectiles = { "ProjectileStaffBall", "ProjectileStaffBallCharged" }
    for _, propertyChange in ipairs(TraitData.StaffJumpSpecialTrait.PropertyChanges) do
        propertyChange.ProjectileNames = { "ProjectileStaffBall", "ProjectileStaffBallCharged" }
    end
end

local function registerHooks()
end

-- =============================================================================
-- Wiring
-- =============================================================================

public.definition.apply = apply
public.definition.revert = revert

local loader = reload.auto_single()

modutil.once_loaded.game(function()
    loader.load(function()
        import_as_fallback(rom.game)
        registerHooks()
        if lib.isEnabled(config, public.definition.modpack) then apply() end
        if public.definition.dataMutation and not lib.isCoordinated(public.definition.modpack) then
            SetupRunData()
        end
    end)
end)

local uiCallback = lib.standaloneUI(public.definition, config, apply, revert)
rom.gui.add_to_menu_bar(uiCallback)
