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


end --Server
