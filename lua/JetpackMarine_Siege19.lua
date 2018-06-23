--.36 == 90% of 4 eh
local originit = JetpackMarine.OnInitialized
function JetpackMarine:OnInitialized()

originit(self)

     //Brilliant formula here. I'd like to copyright it. Well, as for modders. :P i'll capitalize on it. winning formula here!
    JetpackMarine.kJetpackFuelReplenishDelay = ConditionalValue( GetHasTech(self, kTechId.JetpackFuel1), 0.36, .4)  


end

function JetpackMarine:applyBuffAlive()
JetpackMarine.kJetpackFuelReplenishDelay = .36
end