Script.Load("lua/ResearchMixin.lua")
Script.Load("lua/2019/DigestCommMixin.lua")

local networkVars = {}
AddMixinNetworkVars(DigestCommMixin, networkVars)


local origcreate = Crag.OnCreate
function Crag:OnCreate()
   origcreate(self)
   if not GetHasTech(self, kTechId.CragHeals1) and Crag.kHealPercentage ~= 0.06 then --else stays
      Crag.kHealPercentage = 0.06
      Crag.kMinHeal = 10
      Crag.kMaxHeal = 60
   end
       InitMixin(self, DigestCommMixin)
 end
 

local origbuttons = Crag.GetTechButtons
function Crag:GetTechButtons(techId)
local table = {}

table = origbuttons(self, techId)

 table[5] = kTechId.CragHeals1
  table[8] = kTechId.DigestComm

 
 return table

end

 
if Server then

function Crag:OnResearchComplete(researchId)
  
  if researchId == kTechId.CragHeals1 then
     Crag.kHealPercentage = 0.066--Crag.kHealPercentage * 1.05
     Crag.kMinHeal = 11--Crag.kMinHeal * 1.05
     Crag.kMaxHeal = 66--Crag.kMaxHeal * 1.05
   end

end



end