--Kyle 'Avoca' Abent Payload ARC from TF2 from memory and playtest
class 'AvocaArc' (ARC)

local networkVars = 

{
    waypoint = "private float (1 to 25 by 0)",
    lastNearby = "private time",
    lastReverse = "private time", 
     lockedWP = "entityid"

}
AvocaArc.kMoveSpeed = 0.7
AvocaArc.kAttackDamage = 4000
AvocaArc.kMapName = "payload_arc"
local kNanoshieldMaterial = PrecacheAsset("Glow/green/green.material")
local kPhaseSound = PrecacheAsset("sound/NS2.fev/marine/structures/phase_gate_teleport")

local kMoveParam = "move_speed"
local kMuzzleNode = "fxnode_arcmuzzle"

function AvocaArc:OnCreate()
 ARC.OnCreate(self)
 self:AdjustMaxHealth(self:GetMaxHealth())
 self:AdjustMaxArmor(self:GetMaxArmor())
  self.waypoint= 1
  self.lastNearby = 0
  self.lastReverse = 0
  self.kAttackDamage = 9001
  self.lockedWP = Entity.invalidI 
  //create chain

end
function AvocaArc:CreateChain()
local nodes = {}
 
             for index, wp in ientitylist(Shared.GetEntitiesWithClassname("PLArcWP")) do
                    table.insert(nodes, wp )
                    print("current is %s", wp.current)
              end  
              
end
function AvocaArc:SetLockOnWP(userid)
   self.lockedWP = userid
     local OfWP= Shared.GetEntity( self.lockedWP ) 
   //Print("AvocaArc SetLockOnWP is %s",OfWP)
end
function AvocaArc:GetMoveSpeed()
return AvocaArc.kMoveSpeed
end
function AvocaArc:SetMoveSpeed(value)
 AvocaArc.kMoveSpeed = value
end
function AvocaArc:GetIsSelectable(byTeamNumber)
return false
end
function AvocaArc:OnInitialized()
 ARC.OnInitialized(self)
   if Server then
 self:AddTimedCallback(AvocaArc.Instruct, 1)
   self:AddTimedCallback(AvocaArc.DefensiveOrder, 8) 
 --self:AddTimedCallback(AvocaArc.Waypoint, 16)
 -- self:AddTimedCallback(AvocaArc.Scan, 6)
  -- self:AddTimedCallback(AvocaArc.PBAoe,  8)
   // self:CreateChain()
 end

end
local function GiveDeploy(who)
    --Print("GiveDeploy")
who:GiveOrder(kTechId.ARCDeploy, who:GetId(), who:GetOrigin(), nil, true, true)
end
local function PerformAttack(self)

    if self.targetPosition then
    
        self:TriggerEffects("arc_firing")    
        -- Play big hit sound at origin
        
        -- don't pass triggering entity so the sound / cinematic will always be relevant for everyone
        GetEffectManager():TriggerEffects("arc_hit_primary", {effecthostcoords = Coords.GetTranslation(self.targetPosition)})
        
        local hitEntities = GetEntitiesWithMixinWithinRange("Live", self.targetPosition, ARC.kSplashRadius)

        -- Do damage to every target in range
        RadiusDamage(hitEntities, self.targetPosition, ARC.kSplashRadius, ARC.kAttackDamage, self, true)

        -- Play hit effect on each
        for index, target in ipairs(hitEntities) do
        
            if HasMixin(target, "Effects") then
                target:TriggerEffects("arc_hit_secondary")
            end 
           
        end
        
    end
    
    -- reset target position and acquire new target
    self.targetPosition = nil
    self.targetedEntity = Entity.invalidId
    
