 /*Kyle 'Avoca' Abent Karmas Season 4
kyle@kyleabent.com
*/
local Shine = Shine
local Plugin = Plugin
local HTTPRequest = Shared.SendHTTPRequest


Plugin.HasConfig = true
Plugin.ConfigName = "KarmasConfig.json"

Plugin.DefaultConfig  = { kKarmaMultiplier = 1, kKarmasCapPerRound = 200 }

Shine.KarmaData = {}
Shine.LinkFile = {}
Shine.BadgeFile = {}
Plugin.Version = "11.16"

local KarmasPath = "config://shine/plugins/credits.json"
local URLPath = "config://shine/KarmasLink.json"
--local BadgeURLPath = "config://shine/BadgesLink.json"
--local BadgesPath = "config://shine/UserConfig.json"


function Plugin:onConstInit(  )

       self.isacreditstructure = false

end

Shine.Hook.SetupClassHook( "ConstructMixin", "__initmixin", "onConstInit", "PassivePost" )


--Shine.Hook.SetupClassHook( "ScoringMixin", "AddScore", "OnScore", "PassivePost" ) Not right now, eh.

Shine.Hook.SetupClassHook( "OnoGrow", "OnoEggFilled", "OnOnEggFilled", "PassivePost" )

Shine.Hook.SetupClassHook( "NS2Gamerules", "ResetGame", "OnReset", "PassivePost" )

Shine.Hook.SetupClassHook( "Player", "HookWithShineToBuyMist", "BecauseFuckSpammingCommanders", "Replace" )
Shine.Hook.SetupClassHook( "Player", "HookWithShineToBuyMed", "SeriouslyFuckIt", "Replace" )
Shine.Hook.SetupClassHook( "Player", "HookWithShineToBuyAmmo", "InTheButt", "Replace" )
Shine.Hook.SetupClassHook( "GlowMixin", "DelayGlow", "CmonNowGlow", "Replace" )

Shine.Hook.SetupClassHook( "DoConcedeSequence", "OnConcede", "SaveAllKarmas", "pre" )

function Plugin:OnoEggFilled(player)
  self:NotifyKarma( player:GetClient(), "You farted.", true )
end

function Plugin:Initialise()
self:CreateCommands()
self.Enabled = true
self.GameStarted = false
self.KarmaAmount = 0
self.KarmaUsers = {}
self.BuyUsersTimer = {}
self.marinecredits = 420
self.aliencredits = 420
self.marinebonus = 18
self.alienbonus = 18
self.Refunded = false

self.PlayerSpentAmount = {}

self.ShadeInkCoolDown = 0

return true
end


function Plugin:BecauseFuckSpammingCommanders(player)
          if not GetGamerules():GetGameStarted() then return end
          //local KarmaCost = 1
         // local client = player:GetClient()
          //local controlling = 
          local Client =  player:GetClient():GetControllingPlayer():GetClient()
		    
              if self:GetPlayerKarmaInfo(Client) < KarmaCost then
              self:NotifyKarma( Client, "%s costs %s karma, you have %s karma. Purchase invalid.", true, String, KarmaCost, self:GetPlayerKarmaInfo(Client))
             return
             else 
             local mist = GetEntitiesWithinRange("NutrientMist", self:GetOrigin(), 4)
               if #mist >=1 then 
               self:NotifyKarma( Client, "You have mist too close by you.", true )
               return
			   end
             end

     self.KarmaUsers[ Client ] = self:GetPlayerKarmaInfo(Client) - 1
     //self:NotifyKarma( nil, "%s purchased a %s with %s credit(s)", true, Player:GetName(), String, 1)
     player:GiveItem(NutrientMist.kMapName)
    Shine.ScreenText.SetText("Karma", string.format( "%s Karma", self:GetPlayerKarmaInfo(Client) ), Client) 
    self.BuyUsersTimer[Client] = Shared.GetTime() + 3 
     self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + KarmaCost
    return
end


function Plugin:SeriouslyFuckIt(player)
if not GetGamerules():GetGameStarted() then return end
 self:SimpleTimer(4, function() self:SpawnIt(player, MedPack.kMapName)  end)

end

 function Plugin:SpawnIt(player, entity)
 if not player or not player:GetIsAlive() then return end
 local KarmaCost = 1
 local client = player:GetClient()
local controlling = client:GetControllingPlayer()
local Client = controlling:GetClient()
if self:GetPlayerKarmaInfo(Client) < KarmaCost then
self:NotifyKarma( Client, "%s costs %s karma, you have %s karma. Purchase invalid.", true, String, KarmaCost, self:GetPlayerKarmaInfo(Client))
return
end
self.KarmaUsers[ Client ] = self:GetPlayerKarmaInfo(Client) - KarmaCost
   Shine.ScreenText.SetText("Karma", string.format( "%s Karma", self:GetPlayerKarmaInfo(Client) ), Client) 
   self.BuyUsersTimer[Client] = Shared.GetTime() + 3 
     self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + KarmaCost
return
     // CreateEntity( entity, FindFreeSpace(player:GetOrigin(), 1, 4), 1) 
        CreateEntity( entity, player:GetOrigin() ) 
