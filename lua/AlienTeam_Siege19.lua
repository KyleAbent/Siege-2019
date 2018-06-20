local orig_AlienTeam_InitTechTree = AlienTeam.InitTechTree
function AlienTeam:InitTechTree()
    local orig_PlayingTeam_InitTechTree = PlayingTeam.InitTechTree
    PlayingTeam.InitTechTree = function() end
    orig_PlayingTeam_InitTechTree(self)
    local orig_TechTree_SetComplete = self.techTree.SetComplete
    self.techTree.SetComplete = function() end
    orig_AlienTeam_InitTechTree(self)
    self.techTree.SetComplete = orig_TechTree_SetComplete
    
 
//self.techTree:AddBuildNode(kTechId.EggBeacon, kTechId.CragHive)
//self.techTree:AddBuildNode(kTechId.CommTunnel, kTechId.None)
//self.techTree:AddBuildNode(kTechId.StructureBeacon, kTechId.ShiftHive)
self.techTree:AddPassive(kTechId.PrimalScream,              kTechId.None, kTechId.None, kTechId.AllAliens)
 self.techTree:AddResearchNode(kTechId.CragHeals1, kTechId.Shell, kTechId.None)
    self.techTree:AddResearchNode(kTechId.WhipStealFT, kTechId.Whip, kTechId.None)
    self.techTree:AddUpgradeNode(kTechId.DigestComm, kTechId.None, kTechId.None)
    self.techTree:AddResearchNode(kTechId.AlienHealth1,     kTechId.Shell, kTechId.None)
--self.techTree:AddResearchNode(kTechId.LerkHealth,     kTechId.Shell, kTechId.None)
--self.techTree:AddResearchNode(kTechId.FadeHealth,     kTechId.Shell, kTechId.None)
--self.techTree:AddResearchNode(kTechId.OnosHealth,     kTechId.Shell, kTechId.None)
--self.techTree:AddBuildNode(kTechId.PlaceTechPoint, kTechId.BioMassTen)



//self.techTree:AddPassive(kTechId.OnoGrow,              kTechId.None, kTechId.None, kTechId.AllAliens)
    
    
    self.techTree:SetComplete()
    PlayingTeam.InitTechTree = orig_PlayingTeam_InitTechTree
end