end
function AvocaArc:OnTag(tagName)

    PROFILE("ARC:OnTag")
    
    if tagName == "fire_start" then
        PerformAttack(self)
    elseif tagName == "target_start" then
        self:TriggerEffects("arc_charge")
    elseif tagName == "attack_end" then
        self:SetMode(ARC.kMode.Targeting)
    elseif tagName == "deploy_start" then
        self:TriggerEffects("arc_deploying")
    elseif tagName == "undeploy_start" then
        self:TriggerEffects("arc_stop_charge")
    elseif tagName == "deploy_end" then
    
        -- Clear orders when deployed so new ARC attack order will be used
        self.deployMode = ARC.kDeployMode.Deployed
        self:ClearOrders()
        -- notify the target selector that we have moved.
        self.targetSelector:AttackerMoved()
    end
    
end
function AvocaArc:PBAoe()
        GetEffectManager():TriggerEffects("arc_hit_primary", {effecthostcoords = Coords.GetTranslation(self:GetOrigin())})
        local hitEntities = GetEntitiesWithMixinWithinRange("Live", self:GetOrigin(), 18)
        RadiusDamage(hitEntities, self:GetOrigin(), 18, AvocaArc.kAttackDamage, self, true)
        return true
end
function AvocaArc:GetPointValue()
 return kARCPointValue
end

function AvocaArc:GetMaxHealth()
    return 4200
end
function AvocaArc:GetMaxArmor()
    return 1000
end
function AvocaArc:SoTheGameCanEnd()
   GetGamerules():SetGameState(kGameState.Team1Won)
   return false
end
function AvocaArc:OnAdjustModelCoords(modelCoords)
    local scalexz = 1.4
    local scaley = 2.54
    local coords = modelCoords
    coords.xAxis = coords.xAxis * scalexz
    coords.yAxis = coords.yAxis * scaley
    coords.zAxis = coords.zAxis * scalexz
      
    return coords
    
end
function ARC:GetShowDamageIndicator()
    return true
end
function AvocaArc:GetHighestWaypointCount()
    return  #GetEntitiesWithinRange("PLArcWP", self:GetOrigin(), 9999999) or 0
end
function AvocaArc:GetHighestWaypoint()
    local count = #GetEntitiesWithinRange("PLArcWP", self:GetOrigin(), 9999999) or 0
        for _, ent in ientitylist(Shared.GetEntitiesWithClassname("PLArcWP")) do 
           if ent.current == count then
             return ent
          end       
    end  
end
function AvocaArc:GetShowHealthFor(player)
    return false
end
function AvocaArc:GetCanBeVortexed()
return false
end
  function AvocaArc:GetUnitNameOverride(viewer)
    local unitName = GetDisplayName(self)   
    unitName = "Payload"
return unitName
end 
function AvocaArc:GetCanTakeDamageOverride()
    return false
end
local function ReverseFromWaypoints(who)
 //if who.waypoint <= 1 or not GetFrontDoorOpen() or who:GetInAttackMode() then return true end
  if who.waypoint <= 1  or who:GetInAttackMode() then return true end
 if who.lastReverse + 16 >= Shared.GetTime() then return true end
local where = who:GetOrigin()
local destination = Vector(0,0,0)
local self = who
 local previousDestination = nil
 local currentWaypoint = self.waypoint
 local toSet = currentWaypoint
 
 
     local toMatch = currentWaypoint - 1 //2019change to current prev
    for _, ent in ientitylist(Shared.GetEntitiesWithClassname("PLArcWP")) do 
           if ent.current == toMatch then
            destination = ent:GetOrigin()
            toSet = toMatch
            break
          end       
    end  
    
   local toEven = toMatch - 1
    for _, ent in ientitylist(Shared.GetEntitiesWithClassname("PLArcWP")) do 
                if ent.current == toEven then
                previousDestination = ent:GetOrigin()
                toSet = toEven
                break
             end
    end     
    

  local closertoPrevious =(self:GetOrigin() - destination ):GetLength() <=  1 //and ( self:GetOrigin() - nextDestination) >= 
  local getIsNear 
  
    //Print("closertoNext is %s", closertoNext)   
          if closertoPrevious then
              destination = previousDestination
              self.waypoint = toSet
          end
                    self:ClearOrders()
                    self:SetMoveSpeed(0.3)
                    who:GiveOrder(kTechId.Move, nil, destination, nil, true, true)
                //    Print("Self waypoint is %s", self.waypoint)
                
                   //a trick to reset if shouldmove next and not reverse, to get back on track. 
                   // don't change its waypoint otherwise forward will be stuck in reverse
                    who.lastReverse = Shared.GetTime()
                    return true
 
 
