local networkVars = 
{
//lastredeemorrebirthtime = "time", 
//canredeemorrebirth = "boolean",
 primaled = "boolean", 
primaledID = "entityid",
--modelsize = "private float (1 to 2 by 0.01)",
} 

local orig_Alien_OnInit = Alien.OnInitialized

function Alien:OnInitialized()
   orig_Alien_OnInit(self)
   if Server then
     -- Print("HMMMMNMNMN")
      // self:AddTimedCallback(function() UpdateSiegeAbility(self, nil, nil, self:GetTierThreeTechId(), self.GetTierFourTechId  and self:GetTierFourTechId() or kTechId.None ) end, 0.6) 
        UpdateSiegeAbility(self, self:GetTierThreeTechId(),  self:GetTierFourTechId() )
   end
    --  self.modelsize = 1
end

local orig_Alien_OnCreate = Alien.OnCreate
function Alien:OnCreate()
    orig_Alien_OnCreate(self)
    // self:UpdateWeapons()
    // self.lastredeemorrebirthtime = 0 --i would like to make a new alien class with custom networkvars like this some day :/
    // self.canredeemorrebirth = true
      self.primaled = false
      self.primaledID = Entity.invalidI 
      self.primalGiveTime = 0

end

/*
function Alien:AdjustModelSize(size)
  self.modelsize = size
end
--local orig_Onos_OnAdjustModelCoords = Onos.OnAdjustModelCoords
function Alien:OnAdjustModelCoords(modelCoords) 
--orig_Onos_OnAdjustModelCoords(self)
          local scale = 1
        if self.modelsize ~= 1 then
          scale = self.modelsize
        end
    local coords = modelCoords
        coords.xAxis = coords.xAxis * scale
        coords.yAxis = coords.yAxis * scale
        coords.zAxis = coords.zAxis * scale
    return coords
end

*/


local function CheckPrimalScream(self)
	self.primaled = self.primalGiveTime - Shared.GetTime() > 0
	return self.primaled
end

if Server then

function Alien:KarmaBuy(techId)
        local cost = LookupTechData(techId, kTechDataCostKey, 0)
         self:AddResources(cost)
        local upgradetable = {}
        local upgrades = Player.lastUpgradeList
        if upgrades and #upgrades > 0 then
            table.insert(upgradetable, upgrades)
        end
        
        table.insert(upgradetable, techId)
        self:ProcessBuyAction(upgradetable, true)
        self:AddResources(cost)
end
function Alien:GetTierFourTechId()
    return kTechId.None
end

  function Alien:PrimalScream(duration)
        if not self.primaled then
			self:AddTimedCallback(CheckPrimalScream, duration)
		end
        self.primaled = true
        self.primalGiveTime = Shared.GetTime() + duration
end


    function Alien:CancelPrimal()

    if self.primalGiveTime > Shared.GetTime() or self:GetIsOnFire() then 
        self.primalGiveTime = Shared.GetTime()
        self.primaledID = Entity.invalidI
    end
    
    end

end

function Alien:GetHasPrimalScream()
    return self.primaled
end
function Alien:CancelPrimal()

    if self.primalGiveTime > Shared.GetTime() or self:GetIsOnFire() then 
        self.primalGiveTime = Shared.GetTime()
        self.primaledID = Entity.invalidI
    end
    
end
--Hmm? Overwrite? My palms are open, not clenched.. Idk about my asshole, though.
function Alien:OnUpdateAnimationInput(modelMixin)

    Player.OnUpdateAnimationInput(self, modelMixin)
    
    local attackSpeed = self:GetIsEnzymed() and kEnzymeAttackSpeed or 1
    attackSpeed = attackSpeed * ( self.electrified and kElectrifiedAttackSpeed or 1 )
    attackSpeed = attackSpeed + ( self:GetHasPrimalScream() and kPrimalScreamROFIncrease or 0)
    if self.ModifyAttackSpeed then
    
        local attackSpeedTable = { attackSpeed = attackSpeed }
        self:ModifyAttackSpeed(attackSpeedTable)
        attackSpeed = attackSpeedTable.attackSpeed
        
    end
    
    modelMixin:SetAnimationInput("attack_speed", attackSpeed)
    
end

function Alien:GetHasLayStructure()
        local weapon = self:GetWeaponInHUDSlot(6)
        local builder = false
    if (weapon) then
            builder = true
    end
    
    return builder
end
function Alien:GiveLayStructure(techid, mapname)
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
local orig_Alien_UpdateClientEffects = Alien.UpdateClientEffects
function Alien:UpdateClientEffects(deltaTime, isLocal)
orig_Alien_UpdateClientEffects(self, deltaTime, isLocal)
       self:UpdateGhostModel()
