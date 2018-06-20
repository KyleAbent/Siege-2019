--.36 == 90% of 4 eh
local originit = JetpackMarine.OnInitialized
function JetpackMarine:OnInitialized()

originit(self)

   if GetHasTech(self, kTechId.JetpackFuel1) then
    JetpackMarine.kJetpackFuelReplenishDelay = .36
   end

end

function JetpackMarine:applyBuffAlive()
JetpackMarine.kJetpackFuelReplenishDelay = .36
end