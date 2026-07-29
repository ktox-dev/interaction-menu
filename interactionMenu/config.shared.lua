--                _
--               | |
--   _____      _| | _____  ___ _ __
--  / __\ \ /\ / / |/ / _ \/ _ \ '_ \
--  \__ \\ V  V /|   <  __/  __/ |_) |
--  |___/ \_/\_/ |_|\_\___|\___| .__/
--                             | |
--                             |_|
-- https://github.com/swkeep

Config = {}

Config.devMode = true
Config.debugPoly = true

-- Das fxmanifest meldet `provide 'ox_target'`, also halten alle Resourcen
-- ox_target fuer gestartet. Stand der Schalter hier auf false, kehrte der
-- Provider beim Laden sofort zurueck und registrierte seine Exporte nie --
-- ox_doorlock lief damit in „No such export addGlobalObject in resource
-- ox_target". Entweder der Schalter ist an oder das `provide` muss raus.
Config.provide = {
    ox_target = true,
    ox_target_test = false,
    qb_target = false,
    qb_target_test = false
}

Config.indicator = {
    enabled = true,
    eye_enabled = true,

    outline_enabled = true,
    outline_color = { 255, 255, 255, 255 },
}

Config.interactionAudio = {
    mouseWheel = {
        audioName = 'NAV_UP_DOWN',
        audioRef = 'HUD_FRONTEND_DEFAULT_SOUNDSET'
    },
    onSelect = {
        audioName = 'SELECT',
        audioRef = 'HUD_FRONTEND_DEFAULT_SOUNDSET'
    }
}

Config.intervals = {
    -- Wie oft der Suchstrahl geschossen wird.
    detection = 400,

    -- Wie oft ein **offenes** Menue seine Inhalte neu auswertet, also `bind`
    -- und `canInteract`. War vorher fest auf 1000 verdrahtet; hier nur
    -- herausgezogen, damit man daran drehen kann. Der Wert entspricht dem
    -- bisherigen Verhalten.
    sync = 1000,
}

Config.icons = {
    'glowingball',
}

Config.screenBoundaryShape = 'none' -- circle/rectangle/none
Config.controls = {
    -- Note: Player have to to reset their key bindings to default for changes to take effect.

    -- What is this?
    -- This setting allows us to define controls for all menus.
    -- Enabling this feature, significantly improves performance (0.04ms to 0.01ms).
    enforce = true,
    interact = {
        -- https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/keyboard/
        defaultMapper    = 'KEYBOARD',
        defaultParameter = 'E'
    }
}