end
    
    
--local orig_Alien_UpdateGhostModel = Alien.UpdateGhostModel
function Alien:UpdateGhostModel()
--orig_Alien_UpdateGhostModel(self)
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
         end
    end
end --function
function Alien:GetShowGhostModel()
    return self.showGhostModel
end    
function Alien:GetGhostModelTechId()
    return self.currentTechId
end
function Alien:GetGhostModelCoords()
    return self.ghostStructureCoords
end
function Alien:GetIsPlacementValid()
    return self.ghostStructureValid
end
function Alien:AddGhostGuide(origin, radius)
return
end
Alien.kPrimaledViewMaterialName = "cinematics/vfx_materials/primal_view.material"
Alien.kPrimaledThirdpersonMaterialName = "cinematics/vfx_materials/primal.material"
Shared.PrecacheSurfaceShader("cinematics/vfx_materials/primal_view.surface_shader")
Shared.PrecacheSurfaceShader("cinematics/vfx_materials/primal.surface_shader")
Alien.kOnocideViewMaterialName = "cinematics/vfx_materials/Onocide_view.material"
Alien.kOnocideThirdpersonMaterialName = "cinematics/vfx_materials/Onocide.material"
Shared.PrecacheSurfaceShader("cinematics/vfx_materials/Onocide_view.surface_shader")
Shared.PrecacheSurfaceShader("cinematics/vfx_materials/Onocide.surface_shader")
local kEnzymeEffectInterval = 0.2
function Alien:UpdateOnocideEffect(isLocal)
    local weapon = self:GetWeaponInHUDSlot(4)
    local boolean = false
      if weapon then
         boolean = weapon.primaryAttacking
      end
      
    if self.OnocideClient ~= boolean then
        if isLocal then
        
            local viewModel= nil        
            if self:GetViewModelEntity() then
                viewModel = self:GetViewModelEntity():GetRenderModel()  
            end
                
            if viewModel then
   
                if boolean then
                    self.primaledViewMaterial = AddMaterial(viewModel, Alien.kOnocideViewMaterialName)
                else
                
                    if RemoveMaterial(viewModel, self.primaledViewMaterial) then
                        self.primaledViewMaterial = nil
                    end
  
                end
            
            end
        
        end
        
        local thirdpersonModel = self:GetRenderModel()
        if thirdpersonModel then
        
            if boolean then
                self.OnocideMaterial = AddMaterial(thirdpersonModel, Alien.kOnocideThirdpersonMaterialName)
            else
            
                if RemoveMaterial(thirdpersonModel, self.OnocideMaterial) then
                    self.OnocideMaterial = nil
                end
            end
        
        end
        
        self.OnocideClient = boolean
        
    end
    // update cinemtics
    if boolean then
        if not self.lastOnocideEffect or self.lastOnocideEffect + kEnzymeEffectInterval < Shared.GetTime() then
        
            self:TriggerEffects("enzymed")
            self.lastOnocideEffect = Shared.GetTime()
        
        end
    end 
end
function Alien:UpdatePrimalEffect(isLocal)
    if self.primaledClient ~= self.primaled then
        if isLocal then
        
            local viewModel= nil        
            if self:GetViewModelEntity() then
                viewModel = self:GetViewModelEntity():GetRenderModel()  
            end
                
            if viewModel then
   
                if self.primaled then
                    self.primaledViewMaterial = AddMaterial(viewModel, Alien.kPrimaledViewMaterialName)
                else
                
                    if RemoveMaterial(viewModel, self.primaledViewMaterial) then
                        self.primaledViewMaterial = nil
                    end
  
                end
            
            end
        
        end
        
        local thirdpersonModel = self:GetRenderModel()
        if thirdpersonModel then
        
            if self.primaled then
                self.primaledMaterial = AddMaterial(thirdpersonModel, Alien.kPrimaledThirdpersonMaterialName)
            else
            
                if RemoveMaterial(thirdpersonModel, self.primaledMaterial) then
                    self.primaledMaterial = nil
                end
            end
        
        end
        
        self.primaledClient = self.primaled
        
    end
    // update cinemtics
    if self.primaled then
        if not self.lastprimaledEffect or self.lastprimaledEffect + kEnzymeEffectInterval < Shared.GetTime() then
        
            self:TriggerEffects("enzymed")
            self.lastprimaledEffect = Shared.GetTime()
        
        end
    end 
end
local origcupdate = Alien.UpdateClientEffects
function Alien:UpdateClientEffects(deltaTime, isLocal)
     self:UpdatePrimalEffect(isLocal)
     if self:isa("Onos") then self:UpdateOnocideEffect(isLocal) end
     origcupdate(self, deltaTime,isLocal)
end
end//client

