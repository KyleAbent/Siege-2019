function Skulk:GetBaseHealth()
    return ConditionalValue( GetHasTech(self, kTechId.AlienHealth1), Skulk.kHealth * 1.10, Skulk.kHealth)  --Lerk.kHealth
end