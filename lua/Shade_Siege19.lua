Script.Load("lua/2019/AvocaMixin.lua")
--Script.Load("lua/InfestationMixin.lua")
Script.Load("lua/2019/DigestCommMixin.lua")

local networkVars = { 


}

AddMixinNetworkVars(AvocaMixin, networkVars)
--AddMixinNetworkVars(InfestationMixin, networkVars)
AddMixinNetworkVars(DigestCommMixin, networkVars)


local origcreate = Shade.OnCreate
function Shade:OnCreate()
   origcreate(self)
    InitMixin(self, DigestCommMixin)
 end
 

local origbuttons = Shade.GetTechButtons
function Shade:GetTechButtons(techId)
local table = {}

table = origbuttons(self, techId)

 table[8] = kTechId.DigestComm
 return table

end


local originit = Shade.OnInitialized
function Shade:OnInitialized()
originit(self)
     //    InitMixin(self, LevelsMixin)
          -- InitMixin(self, InfestationMixin)
           InitMixin(self, AvocaMixin)
       -- self.salty = false

end
/*
function Whip:GetInfestationMaxRadius()
    return 1
end


function Whip:GetInfestationRadius()
   if not  GetIsPointOnInfestation(self:GetOrigin()) then 
    return 1
    else 
     return 0 
    end
end
*/



Shared.LinkClassToMap("Shade", Shade.kMapName, networkVars)