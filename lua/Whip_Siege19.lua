Script.Load("lua/2019/AvocaMixin.lua")
Script.Load("lua/InfestationMixin.lua")
Script.Load("lua/2019/DigestCommMixin.lua")

local networkVars = { 


}

AddMixinNetworkVars(AvocaMixin, networkVars)
AddMixinNetworkVars(InfestationMixin, networkVars)
AddMixinNetworkVars(DigestCommMixin, networkVars)


local origcreate = Whip.OnCreate
function Whip:OnCreate()
   origcreate(self)
    InitMixin(self, DigestCommMixin)
 end
 
 
local origbuttons = Whip.GetTechButtons
function Whip:GetTechButtons(techId)
local table = {}

table = origbuttons(self, techId)

 --table[4] = kTechId.WhipExplode
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

if Server then

function Whip:CreateFTAtAttachPointandFlickIt()

    local bombStart = self:GetAttachPointOrigin("Whip_Ball")
    local flamethrower = CreateEntity(Flamethrower.kMapName, bombStart + Vector(0,1,0), 1)
end             
                    
local slap = Whip.SlapTarget
function Whip:SlapTarget(target)

    if GetHasTech(self, kTechId.WhipStealFT ) and target and self.slapping then //
        if not self:GetIsOnFire() and self.slapTargetSelector:ValidateTarget(target) then //
         if target:isa("Marine") or target:isa("JetpackMarine") then //
          local client = target:GetClient()
          if not client then return end
          local controlling = client:GetControllingPlayer()
            if controlling:GetWeaponInHUDSlot(1) ~= nil and controlling:GetWeaponInHUDSlot(1):isa("Flamethrower") then //
                local roll = math.random(1,100)
                if roll <= math.random(10,30) then //
                  DestroyEntity(controlling:GetWeaponInHUDSlot(1))
                     if controlling:GetWeaponInHUDSlot(2) ~= nil then //
                      controlling:SwitchWeapon(2)
                      else
                          controlling:SwitchWeapon(3)
                      end     //
                       self:CreateFTAtAttachPointandFlickIt()
                end //
             end //
         end    //                    
        end //
    end //
    
    slap(self, target)
    
end

end


Shared.LinkClassToMap("Whip", Whip.kMapName, networkVars)