local Shine = Shine

local Plugin = Plugin

function Plugin:Initialise()
self.Enabled = true
return true
end

Shine.VoteMenu:AddPage ("SpendStructures", function( self )
       local player = Client.GetLocalPlayer()
    if player:GetTeamNumber() == 1 then 
    self:AddSideButton( "Mac(5)", function() Shared.ConsoleCommand ("sh_buy Mac")  end)
    self:AddSideButton( "Arc(10)", function() Shared.ConsoleCommand ("sh_buy Arc")  end)
    self:AddSideButton( "Observatory(10)", function() Shared.ConsoleCommand ("sh_buy Observatory")  end)
    self:AddSideButton( "Sentry(5)", function() Shared.ConsoleCommand ("sh_buy Sentry")  end)
    self:AddSideButton( "BackupBattery(10)", function() Shared.ConsoleCommand ("sh_buy BackupBattery")  end)
    --self:AddSideButton( "BackupLight(4)", function() Shared.ConsoleCommand ("sh_buy BackupLight")  end)
    self:AddSideButton( "Armory(10)", function() Shared.ConsoleCommand ("sh_buy Armory")  end)
    self:AddSideButton( "AdvancedArmory(35)", function() Shared.ConsoleCommand ("sh_buy AdvancedArmory")  end)
    self:AddSideButton( "PhaseGate(15)", function() Shared.ConsoleCommand ("sh_buy PhaseGate")  end)
    self:AddSideButton( "InfantryPortal(20)", function() Shared.ConsoleCommand ("sh_buy InfantryPortal")  end)
    self:AddSideButton( "RoboticsFactory(10)", function() Shared.ConsoleCommand ("sh_buy RoboticsFactory")  end)
   // self:AddSideButton( "LowerSupplyLimit(5)", function() Shared.ConsoleCommand ("sh_buy LowerSupplyLimit")  end)
    elseif player:GetTeamNumber() == 2 then
   -- self:AddSideButton( "Hydra(1)", function() Shared.ConsoleCommand ("sh_buy Hydra")  end)
    --self:AddSideButton( "KarmayEgg(15)", function() Shared.ConsoleCommand ("sh_buy KarmayEgg")  end)
    --self:AddSideButton( "Drifter(5)", function() Shared.ConsoleCommand ("sh_buy Drifter")  end)
    self:AddSideButton( "Shade(13)", function() Shared.ConsoleCommand ("sh_buy Shade")  end)
    self:AddSideButton( "Crag(13)", function() Shared.ConsoleCommand ("sh_buy Crag")  end)
    self:AddSideButton( "Whip(13)", function() Shared.ConsoleCommand ("sh_buy Whip")  end)
    self:AddSideButton( "Shift(13)", function() Shared.ConsoleCommand ("sh_buy Shift")  end)
   -- self:AddSideButton( "Clog(2)", function() Shared.ConsoleCommand ("sh_buy Clog")  end)
    //  if player:isa("Gorge") then
    //self:AddSideButton( "Tunnel@Hive", function() Shared.ConsoleCommand ("sh_buycustom TunnelEntrance")  end)
     // end
    //self:AddSideButton( "LowerSupplyLimit(5)", function() Shared.ConsoleCommand ("sh_buy LowerSupplyLimit")  end)
   end

        self:AddBottomButton( "Back", function()self:SetPage("SpendCredits")end) 
end)
Shine.VoteMenu:AddPage ("SpendExpenive", function( self )
       local player = Client.GetLocalPlayer()
    if player:GetTeamNumber() == 1 then 
            self:AddSideButton( "Extractor", function() Shared.ConsoleCommand ("sh_buy Extractor")  end)
    elseif  player:GetTeamNumber() == 2 then
      self:AddSideButton( "Harvester", function() Shared.ConsoleCommand ("sh_buy Harvester")  end)
    end
        self:AddBottomButton( "Back", function()self:SetPage("SpendCredits")end) 
end)