end
function Plugin:InTheButt(player)
if not player or not player:GetIsAlive() then return end
if not GetGamerules():GetGameStarted() then return end
 self:SimpleTimer(4, function() self:SpawnIt(player, AmmoPack.kMapName)    end)
end

function Plugin:CmonNowGlow(who, glowco, duration)
 who:GlowColor(glowco, duration)  
end
 


function Plugin:GenereateTotalKarmaAmount()
local credits = 0
Print("%s users", table.Count(self.KarmaData.Users))
for i = 1, table.Count(self.KarmaData.Users) do
    local table = self.KarmaData.Users.credits
    credits = credits + table
end
Print("%s karma",credits)
end


local function GetPathingRequirementsMet(position, extents)

    local noBuild = Pathing.GetIsFlagSet(position, extents, Pathing.PolyFlag_NoBuild)
    local walk = Pathing.GetIsFlagSet(position, extents, Pathing.PolyFlag_Walk)
    return not noBuild and walk
    
end

function Plugin:HasLimitOf(Client)
    
    return  self.PlayerSpentAmount[Client] >= 200
end
function Plugin:PregameLimit(teamnum)
local entitycount = 0
local entities = {}
        for index, entity in ipairs(GetEntitiesWithMixinForTeam("Live", teamnum)) do
       entitycount = entitycount + 1  
    end
       if entitycount <= 99 then return false end
       return false 
end
 /*
function Plugin:LoadBadges()
     local function UsersResponse( Response )
		local UserData = json.decode( Response )
		self.UserData = UserData
		 Shine.SaveJSONFile( self.UserData, BadgesPath  )
		 
		         self:SimpleTimer(4, function ()
        Shared.ConsoleCommand("sh_reloadusers" ) 
        end)
        
      end
       local BadgeFiley = Shine.LoadJSONFile( BadgeURLPath )
        self.BadgeFile = BadgeFiley
        HTTPRequest( self.BadgeFile.LinkToBadges, "GET", UsersResponse)
end
*/
local function AddOneScore(Player,Points,Res, WasKill)
            local points = Points
            local wasKill = WasKill
            local displayRes = ConditionalValue(type(res) == "number", res, 0)
            Server.SendNetworkMessage(Server.GetOwner(Player), "ScoreUpdate", { points = points, res = displayRes, wasKill = wasKill == true }, true)
            Player.score = Clamp(Player.score + points, 0, 100)

            if not Player.scoreGainedCurrentLife then
                Player.scoreGainedCurrentLife = 0
            end

            Player.scoreGainedCurrentLife = Player.scoreGainedCurrentLife + points   

end
function Plugin:PrimalScreamPointBonus(who, Points)
  local lerk = Shared.GetEntity( who.primaledID ) 
  if lerk ~= nil then
      local client = lerk.getClient and lerk:GetClient()
      if client then 
        local player = client:GetControllingPlayer()
         if player then
          player:AddScore(Points * 0.3)
          end
      end
  end
end
function Plugin:OnScore( Player, Points, Res, WasKill )
if Points ~= nil and Points ~= 0 and Player  then
   --if not self.GameStarted then Points = 1  AddOneScore(Player,Points,Res, WasKill) end
  --if WasKill and Player:isa("Alien") and Player:GetHasPrimalScream() then self:PrimalScreamPointBonus(Player, Points) end
 local client = Player:GetClient()
 if not client then return end
         
    local addamount = Points/6--Points/(10/self.Config.kKarmaMultiplier)      
 local controlling = client:GetControllingPlayer()
 
      --   if Player:GetTeamNumber() == 1 then
       --  self.marinecredits = self.marinecredits + addamount
     --   elseif Player:GetTeamNumber() == 2 then
       --  self.aliencredits = self.aliencredits + addamount
       --  end
         
