function GetIsTimeUp(timeof, timelimitof)
 local time = Shared.GetTime()
 local boolean = (timeof + timelimitof) < time
 --Print("timeof is %s, timelimitof is %s, time is %s", timeof, timelimitof, time)
 -- if boolean == true then Print("GetTimeIsUp boolean is %s, timelimitof is %s", boolean, timelimitof) end
 return boolean
end


function GetSetupConcluded()
return GetFrontDoorOpen()
end
function GetFrontDoorOpen()
   return GetTimer():GetFrontOpenBoolean()
end
function GetSiegeDoorOpen()
   local boolean = GetTimer():GetSiegeOpenBoolean()
   return boolean
end



function GetPayloadPercent()  //change to link 
    local entityList = Shared.GetEntitiesWithClassname("AvocaArc")
    if entityList:GetSize() > 0 then
                 local payload = entityList:GetEntityAtIndex(0) 
                 local furthestgoal = payload:GetHighestWaypoint()
                 local speed = payload:GetMoveSpeed()
                 local isReverse = speed < 1
                 local distance =  GetPathDistance(payload:GetOrigin(), furthestgoal:GetOrigin()) 
                 local time = math.round(distance / speed, 1)
                 //Print("Distance is %s, speed is %s, time is %s", distance, speed, time)
                 return time, speed, isReverse
    end    
    return nil
end

function GetSiegeDoor() --it washed away
    local entityList = Shared.GetEntitiesWithClassname("SiegeDoor")
    if entityList:GetSize() > 0 then
                 local siegedoor = entityList:GetEntityAtIndex(0) 
                 return siegedoor
    end    
    return nil
end
function GetTimer() --it washed away
    local entityList = Shared.GetEntitiesWithClassname("Timer")
    if entityList:GetSize() > 0 then
                 local timer = entityList:GetEntityAtIndex(0) 
                 return timer
    end    
    return nil
end

function GetGameStarted()
     local gamestarted = false
   if GetGamerules():GetGameState() == kGameState.Started or GetGamerules():GetGameState() == kGameState.Countdown then gamestarted = true end
   return gamestarted
end
function GetIsInSiege(who)
local locationName = GetLocationForPoint(who:GetOrigin())
                     locationName = locationName and locationName.name or nil
                     if locationName== nil then return false end
if locationName and string.find(locationName, "siege") or string.find(locationName, "Siege") then return true end
return false
end

function GetWhereIsInSiege(where)
local locationName = GetLocationForPoint(where)
                     locationName = locationName and locationName.name or nil
                     if locationName== nil then return false end
if string.find(locationName, "siege") or string.find(locationName, "Siege") then return true end
return false
end
