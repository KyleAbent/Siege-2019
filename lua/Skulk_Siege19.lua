local networkVars = 
{
  raged = "boolean"
}

local orig = Skulk.OnInitialized
function Skulk:OnInitialized()
    orig(self)
   self.raged =  ConditionalValue( GetHasTech(self, kTechId.SkulkRage), true, false)  --Can't be too bad on perf, right? 
end

function Skulk:GetBaseHealth()
    return ConditionalValue( GetHasTech(self, kTechId.AlienHealth1), Skulk.kHealth * 1.10, Skulk.kHealth)  -- why onUpdate?? better as var?
end

function Skulk:OnUpdateAnimationInput(modelMixin)

    Player.OnUpdateAnimationInput(self, modelMixin)
    Alien.OnUpdateAnimationInput(self, modelMixin)
    local attackSpeed = self.raged and 1.10 or 1
      --What's better? GetHasTech or skulk networkvar? I choose networkvar b.c enzyme does that, and primal
    if self.ModifyAttackSpeed then
    
        local attackSpeedTable = { attackSpeed = attackSpeed }
        self:ModifyAttackSpeed(attackSpeedTable)
        attackSpeed = attackSpeedTable.attackSpeed
        
    end
    
    modelMixin:SetAnimationInput("attack_speed", attackSpeed)
    
end

Shared.LinkClassToMap("Skulk", Skulk.kMapName, networkVars, true)
