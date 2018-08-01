Lerk.kHealth = kLerkHealth
function Lerk:GetBaseHealth()
    return ConditionalValue( GetHasTech(self, kTechId.AlienHealth1), Lerk.kHealth * 1.10, Lerk.kHealth)  --Lerk.kHealth
end


 
function Lerk:OnAdjustModelCoords(modelCoords) --adjust hitbox model too
    local scale = .8
    local coords = modelCoords
    coords.xAxis = coords.xAxis * scale
    coords.yAxis = coords.yAxis * scale
    coords.zAxis = coords.zAxis * scale
      
    return coords
    
end

function Lerk:GetRebirthLength()
return 4
end
function Lerk:GetRedemptionCoolDown()
return 15
end

if Server then

function Lerk:GetTierFourTechId()
    return kTechId.PrimalScream
end




end



