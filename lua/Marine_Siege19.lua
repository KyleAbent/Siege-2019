local originit = Marine.OnInitialized
function Marine:OnInitialized()

originit(self)



     --Brilliant formula here. I'd like to copyright it. Well, as for modders. :P i'll capitalize on it. winning formula here!
     --Then again, who knows the perf onspawn adjusting networkvar. 
       -- if global then why call all the time and not when necessary? ill figure it out for later
   -- if Marine.kWalkMaxSpeed == 5 then
    Marine.kWalkMaxSpeed = ConditionalValue( GetHasTech(self, kTechId.RunSpeed1), 5 * 1.04, 5)  
    Marine.kRunMaxSpeed = ConditionalValue( GetHasTech(self, kTechId.RunSpeed1), 5.75 * 1.04, 5.75) 
    Marine.kRunInfestationMaxSpeed = ConditionalValue( GetHasTech(self, kTechId.RunSpeed1), 5 * 1.04, 5) 
  --  end
    --Better if no respawn required such as alien
  --Print("%s %s %s", Marine.kWalkMaxSpeed, Marine.kRunMaxSpeed, Marine.kRunInfestationMaxSpeed)

end

local orig = Marine.InitWeapons
function Marine:InitWeapons()
      orig(self)
      
    // if not self:isa("JetpackMarine") and Server then 
    //  self:GiveJetpack()
   
       self:GiveItem(Welder.kMapName)
        self:SetActiveWeapon(Rifle.kMapName)

    //end

end


function Marine:GetHasLayStructure()
        local weapon = self:GetWeaponInHUDSlot(5)
        local builder = false
    if (weapon) then
            builder = true
    end
    
    return builder
end


function Marine:GiveLayStructure(techid, mapname)
  --  if not self:GetHasLayStructure() then
           local laystructure = self:GiveItem(LayStructures.kMapName)
           self:SetActiveWeapon(LayStructures.kMapName)
           laystructure:SetTechId(techid)
           laystructure:SetMapName(mapname)
  -- else
   --  self:TellMarine(self)
  -- end
end

if Client then

local orig_Marine_UpdateGhostModel = Marine.UpdateGhostModel
function Marine:UpdateGhostModel()

orig_Marine_UpdateGhostModel(self)

 self.currentTechId = nil
 
    self.ghostStructureCoords = nil
    self.ghostStructureValid = false
    self.showGhostModel = false
    
    local weapon = self:GetActiveWeapon()

    if weapon then
       if weapon:isa("LayStructures") then
        self.currentTechId = weapon:GetDropStructureId()
        self.ghostStructureCoords = weapon:GetGhostModelCoords()
        self.ghostStructureValid = weapon:GetIsPlacementValid()
        self.showGhostModel = weapon:GetShowGhostModel()
        elseif weapon:isa("LayMines") then
        self.currentTechId = kTechId.Mine
        self.ghostStructureCoords = weapon:GetGhostModelCoords()
        self.ghostStructureValid = weapon:GetIsPlacementValid()
        self.showGhostModel = weapon:GetShowGhostModel()
         end
    end




end --function


function Marine:AddGhostGuide(origin, radius)

return

end

end -- client




if Server then

function Marine:GiveExo(spawnPoint)

    local exo = self:Replace(Exo.kMapName, self:GetTeamNumber(), false, spawnPoint, { layout = "MinigunMinigun" })
    return exo
    
end--function


function Marine:GiveDualWelder(spawnPoint)

    local exo = self:Replace(Exo.kMapName, self:GetTeamNumber(), false, spawnPoint, { layout = "WelderWelder" })
    return exo
    
end
function Marine:GiveDualFlamer(spawnPoint)

    local exo = self:Replace(Exo.kMapName, self:GetTeamNumber(), false, spawnPoint, { layout = "FlamerFlamer"  })
    return exo
    
end

function Marine:GiveWelderFlamer(spawnPoint)

    local exo = self:Replace(Exo.kMapName, self:GetTeamNumber(), false, spawnPoint, { layout = "WelderFlamer"  })
    return exo
    
end
kIsExoTechId = { [kTechId.DualFlamerExosuit] = true, [kTechId.DualMinigunExosuit] = true,
                 [kTechId.DualWelderExosuit] = true, [kTechId.DualRailgunExosuit] = true,  [kTechId.WeldFlamerExosuit] = true  }
local function BuyExo(self, techId)

    local maxAttempts = 100
    for index = 1, maxAttempts do
    
        -- Find open area nearby to place the big guy.
        local capsuleHeight, capsuleRadius = self:GetTraceCapsule()
        local extents = Vector(Exo.kXZExtents, Exo.kYExtents, Exo.kXZExtents)

        local spawnPoint        
        local checkPoint = self:GetOrigin() + Vector(0, 0.02, 0)
        
        if GetHasRoomForCapsule(extents, checkPoint + Vector(0, extents.y, 0), CollisionRep.Move, PhysicsMask.Evolve, self) then
            spawnPoint = checkPoint
        else
            spawnPoint = GetRandomSpawnForCapsule(extents.y, extents.x, checkPoint, 0.5, 5, EntityFilterOne(self))
        end    
            
        local weapons 

        if spawnPoint then
        
            self:AddResources(-GetCostForTech(techId))
            
            local exo = nil
            
            if techId == kTechId.DualFlamerExosuit then
                exo = self:GiveDualFlamer(spawnPoint)
            elseif techId == kTechId.DualMinigunExosuit then
                exo = self:GiveDualExo(spawnPoint)
            elseif techId == kTechId.DualWelderExosuit then
                exo = self:GiveDualWelder(spawnPoint)
            elseif techId == kTechId.DualRailgunExosuit then
                exo = self:GiveDualRailgunExo(spawnPoint)
            elseif techId == kTechId.WeldFlamerExosuit then
                exo = self:GiveWelderFlamer(spawnPoint)
            end
            

            
            exo:TriggerEffects("spawn_exo")
            
            return
            
        end
        
    end
    
    Print("Error: Could not find a spawn point to place the Exo")
    
end
local function GetHostSupportsTechId(forPlayer, host, techId)

    if Shared.GetCheatsEnabled() then
        return true
    end
    
    local techFound = false
    
    if host.GetItemList then
    
        for index, supportedTechId in ipairs(host:GetItemList(forPlayer)) do
        
            if supportedTechId == techId then
            
                techFound = true
                break
                
            end
            
        end
        
    end
    
    return techFound
    
end



local origattemptbuy = Marine.AttemptToBuy
function Marine:AttemptToBuy(techIds)

  local techId = techIds[1]
   
    local hostStructure = GetHostStructureFor(self, techId)

    if hostStructure then
    
        local mapName = LookupTechData(techId, kTechDataMapName)
        
        if mapName then
        
            Shared.PlayPrivateSound(self, Marine.kSpendResourcesSoundName, nil, 1.0, self:GetOrigin())
            
            if self:GetTeam() and self:GetTeam().OnBought then
                self:GetTeam():OnBought(techId)
            end
            
                 
              if kIsExoTechId[techId] then
                BuyExo(self, techId)    
               else
                if hostStructure:isa("Armory") then self:AddResources(-GetCostForTech(techId)) end
                origattemptbuy(self, techIds)
            end
       end
   end
    

end



end --Server
