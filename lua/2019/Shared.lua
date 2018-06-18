//Script.Load("lua/Additions/Additions.lua")
//Script.Load("lua/Modifications/Modifications.lua")
//Script.Load("lua/SiegeMod/unstick.lua")

Script.Load("lua/doors/Doors.lua")
Script.Load("lua/doors/BreakableDoor.lua")
Script.Load("lua/doors/timer.lua")
Script.Load("lua/director/director_camera.lua")
Script.Load("lua/2019/Functions19.lua")
Script.Load("lua/AntiExploit.lua")
Script.Load("lua/WeldPoint.lua")
Script.Load("lua/Convars19.lua")
Script.Load("lua/2019/LayStructures.lua")
Script.Load("lua/2019/ARC_Credits.lua")


local function GetHasSentryBatteryInRadius(self)
      local backupbattery = GetEntitiesWithinRange("SentryBattery", self:GetOrigin(), kBatteryPowerRange)
          for index, battery in ipairs(backupbattery) do
            if GetIsUnitActive(battery) then return true end
           end      
 
   return false
end

function PowerConsumerMixin:GetIsPowered() 
    return self.powered or self.powerSurge or GetHasSentryBatteryInRadius(self)
end


kMaxEntitiesInRadius = 99
kMaxEntityRadius = 99


//Script.Load("lua/payload/payload_arc_wp.lua") //important to load wp before arc lol
//Script.Load("lua/payload/AvocaArc.lua") // needs linked waypoint and rewrite for current next prev chain