end
local function MoveToWaypoints(who) --Closest hive from origin
//if not GetFrontDoorOpen() or who:GetInAttackMode() then return true end
if who:GetInAttackMode() then return true end//hm?
local where = who:GetOrigin()
local destination = Vector(0,0,0)
local self = who
 local nextDestination = nil
 local oldWaypoint = self.waypoint
 local count = #GetEntitiesWithinRange("PLArcWP", who:GetOrigin(), 9999999) or 0//current prev
  

 
 // Print("Self waypoint is %s", self.waypoint) //come back here. dont do this search every time. use links.
     // if ( self.lockedWP == Entity.invalidId ) then
                 local toMatch = self.waypoint
                 for _, ent in ientitylist(Shared.GetEntitiesWithClassname("PLArcWP")) do 
                       if ent.current == toMatch then //2019 change 
                        self.waypoint = ent.current
                        destination = ent:GetOrigin()
                        self:SetLockOnWP(ent:GetId())
                        break
                       end//       
                  end  //
              //end//valid link
    //  else   //next of current
        //   self.waypoint = ent.current.next
          //  destination = ent:GetOrigin() //false needs current next 
    //  end
      
      
    local toBreak = toMatch + 1
        for _, ent in ientitylist(Shared.GetEntitiesWithClassname("PLArcWP")) do 
                if ent.current == toBreak then
                nextDestination = ent:GetOrigin()
                break
             end
         end     

  local closertoNext =(self:GetOrigin() - destination ):GetLength() <=  1 //and ( self:GetOrigin() - nextDestination) >= 
  local getIsNear 
  
    //Print("closertoNext is %s", closertoNext)   
          if closertoNext then
              destination = nextDestination
              self.waypoint = toBreak
          end

                   
                    if closertoNext and self.waypoint > count then
                     //   Print("Count is %s", count)
                        // end of track
                        //self.driving = false
                        //TODO : what happens then?
                        //self.waypoint = 1
                         GiveDeploy(self)
                         if Server then 
                        self:AddTimedCallback(AvocaArc.SoTheGameCanEnd,  4)
                         end
                    end
                    if oldWaypoint ~= self.waypoint then self:PBAoe() end
                  self:ClearOrders()
                    who:GiveOrder(kTechId.Move, nil, destination, nil, true, true)
                //    Print("Self waypoint is %s", self.waypoint)
              
         
                    return true
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

local function FindNewParent(who)//make it comm
    local where = who:GetOrigin()
    local player =  GetNearest(where, "Player", 1, function(ent) return ent:GetIsAlive() end)
    if player then
    who:SetOwner(player)
    end
end

local function GiveUnDeploy(who)
     --Print("GiveUnDeploy")
     who:CompletedCurrentOrder()
     who:SetMode(ARC.kMode.Stationary)
     who.deployMode = ARC.kDeployMode.Undeploying
     who:TriggerEffects("arc_stop_charge")
     who:TriggerEffects("arc_undeploying")
end
local function PlayersNearby(who)

local players =  GetEntitiesForTeamWithinRange("Player", 1, who:GetOrigin(), 4)
local alive = true //2019 toEdit yo ! false TEMP LOL
//temp for testing
who.lastNearby = Shared.GetTime()
/*
    if not who:GetInAttackMode() and #players >= 1 then
         for i = 1, #players do
            local player = players[i]
             if player:isa("Marine")  or player:isa("Exo") then
             if player:GetIsAlive() and alive == false then alive = true who.lastNearby = Shared.GetTime() end
            end
         end
    end
    */
