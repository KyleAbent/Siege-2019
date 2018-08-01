Script.Load("lua/PointGiverMixin.lua")  //if in siege then no bile?

local origcreate = Contamination.OnCreate
function Contamination:OnCreate()
    origcreate(self)
    InitMixin(self, PointGiverMixin)
end

local orig = Contamination.OnInitialized
function Contamination:OnInitialized()

orig(self)

if not GetSetupConcluded() then DestroyEntity(self) end

end

function Contamination:GetPointValue()
    return 3
end