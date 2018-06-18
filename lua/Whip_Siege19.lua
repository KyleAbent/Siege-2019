Script.Load("lua/2019/AvocaMixin.lua")
Script.Load("lua/InfestationMixin.lua")

local networkVars = { 

salty = "private boolean" 

}

AddMixinNetworkVars(AvocaMixin, networkVars)
AddMixinNetworkVars(InfestationMixin, networkVars)


local originit = Whip.OnInitialized
function Whip:OnInitialized()
originit(self)
     //    InitMixin(self, LevelsMixin)
           InitMixin(self, InfestationMixin)
        InitMixin(self, AvocaMixin)
        self.salty = false

end


function Whip:GetInfestationRadius()
    if self.salty then
    return 1
    else
    return 0
    end
end

function Whip:SetSalty()
         self.salty = true 
end