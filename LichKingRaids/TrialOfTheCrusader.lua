--------------------------------------
-- Namespaces
--------------------------------------
local _, core = ...

------------------------------------------------------
---- Trial of the Crusader Bosses
------------------------------------------------------
core.TrialOfTheCrusader = {}

------------------------------------------------------
---- The Northrend Beasts
------------------------------------------------------
local AcidmawKilled = false
local DreadscaleKilled = false
local snoboldMaxCounter = 0
local snoboldCounter = 4
local timerStarted = false

------------------------------------------------------
---- Lord Jaraxxus
------------------------------------------------------
local mistressOfPainCounter = 0

------------------------------------------------------
---- Faction Champions
------------------------------------------------------
local allianceChampions = {"34461","34460","34469","34467","34468","34465","34471","34466","34473","34472","34463","34470","34474","34475"}
local hordeChampions = {"34458","34451","34459","34448","34449","34445","34456","34447","34441","34454","34455","34444","34450","34453"}
local timer

------------------------------------------------------
---- Anub'arak
------------------------------------------------------
local swarmScarabCounterReached = false
local swarmScarabKilled = 0

function core.TrialOfTheCrusader:UpperBackPain()
    core:getAchievementToTrack()

    if core.difficultyID == 3 then
        --10man 2 snobold
        snoboldMaxCounter = 2
    elseif core.difficultyID == 4 then
        --25man 4 snobold
        snoboldMaxCounter = 4
    end

    --Snobold Died
    if core.type == "UNIT_DIED" and core.destID == "34800" then
        snoboldCounter = snoboldCounter - 1
        if snoboldCounter < snoboldMaxCounter then
            core:getAchievementFailed(1)
        end
    end
end

function core.TrialOfTheCrusader:NotOneButTwoJormungars()
    --Defeat Acidmaw and Dreadscale within 10 seconds of one another
    core:getAchievementToTrack(2)

    --Acidmaw killed
    if core.type == "UNIT_DIED" and core.destID == "35144" then
        print("Acidmaw Died")
        AcidmawKilled = true

        C_Timer.After(10, function()  
            if DreadscaleKilled == true then
                core:getAchievementSuccess(2)
            else
                core:getAchievementFailed(2)
            end
        end)
    end

    --Dreadscale killed
    if core.type == "UNIT_DIED" and core.destID == "34799" then
        print("Dreadscale Died")
        DreadscaleKilled = true

        C_Timer.After(10, function()
            if AcidmawKilled == true then
                core:getAchievementSuccess(2)
            else
                core:getAchievementFailed(2)
            end
        end)
    end
end

function core.TrialOfTheCrusader:ThreeSixtyPainSpike()
    --Mistress of pain summoned
    if core.type == "SPELL_SUMMON" and core.destID == "34826" then
        mistressOfPainCounter = mistressOfPainCounter + 1
        core:sendMessage(core:getAchievement() .. " Mistress of Pain Counter (" .. mistressOfPainCounter .. "/2)")
    end

    --Mistress of pain died
    if core.type == "UNIT_DIED" and core.destID == "34826" then
        mistressOfPainCounter = mistressOfPainCounter - 1
        core:sendMessage(core:getAchievement() .. " Mistress of Pain Counter (" .. mistressOfPainCounter .. "/2)")

        --If achievement was already completed, then warn player not to kill boss
        if core.achievementsCompleted[1] == true then
            core:sendMessage(core:getAchievement() .. " Mistress of pain died. Do not kill boss. Wait for another add to spawn")
            core.achievementsCompleted[1] = false
        end
    end

    if mistressOfPainCounter >= 2 then
        core:getAchievementSuccess()
    end
end

function core.TrialOfTheCrusader:FactionChampions()
    if core.inCombat == true then
        core:getAchievementToTrack()
    end

    if core.type == "UNIT_DIED" and (core:has_value(allianceChampions, core.destID) == true or core:has_value(hordeChampions, core.destID) == true) then
        if timerStarted == false then
            timerStarted = true
            core:sendMessage(core:getAchievement() .. " Timer Started. 60 seconds remaining to kill remaining champions")
            timer = C_Timer.NewTimer(60, function() 
                core:getAchievementFailed()
            end)
        end  
    end
end

function core.TrialOfTheCrusader:TwinValkyr()
    if timerStarted == false then
        timerStarted = true
        timer = C_Timer.NewTimer(180, function() 
            core:getAchievementFailed()
        end)
    end    
end

function core.TrialOfTheCrusader:Anubarak()
    core:trackMob("34605", "Swarm Scarab", 25, " 25 Swarm Scarabs Spawned. Kill them now", 5, nil, 1)

    if core.mobCounter >= 25 then
        swarmScarabCounterReached = true
    end

    if core.type == "UNIT_DIED" and swarmScarabCounterReached == true then
        swarmScarabKilled = swarmScarabKilled + 1
        if timerStarted == false then
            timerStarted = true
            C_Timer.After(30, function() 
                if swarmScarabKilled >= 25 then
                    core:getAchievementSuccess()
                else
                    core:sendMessage(core:getAchievement() .. " (" .. swarmScarabKilled .. "/25) Swarm Scarab Killed in time")
                    timerStarted = false
                    swarmScarabKilled = 0
                    swarmScarabCounterReached = false
                end
            end)
        else
            if swarmScarabKilled >= 25 then
                core:getAchievementSuccess()
            end
        end 
    end
end

function core.TrialOfTheCrusader:ClearVariables()
    ------------------------------------------------------
    ---- The Northrend Beasts
    ------------------------------------------------------
    AcidmawKilled = false
    DreadscaleKilled = false
    snoboldMaxCounter = 0
    snoboldCounter = 4

    ------------------------------------------------------
    ---- Lord Jaraxxus
    ------------------------------------------------------
    mistressOfPainCounter = 0

    ------------------------------------------------------
    ---- Faction Champions
    ------------------------------------------------------
    timerStarted = false
    if timer ~= nil then
        print("Timer Cancelled")
        timer:Cancel()
    end

    ------------------------------------------------------
    ---- Anub'arak
    ------------------------------------------------------
    swarmScarabCounterReached = false
    swarmScarabKilled = 0
end