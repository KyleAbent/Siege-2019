--Kyle 'Avoca' Abent
Script.Load("lua/doors/timer.lua") -- to load timer hook opensiege onopensiege otherwise wont hook
//Script.Load("lua/Additions/Imaginator.lua")
local Shine = Shine
local Plugin = Plugin


local function GetHasSentryBatteryInRadius(self)
      local backupbattery = GetEntitiesWithinRange("SentryBattery", self:GetOrigin(), kBatteryPowerRange)
          for index, battery in ipairs(backupbattery) do
            if GetIsUnitActive(battery) then return true end
           end      
 
   return false
end

local function NewUpdateBatteryState( self )
        local time = Shared.GetTime()
        
        if self.lastBatteryCheckTime == nil or (time > self.lastBatteryCheckTime + 1) then
        
           local location = GetLocationForPoint(self:GetOrigin())
           local powerpoint = location ~= nil and GetPowerPointForLocation(location:GetName())   
            self.attachedToBattery = false
           if powerpoint then 
            self.attachedToBattery = (powerpoint:GetIsBuilt() and not powerpoint:GetIsDisabled()) or GetHasSentryBatteryInRadius(self)
            end
            self.lastBatteryCheckTime = time
        end
end

OldUpdateBatteryState = Shine.Hook.ReplaceLocalFunction( Sentry.OnUpdate, "UpdateBatteryState", NewUpdateBatteryState )


Plugin.Version = "1.0"

function Plugin:Initialise()
self.Enabled = true
self:CreateCommands()
return true
end


function Plugin:MapPostLoad()
      Server.CreateEntity(Timer.kMapName)

end



  function Plugin:OnSiege() 
    Shared.ConsoleCommand("sh_csay Siege Door(s) now open!!!!") 
    self:NotifyTimer( nil, "Siege Door(s) now open!!!!", true)
  end
  
   function Plugin:OnFront() 
    Shared.ConsoleCommand("sh_csay Front Door(s) now open!!!!") 
    self:NotifyTimer( nil, "Front Door(s) now open!!!!", true)
  end
  
Shine.Hook.SetupClassHook( "NS2Gamerules", "DisplayFront", "OnFront", "PassivePost" ) --NS2GameRules b.c im assuming timer isnt created
  
Shine.Hook.SetupClassHook( "NS2Gamerules", "DisplaySiege", "OnSiege", "PassivePost" )  --Timmer calling gamerules for this hook -.-

local function AddFrontTimer(who)
    local Client = who
    local NowToFront = GetTimer():GetFrontLength() - (Shared.GetTime() - GetGamerules():GetGameStartTime())
    local FrontLength =  math.ceil( Shared.GetTime() + NowToFront - Shared.GetTime() )
    Shine.ScreenText.Add( 1, {X = 0.02, Y = 0.40,Text = "Front: %s",Duration = FrontLength,R = 255, G = 255, B = 255,Alignment = 0,Size = 1,FadeIn = 0,}, Client )
end

local function AddSiegeTimer(who)
    local Client = who
    local NowToSiege = GetTimer():GetSiegeLength() - (Shared.GetTime() - GetGamerules():GetGameStartTime())
    local SiegeLength =  math.ceil( Shared.GetTime() + NowToSiege - Shared.GetTime() )
    local ycoord = ConditionalValue(who:isa("Spectator"), 0.85, 0.95)
    Shine.ScreenText.Add( 2, {X = 0.02, Y = 0.45,Text = "Siege: %s",Duration = SiegeLength,R = 255, G = 255, B = 255,Alignment = 0,Size = 1,FadeIn = 0,}, Client )
end


local function GiveTimersToAll()
              local Players = Shine.GetAllPlayers()
              for i = 1, #Players do
              local Player = Players[ i ]
                  if Player then
                  AddFrontTimer(Player)
                  AddSiegeTimer(Player) 
                  end
              end
end


