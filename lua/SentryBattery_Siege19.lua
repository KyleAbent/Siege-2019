/*

6.20 status: Indestructible while power on , after built if power on, doesn't flicker with light power. Darn.

PrecacheAsset("cinematics/vfx_materials/ghoststructure.surface_shader")
local kGhoststructureMaterial = PrecacheAsset("cinematics/vfx_materials/ghoststructure.material")

local networkVars =
{
 isIndestruct = "boolean"
}

local orig = SentryBattery.OnCreate
function SentryBattery:OnCreate()

    orig(self)
    self.isIndestruct = false
    
end

function SentryBattery:OnConstructionComplete(builder)
   if GetIsRoomPowerUp(self) then  self.isIndestruct = true end
end
function SentryBattery:OnPowerOn()
 self.isIndestruct = true
end
function SentryBattery:OnPowerOff()
--Print("power off")
 self.isIndestruct = false
end
function SentryBattery:ModifyDamageTaken(damageTable, attacker, doer, damageType, hitPoint)

 
    if doer ~= nil and  self.isIndestruct then
        damageTable.damage = 0
    end

end


function SentryBattery:GetUnitNameOverride(viewer)

    local unitName = GetDisplayName(self)
    if  self.isIndestruct  then
        unitName = unitName .. " (" .. Locale.ResolveString("INDESTRUCTABLE") .. ")"
    end

    return unitName
    
end    


if Client then

    function SentryBattery:OnUpdateRender()
          local showMaterial = self.isIndestruct
    
        local model = self:GetRenderModel()
        if model then

            model:SetMaterialParameter("glowIntensity", 4)

            if showMaterial then
                
                if not self.hallucinationMaterial then
                    self.hallucinationMaterial = AddMaterial(model, kGhoststructureMaterial)
                end
                
                self:SetOpacity(0, "hallucination")
            
            else
            
                if self.hallucinationMaterial then
                    RemoveMaterial(model, self.hallucinationMaterial)
                    self.hallucinationMaterial = nil
                end//
                
                self:SetOpacity(1, "hallucination")
            
            end //showma
            
        end//omodel
end //up render
end -- client

Shared.LinkClassToMap("SentryBattery", SentryBattery.kMapName, networkVars)
*/

