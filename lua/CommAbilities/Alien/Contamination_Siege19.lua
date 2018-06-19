local orig = Contamination.OnInitialized
function Contamination:OnInitialized()

orig(self)

if not GetSetupConcluded() then DestroyEntity(self) end

end