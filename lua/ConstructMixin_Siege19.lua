/*
local orig = ConstructMixin.__initmixin
function ConstructMixin:__initmixin() --Simple? -- Avoca -- Requires more in this formula. I love while more than onupdate or timedcallback or timer.
   orig (self)
   if self:isa("PowerPoint") or ( Server and GetGameRules() == nil or not GetGameRules():GetMapLoaded() ) then return end
    if GetGameStarted() and  not GetSetupConcluded() then //and powered if marine or unpowered if alien
           while(not GetSetupConcluded() and self.underConstruction == false and (self.timeLastConstruct == nil or self.timeLastConstruct > 4) and self.buildFraction < 0.9) do
              self.timeLastConstruct = Shared.GetTime() //if is powered and marine then not ghost//
              self:Construct(0.25, false) 
              Print("HM")
          end --while
    end --setup
end
*/