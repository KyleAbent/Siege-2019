
local originit = Armory.OnInitialized
function Armory:OnInitialized()

originit(self)
    --The new one does the oninit global, fantastic!
    --if Armory.kHealAmount == 25 then --if global then why call all the time and not when necessary? ill figure it out for later
    Armory.kHealAmount = ConditionalValue( GetHasTech(self, kTechId.ArmoryBuff1), 25 * 1.10, 5)  
    Armory.kResupplyInterval = ConditionalValue( GetHasTech(self, kTechId.ArmoryBuff1), .8 * 1.10, 5) 
    Armory.kResupplyUseRange = ConditionalValue( GetHasTech(self, kTechId.ArmoryBuff1), 2.5 * 1.10, 5) 
    --OnInit because it won't reset to buffed values such as onresearch would do?
    --If armory dies then it will have the tech if armory is respawned lol. 
  --  end
    
end
local origbuttons = Armory.GetTechButtons
function Armory:GetTechButtons(techId)
local table = {}

table = origbuttons(self, techId)
 table[4] = kTechId.ArmoryBuff1
 return table

end

