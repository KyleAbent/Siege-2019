local origspeed = Lerk.GetMaxSpeed

function Lerk:GetMaxSpeed(possible)

local speed = origspeed(self, possible)

     // if GetSiegeDoorOpen() then 
       speed = speed * 1.3 //kDuringSiegeOnosSpdBuff 
    // end
     
    -- if self:GetIsPoopGrowing() then
    -- speed = 0.1
   --  end
     
     return speed
    
    
end