self.KarmaUsers[ controlling:GetClient() ] = self:GetPlayerKarmaInfo(controlling:GetClient()) + addamount
Shine.ScreenText.SetText("Karma", string.format( "%s Karma", self:GetPlayerKarmaInfo(controlling:GetClient()) ), controlling:GetClient()) 
end
end
function Plugin:NotifySiege( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[Siege]",  math.random(0,255), math.random(0,255), math.random(0,255), String, Format, ... )
end




function Plugin:OnReset()
  if self.GameStarted and not self.Refunded then
       self:NotifyKarma( nil, "Did you spend any credits only for the round to reset? If so, then no worries! - You have just been refunded!", true )
       
              Shine.ScreenText.End("Karma")  
              self.marinecredits = 0
              self.aliencredits = 0
              self.marinebonus = 0
              self.alienbonus = 0
              self.MarineTotalSpent = 0 
              self.AlienTotalSpent = 0
              self.KarmaUsers = {}
              self.PlayerSpentAmount = {}
          
              local Players = Shine.GetAllPlayers()
              for i = 1, #Players do
              local Player = Players[ i ]
                  if Player then
                  Shine.ScreenText.Add( "Karma", {X = 0.20, Y = 0.95,Text = string.format( "%s Karma", self:GetPlayerKarmaInfo(Player:GetClient()) ),Duration = 1800,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 3,FadeIn = 0,}, Player:GetClient() )
                  end
              end
    self.Refunded = true
   end     
end

function Plugin:OnFirstThink() 
local KarmasFile = Shine.LoadJSONFile( KarmasPath )
self.KarmaData = KarmasFile
end

 local function GetKarmaToSave(self, Client, savedamount)
            local cap = self.Config.kKarmasCapPerRound 
          local creditstosave = self:GetPlayerKarmaInfo(Client)
          local earnedamount = creditstosave - savedamount
          if earnedamount > cap then 
          creditstosave = savedamount + cap
          self:NotifyKarma( Client, "%s Karma cap per round exceeded. You earned %s karma this round. Only %s are saved. So your new total is %s", true, self.Config.kKarmasCapPerRound, earnedamount, self.Config.kKarmasCapPerRound, creditstosave )
          Shine.ScreenText.SetText("Karma", string.format( "%s Karma", creditstosave ), Client) 
           end
    return creditstosave
 end
 
function Plugin:SaveKarmas(Client, disconnected)
       local Data = self:GetKarmaData( Client )
       if Data and Data.credits then 
         if not Data.name or Data.name ~= Client:GetControllingPlayer():GetName() then
           Data.name = Client:GetControllingPlayer():GetName()
           end      
           Data.credits = GetKarmaToSave(self, Client, Data.credits)  
       else 
      self.KarmaData.Users[Client:GetUserId() ] = {credits = self:GetPlayerKarmaInfo(Client), name = Client:GetControllingPlayer():GetName() }
       end
     if disconnected == true then Shine.SaveJSONFile( self.KarmaData, KarmasPath  ) end
end


function Plugin:ClientDisconnect(Client)
       self:SaveKarmas(Client, true)
end
function Plugin:GetPlayerKarmaInfo(Client)
   local Karmas = 0
       if self.KarmaUsers[ Client ] then
          Karmas = self.KarmaUsers[ Client ]
       elseif not self.KarmaUsers[ Client ] then 
          local Data = self:GetKarmaData( Client )
           if Data and Data.credits then 
           Karmas = Data.credits 
           end
       end
return math.round(Karmas, 2)
end
local function GetIDFromClient( Client )
	return Shine.IsType( Client, "number" ) and Client or ( Client.GetUserId and Client:GetUserId() ) // or nil //or nil was blocked but im testin
 end
function Plugin:GetKarmaData(Client)
  if not self.KarmaData then return nil end
  if not self.KarmaData.Users then return nil end
  local ID = GetIDFromClient( Client )
  if not ID then return nil end
  local User = self.KarmaData.Users[ tostring( ID ) ] 
  if not User then 
     local SteamID = Shine.NS2ToSteamID( ID )
     User = self.KarmaData.Users[ SteamID ]
     if User then
     return User, SteamID
     end
     local Steam3ID = Shine.NS2ToSteam3ID( ID )
     User = self.KarmaData.Users[ ID ]
     if User then
     return User, Steam3ID
     end
     return nil, ID
   end
return User, ID
end

 function Plugin:ClientConfirmConnect(Client)
 
 if Client:GetIsVirtual() then return end
 
  Shine.ScreenText.Add( "Karma", {X = 0.20, Y = 0.85,Text = string.format( "%s Karma", self:GetPlayerKarmaInfo(Client) ),Duration = 1800,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 3,FadeIn = 0,}, Client )
    self.PlayerSpentAmount[Client] = 0
    
    
 end
function Plugin:SaveAllKarmas()
               local Players = Shine.GetAllPlayers()
              for i = 1, #Players do
              local Player = Players[ i ]
                  if Player then
                  self:SaveKarmas(Player:GetClient(), false)
                  end
             end
                     
            local LinkFiley = Shine.LoadJSONFile( URLPath )
            self.LinkFile = LinkFiley                
                 self:SimpleTimer( 2, function() 
                 Shine.SaveJSONFile( self.KarmaData, KarmasPath  )
                 end)
                             
              --   self:SimpleTimer( 4, function() 
                -- HTTPRequest( self.LinkFile.LinkToUpload, "POST", {data = json.encode(self.KarmaData)})
                -- end)
                 
               --  self:SimpleTimer( 12, function() 
               --  self:LoadBadges()
               --  end)
                 
               --  self:SimpleTimer( 14, function() 
              --   self:NotifyKarma( nil, "http://credits.ns2siege.com - credit ranking updated", true)
              --   end)        
                 

end
function Plugin:DeductKarmaIfNotPregame(self, who, amount, delayafter)
        --Print("DeductKarmaIfNotPregame, amount is %s", amount)
 if ( GetGamerules():GetGameStarted() and not GetGamerules():GetCountingDown() )  then
    self.KarmaUsers[ who:GetClient() ] = self:GetPlayerKarmaInfo(who:GetClient()) - amount
     self.PlayerSpentAmount[who:GetClient()] = self.PlayerSpentAmount[who:GetClient()]  + amount
   self.BuyUsersTimer[who:GetClient()] = Shared.GetTime() + delayafter
   Shine.ScreenText.SetText("Karma", string.format( "%s Karma", self:GetPlayerKarmaInfo(who:GetClient()) ), who) 
 else
 self:NotifyKarma(who, "Pregame seeding free of charge", true) 
 end
 
end
function Plugin:SetGameState( Gamerules, State, OldState )
       if State == kGameState.Countdown then
      
          
        self.GameStarted = true
        self.Refunded = false
              Shine.ScreenText.End(80)
              Shine.ScreenText.End(81)  
              Shine.ScreenText.End(82)  
              Shine.ScreenText.End(83)  
              Shine.ScreenText.End(84)  
              Shine.ScreenText.End(85)  
              Shine.ScreenText.End(86)
              Shine.ScreenText.End(87)  
          Shine.ScreenText.End("Karma")    
              self.marinecredits = 0
              self.aliencredits = 0
              self.marinebonus = 0
              self.alienbonus = 0
              self.MarineTotalSpent = 0
              self.AlienTotalSpent = 0
              self.PlayerSpentAmount = {}
              
              local Players = Shine.GetAllPlayers()
              for i = 1, #Players do
              local Player = Players[ i ]
                  if Player then
                  self.PlayerSpentAmount[Player:GetClient()] = 0
                  //Shine.ScreenText.Add( "Karmas", {X = 0.20, Y = 0.95,Text = "Loading Karmas...",Duration = 1800,R = 255, G = 0, B = 0,Alignment = 0,Size = 3,FadeIn = 0,}, Player )
                  Shine.ScreenText.Add( "Karma", {X = 0.20, Y = 0.95,Text = string.format( "%s Karma", self:GetPlayerKarmaInfo(Player:GetClient()) ),Duration = 1800,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 3,FadeIn = 0,}, Player:GetClient() )
                  end
              end
              
      end        
              
     if State == kGameState.Team1Won or State == kGameState.Team2Won or State == kGameState.Draw then
     


      self.GameStarted = false
          
                 self:SimpleTimer(6, function ()

       	       self:NotifyKarma( nil, "Round Concluded! Converting Score into Karma! (1 score = 0.6 karma). Now Saving.", true )
		       --self:NotifyKarma( nil, "Individual client saving upon disconnect is currently disabled.", true )

              local Players = Shine.GetAllPlayers()
              for i = 1, #Players do
              local Player = Players[ i ]
                  if Player then
                 // self:SaveKarmas(Player:GetClient())
                     --if Player:GetTeamNumber() == 1 or Player:GetTeamNumber() == 2 then
					 if Player:GetScore() > 1 then
					 local earned = Player:GetScore() / 6
					 self.KarmaUsers[ Player:GetClient() ] = self:GetPlayerKarmaInfo(Player:GetClient()) + earned
                     Shine.ScreenText.SetText("Karma", string.format( "%s Karma", self:GetPlayerKarmaInfo(Player:GetClient()) ), Player:GetClient()) 
                    Shine.ScreenText.Add( 80, {X = 0.40, Y = 0.15,Text = "Karma Mined:".. math.round(earned, 2), Duration = 120,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,}, Player )
                    Shine.ScreenText.Add( 81, {X = 0.40, Y = 0.20,Text = "Karma Spent:".. self.PlayerSpentAmount[Player:GetClient()], Duration = 120,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,}, Player )
                     end
                  end
             end
      end)
      
      
            self:SimpleTimer( 8, function() 
       local LinkFiley = Shine.LoadJSONFile( URLPath )
        self.LinkFile = LinkFiley
            self:SaveAllKarmas()
            end)
            
            
           //   local Time = Shared.GetTime()
          //   if not Time > kMaxServerAgeBeforeMapChange then
                 self:SimpleTimer( 25, function() 
               --  self:LoadBadges()
                 end)
       

    //  self:SimpleTimer(3, function ()    
    //  Shine.ScreenText.Add( 82, {X = 0.40, Y = 0.10,Text = "End of round Stats:",Duration = 120,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,} )
    // Shine.ScreenText.Add( 83, {X = 0.40, Y = 0.25,Text = "(Server Wide)Total Karmas Earned:".. math.round((self.marinecredits + self.aliencredits), 2), Duration = 120,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,} )
    //  Shine.ScreenText.Add( 84, {X = 0.40, Y = 0.25,Text = "(Marine)Total Karmas Earned:".. math.round(self.marinecredits, 2), Duration = 120,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,} )
    //  Shine.ScreenText.Add( 85, {X = 0.40, Y = 0.30,Text = "(Alien)Total Karmas Earned:".. math.round(self.aliencredits, 2), Duration = 120,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,} )
    //  Shine.ScreenText.Add( 86, {X = 0.40, Y = 0.35,Text = "(Marine)Total Karmas Spent:".. math.round(self.MarineTotalSpent, 2), Duration = 120,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,} )
    //  Shine.ScreenText.Add( 87, {X = 0.40, Y = 0.40,Text = "(Alien)Total Karmas Spent:".. math.round(self.AlienTotalSpent, 2), Duration = 120,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,} )
  //    end)
  end
     
end

function Plugin:NotifyGeneric( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[Admin Abuse]",  math.random(0,255), math.random(0,255), math.random(0,255), String, Format, ... )
end
function Plugin:NotifyKarma( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[Karma]",  math.random(0,255), math.random(0,255), math.random(0,255), String, Format, ... )
end
function Plugin:NotifyKarmaDC( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[Double Karma Weekend]",  math.random(0,255), math.random(0,255), math.random(0,255), String, Format, ... )
end
 function Plugin:TunnelExistsNearHiveFor(who)
  self:NotifyKarma( who:GetClient(), "You already have a tunnelentrance at hive, you derp! YOU MADE ME TYPE THIS STATEMENT 4 U!", true)
end
function Plugin:Cleanup()
	self:Disable()
	self.BaseClass.Cleanup( self )    
	self.Enabled = false
end
local function GetIsAlienInSiege(Player)
   if  Player.GetLocationName and 
   string.find(Player:GetLocationName(), "siege") or string.find(Player:GetLocationName(), "Siege") then
   return true
    end
    return false
 end
local function PerformBuy(self, who, String, whoagain, cost, reqlimit, reqground,reqpathing, setowner, delayafter, mapname, techid)
   local autobuild = false 
   local success = false

if whoagain:GetHasLayStructure() then 
self:NotifyKarma(who, "Empty laystructure before buying structure, newb. You're such a newb.", true)
return
end

 

if self:HasLimitOf(who) then 
self:NotifyKarma(who, "Limit of 200 karma per round")
return
end


if reqground then

if not whoagain:GetIsOnGround() then
 self:NotifyKarma( who, "You must be on the ground to purchase %s", true, mapname)
 return
 end
 
 end
 
 if reqpathing then 
 if not GetPathingRequirementsMet(Vector( whoagain:GetOrigin() ),  GetExtents(kTechId.MAC) ) then
self:NotifyKarma( who, "Pathing does not exist in this placement. Purchase invalid.", true)
return 
end
 end
 

self:DeductKarmaIfNotPregame(self, whoagain, cost, delayafter)


local entity = nil 

         if not whoagain:isa("Exo") and ( mapname ~= NutrientMist.kMapName and mapname ~= EnzymeCloud.kMapName 
         and mapname ~= HallucinationCloud.kMapName  ) then 
          whoagain:GiveLayStructure(techid, mapname)
        else
          // entity = CreateEntity(mapname, FindFreeSpace(whoagain:GetOrigin(), 1, 4), whoagain:GetTeamNumber()) 
           entity =  CreateEntity( mapname, whoagain:GetOrigin(), whoagain:GetTeamNumber()) 
           if entity.SetOwner then entity:SetOwner(whoagain) end
          if entity.SetConstructionComplete then  entity:SetConstructionComplete() end
              --if entity:isa("PoopEgg") or entity:isa("Whip") then ent:SetKarmay() end
        end


if entity then 
local supply = LookupTechData(entity:GetTechId(), kTechDataSupply, nil) or 0
whoagain:GetTeam():RemoveSupplyUsed(supply)
end
   local delaytoadd = not GetSetupConcluded() and 4 or delayafter
   Shine.ScreenText.SetText("Karma", string.format( "%s Karma", self:GetPlayerKarmaInfo(who) ), who) 
self.BuyUsersTimer[who] = Shared.GetTime() + delaytoadd
--Shared.ConsoleCommand(string.format("sh_addpool %s", cost)) 
  



end
local function FirstCheckRulesHere(self, Client, Player, String, cost, isastructure)
local Time = Shared.GetTime()
local NextUse = self.BuyUsersTimer[Client]
if NextUse and NextUse > Time and not Shared.GetCheatsEnabled() then
self:NotifyKarma( Client, "Please wait %s seconds before purchasing %s. Thanks.", true, string.TimeToString( NextUse - Time ), String)
return true
end
   if isastructure then 
if ( not GetGamerules():GetGameStarted() and self:PregameLimit(Player:GetTeamNumber()) ) then
self:NotifyKarma( Client, "live count reached for pregame", true)
return true
end

end


if Player:isa("Commander") or not Player:GetIsAlive() then 
      self:NotifyKarma( Client, "Either you're dead, or a commander... Really no difference between the two.. anyway, no credit spending for you.", true)
return true
end

/*
if Player then
 self:NotifyKarma( Client, "Purchases currently disabled. ", true)
 return
end
*/

if ( GetGamerules():GetGameStarted() and not GetGamerules():GetCountingDown()  )  then 
local playeramt =  self:GetPlayerKarmaInfo(Client)
 if playeramt < cost then 
   --Print("player has %s, cost is %s", playeramt,cost)
self:NotifyKarma( Client, "%s costs %s karma, you have %s karma. Purchase invalid.", true, String, cost, self:GetPlayerKarmaInfo(Client))
return true
end

end

end
local function TeamOneBuyRules(self, Client, Player, String)

local mapnameof = nil
local delay = 12
local reqpathing = false
local KarmaCost = 1
local reqground = false
local techid = nil

if String == "Scan" then
mapnameof = Scan.kMapName
techid = kTechId.Scan
delay = 8
elseif String == "Medpack" then
mapnameof = MedPack.kMapName
techid = kTechId.MedPack
delay = 16
elseif String == "Observatory"  then
mapnameof = Observatory.kMapName
techid = kTechId.Observatory
KarmaCost = gKarmaStructureObservatoryCost
elseif String == "Armory"  then
KarmaCost = gKarmaStructureArmoryCost
mapnameof = Armory.kMapName
techid = kTechId.Armory
elseif String == "AdvancedArmory"  then
KarmaCost = gKarmaStructureAdvancedArmoryCost
mapnameof = AdvancedArmory.kMapName
techid = kTechId.AdvancedArmory
elseif String == "Sentry"  then
mapnameof = Sentry.kMapName
techid = kTechId.Sentry
KarmaCost = gKarmaStructureSentryCost
elseif String == "BackupBattery"  then
mapnameof = SentryBattery.kMapName
techid = kTechId.SentryBattery
KarmaCost = gKarmaStructureBackUpBatteryCost
--elseif String == "BackupLight"  then
--mapnameof = BackupLight.kMapName
--techid = kTechId.BackupLight
--limit = 2
--KarmaCost = 6
elseif String == "PhaseGate" then
KarmaCost = gKarmaStructurePhaseGateCost
mapnameof = PhaseGate.kMapName
techid = kTechId.PhaseGate
elseif String == "InfantryPortal" then
mapnameof = InfantryPortal.kMapName
techid = kTechId.InfantryPortal
KarmaCost = gKarmaStructureInfantryPortalCost
elseif  String == "RoboticsFactory" then
mapnameof = RoboticsFactory.kMapName
techid = kTechId.RoboticsFactory
KarmaCost = gKarmaStructureRoboticsFactoryCost
elseif String == "Mac" then
techid = kTechId.MAC
KarmaCost = gKarmaStructureMacCost
mapnameof = MAC.kMapName
elseif String == "Arc" then 
techid = kTechId.ARC
KarmaCost = gKarmaStructureArcCost
mapnameof = ARCCredit.kMapName
elseif String == "Extractor" then 
techid = kTechId.Extractor
KarmaCost = gKarmaStructureCostHarvesterExtractor
mapnameof = Extractor.kMapName
elseif string == nil then
end

return mapnameof, delay, reqground, reqpathing, KarmaCost, techid

end

local function TeamTwoBuyRules(self, Client, Player, String)

local mapnameof = nil
local delay = 12
local reqpathing = false
local reqground = false
local KarmaCost = 2
local techid = nil


if String == "NutrientMist" then 
KarmaCost = gKarmaAbilityCostNutrientMist
mapnameof = NutrientMist.kMapName
reqground = true
elseif String == "Contamination"  then
KarmaCost = gKarmaAbilityCostContamination
mapnameof = Contamination.kMapName    
techid = kTechId.Contamination
elseif String == "EnzymeCloud" then
KarmaCost = gKarmaAbilityCostEnzymeCloud
mapnameof = EnzymeCloud.kMapName
elseif String == "Hallucination" then
KarmaCost = gKarmaAbilityCostHallucination
reqpathing = false
 mapnameof = HallucinationCloud.kMapName

elseif String == "Shade" then
KarmaCost = gKarmaStructureCostShade
mapnameof = Shade.kMapName
techid = kTechId.Shade
elseif String == "Crag" then
KarmaCost = gKarmaStructureCostCrag
mapnameof = Crag.kMapName
techid = kTechId.Crag
elseif String == "Whip" then
KarmaCost = gKarmaStructureCostWhip
mapnameof = Whip.kMapName
techid = kTechId.Whip
elseif String == "Shift" then
KarmaCost = gKarmaStructureCostShift
mapnameof = Shift.kMapName
techid = kTechId.Shift
//elseif String == "Hydra" then
//KarmaCost = 1
//mapnameof = HydraSiege.kMapName
//techid = kTechId.Hydra
//elseif String == "KarmayEgg" then
//KarmaCost = 15
//mapnameof = PoopEgg.kMapName
//techid = kTechId.Egg
elseif String == "Harvester" then
KarmaCost = gKarmaStructureCostHarvesterExtractor
mapnameof = Harvester.kMapName
techid = kTechId.Harvester
end
       
return mapnameof, delay, reqground, reqpathing, KarmaCost, techid

end
local function DeductBuy(self, who, cost, delayafter)
  return self:DeductKarmaIfNotPregame(self, who, cost, delayafter)
end
function Plugin:CreateCommands()


local function TBuy(Client, String)
local Player = Client:GetControllingPlayer()
local mapname = nil
local delayafter = 60
local cost = 1
if not Player then return end

 
local Time = Shared.GetTime()
local NextUse = self.ShadeInkCoolDown
if NextUse and NextUse > Time and not Shared.GetCheatsEnabled() then
self:NotifyKarma( Client, "Team Cooldown on Ink: %s (thank Jon)", true, string.TimeToString( NextUse - Time ), String)
return true
end

   

 
    if String  == "Ink" then cost = 1.5 mapname = ShadeInk.kMapName
   end
   
    if FirstCheckRulesHere(self, Client, Player, String, cost, false ) == true then return end
   
      self:DeductKarmaIfNotPregame(self, Player, cost, delayafter)


 
  Player:GiveItem(mapname)
   
   self.ShadeInkCoolDown = Shared.GetTime() + delayafter
   
end

local function BuyGlow(Client, String)

local Player = Client:GetControllingPlayer()
local delayafter = 8 
local cost = 5
local color = 0
if not Player then return end

if Player:GetIsGlowing() then
self:NotifyKarma( Client, "You're already glowing. Wait until you cease to glow.", true)
 return
end

 if String == "purple" then color = 1 
  elseif String == "weed" then color = 2
  elseif String == "gold" then color = 3
  elseif String == "red" then color = 4
  end
  
 if FirstCheckRulesHere(self, Client, Player, String, cost, false ) == true then return end
            if color == 0 then return end
            
            DeductBuy(self, Player, cost, delayafter)  
            Player:GlowColor(color, 300)
           -- self.GlowClientsTime[Player:GetClient()] = Shared.GetTime() + 300
            --self.GlowClientsColor[Player:GetClient()] = color
   
end


local BuyGlowCommand = self:BindCommand("sh_buyglow", "buyglow", BuyGlow, true)
BuyGlowCommand:Help("sh_buyglow <color number> ")
BuyGlowCommand:AddParam{ Type = "string" }
BuyGlowCommand:AddParam{ Type = "string", Optional = true }



local TBuyCommand = self:BindCommand("sh_tbuy", "tbuy", TBuy, true)
TBuyCommand:Help("sh_buywp <weapon name>")
TBuyCommand:AddParam{ Type = "string" }

local function BuyWP(Client, String)
local Player = Client:GetControllingPlayer()
local mapname = nil
local delayafter = 8 
local cost = 1
if not Player then return end

 

   

 
    if String  == "Mines" then cost = gKarmaWeaponCostMines mapname = LayMines.kMapName
   elseif String == "Welder" then cost = gKarmaWeaponCostWelder mapname = Welder.kMapName
   elseif String == "HeavyMachineGun" then cost = gKarmaWeaponCostHMG mapname = HeavyMachineGun.kMapName
    elseif String  == "Shotgun" then cost = gKarmaWeaponCostShotGun mapname = Shotgun.kMapName 
   elseif String == "FlameThrower" then mapname = Flamethrower.kMapName cost = gKarmaWeaponCostFlameThrower
   elseif String == "GrenadeLauncher" then mapname =  GrenadeLauncher.kMapName cost = gKarmaWeaponCostGrenadeLauncher 
  -- elseif String == "OffensiveConcGrenade" then cost = 100 mapname = ConcGrenadeThrower.kMapName
  -- elseif String == "JediConcGrenade" then cost = 5 mapname = JediConcGrenadeThrower.kMapName
   end
   
    if FirstCheckRulesHere(self, Client, Player, String, cost, false ) == true then return end
    
    
     self:DeductKarmaIfNotPregame(self, Player, cost, delayafter)

 
  Player:GiveItem(mapname)
   
end



local BuyWPCommand = self:BindCommand("sh_buywp", "buywp", BuyWP, true)
BuyWPCommand:Help("sh_buywp <weapon name>")
BuyWPCommand:AddParam{ Type = "string" }

local function BuyCustom(Client, String)
local Player = Client:GetControllingPlayer()
local cost = 4
local delayafter = 8
 if FirstCheckRulesHere(self, Client, Player, String, cost, false ) == true then return end
      local exit, nearhive, count = FindPlayerTunnels(Player)
              if not exit then
              --  Print("No Exit Found!")
             elseif nearhive or ( nearhive and count == 2) then
            -- Print("Tunnel nearhive already exists.")
               self:TunnelExistsNearHiveFor(Player)
             return
             end
     if String == "TunnelEntrance" and Player:isa("Gorge") then
       GorgeWantsEasyEntrance(Player, exit, nearhive)
       DeductBuy(self, Player, cost, delayafter)
     end
end

local BuyCustomCommand = self:BindCommand("sh_buycustom", "buycustom", BuyCustom, true)
BuyCustomCommand:Help("sh_buycustom <custom function> because I want these fine tuned accordingly")
BuyCustomCommand:AddParam{ Type = "string" }

local function BuyClass(Client, String)

local Player = Client:GetControllingPlayer()
local delayafter = 8 
local cost = 1
if not Player then return end

 if String == "JetPack" and not Player:isa("Exo") and not Player:isa("JetPack") then cost = gKarmaClassCostJetPack
  elseif String == "RailGun" and not Player:isa("Exo") then cost = gKarmaClassCostRailGunExo delayafter =   9 
  elseif String == "MiniGun" and not Player:isa("Exo") then  cost = gKarmaClassCostMiniGunExo  delayafter = 9
  elseif String == "Welder" and not Player:isa("Exo") then  cost = 45  delayafter = 15 
   elseif String == "Flamer" and not Player:isa("Exo") then  cost = 46  delayafter = 15 
   elseif String == "WelderFlamer" and not Player:isa("Exo") then  cost = 44  delayafter = 15 
  elseif String == "Gorge" then cost = gKarmaClassCostGorge
  elseif String == "Lerk" then  cost = gKarmaClassCostLerk
  elseif String == "Fade" then cost = gKarmaClassCostFade 
  elseif String == "Onos" then cost = gKarmaClassCostOnos 
  end
  
 if FirstCheckRulesHere(self, Client, Player, String, cost, false ) == true then return end
 
            --Messy, could be re-written to only require activation once of string = X then call DeductBuy @ end
         if Player:GetTeamNumber() == 1 then
              if cost == gKarmaClassCostJetPack then DeductBuy(self, Player, cost, delayafter)   Player:GiveJetpack()
             elseif cost == gKarmaClassCostMiniGunExo then DeductBuy(self, Player, cost, delayafter)  Player:GiveDualExo(Player:GetOrigin())
             elseif cost == gKarmaClassCostRailGunExo then DeductBuy(self, Player, cost, delayafter) Player:GiveDualRailgunExo(Player:GetOrigin())
             elseif cost == 44 then DeductBuy(self, Player, cost, delayafter) Player:GiveWelderFlamer(Player:GetOrigin())
             elseif cost == 45 then DeductBuy(self, Player, cost, delayafter) Player:GiveDualWelder(Player:GetOrigin())
             elseif cost == 46 then DeductBuy(self, Player, cost, delayafter) Player:GiveDualFlamer(Player:GetOrigin())
             end
         elseif Player:GetTeamNumber() == 2 then
              if cost == gKarmaClassCostGorge then DeductBuy(self, Player, cost, delayafter) Player:KarmaBuy(kTechId.Gorge)  
              elseif cost ==gKarmaClassCostLerk  then   DeductBuy(self, Player, cost, delayafter)  Player:KarmaBuy(kTechId.Lerk)
              elseif cost == gKarmaClassCostFade then  DeductBuy(self, Player, cost, delayafter)   Player:KarmaBuy(kTechId.Fade)
              elseif cost == gKarmaClassCostOnos then  DeductBuy(self, Player, cost, delayafter) Player:KarmaBuy(kTechId.Onos) 
              end
         end
   

 
   
end


local BuyClassCommand = self:BindCommand("sh_buyclass", "buyclass", BuyClass, true)
BuyClassCommand:Help("sh_buyclass <class name>")
BuyClassCommand:AddParam{ Type = "string" }


local function Buy(Client, String)

local Player = Client:GetControllingPlayer()
local mapnameof = nil
local Time = Shared.GetTime()
local NextUse = self.BuyUsersTimer[Client]
local reqpathing = true
local reqground = true
if not Player then return end
local KarmaCost = 1
local techid = nil

if Player:GetTeamNumber() == 1 then 
  mapnameof, delay, reqground, reqpathing, KarmaCost, techid = TeamOneBuyRules(self, Client, Player, String)
elseif Player:GetTeamNumber() == 2 then
reqground = false
  mapnameof, delay, reqground, reqpathing, KarmaCost, techid  = TeamTwoBuyRules(self, Client, Player, String)
end // end of team numbers

if mapnameof and ( not FirstCheckRulesHere(self, Client, Player, String, KarmaCost, true ) == true ) then
 PerformBuy(self, Client, String, Player, KarmaCost, true, reqground,reqpathing, true, delay, mapnameof, techid, String) 
end

end



local BuyCommand = self:BindCommand("sh_buy", "buy", Buy, true)
BuyCommand:Help("sh_buy <item name>")
BuyCommand:AddParam{ Type = "string" }

local function Karma(Client, Targets)
for i = 1, #Targets do
local Player = Targets[ i ]:GetControllingPlayer()
self:NotifyKarma( Client, "%s has a total of %s karma", true, Player:GetName(), self:GetPlayerKarmaInfo(Player:GetClient()))
end
end

local KarmasCommand = self:BindCommand("sh_karma", "karma", Karma, true, false)
KarmasCommand:Help("sh_karma <name>")
KarmasCommand:AddParam{ Type = "clients" }

local function AddKarma(Client, Targets, Number, Display, Double)

  if Number > 911 then
      Number = 911
  end 
  
for i = 1, #Targets do
local Player = Targets[ i ]:GetControllingPlayer()
if Double == true then Number = Number * self.Config.kKarmaMultiplier end
self.KarmaUsers[ Player:GetClient() ] = self:GetPlayerKarmaInfo(Player:GetClient()) + Number
Shine.ScreenText.SetText("Karma", string.format( "%s Karma", self:GetPlayerKarmaInfo(Player:GetClient()) ), Player:GetClient()) 
   if Display == true then
   self:NotifyGeneric( nil, "gave %s karma to %s (who now has a total of %s)", true, Number, Player:GetName(), self:GetPlayerKarmaInfo(Player:GetClient()))
   end
end
end

local AddKarmasCommand = self:BindCommand("sh_addkarma", "addkarma", AddKarma)
AddKarmasCommand:Help("sh_addkarma <player> <number> <display> <double> Choose not to display, or to double the amt if dbl crd is act.")
AddKarmasCommand:AddParam{ Type = "clients" }
AddKarmasCommand:AddParam{ Type = "number" }
AddKarmasCommand:AddParam{ Type = "boolean", Optional = true, Default = true }
AddKarmasCommand:AddParam{ Type = "boolean", Optional = true, Default = false }



local function SaveKarmasCmd(Client)
self:SaveAllKarmas(false)
end

local SaveKarmasCommand = self:BindCommand("sh_savecredits", "savecredits", SaveKarmasCmd)
SaveKarmasCommand:Help("sh_savecredits saves all credits online")

end