/*
breaks cysts
if Server then

local orig = Hive.OnInitialized
function Hive:OnInitialized()
orig(self)
    local origin = self:GetOrigin()
    local nearest = GetNearest(self:GetOrigin(), "TechPoint" ) //nearest should be alien tech not marine :P
    //  Print("Eh? 1")
    if nearest then
  //  Print("Eh? 2")
        origin = origin + Vector(0,nearest.height,0)
        self:SetOrigin(origin)
    end
    
end
end

*/