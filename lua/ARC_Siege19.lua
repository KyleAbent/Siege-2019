//Print("ARC19")Print("ARC19")Print("ARC19")Print("ARC19")Print("ARC19")Print("ARC19")Print("ARC19")Print("ARC19") 
Script.Load("lua/ResearchMixin.lua")
Script.Load("lua/RecycleMixin.lua")
--Script.Load("lua/2019/LevelsMixin.lua")


local networkVars = 

{


}
AddMixinNetworkVars(ResearchMixin, networkVars)
AddMixinNetworkVars(RecycleMixin, networkVars)
--AddMixinNetworkVars(LevelsMixin, networkVars)

local origcreate = ARC.OnCreate
function ARC:OnCreate()
    InitMixin(self, ResearchMixin)
    InitMixin(self, RecycleMixin)
   --   InitMixin(self, LevelsMixin)
    origcreate(self)
end

    /*
    
    function ARC:GetMaxLevel()
    return 10
    end
    
    function ARC:OnAddXp()
   --  local dmg = kARCDamage
     self.kAttackDamage = kARCDamage * (self.level/100) + kARCDamage --difference between self.kattack and arc.kattack :P
     end

    function ARC:GetAddXPAmount()
    return 0.25--0.25
    end
    */


if Server then
   /*
    local origTag= ARC.OnTag
 function ARC:OnTag(tagName) 
     if tagName == "fire_start" then
        self:AddXP(self:GetAddXPAmount())
     end
    origTag(self, tagName)
end 
*/


local origrules = ARC.AcquireTarget
function ARC:AcquireTarget() 

local canfire = GetSetupConcluded()
--Print("Arc can fire is %s", canfire)
if not canfire then return end
return origrules(self)

end



end



Shared.LinkClassToMap("ARC", ARC.kMapName, networkVars)
    


    
    
    
