
--Script.Load("lua/InfestationMixin.lua")
Script.Load("lua/2019/DigestCommMixin.lua")

local networkVars = { 


}


--AddMixinNetworkVars(InfestationMixin, networkVars)
AddMixinNetworkVars(DigestCommMixin, networkVars)


local origcreate = Shift.OnCreate
function Shift:OnCreate()
   origcreate(self)
    InitMixin(self, DigestCommMixin)
 end
 

local origbuttons =  Shift.GetTechButtons
function  Shift:GetTechButtons(techId)
local table = {}

table = origbuttons(self, techId)

  table[8] = kTechId.DigestComm
 return table

end


local originit = Shift.OnInitialized
function Shift:OnInitialized()
originit(self)
     //    InitMixin(self, LevelsMixin)
          -- InitMixin(self, InfestationMixin)
      
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



Shared.LinkClassToMap("Shift", Shift.kMapName, networkVars)