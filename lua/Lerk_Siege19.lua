/*
local orig_Alien_OnInit = Lerk.OnInitialized

function Lerk:OnInitialized()
   orig_Alien_OnInit(self)
 --  if  GetHasTech(self, kTechId.LerkHealth)then
  --      self:AddTimedCallback(Lerk.UpdateHealthAmountManual, .5) 
--end

    
  -- return false
end
*/

function Lerk:UpdateHealthAmountManual()
       if newMaxHealth ~= self.maxHealth  then
        self:AdjustMaxHealth(kLerkHealth * 4)
        self:SetMaxHealth(kLerkHealth * 4)
        end
end

function Lerk:OnAdjustModelCoords(modelCoords)
    local scale = .8
    local coords = modelCoords
    coords.xAxis = coords.xAxis * scale
    coords.yAxis = coords.yAxis * scale
    coords.zAxis = coords.zAxis * scale
      
    return coords
    
end

if Server then

function Lerk:GetTierFourTechId()
    return kTechId.PrimalScream
end




end