function Plugin:ClientConfirmConnect(Client)
 
 if Client:GetIsVirtual() then return end
 
      
if GetGamerules():GetGameStarted() then

if ( Shared.GetTime() - GetGamerules():GetGameStartTime() ) < kFrontTimer then
     AddFrontTimer(Client)
   end
   
 if ( Shared.GetTime() - GetGamerules():GetGameStartTime() ) < kSiegeTimer then
         AddSiegeTimer(Client)
   end
   

   


end

end
local function OpenAllBreakableDoors()
 for _, door in ientitylist(Shared.GetEntitiesWithClassname("BreakableDoor")) do 
           door.open = true
       door.timeOfDestruction = Shared.GetTime() 
       door:SetHealth(door:GetHealth() - 10)
 end
end
function Plugin:SetGameState( Gamerules, State, OldState )

 if State == kGameState.Started then 
    GiveTimersToAll()
   //  if string.find(Shared.GetMapName(), "pl_") then GivePayloadInfoToAll(self) end
     OpenAllBreakableDoors()
  else
 Shine.ScreenText.End(1) 
 Shine.ScreenText.End(2)
 Shine.ScreenText.End(3)


                       
  end 
    if State ==  kGameState.Team1Won  or State ==  kGameState.Team2Won   then
    self.Started = false
           elseif State == kGameState.Countdown then
              GetTimer():OnRoundStart()
           elseif State == kGameState.NotStarted then
              GetTimer():OnPreGame()
          end
          
    
end


