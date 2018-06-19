--Kyle 'Avoca' Abent
local Shine = Shine
local Plugin = Plugin


Shine.Hook.SetupClassHook( "Spectator", "ChangeView", "OnChangeView", "Post" )

Plugin.Version = "1.0"

function Plugin:OnFirstThink() 
    Shine.Timer.Create( "AutoSpectate", 8, -1, function() 
                   for index, player in ientitylist(Shared.GetEntitiesWithClassname("Spectator")) do
                              self:OnChangeView(player)
              end 
    end )
end



function Plugin:Initialise()
self.Enabled = true
self:CreateCommands()
return true
end
function Plugin:NotifyGeneric( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[Director]",  255, 0, 0, String, Format, ... )
end
function Plugin:NotifySand( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[Director]",  255, 0, 0, String, Format, ... )
end
local function GetPregameView()
local choices = {}
 
              
                   for index, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
                  if player ~= self and not player:isa("Spectator")  and not player:isa("ReadyRoomPlayer")  and not player:isa("Commander") and player:GetIsOnGround() then table.insert(choices, player) break end
              end 
            
              local random = table.random(choices)
              return random
              

end
local function GetIsBusy(who)
  local order = who:GetCurrentOrder()
local busy = false
   if order then
   busy = true
   end
  -- if who:isa("MAC") then
 --  elseif who:isa("Drifter") then
   -- end
return busy
end
local function GetViewOne()


if not GetGamerules():GetGameStarted() then return GetPregameView() end

local choices = {}
--arc if moving or in siege
--contam
--commandstructure if in combat
--alive power node in combat
--egg or structure beacon
//local interesting = nil //GetLocationWithMostMixedPlayers()
//if interesting ~= nil then table.insert(choices,interesting) end
           
                for index, camera in ientitylist(Shared.GetEntitiesWithClassname("DirectorCamera")) do
                   table.insert(choices, camera) //should be random not first. always will go to same first. argh. NM no break lol
              end    
              
              for index, shadeink in ientitylist(Shared.GetEntitiesWithClassname("ShadeInk")) do
                   table.insert(choices, shadeink)
              end     
    
              
               for index, arc in ientitylist(Shared.GetEntitiesWithClassname("ARC")) do
                      if arc.mode == ARC.kMode.Moving then table.insert(choices, arc) end
              end 
              
                            
               for index, whip in ientitylist(Shared.GetEntitiesWithClassname("Whip")) do
                      if whip.moving  then table.insert(choices, whip) end
              end 
              
             for index, contam in ientitylist(Shared.GetEntitiesWithClassname("Contamination")) do
                  table.insert(choices, contam) 
                   break  -- just 1xx
              end 
             for index, cs in ientitylist(Shared.GetEntitiesWithClassname("CommandStructure")) do
                  if cs:GetIsInCombat() then table.insert(choices, cs) break end
              end 
                 for _, construct in ipairs(GetEntitiesWithMixin("Construct")) do
                 if not construct:isa("Hydra") and not construct:isa("PowerPoint") and construct:GetIsAlive() and construct:GetHealthScalar() <= .5 and construct:GetIsInCombat() then table.insert(choices, construct) break end --built and not disabled should be summed up by if in combat?
             end  

              
               for index, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
                  if player ~= self and not player:isa("Spectator")  and not player:isa("ReadyRoomPlayer") 
                    and not player:isa("Commander") and player:GetIsInCombat() then 
                   table.insert(choices, player) 
                     break 
                  end
              end 
              
              local random = table.random(choices)
              return random
end
 local function GetViewTwo()

local choices = {}
//local interesting = GetLocationWithMostMixedPlayers()
//if interesting ~= nil then table.insert(choices,interesting) end
            
                                 for index, camera in ientitylist(Shared.GetEntitiesWithClassname("DirectorCamera")) do
                   table.insert(choices, camera) //should be random not first. always will go to same first. argh. NM no break lol
              end    
              
 
             for index, obs in ientitylist(Shared.GetEntitiesWithClassname("Observatory")) do
                  if obs:GetIsBeaconing()  then table.insert(choices, obs) break end --built and not disabled should be summed up by if in combat?
              end  
              
                      for index, whip in ientitylist(Shared.GetEntitiesWithClassname("Whip")) do
                      if whip.moving  then table.insert(choices, whip) end
                     end        
      
             for index, contam in ientitylist(Shared.GetEntitiesWithClassname("Contamination")) do
                  table.insert(choices, contam) 
                   break  -- just 1
              end
        
                  for _, construct in ipairs(GetEntitiesWithMixin("Construct")) do
                 if construct:GetIsBuilt() and  not construct:isa("PowerPoint") and construct:GetHealthScalar() <= .3 and construct:GetIsInCombat() then table.insert(choices, construct) break end --built and not disabled should be summed up by if in combat?
              end     

               for index, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
                  if player ~= self and not player:isa("Spectator")  and not player:isa("ReadyRoomPlayer") 
                    and not player:isa("Commander") and player:GetIsInCombat() then 
                   table.insert(choices, player) 
                     break 
                  end
              end       
              
              
              local random = table.random(choices)
              return random

end
local function GetViewThree()
local choices = {}    
       
                            for index, camera in ientitylist(Shared.GetEntitiesWithClassname("DirectorCamera")) do
                   table.insert(choices, camera) //should be random not first. always will go to same first. argh. NM no break lol
              end    
              
                      for index, arc in ientitylist(Shared.GetEntitiesWithClassname("ARC")) do
                    local order = arc:GetCurrentOrder()
                      if order then 
                 if order:GetType() == kTechId.Move then table.insert(choices, arc) break end -- just 1
                     end
              end 
              
                             for index, whip in ientitylist(Shared.GetEntitiesWithClassname("Whip")) do
                      if whip.moving  then table.insert(choices, whip) end
              end 
              
              
             for index, mac in ientitylist(Shared.GetEntitiesWithClassname("MAC")) do
                  if GetIsBusy(mac) then table.insert(choices, mac) break end 
              end   
         /*
             for index, cyst in ientitylist(Shared.GetEntitiesWithClassname("Cyst")) do
                  if not cyst:GetIsBuilt() then table.insert(choices, cyst) break end 
              end
      */
      
                     for index, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
                  if player ~= self and not player:isa("Spectator")  and not player:isa("ReadyRoomPlayer") 
                    and not player:isa("Commander") and player:GetIsInCombat() then 
                   table.insert(choices, player) 
                     break 
                  end
              end 
  
             for index, drifter in ientitylist(Shared.GetEntitiesWithClassname("Drifter")) do
                  if GetIsBusy(drifter) then table.insert(choices, drifter) break end 
              end    
                   for _, construct in ipairs(GetEntitiesWithMixin("Construct")) do //should be randomized and not index 0
                  if not construct:isa("PowerPoint") and not construct:GetIsBuilt() and construct:GetIsInCombat()
                 then table.insert(choices, construct) 
                  break
                  end --built and not disabled should be summed up by if in combat?
              end    
              
              local random = table.random(choices)
              return random

end
local function GetLocationName(who)
        local location = GetLocationForPoint(who:GetOrigin())
        local locationName = location and location:GetName() or ""
        return locationName
end
local function FindEntNear(where)
                  local entity =  GetNearestMixin(where, "Combat", nil, function(ent) return ent:GetIsInCombat() and not ent:isa("Commander") end)
                    if entity then
                    return FindFreeSpace(entity:GetOrigin())
            end
            return where
end


local function SwitchToOverHead(client, self, where)
        client:BreakChains()
        local height = math.random(4,12)
        self:NotifyGeneric( client, "Overhead mode nearby otherwise inside entity origin. Height is %s", true, height)
        if client.specMode ~= kSpectatorMode.Overhead  then client:SetSpectatorMode(kSpectatorMode.Overhead)  end
        client:SetOrigin(where)
        client.overheadModeHeight =  height

end
local function overHeadandNear(self, client, vip)
          client:SetDesiredCameraDistance(0)
        -- Print("vip is %s", vip:GetClassName())
          if client:GetSpectatorMode() ~= kSpectatorMode.FreeLook then client:SetSpectatorMode(kSpectatorMode.FreeLook)  end
          local viporigin = vip:GetOrigin()
        //  local findfreespace = FindFreeSpace(viporigin, 1, 8)
        //  if findfreespace == viporigin then findfreespace.x = findfreespace.x - 2 return end
            //  client:SetOrigin(findfreespace)
             client:SetOrigin(viporigin)
             client:SetOffsetAngles(vip:GetAngles()) //if iscam
            
           //  local dir = GetNormalizedVector(viporigin - client:GetOrigin())
          //   local angles = Angles(GetPitchFromVector(dir), GetYawFromVector(dir), 0)
           //  client:SetOffsetAngles(angles)
            // client:SetLockOnTarget(vip:GetId())
             //Sixteenth notes within eigth notes which is the other untilNext
             
             self:NotifyGeneric( client, "VIP is %s, location is %s", true, vip:GetClassName(), GetLocationName(client) )
end
local function firstPersonScoreBased(self, client)

    client:BreakChains()
    function sortByScore(ent1, ent2)
        return ent1:GetScore() > ent2:GetScore()
    end
    
    local tableof = {}
                for _, scorer in ipairs(GetEntitiesWithMixin("Scoring")) do
                 if not scorer:isa("ReadyRoomPlayer") and not scorer:isa("Commander") and scorer:GetIsAlive() then table.insert(tableof, scorer) end
              end  
    if table.count(tableof) == 0 then return end
    local max = Clamp(table.count(tableof), 1, 4)
    table.sort(tableof, sortByScore)
    local entrant = math.random(1,max)
    local topscorer = tableof[entrant]
    if not topscorer then return end
    if client:GetSpectatorMode() ~= kSpectatorMode.FirstPerson then client:SetSpectatorMode(kSpectatorMode.FirstPerson)  end
    Server.GetOwner(client):SetSpectatingPlayer(topscorer)
    self:NotifyGeneric( client, "(First person) VIP is %s, # rank in score is %s", true, topscorer:GetName(), entrant )
end
 function Plugin:OnChangeView(client, untilNext, betweenLast)
        
        if not client then return end
       local vip = nil
       

    //while (vip == null) do
        local vip = null
        local random = math.random(1,3)
        if random == 1 then
           vip = GetViewOne()
        elseif random == 2 then
           vip = GetViewTwo()
        elseif random == 3 then
           vip = GetViewThree()
        //else 
        //    firstPersonScoreBased(self, client)
        end
    //end
   
        if vip ~= nil then 
              local roll = math.random(1,2)
             if roll == 1 then
              overHeadandNear(self, client, vip)
             elseif roll == 2 then
              firstPersonScoreBased(self, client)
              end
        else
       firstPersonScoreBased(self, client)
        end
  
         Shine.ScreenText.Add( 50, {X = 0.20, Y = 0.75,Text = "[Director] untilNext: %s",Duration = betweenLast or 0,R = 255, G = 0, B = 0,Alignment = 0,Size = 1,FadeIn = 0,}, client )  

end




function Plugin:CreateCommands()



local function Direct( Client, Targets )
          AutoSpectate(self)
    for i = 1, #Targets do
    local Player = Targets[ i ]:GetControllingPlayer()
          //Shared.ConsoleCommand(string.format("sh_setteam %s %s", Player:GetUserId(), 3 )) 
          //Player:ReplaceRespawnPlayer(Player, nil, nil, Spectator.kMapName)
          Player:Replace(Spectator.kMapName, 3)
     end
end

local DirectCommand = self:BindCommand( "sh_direct", "direct", Direct)
DirectCommand:AddParam{ Type = "clients" }



end