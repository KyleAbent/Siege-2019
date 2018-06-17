
local orig = Marine.InitWeapons
function Marine:InitWeapons()
      orig(self)
      
    // if not self:isa("JetpackMarine") and Server then 
    //  self:GiveJetpack()
   
       self:GiveItem(Welder.kMapName)
        self:SetActiveWeapon(Rifle.kMapName)
    //end

end
