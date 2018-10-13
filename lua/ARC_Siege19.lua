//Print("ARC19")Print("ARC19")Print("ARC19")Print("ARC19")Print("ARC19")Print("ARC19")Print("ARC19")Print("ARC19") 
Script.Load("lua/ResearchMixin.lua")
Script.Load("lua/RecycleMixin.lua")
--Script.Load("lua/2019/LevelsMixin.lua")


local networkVars = 

{


}
AddMixinNetworkVars(ResearchMixin, networkVars)
AddMixinNetworkVars(RecycleMixin, networkVars)
--AddMixinNetworkVars(LevelsMixin, networkVars)

local origcreate = ARC.OnCreate
function ARC:OnCreate()
    InitMixin(self, ResearchMixin)
    InitMixin(self, RecycleMixin)
   --   InitMixin(self, LevelsMixin)
    origcreate(self)
end

    /*
    
    function ARC:GetMaxLevel()
    return 10
    end
    
    function ARC:OnAddXp()
   --  local dmg = kARCDamage
     self.kAttackDamage = kARCDamage * (self.level/100) + kARCDamage --difference between self.kattack and arc.kattack :P
     end

    function ARC:GetAddXPAmount()
    return 0.25--0.25
    end
    */


if Server then


function ARC:Instruct()
   self:SpecificRules()
   return true
end
local function GetSiegeLocation()
--local locations = {}

local hive = nil

 for _, hivey in ientitylist(Shared.GetEntitiesWithClassname("Hive")) do
    hive = hivey
 end
 local siegeloc = nil
 if hive ~= nil then
  siegeloc = GetNearest(hive:GetOrigin(), "Location", nil, function(ent) return string.find(ent.name, "siege") or string.find(ent.name, "Siege") end)
 end
 
if siegeloc then return siegeloc end
 return nil
end
local function MoveToHives(self) --Closest hive from origin
--Print("Siegearc MoveToHives")
local siegelocation = GetSiegeLocation()
if not siegelocation then return true end
local siegepower = GetPowerPointForLocation(siegelocation.name)
local hiveclosest = GetNearest(siegepower:GetOrigin(), "Hive", 2)
local origin = 0

--if hiveclosest then
--origin = siegepower:GetOrigin()
--origin = origin + hiveclosest:GetOrigin()
--origin = origin + siegelocation:GetOrigin()
--origin = origin / 3
--end
if origin == 0 then origin = FindArcHiveSpawn(siegepower:GetOrigin())  end
local where = origin
               if where then
        self:GiveOrder(kTechId.Move, nil, where, nil, true, true)
                    return
                end  
   return not self.mode == ARC.kMode.Moving  and not GetIsInSiege(self)  
end
local function MoveToRandomChair(who) --Closest hive from origin
 local commandstation = GetEntitiesForTeam( "CommandStation", 1 )
  commandstation = table.random(commandstation)
 
               if commandstation then
        local origin = commandstation:GetOrigin() -- The arc should auto deploy beforehand
        who:GiveOrder(kTechId.Move, nil, origin, nil, true, true)
                    return
                end  
    -- Print("No closest hive????")    
end
local function CheckForAndActAccordingly(who)
local stopanddeploy = false
          for _, enemy in ipairs(GetEntitiesWithMixinForTeamWithinRange("Live", 2, who:GetOrigin(), kARCRange)) do
             if who:GetCanFireAtTarget(enemy, enemy:GetOrigin()) then
             stopanddeploy = true
             break
             end
          end
        --Print("stopanddeploy is %s", stopanddeploy)
       return stopanddeploy
end
local function GiveUnDeploy(who)
     --Print("GiveUnDeploy")
     who:CompletedCurrentOrder()
     who:SetMode(ARC.kMode.Stationary)
     who.deployMode = ARC.kDeployMode.Undeploying
     who:TriggerEffects("arc_stop_charge")
     who:TriggerEffects("arc_undeploying")
end
local function GiveDeploy(who)
    --Print("GiveDeploy")
who:GiveOrder(kTechId.ARCDeploy, who:GetId(), who:GetOrigin(), nil, true, true)
end
local function FindNewParent(who)
    local where = who:GetOrigin()
    local player =  GetNearest(where, "Player", 1, function(ent) return ent:GetIsAlive() end)
    if player then
    who:SetOwner(player)
    end
end
function ARC:GetIsDeployed()
return  self.deployMode == ARC.kDeployMode.Deployed
end
function ARC:SetDeployed()
GiveDeploy(self) 
end
local function hasScan(who, where)
          if not where then where = who:GetOrigin() end 
          for _, scan in ipairs(GetEntitiesForTeamWithinRange("Scan", 1, where, kScanRadius)) do
               if scan then
                  return true
             end
          end
          
          return false
end
function ARC:GiveScan()
  
   if not self:GetInAttackMode() then return end --or  self.targetPosition == nil then return end
   
   --I hate loops
     for _, entity in ipairs( GetEntitiesWithMixinWithinRange("Construct", self:GetOrigin(), 18 )) do
         if entity:GetTeamNumber() == 2 then
          local where = entity:GetOrigin()
            if not hasScan(self, where ) then  
             CreateEntity(Scan.kMapName, where, 1) 
              end
              break
         end
     end 
     

      
    for _, shade in ipairs(GetEntitiesWithinRange("Shade", self:GetOrigin(), 20)) do
       if shade:GetIsBuilt() then
           shade.shouldInk = true  --better than shade onup scan check
           break -- one at a time?
       --  self.vortexCheck = true
         end
    end
    

end
function ARC:SpecificRules()
local moving = self.mode == ARC.kMode.Moving    
local isSiegeOpen =  GetSiegeDoorOpen() 
        
local attacking = self.deployMode == ARC.kDeployMode.Deployed
            if attacking then self:GiveScan() end
local inradius =  not isSiegeOpen and ( GetIsPointWithinChairRadius(self:GetOrigin()) or CheckForAndActAccordingly(self) ) or 
                      isSiegeOpen and (  GetIsInSiege(self) and GetIsPointWithinHiveRadius(self:GetOrigin()) )
local shouldstop = false
local shouldmove = not shouldstop and not moving and not inradius
local shouldstop = moving and shouldstop
local shouldattack = inradius and not attacking 
local shouldundeploy = attacking and not inradius and not moving
  
  if moving then
    
    if shouldstop or shouldattack then 
           FindNewParent(self)
       --Print("StopOrder")
       self:ClearOrders()
       self:SetMode(ARC.kMode.Stationary)
      end 
 elseif not moving then
      
    if shouldmove and not shouldattack  then
        if shouldundeploy then
      
         GiveUnDeploy(self)
       else 
            if not isSiegeOpen then
             MoveToRandomChair(self)
            else
             MoveToHives(self)
            end
       end
       
   elseif shouldattack then
   
     GiveDeploy(self)
    return true
    
 end
 
    end
end//function


local origrules = ARC.AcquireTarget
function ARC:AcquireTarget() 

local canfire = GetSetupConcluded()
--Print("Arc can fire is %s", canfire)
if not canfire then return end
return origrules(self)
end



end//server



Shared.LinkClassToMap("ARC", ARC.kMapName, networkVars)
    


    
    
    