Shine.VoteMenu:AddPage ("SpendWeapons", function( self )

        self:AddSideButton( "Mines(10)", function() Shared.ConsoleCommand ("sh_buywp Mines")  end)
        self:AddSideButton( "HeavyMachineGun(20)", function() Shared.ConsoleCommand ("sh_buywp HeavyMachineGun")  end)
        self:AddSideButton( "Shotgun(20)", function() Shared.ConsoleCommand ("sh_buywp Shotgun")  end)
        self:AddSideButton( "FlameThrower(20)", function() Shared.ConsoleCommand ("sh_buywp FlameThrower")  end)
        self:AddSideButton( "GrenadeLauncher(20)", function() Shared.ConsoleCommand ("sh_buywp GrenadeLauncher")  end)
          self:AddSideButton( "Welder(3)", function() Shared.ConsoleCommand ("sh_buywp Welder")  end)
        self:AddBottomButton( "Back", function()self:SetPage("SpendCredits")end) 
end)
Shine.VoteMenu:AddPage ("SpendClasses", function( self )
       local player = Client.GetLocalPlayer()
    if player:GetTeamNumber() == 1 then 
    self:AddSideButton( "JetPack(15)", function() Shared.ConsoleCommand ("sh_buyclass JetPack")  end)
    self:AddSideButton( "MiniGunExo(55)", function() Shared.ConsoleCommand ("sh_buyclass MiniGun")  end)
    self:AddSideButton( "RailGunExo(55)", function() Shared.ConsoleCommand ("sh_buyclass RailGun")  end)
    self:AddSideButton( "WelderExo(45)", function() Shared.ConsoleCommand ("sh_buyclass Welder")  end)
    self:AddSideButton( "FlamerExo(46)", function() Shared.ConsoleCommand ("sh_buyclass Flamer")  end)
    self:AddSideButton( "WelderFlamerExo(44)", function() Shared.ConsoleCommand ("sh_buyclass WelderFlamer")  end)
        elseif player:GetTeamNumber() == 2 then
      self:AddSideButton( "Gorge(8)", function() Shared.ConsoleCommand ("sh_buyclass Gorge")  end)
      self:AddSideButton( "Lerk(21)", function() Shared.ConsoleCommand ("sh_buyclass Lerk")  end)
      self:AddSideButton( "Fade(37)", function() Shared.ConsoleCommand ("sh_buyclass Fade")  end)
      self:AddSideButton( "Onos(62)", function() Shared.ConsoleCommand ("sh_buyclass Onos")  end)
    end
        self:AddBottomButton( "Back", function()self:SetPage("SpendCredits")end) 
end)
/*
Shine.VoteMenu:AddPage ("SpendExpenive", function( self )
        self:AddSideButton( "OffensiveConcGrenade(100) (WIP)", function() Shared.ConsoleCommand ("sh_buywp OffensiveConcGrenade")  end)
             self:AddBottomButton( "Back", function()self:SetPage("SpendCredits")end) 

end)
*/
Shine.VoteMenu:AddPage ("SpendFun", function( self )
      --  self:AddSideButton( "JediConcGrenade(5) (WIP)", function() Shared.ConsoleCommand ("sh_buywp JediConcGrenade")  end)
             self:AddBottomButton( "Back", function()self:SetPage("SpendCredits")end) 

end)

Shine.VoteMenu:AddPage ("SpendCommAbilities", function( self )
       local player = Client.GetLocalPlayer()
           if player:GetTeamNumber() == 1 then 
                  self:AddSideButton ("Scan(3)", function()Shared.ConsoleCommand ("sh_buy Scan")end)
                  self:AddSideButton ("Medpack(2)", function()Shared.ConsoleCommand ("sh_buy Medpack")end)
           else
       self:AddSideButton ("NutrientMist(1)", function()Shared.ConsoleCommand ("sh_buy NutrientMist")end)
       self:AddSideButton( "EnzymeCloud(4)", function() Shared.ConsoleCommand ("sh_buy EnzymeCloud")  end)
       self:AddSideButton( "Ink(3)", function() Shared.ConsoleCommand ("sh_tbuy Ink")  end)
       self:AddSideButton( "Hallucination(4)", function() Shared.ConsoleCommand ("sh_buy Hallucination")  end)
       self:AddSideButton( "Contamination(5)", function() Shared.ConsoleCommand ("sh_buy Contamination")  end)
     end
     self:AddBottomButton( "Back", function()self:SetPage("SpendCredits")end) 
end)


Shine.VoteMenu:AddPage ("SpendCredits", function( self )
       local player = Client.GetLocalPlayer()
            self:AddSideButton( "CommAbilities", function() self:SetPage( "SpendCommAbilities" ) end)
    if player:GetTeamNumber() == 1 then 
        self:AddSideButton( "Weapons", function() self:SetPage( "SpendWeapons" ) end)
      end  


    

     self:AddSideButton( "Classes", function() self:SetPage( "SpendClasses" ) end) 
     self:AddSideButton( "Structures", function() self:SetPage( "SpendStructures" ) end)
             --  self:AddSideButton( "Fun", function() self:SetPage( "SpendFun" ) end)
               self:AddSideButton( "Expensive", function() self:SetPage( "SpendExpenive" ) end)
     self:AddBottomButton( "Back", function()self:SetPage("Main")end)
end)





     
     
Shine.VoteMenu:EditPage( "Main", function( self ) 
self:AddSideButton( "Karma", function() self:SetPage( "SpendCredits" ) end)
end)