function Plugin:NotifyTimer( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[Timer]",  255, 0, 0, String, Format, ... )
end
function Plugin:NotifyGiveRes( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[GiveRes]",  255, 0, 0, String, Format, ... )
end
function Plugin:NotifyGeneric( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[Admin Abuse]",  255, 0, 0, String, Format, ... )
end
function Plugin:NotifyAutoComm( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[AutoComm]",  255, 0, 0, String, Format, ... )
end
function Plugin:NotifyMods( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[Moderator Chat]",  255, 0, 0, String, Format, ... )
end
function Plugin:GiveCyst(Player)
            local ent = CreateEntity(CystSiege.kMapName, Player:GetOrigin(), Player:GetTeamNumber())  
             ent:SetConstructionComplete()
end



function Plugin:CreateCommands()




local function Pres( Client, Targets, Number )
    for i = 1, #Targets do
    local Player = Targets[ i ]:GetControllingPlayer()
            if not Player:isa("ReadyRoomTeam")  and Player:isa("Alien") or Player:isa("Marine") then
            Player:SetResources(Number)
           	 Shine:CommandNotify( Client, "set %s's resources to %s", true,
			 Player:GetName() or "<unknown>", Number )  
             end
     end
end

local PresCommand = self:BindCommand( "sh_pres", "pres", Pres)
PresCommand:AddParam{ Type = "clients" }
PresCommand:AddParam{ Type = "number" }
PresCommand:Help( "sh_pres <player> <number> sets player's pres to the number desired." )


local function  AddScore( Client, Targets, Number )
    for i = 1, #Targets do
    local Player = Targets[ i ]:GetControllingPlayer()
            if HasMixin(Player, "Scoring") then
            Player:AddScore(Number, 0, false)
           	 Shine:CommandNotify( Client, "%s's score increased by %s", true,
			 Player:GetName() or "<unknown>", Number )  
             end
     end
end

local AddScoreCommand = self:BindCommand( "sh_addscore", "addscore", AddScore)
AddScoreCommand:AddParam{ Type = "clients" }
AddScoreCommand:AddParam{ Type = "number" }
AddScoreCommand:Help( "sh_addscore <player> <number> adds number to players score" )





local function RandomRR( Client )
        local rrPlayers = GetGamerules():GetTeam(kTeamReadyRoom):GetPlayers()
        for p = #rrPlayers, 1, -1 do
            JoinRandomTeam(rrPlayers[p])
        end
           Shine:CommandNotify( Client, "randomized the readyroom", true)  
end
local RandomRRCommand = self:BindCommand( "sh_randomrr", "randomrr", RandomRR )
RandomRRCommand:Help( "randomize's the ready room.") 


local function Stalemate( Client )
local Gamerules = GetGamerules()
if not Gamerules then return end
Gamerules:DrawGame()
end 


local StalemateCommand = self:BindCommand( "sh_stalemate", "stalemate", Stalemate )
StalemateCommand:Help( "declares the round a draw." )




local function Slap( Client, Targets, Number )
//local Giver = Client:GetControllingPlayer()


  
for i = 1, #Targets do
local Player = Targets[ i ]:GetControllingPlayer()
       if Player and Player:GetIsAlive() and not Player:isa("Commander") then
           self:NotifyGeneric( nil, "slapping %s for %s seconds", true, Player:GetName(), Number)
            self:CreateTimer( 13, 1, Number, 
            function () 
           if not Player:GetIsAlive()  and self:TimerExists(13) then self:DestroyTimer( 13 ) return end
            Player:SetVelocity(  Player:GetVelocity() + Vector(math.random(-900,900),math.random(-900,900),math.random(-900,900)  ) )
            end )
end
end
end
local SlapCommand = self:BindCommand( "sh_slap", "slap", Slap)
SlapCommand:Help ("sh_slap <player> <time> Slaps the player once per second random strength")
SlapCommand:AddParam{ Type = "clients" }
SlapCommand:AddParam{ Type = "number" }




local function PHealth( Client, Targets, Number )
    for i = 1, #Targets do
    local Player = Targets[ i ]:GetControllingPlayer()
            if not Player:isa("ReadyRoomTeam")  and Player:isa("Alien") or Player:isa("Marine") then
            local defaulthealth = LookupTechData(Player:GetTechId(), kTechDataMaxHealth, 1)
            if Number > defaulthealth then Player:AdjustMaxHealth(Number) end
              Player:SetHealth(Number)
              
           	 Shine:CommandNotify( Client, "set %s's health to %s", true,
			 Player:GetName() or "<unknown>", Number )  
             end --
     end--
end--
local PHealthCommand = self:BindCommand( "sh_phealth", "phealth", PHealth)
PHealthCommand:AddParam{ Type = "clients" }
PHealthCommand:AddParam{ Type = "number", Min = 1, Max = 8191, Error = "1 min 8191 max" }
PHealthCommand:Help( "sh_phealth <player> <number> sets player's health to the number desired." )

local function PArmor( Client, Targets, Number )
    for i = 1, #Targets do
    local Player = Targets[ i ]:GetControllingPlayer()
            if not Player:isa("ReadyRoomTeam")  and Player:isa("Alien") or Player:isa("Marine") then
            local defaultarmor = LookupTechData(Player:GetTechId(), kTechDataMaxArmor, 1)
            if Number > defaultarmor then Player:AdjustMaxArmor(Number) end
              Player:SetArmor(Number)
              
           	 Shine:CommandNotify( Client, "set %s's armor to %s", true,
			 Player:GetName() or "<unknown>", Number )  
             end--
     end--
end--
local PArmorCommand = self:BindCommand( "sh_parmor", "parmor", PArmor)
PArmorCommand:AddParam{ Type = "clients" }
PArmorCommand:AddParam{ Type = "number", Min = 1, Max = 2045, Error = "1 min 2045 max" }
PArmorCommand:Help( "sh_parmor <player> <number> sets player's armor to the number desired." )


local function SHealth( Client, String, Number  )
        local player = Client:GetControllingPlayer()
        for _, entity in ipairs( GetEntitiesWithMixinWithinRange( "Live", player:GetOrigin(), 8 ) ) do
            if string.find(entity:GetMapName(), String)  then
                  local defaulthealth = LookupTechData(entity:GetTechId(), kTechDataMaxHealth, 1)
                   if entity.SetMature then entity:SetMature() end
                  if Number > defaulthealth then entity:AdjustMaxHealth(Number) end
                  entity:SetHealth(Number)
                  self:NotifyGeneric( nil, "set %s health to %s (%s)", true, entity:GetMapName(), Number,entity:GetLocationName())
             end--
         end--
end--
local SHealthCommand = self:BindCommand( "sh_shealth", "shealth", SHealth )
SHealthCommand:AddParam{ Type = "string" }
SHealthCommand:AddParam{ Type = "number", Min = 1, Max = 8191, Error = "1 min 8191 max" }
SHealthCommand:Help( "shealth <string> <number> within 8 radius sets this classname's health to X" )

local function Sarmor( Client, String, Number  )
        local player = Client:GetControllingPlayer()
        for _, entity in ipairs( GetEntitiesWithMixinWithinRange( "Live", player:GetOrigin(), 8 ) ) do
            if string.find(entity:GetMapName(), String)  then
                  local defaultarmor = LookupTechData(entity:GetTechId(), kTechDataMaxArmor, 1)
                  if Number > defaultarmor then entity:AdjustMaxArmor(Number) end
                  entity:SetArmor(Number)
                  self:NotifyGeneric( nil, "set %s armor to %s (%s)", true, entity:GetMapName(), Number,entity:GetLocationName())
             end--
         end--
end--
local SarmorCommand = self:BindCommand( "sh_sarmor", "sarmor", Sarmor )
SarmorCommand:AddParam{ Type = "string" }
SarmorCommand:AddParam{ Type = "number", Min = 1, Max = 2045, Error = "1 min 2045 max" }
SarmorCommand:Help( "sarmor <string> <number> within 8 radius sets this classname's armor to X" )


local function Respawn( Client, Targets )
    for i = 1, #Targets do
    local Player = Targets[ i ]:GetControllingPlayer()
	        	Shine:CommandNotify( Client, "respawned %s.", true,
				Player:GetName() or "<unknown>" )  
         Player:GetTeam():ReplaceRespawnPlayer(Player)
                 Player:SetCameraDistance(0)
     end--
end--
local RespawnCommand = self:BindCommand( "sh_respawn", "respawn", Respawn )
RespawnCommand:AddParam{ Type = "clients" }
RespawnCommand:Help( "<player> respawns said player" )


local function RunCMD( Client, Targets, String )
    for i = 1, #Targets do
    local Player = Targets[ i ]:GetControllingPlayer()
	        	Player:RunCommand(String)
     end--
end--
local RunCMDCommand = self:BindCommand( "sh_runcmd", "runcmd", RunCMD )
RunCMDCommand:AddParam{ Type = "clients" }
RunCMDCommand:AddParam{ Type = "string" }
RunCMDCommand:Help( "<player> <string> makes the client type something in console of which you choose." )




local function ModelSize( Client, Targets, Number )
  if Number > 10 then return end
    self:NotifyGeneric( nil, "Adjusted %s players size to %s percent", true, #Targets, Number * 100)
    for i = 1, #Targets do
    local Player = Targets[ i ]:GetControllingPlayer()
            if not Player:isa("Commander") and not Player:isa("Spectator") and Player.modelsize and Player:GetIsAlive() then
                Player:AdjustModelSize(Number)
             end
     end
end

local ModelSizeCommand = self:BindCommand( "sh_modelsize", "modelsize", ModelSize )
ModelSizeCommand:AddParam{ Type = "clients" }
ModelSizeCommand:AddParam{ Type = "number" }
ModelSizeCommand:Help( "sh_playergravity <player> <number> works differently than ns1. kinda glitchy. respawn to reset." )


local function TeamSize( Client, Number, NumberTwo )
  if NumberTwo > 10 or (Number ~= 1 and Number ~= 2) then return end
   if Number == 1 then
    self:NotifyGeneric( nil, "Adjusted Marines team size to %s", true, NumberTwo * 100)
    elseif Number == 2 then
        self:NotifyGeneric( nil, "Adjusted Aliens team size to %s", true, NumberTwo * 100)
    end
    
    local Players = Shine.GetAllPlayers()
              for i = 1, #Players do
              local Player = Players[ i ]
                  if Player and Player:GetTeamNumber() == Number and not Player:isa("Commander") and not Player:isa("Spectator") and Player.modelsize then
                       Player:AdjustModelSize(NumberTwo)
                  end
              end
end
local TeamSizeCommand = self:BindCommand( "sh_teamsize", "teamsize", TeamSize )
TeamSizeCommand:AddParam{ Type = "number" }
TeamSizeCommand:AddParam{ Type = "number" }
TeamSizeCommand:Help( "sh_teamsize." )

local function Bury( Client, Targets, Number )
//local Giver = Client:GetControllingPlayer()
for i = 1, #Targets do
local Player = Targets[ i ]:GetControllingPlayer()
       if Player and Player:GetIsAlive() and not Player:isa("Commander") then
           Player:SetOrigin(Player:GetOrigin() - Vector(0, .5, 0))
         self:NotifyGeneric( nil, "Burying %s for %s seconds", true, Player:GetName(), Number)
            self:CreateTimer( 14, Number, 1, 
            function () 
           if not Player:GetIsAlive()  and self:TimerExists(14) then self:DestroyTimer( 14 ) return end
            Player:SetOrigin(Player:GetOrigin() + Vector(0, .5, 0))
            end )
end
end
end

local BuryCommand = self:BindCommand( "sh_bury", "bury", Bury)
BuryCommand:Help ("sh_bury <player> <time> Buries the player for the given time")
BuryCommand:AddParam{ Type = "clients" }
BuryCommand:AddParam{ Type = "number" }

local function Destroy( Client, String  )
        local player = Client:GetControllingPlayer()
        for _, entity in ipairs( GetEntitiesWithMixinWithinRange( "Live", player:GetOrigin(), 8 ) ) do
            if string.find(entity:GetMapName(), String)  then
                  self:NotifyGeneric( nil, "destroyed %s in %s", true, entity:GetMapName(), entity:GetLocationName())
                  DestroyEntity(entity)
             end
         end
end
local DestroyCommand = self:BindCommand( "sh_destroy", "destroy", Destroy )
DestroyCommand:AddParam{ Type = "string" }
DestroyCommand:Help( "Destroy <string> Destroys all entities with this name within 8 radius" )

local function ThirdPerson( Client )
local Player = Client:GetControllingPlayer()
--if not Player or not HasMixin( Player, "CameraHolder" ) then return end
Player:SetCameraDistance(3) //* ConditionalValue(not Player:isa("ReadyRoomPlayer") and Player.modelsize > 1, Player.modelsize * .5, 1))
end

local ThirdPersonCommand = self:BindCommand( "sh_thirdperson", { "thirdperson", "3rdperson" }, ThirdPerson, true)
ThirdPersonCommand:Help( "Triggers third person view" )

local function Disco( Client )
     if Shine:GetUserImmunity(Client) >= 50 then 
     local Player = Client:GetControllingPlayer()
     GetTimer():PerformDisco()
     self:NotifyGeneric( Client, "Disco has no off switch bay bay", true)  
     end 
end

local DiscoCommand = self:BindCommand( "sh_disco", "disco", Disco, true)
--DiscoCommand:Help( "" )

	
local function FirstPerson( Client )
local Player = Client:GetControllingPlayer()
if not Player or not HasMixin( Player, "CameraHolder" ) then return end
Player:SetCameraDistance(0)
end

local FirstPersonCommand = self:BindCommand( "sh_firstperson", { "firstperson", "1stperson" }, FirstPerson, true)
FirstPersonCommand:Help( "Triggers first person view" )

local function GiveRes( Client, TargetClient, Number )
local Giver = Client:GetControllingPlayer()
local Reciever = TargetClient:GetControllingPlayer()
//local TargetName = TargetClient:GetName()
 //Only apply this formula to pres non commanders // If trying to give a number beyond the amount currently owned in pres, do not continue. Or If the reciever already has 100 resources then do not bother taking resources from the giver
  if Giver:GetTeamNumber() ~= Reciever:GetTeamNumber() or Giver:isa("Commander") or Reciever:isa("Commander") or Number > Giver:GetResources() or Reciever:GetResources() == 100 then
  self:NotifyGiveRes( Giver, "Unable to donate any amount of resources to %s", true, Reciever:GetName())
 return end 

 
            //If giving res to a person and that total amount exceeds 100. Only give what can fit before maxing to 100, and not waste the rest.
            if Reciever:GetResources() + Number > 100 then // for example 80 + 30 = 110
            local GiveBack = 0 //introduce x
            GiveBack = Reciever:GetResources() + Number // x = 80 + 30 (110)
            GiveBack = GiveBack - 100  // 110 = 110 - 100 (10)
            Giver:SetResources(Giver:GetResources () - Number + GiveBack) // Sets resources to the value wanting to donate + the portion to give back that's above 100
            local Show = Number - GiveBack
            Reciever:SetResources(100) // Set res to 100 anyway because the check above says if getres + num > 100. Therefore it would be 100 anyway.
              self:NotifyGiveRes( Giver, "%s has reached 100 res, therefore you've only donated %s resource(s)", true, Reciever:GetName(), Show)
              self:NotifyGiveRes( Reciever, "%s donated %s resource(s) to you", true, Giver:GetName(), Show)
            return //prevent from going through the process of handing out res again down below(?)
            end
            ////
 //Otherwise if the giver has the amount to give, and the reciever amount does not go beyond 100, complete the trade. (pres)     
 //Shine:Notify(Client, Number, TargetClient, "Successfully donated %s resource(s) to %s", nil)
Giver:SetResources(Giver:GetResources() - Number)
Reciever:SetResources(Reciever:GetResources() + Number)
self:NotifyGiveRes( Giver, "Succesfully donated %s resource(s) to %s", true, Number, Reciever:GetName())
self:NotifyGiveRes( Reciever, "%s donated %s resource(s) to you", true, Giver:GetName(), Number)
//Notify(StringFormat("[GiveRes] Succesfully donated %s resource(s) to %s.",  Number, TargetName) )


//Now for some fun and to expand on the potential of giveres within ns2 that ns1 did not reach?
//In particular, team res and commanders. 

//If the giver is a commander to a recieving teammate then take the resources out of team resources rather than personal.

//if Giver:GetTeamNumber() == Reciever:GetTeamNumber() and Giver:isa(Commander) then
end

local GiveResCommand = self:BindCommand( "sh_giveres", "giveres", GiveRes, true)
GiveResCommand:Help( "giveres <name> <amount> ~ (No commanders)" )
GiveResCommand:AddParam{ Type = "client",  NotSelf = true, IgnoreCanTarget = true }
GiveResCommand:AddParam{ Type = "number", Min = 1, Max = 100, Round = true }


local function Gravity( Client, Number )
 for _, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do 
    player:SetGravity(Number)
 end
   self:NotifyGeneric( nil, "Set Gravity to %s (0=off)", true, Number)  
end
local GravityCommand = self:BindCommand( "sh_gravity", "gravity", Gravity )
GravityCommand:AddParam{ Type = "number" }
GravityCommand:Help( "sh_gravity <number> (0 = default) applies to all players and copies values on respawn, meaning new players may not be affected?" )

local function Gbd( Client )
local Player = Client:GetControllingPlayer()
 Player:GiveLayStructure(kTechId.Door, BreakableDoor.kMapName)
end
local GbdCommand = self:BindCommand( "sh_gbd", "gbd", Gbd )
GbdCommand:Help( "gives self laystructure breakabledoor placeable anywhere without limit - aboos" )

local function Give( Client, Targets, String, Number )
for i = 1, #Targets do
local Player = Targets[ i ]:GetControllingPlayer()
if Player and Player:GetIsAlive() and String ~= "alien" and not (Player:isa("Alien") and String == "armory") and not (Player:isa"ReadyRoomTeam" and String == "CommandStation" or String == "Hive") and not Player:isa("Commander") then


           
 local teamnum = Number and Number or Player:GetTeamNumber()
 local ent = CreateEntity(String, Player:GetOrigin(), teamnum)  
if HasMixin(ent, "Construct") then  ent:SetConstructionComplete() end
             Shine:CommandNotify( Client, "gave %s an %s", true,
			 Player:GetName() or "<unknown>", String )  
end
end
end
local GiveCommand = self:BindCommand( "sh_give", "give", Give )
GiveCommand:AddParam{ Type = "clients" }
GiveCommand:AddParam{ Type = "string" }
GiveCommand:AddParam{ Type = "number", Optional = true }
GiveCommand:Help( "<player> Give item to player(s)" )


local function Chat( Client, String )
           
      self:SendMessageToMods(String)
end
local ChatCommand = self:BindCommand( "sh_chat", "chat", Chat )
ChatCommand:AddParam{ Type = "string" }
ChatCommand:Help( "for mods to talk in private. Only mods can see and use this chat." )



local function Cyst( Client, Targets )
     for i = 1, #Targets do
     local Player = Targets[ i ]:GetControllingPlayer()
         if Player and Player:GetIsAlive() and Player:isa("Alien") and not Player:isa("Commander") then
             self:GiveCyst(Player)
           self:NotifyGeneric( nil, "Gave %s an Cyst", true, Player:GetName())
          end
     end
end
local CystCommand = self:BindCommand( "sh_cyst", "cyst", Cyst )
CystCommand:AddParam{ Type = "clients" }
CystCommand:Help( "<player> Give cyst to player(s)" )

local function TellHives()
           for index, hive in ientitylist(Shared.GetEntitiesWithClassname("Hive")) do
                hive:OnAutoCommTriggerOn() 
                end
                
                
end

local function Imaginator( Client, Number, Boolean )
GetImaginator():SetImagination(Boolean, Number)
if Number == 1 then 
GetImaginator().marineenabled = Boolean
elseif Number == 2 then
GetImaginator().alienenabled = Boolean
TellHives()
end
 self:NotifyGeneric( nil, "%s Imaginator set to %s (No Comm Required)", true, Number, Boolean)
  
end

local ImaginatorCommand = self:BindCommand( "sh_imaginator", "imaginator", Imaginator )
ImaginatorCommand:Help( "sh_Imaginator - 1/2 - true/false - Automated structure placement system (No Comm Required) " )
ImaginatorCommand:AddParam{ Type = "team" }
ImaginatorCommand:AddParam{ Type = "boolean" }


local function OpenFrontDoors()
           for index, timer in ientitylist(Shared.GetEntitiesWithClassname("Timer")) do
                timer:OpenFrontDoors() 
                end

end

local function OpenBreakableDoors()
           for index, breakabledoor in ientitylist(Shared.GetEntitiesWithClassname("BreakableDoor")) do
               if breakabledoor.health ~= 0 then breakabledoor.health = 0 end 
                end

end

local function Open( Client, String )
local Gamerules = GetGamerules()
     if String == "Front" or String == "front" then
       OpenFrontDoors()
        Shine.ScreenText.End(1) 
     elseif String == "Siege" or String == "siege" then
       GetTimer():OpenSiegeDoors()
         Shine.ScreenText.End(2) 
        -- self:OnOpenSiegeDoors()
     elseif String == "Breakable" or String == "breakable" then
        OpenBreakableDoors()
    end  --
  self:NotifyGeneric( nil, "Opened the %s doors", true, String)  
  
end --

local OpenCommand = self:BindCommand( "sh_open", "open", Open )
OpenCommand:AddParam{ Type = "string" }
OpenCommand:Help( "Opens <type> doors (Front/Siege) (not case sensitive) - timer will still display." )

local function TestFilm( Client )
           for i = 1, 10 do
          Shared.ConsoleCommand("addbot")
         end
         Shared.ConsoleCommand("sh_randomrr")
            Shared.ConsoleCommand("sh_forceroundstart")
            Shared.ConsoleCommand("sh_imaginator 1 true")
          Shared.ConsoleCommand("sh_imaginator 2 true")

  
   self:NotifyGeneric( nil, "%s Test Film ", true)
  
end

local TestFilmCommand = self:BindCommand( "sh_testfilm", "testfilm", TestFilm )
TestFilmCommand:Help( "sh_testfilm adds bots forces round and enables imaginator  " )


local function AutoComm( Client )

  if Shine:GetUserImmunity(Client) >= 10 then 
      
     if not GetGamerules():GetGameStarted() then
            Shared.ConsoleCommand("sh_forceroundstart")
     end

         local boolean = GetImaginator():GetAlienEnabled()
            Shared.ConsoleCommand(string.format("sh_imaginator 2 %s", not boolean )  )
            Shared.ConsoleCommand(string.format("sh_imaginator 1 %s", not boolean )  )
            
            self:NotifyAutoComm( nil, "AutoComm toggle offswitch set to %s", true, boolean)
    end
           
end

local AutoCommCommand = self:BindCommand( "sh_autocomm", "autocomm", AutoComm, true )
AutoCommCommand:Help( "sh_testfilm forces autocomm (disables if human comm) and forces round to start  " )

local function StopAutoComm( Client )
      local Player = Client:GetControllingPlayer()
      if Shine:GetUserImmunity(Client) < 10 then return end--isamod 
      self.stopped = true
      self:NotifyAutoComm( nil, "%s Stopped AutoComm pregame countdown forceroundstart (offswitch is off unless sh_autocomm is toggled during round)", true, Player:GetName() )
end

local StopAutoCommCommand = self:BindCommand( "sh_stop", "stop", StopAutoComm, true )
StopAutoCommCommand:Help( "sh_stop stops auto comm  timer" )

local function ExtendAutoComm( Client )
   local Player = Client:GetControllingPlayer()
   if not self.lastExtend or Shared.GetTime() > self.lastExtend + 90 then
      self.autoCommTime = self.autoCommTime + 60
      self:NotifyAutoComm( nil, "%s Extended AutoComm by 60s. Now at %s seconds left", true, Player:GetName(), self.autoCommTime )
      self.lastExtend = Shared.GetTime()
     self.nextUse = Shared.GetTime() + 90
      else
      self:NotifyAutoComm( Player, "%s seconds until extension allowed", true, string.TimeToString( self.nextUse - Shared.GetTime() ) )
   end
  
 
  
end

local ExtendAutoCommCommand = self:BindCommand( "sh_extend", "extend", ExtendAutoComm, true )
ExtendAutoCommCommand:Help( "sh_extend forces autocomm (disables if human comm) and forces round to start  " )



local function BringAll( Client )
    self:NotifyGeneric( nil, "Brought everyone to one locaiton/area", true)
    
        local Players = Shine.GetAllPlayers()
              for i = 1, #Players do
              local Player = Players[ i ]
                  if Player and not Player:isa("Commander") and not Player:isa("Spectator") then
                       local where = FindFreeSpace(Client:GetControllingPlayer():GetOrigin())
                       Player:SetOrigin(where)
                  end
              end
end

local BringAllCommand = self:BindCommand( "sh_bringall", "bringall", BringAll )
BringAllCommand:Help( "sh_bringall - teleports everyone to the same spot" )





end