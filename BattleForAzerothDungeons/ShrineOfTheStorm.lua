--------------------------------------
-- Namespaces
--------------------------------------
local _, core = ...

------------------------------------------------------
---- Shrine of the Storm Bosses
------------------------------------------------------
core._1864 = {}

------------------------------------------------------
---- Vol'zith the Whisperer
------------------------------------------------------
local maddeningDreamCount = 0
local maddeningDreamPlayersUID = {}
local volzithKilled = false

function core._1864:VolzithTheWhisperer()
    --Defeat Vol'zith the Whisperer while all party members are afflicted with Maddening Dreams in Shrine of the Storm on Mythic difficulty.

    if volzithKilled == false then
        --Player gains Maddening Dreams
        if core.type == "SPELL_AURA_APPLIED" and core.spellId == 275690 then
            if maddeningDreamPlayersUID[core.destName] == nil then
                maddeningDreamCount = maddeningDreamCount + 1
                maddeningDreamPlayersUID[core.destName] = core.destName
                core:sendMessage(core.destName .. " has gained Maddening Dreams (" .. maddeningDreamCount .. "/" .. core.groupSize .. ")")
            end
        end

        --Player looses Maddening Dreams
        if core.type == "SPELL_AURA_REMOVED" and core.spellId == 275690 then
            if maddeningDreamPlayersUID[core.destName] ~= nil then
                maddeningDreamCount = maddeningDreamCount - 1
                maddeningDreamPlayersUID[core.destName] = nil
                core:sendMessage(core.destName .. " has lost Maddening Dreams (" .. maddeningDreamCount .. "/" .. core.groupSize .. ")")

                --If achievement was already completed then fail it
                if core.achievementsCompleted[1] == true then
                    core:getAchievementFailed()
                    core.achievementsCompleted[1] = false
                end
            end
        end

        --Check if all players have Maddening Dreams
        if maddeningDreamCount == core.groupSize then
            core:getAchievementSuccess()
            core.achievementsFailed[1] = false
        end
    end
end

function core._1864:LordStormsong()
	--Defeat Lord Stormsong without coming into contact with any Awoken Void in Shrine of the Storm on Mythic difficulty.
	if core.spellId == 269104 then
		core:getAchievementFailed(core.destName)
	end
end

function core._1864:ClearVariables()
    ------------------------------------------------------
    ---- Vol'zith the Whisperer
    ------------------------------------------------------
    maddeningDreamCount = 0
    maddeningDreamPlayersUID = {}
    volzithKilled = false
end