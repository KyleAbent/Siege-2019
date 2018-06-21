Script.Load("lua/2019/AvocaMixin.lua")
Script.Load("lua/InfestationMixin.lua")
Script.Load("lua/2019/DigestCommMixin.lua")

local networkVars = { 


}

AddMixinNetworkVars(AvocaMixin, networkVars)
AddMixinNetworkVars(InfestationMixin, networkVars)
AddMixinNetworkVars(DigestCommMixin, networkVars)


local originit = Whip.OnInitialized
function Whip:OnInitialized()

originit(self)
     --Brilliant formula here. I'd like to copyright it. Well, as for modders. :P i'll capitalize on it. winning formula here!
     --Then again, who knows the perf onspawn adjusting networkvar. 
       -- if global then why call all the time and not when necessary? ill figure it out for later
   -- if Marine.kWalkMaxSpeed == 5 then

    Whip.kMoveSpeed = ConditionalValue( GetHasTech(self, kTechId.WhipBuff1), 3.5 * 1.05, 3.5)  
    Whip.kMaxMoveSpeedParam = ConditionalValue( GetHasTech(self, kTechId.WhipBuff1), 10 * 1.05, 10)
    Whip.kRange = ConditionalValue( GetHasTech(self, kTechId.WhipBuff1), 7 * 1.05, 7) 
    Whip.kBombardRange = ConditionalValue( GetHasTech(self, kTechId.WhipBuff1), 20 * 1.05, 20) 
    Whip.kBombSpeed = ConditionalValue( GetHasTech(self, kTechId.WhipBuff1), 20 * 1.05, 20) 
  --  end
    --Better if no respawn required such as alien
  --Print("%s %s %s", Marine.kWalkMaxSpeed, Marine.kRunMaxSpeed, Marine.kRunInfestationMaxSpeed)

end

local origcreate = Whip.OnCreate
function Whip:OnCreate()
   origcreate(self)
    InitMixin(self, DigestCommMixin)
 end
 
 
local origbuttons = Whip.GetTechButtons
function Whip:GetTechButtons(techId)
local table = {}

table = origbuttons(self, techId)

  table[3] = kTechId.WhipBuff1
 table[8] = kTechId.DigestComm
 return table

end

local originit = Whip.OnInitialized
function Whip:OnInitialized()
originit(self)
     //    InitMixin(self, LevelsMixin)
           InitMixin(self, InfestationMixin)
        InitMixin(self, AvocaMixin)
        self.salty = false

end

function Whip:GetInfestationMaxRadius()
    return 1
end

function Whip:GetInfestationRadius()
   if not  GetIsPointOnInfestation(self:GetOrigin()) then 
    return 1
    else 
     return 0 
    end
end

function Whip:SetSalty()
 --nope
end


function Whip:GetCanFireAtTargetActual(target, targetPoint)    

    if target:isa("BreakableDoor") and target.health == 0 then
    return false
    end
    
    return true
    
end


Shared.LinkClassToMap("Whip", Whip.kMapName, networkVars)