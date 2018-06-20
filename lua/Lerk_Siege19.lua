Lerk.kHealth = kLerkHealth
function Lerk:GetBaseHealth()
    return ConditionalValue( GetHasTech(self, kTechId.AlienHealth1), Lerk.kHealth * 1.10, Lerk.kHealth)  --Lerk.kHealth
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



