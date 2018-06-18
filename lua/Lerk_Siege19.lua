




local origspeed = Lerk.GetMaxSpeed

function Lerk:GetMaxSpeed(possible)

local speed = origspeed(self, possible)

     // if GetSiegeDoorOpen() then 
       speed = speed * 1.15 //kDuringSiegeOnosSpdBuff 
    // end
     
    -- if self:GetIsPoopGrowing() then
    -- speed = 0.1
   --  end
     
     return speed
    
    
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