return alive, #players
end
if Server then

    function AvocaArc:OnOrderComplete(currentOrder)

        if currentOrder == kTechId.Move then
          self:ClearOrders()
        end
    
    end
    
    end
function AvocaArc:SpecificRules() 

//local moving = self.mode == ARC.kMode.Moving     
//Print("moving is %s", moving) 
        
local attacking = self:GetInAttackMode()
local inradius = (self:GetOrigin() == self:GetHighestWaypoint():GetOrigin()() ) //expensive much? lol //and GetIsPointWithinHiveRadius(self:GetOrigin()) //or CheckForAndActAccordingly(self)  
local playersnearby,numplayers = PlayersNearby(self)
local shouldstop = not playersnearby
local shouldmove = not shouldstop and not inradius
local shouldReverse = not shouldmove and GetIsTimeUp(self.lastNearby,16 )
shouldstop = shouldstop and not shouldReverse


//Print("shouldReverse is %s", shouldReverse)
  
    
    if shouldstop or shouldattack then 
     //  Print("StopOrder")
      // FindNewParent(self)
       self:ClearOrders()
       self:SetMode(ARC.kMode.Stationary)
      end 
      
    if not shouldattack  then
          if shouldmove then
      // Print("GiveMove")
           MoveToWaypoints(self)
          local movespeed = 0.7
           movespeed = movespeed  + 0.25
          self:SetMoveSpeed(Clamp(movespeed, 0.7, 2.5))
          elseif shouldReverse then
         ReverseFromWaypoints(self)
       end
   elseif shouldattack then
     --Print("ShouldAttack")
     GiveDeploy(self)
    return true
   end
 
end
function AvocaArc:GetDeathIconIndex()
    return kDeathMessageIcon.ARC
end

function AvocaArc:GetDamageType()
return kDamageType.StructuresOnly
end

function AvocaArc:OnGetMapBlipInfo()
    local success = false
    local blipType = kMinimapBlipType.Undefined
    local blipTeam = -1
    local isAttacked = HasMixin(self, "Combat") and self:GetIsInCombat()
    blipType = kMinimapBlipType.ARC
     blipTeam = self:GetTeamNumber()
    if blipType ~= 0 then
        success = true
    end
    
    return success, blipType, blipTeam, isAttacked, false --isParasited
end
if Server then
function AvocaArc:DefensiveOrder()
    for _, marine in ipairs(GetEntitiesWithinRange("Marine", self:GetOrigin(), 9999)) do
                     if marine:GetIsAlive() and not marine:isa("Commander") then //marine:GetClient():GetIsVirtual()
                       if ( marine.GetHasOrder and not  marine:GetHasOrder() ) then
                       marine:GiveOrder(kTechId.Defend, self:GetId(), self:GetOrigin(), nil, true, true)
                        end
                     end
    end
    return true
end

function AvocaArc:Instruct()
   self:SpecificRules()
   return true
end




end



if Client then

    function AvocaArc:OnUpdateRender()
          local showMaterial = not self:GetInAttackMode()
    
        local model = self:GetRenderModel()
        if model then

            model:SetMaterialParameter("glowIntensity", 4)

            if showMaterial then
                
                if not self.hallucinationMaterial then
                    self.hallucinationMaterial = AddMaterial(model, kNanoshieldMaterial)
                end
                
                self:SetOpacity(0.5, "hallucination")
            
            else
            
                if self.hallucinationMaterial then
                    RemoveMaterial(model, self.hallucinationMaterial)
                    self.hallucinationMaterial = nil
                end//
                
                self:SetOpacity(1, "hallucination")
            
            end //showma
            
        end//omodel
end //up render
end -- client


Shared.LinkClassToMap("AvocaArc", AvocaArc.kMapName, networkVars)