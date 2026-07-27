-- ox_core bridge
--
-- Ohne eine geladene Bruecke sind `item`, `items`, `job`, `gang` und `groups` am
-- Menueeintrag wirkungslos -- `apply_framework_restrictions` steigt bei
-- `Bridge.active == false` sofort aus. Upstream gibt es nur Bruecken fuer ESX und
-- QBCore, ox_core hatte keine. Diese hier schliesst die Luecke.
--
-- ox_core kennt keine "jobs", sondern **Gruppen**: ein Spieler kann in mehreren
-- gleichzeitig sein, jede mit eigenem Grad. Das laesst sich nicht sinnvoll auf
-- das eine `job`-Feld abbilden, deshalb liefern `getJob` und `getGang` hier nichts
-- und stattdessen gibt es `hasGroup` -- passend zu ox_targets `groups`-Feld.

return {
    client = function()
        local groups = {}
        local seeded = false

        --- Fragt ox_core direkt. Nur beim ersten Mal noetig; danach halten uns die
        --- Ereignisse auf dem Laufenden.
        local function seed()
            if GetResourceState('ox_core') ~= 'started' then return end

            local ok, res = pcall(function()
                return exports.ox_core:CallPlayer('getGroups')
            end)

            if ok and type(res) == 'table' then
                groups = res
                seeded = true
            end
        end

        RegisterNetEvent('ox:setActiveCharacter', function(_, playerGroups)
            groups = type(playerGroups) == 'table' and playerGroups or {}
            seeded = true
        end)

        RegisterNetEvent('ox:setGroup', function(name, grade)
            if type(name) ~= 'string' then return end

            if grade and grade > 0 then
                groups[name] = grade
            else
                groups[name] = nil
            end
        end)

        -- Es gibt kein Abmelde-Ereignis. ox_core leert seine eigenen Gruppen an
        -- genau dieser Stelle (client/player/index.ts:34-41), also tun wir es auch.
        RegisterNetEvent('ox:startCharacterSelect', function()
            groups = {}
            seeded = false
        end)

        CreateThread(seed)

        --- Prueft eine Gruppenvorgabe in allen drei Schreibweisen, die ox_target
        --- zulaesst: 'police', { 'police', 'ambulance' } oder { police = 2 }.
        ---
        --- Bewusst in Lua gerechnet statt ueber ox_cores `getGroup`: das prueft
        --- `if (grade && requiredGrade <= grade)`, und in JavaScript ist die 0
        --- unwahr -- ein Mitglied mit Grad 0 fiele dort durch.
        ---@param filter string|string[]|table<string, number>
        ---@return boolean
        local function hasGroup(filter)
            if not filter then return true end
            if not seeded then seed() end

            if type(filter) == 'string' then
                return groups[filter] ~= nil
            end

            if type(filter) ~= 'table' then return false end

            for key, value in pairs(filter) do
                if type(key) == 'number' then
                    -- Liste: { 'police', 'ambulance' } -- Mitgliedschaft genuegt
                    if groups[value] ~= nil then return true end
                else
                    -- Tabelle: { police = 2 } -- Grad muss reichen
                    local grade = groups[key]
                    if grade and grade >= (tonumber(value) or 0) then return true end
                end
            end

            return false
        end

        return {
            -- ox_core hat kein Job-Modell. Nichts zurueckgeben ist ehrlicher,
            -- als eine beliebige Gruppe zum "job" zu erklaeren.
            ['getJob'] = function()
                return nil, nil
            end,
            ['getGang'] = function()
                return nil, nil
            end,
            ['hasGroup'] = hasGroup,
            ['hasItem'] = function(item_name, required_amount)
                required_amount = required_amount or 1

                local ok, count = pcall(function()
                    return exports.ox_inventory:GetItemCount(item_name, nil, true)
                end)

                if not ok or type(count) ~= 'number' then return false, false end

                return count > 0, count >= required_amount
            end
        }
    end
}
