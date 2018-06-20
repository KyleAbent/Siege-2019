Gorge.kHealth = kGorgeHealth
function Gorge:GetBaseHealth()
  return ConditionalValue( GetHasTech(self, kTechId.AlienHealth1), Gorge.kHealth * 1.10, Gorge.kHealth)  --Lerk.kHealth
end
