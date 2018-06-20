local origspeed = Fade.GetMaxSpeed
function Fade:GetMaxSpeed(possible)
     local speed = origspeed(self)
  --return speed * 1.10
  --return not self:GetIsOnFire() and speed * 1.25 or speed
  return speed
end

function Fade:GetBaseHealth()
    return ConditionalValue( GetHasTech(self, kTechId.AlienHealth1), Fade.kHealth * 1.10, Fade.kHealth)  --Lerk.kHealth
end
