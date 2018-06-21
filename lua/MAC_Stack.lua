Script.Load("lua/ResearchMixin.lua")
Script.Load("lua/RecycleMixin.lua")

local networkVars = {}
AddMixinNetworkVars(ResearchMixin, networkVars)
AddMixinNetworkVars(RecycleMixin, networkVars)
local origcreate = MAC.OnCreate
function MAC:OnCreate()
    origcreate(self)
    InitMixin(self, ResearchMixin)
    InitMixin(self, RecycleMixin)

end
local originit = MAC.OnInitialized
function MAC:OnInitialized()
    originit(self)
    MAC.kConstructRate = ConditionalValue( GetHasTech(self, kTechId.MacDefenseBuff), 0.4* 1.15, 0.4)  
    MAC.kWeldRate = ConditionalValue( GetHasTech(self, kTechId.MacDefenseBuff), 0.5 * 1.15, 0.5) 
    MAC.kRepairHealthPerSecond = ConditionalValue( GetHasTech(self, kTechId.MacDefenseBuff), 50 * 1.15, 50) 
   -- MAC.kArmor = ConditionalValue( GetHasTech(self, kTechId.MacDefenseBuff), kMACArmor * 1.15, kMACArmor) 
    --Print("kConstructRate %s", MAC.kConstructRate)
end
--Weld other macs and stack macs and dont have delay for not welding while damaged

function MAC:GetCanBeWeldedOverride()
    return true --self.lastTakenDamageTime + 1 < Shared.GetTime()
end

local function GetBackPosition(self, target)

    if not target:isa("Player") then
        return None
    end
    
    local coords = target:GetViewAngles():GetCoords()
    local targetViewAxis = coords.zAxis
    targetViewAxis.y = 0 -- keep it 2D
    targetViewAxis:Normalize()
    local fromTarget = self:GetOrigin() - target:GetOrigin()
    local targetDist = fromTarget:GetLengthXZ()
    fromTarget.y = 0
    fromTarget:Normalize()

    local weldPos = None    
    local dot = targetViewAxis:DotProduct(fromTarget)    
    -- if we are in front or not sufficiently away from the target, we calculate a new weldPos
    if dot > 0.866 or targetDist < MAC.kWeldDistance - 0.5 then
        -- we are in front, find out back positon
        local obstacleSize = 0
        if HasMixin(target, "Extents") then
            obstacleSize = target:GetExtents():GetLengthXZ()
        end
        -- we do not want to go straight through the player, instead we move behind and to the
        -- left or right
        local targetPos = target:GetOrigin()
        local toMidPos = targetViewAxis * (obstacleSize + MAC.kWeldDistance - 0.1)
        local midWeldPos = targetPos - targetViewAxis * (obstacleSize + MAC.kWeldDistance - 0.4)
        local leftV = Vector(-targetViewAxis.z, targetViewAxis.y, targetViewAxis.x)
        local rightV = Vector(targetViewAxis.z, targetViewAxis.y, -targetViewAxis.x)
        local leftWeldPos = midWeldPos + leftV * 2
        local rightWeldPos = midWeldPos + rightV * 2
        --[[
        DebugBox(leftWeldPos+Vector(0,1,0),leftWeldPos+Vector(0,1,0),Vector(0.1,0.1,0.1), 5, 1, 0, 0, 1)
        DebugBox(rightWeldPos+Vector(0,1,0),rightWeldPos+Vector(0,1,0),Vector(0.1,0.1,0.1), 5, 1, 1, 0, 1)
        DebugBox(midWeldPos+Vector(0,1,0),midWeldPos+Vector(0,1,0),Vector(0.1,0.1,0.1), 5, 1, 1, 1, 1)       
        --]]
        -- take the shortest route
        local origin = self:GetOrigin()
        if (origin - leftWeldPos):GetLengthSquared() < (origin - rightWeldPos):GetLengthSquared() then
            weldPos = leftWeldPos
        else
            weldPos = rightWeldPos
        end
    end
    
    return weldPos
        
end
local function CheckBehindBackPosition(self, orderTarget)
                    
    if not self.timeOfLastBackPositionCheck or Shared.GetTime() > self.timeOfLastBackPositionCheck + MAC.kWeldPositionCheckInterval then
 
        self.timeOfLastBackPositionCheck = Shared.GetTime()
        self.backPosition = GetBackPosition(self, orderTarget)

    end

    return self.backPosition    
end
function MAC:ProcessWeldOrder(deltaTime, orderTarget, orderLocation, autoWeld)

    local time = Shared.GetTime()
    local canBeWeldedNow = false
    local orderStatus = kOrderStatus.InProgress

    -- It is possible for the target to not be weldable at this point.
    -- This can happen if a damaged Marine becomes Commander for example.
    -- The Commander is not Weldable but the Order correctly updated to the
    -- new entity Id of the Commander. In this case, the order will simply be completed.
    if orderTarget and HasMixin(orderTarget, "Weldable") then

        local toTarget = (orderLocation - self:GetOrigin())
        local distanceToTarget = toTarget:GetLength()
        canBeWeldedNow = orderTarget:GetCanBeWelded(self)

        local obstacleSize = 0
        if HasMixin(orderTarget, "Extents") then
            obstacleSize = orderTarget:GetExtents():GetLengthXZ()
        end

        local tooFarFromLeash = self.leashedPosition and Vector(self.leashedPosition - self:GetOrigin()):GetLength() > 30 or false

        if autoWeld and (distanceToTarget > 15 or tooFarFromLeash) then
            orderStatus = kOrderStatus.Cancelled
        elseif not canBeWeldedNow then
            orderStatus = kOrderStatus.Completed
        else
            local forceMove = false
            local targetPosition = orderTarget:GetOrigin()

            local closeEnoughToWeld = distanceToTarget - obstacleSize < MAC.kWeldDistance + 0.5
            local shouldMoveCloser = distanceToTarget - obstacleSize > MAC.kWeldDistance

            if closeEnoughToWeld then
                local backPosition = CheckBehindBackPosition(self, orderTarget)
                if backPosition then
                    forceMove = true
                    targetPosition = backPosition
                end
            end

            if shouldMoveCloser or forceMove then
                -- otherwise move towards it
                local hoverAdjustedLocation = GetHoverAt(self, targetPosition)
                local doneMoving = self:MoveToTarget(PhysicsMask.AIMovement, hoverAdjustedLocation, self:GetMoveSpeed(), deltaTime)
                self.moving = not doneMoving
            else
                self.moving = false
            end

            -- Not allowed to weld after taking damage recently.
          -- - if Shared.GetTime() - self:GetTimeLastDamageTaken() <= 1.0 then
          --      return kOrderStatus.InProgress
           -- end

            -- Weld target if we're close enough to weld and enough time has passed since last weld
            if closeEnoughToWeld and (time > self.timeOfLastWeld + MAC.kWeldRate) then
                orderTarget:OnWeld(self, MAC.kWeldRate)
                self.timeOfLastWeld = time
            end

        end

    else
        orderStatus = kOrderStatus.Cancelled
    end
    
    -- Continuously turn towards the target. But don't mess with path finding movement if it was done.
    if orderLocation then
    
        local toOrder = (orderLocation - self:GetOrigin())
        self:SmoothTurn(deltaTime, GetNormalizedVector(toOrder), 0)
        
    end
    
    return orderStatus
    
end

local function GetAutomaticOrder(self)

    local target
    local orderType

    if self.timeOfLastFindSomethingTime == nil or Shared.GetTime() > self.timeOfLastFindSomethingTime + 1 then

        local currentOrder = self:GetCurrentOrder()
        local primaryTarget
        if currentOrder and currentOrder:GetType() == kTechId.FollowAndWeld then
            primaryTarget = Shared.GetEntity(currentOrder:GetParam())
        end

        if primaryTarget and (HasMixin(primaryTarget, "Weldable") and primaryTarget:GetWeldPercentage() < 1) and not primaryTarget:isa("MAC") then
            
            target = primaryTarget
            orderType = kTechId.AutoWeld
                    
        else

            -- If there's a friendly entity nearby that needs constructing, constuct it.
            local constructables = GetEntitiesWithMixinForTeamWithinRange("Construct", self:GetTeamNumber(), self:GetOrigin(), MAC.kOrderScanRadius)
            for c = 1, #constructables do
            
                local constructable = constructables[c]
                if constructable:GetCanConstruct(self) then
                
                    target = constructable
                    orderType = kTechId.Construct
                    break
                    
                end
                
            end
            
            if not target then
            
                -- Look for entities to heal with weld.
                local weldables = GetEntitiesWithMixinForTeamWithinRange("Weldable", self:GetTeamNumber(), self:GetOrigin(), MAC.kOrderScanRadius)
                for w = 1, #weldables do
                
                    local weldable = weldables[w]
                    -- There are cases where the weldable's weld percentage is very close to
                    -- 100% but not exactly 100%. This second check prevents the MAC from being so pedantic.
                    if weldable:GetCanBeWelded(self) and weldable:GetWeldPercentage() < 1 then
                    
                        target = weldable
                        orderType = kTechId.AutoWeld
                        break

                    end
                    
                end
            
            end
        
        end

        self.timeOfLastFindSomethingTime = Shared.GetTime()

    end
    
    return target, orderType

end
local function UpdateOrders(self, deltaTime)

    local currentOrder = self:GetCurrentOrder()
    if currentOrder ~= nil then
    
        local orderStatus = kOrderStatus.None        
        local orderTarget = Shared.GetEntity(currentOrder:GetParam())
        local orderLocation = currentOrder:GetLocation()
    
        if currentOrder:GetType() == kTechId.FollowAndWeld then
            orderStatus = self:ProcessFollowAndWeldOrder(deltaTime, orderTarget, orderLocation)    
        elseif currentOrder:GetType() == kTechId.Move then
            local closeEnough = 2.5
            orderStatus = self:ProcessMove(deltaTime, orderTarget, orderLocation, closeEnough)
            self:UpdateGreetings()

        elseif currentOrder:GetType() == kTechId.Weld or currentOrder:GetType() == kTechId.AutoWeld then
            orderStatus = self:ProcessWeldOrder(deltaTime, orderTarget, orderLocation, currentOrder:GetType() == kTechId.AutoWeld)
        elseif currentOrder:GetType() == kTechId.Build or currentOrder:GetType() == kTechId.Construct then
            orderStatus = self:ProcessConstruct(deltaTime, orderTarget, orderLocation)
        end
        
        if orderStatus == kOrderStatus.Cancelled then
            self:ClearCurrentOrder()
        elseif orderStatus == kOrderStatus.Completed then
            self:CompletedCurrentOrder()
        end
        
    end
    
end

local function FindSomethingToDo(self)
    
    local target, orderType = GetAutomaticOrder(self)
	
    if target and orderType then
        if self.leashedPosition then
            local tooFarFromLeash = Vector(self.leashedPosition - target:GetOrigin()):GetLength() > 15
            if tooFarFromLeash then
                --DebugPrint("Strayed too far!")
                return false
            end
        else
            self.leashedPosition = GetHoverAt(self, self:GetOrigin())
            --DebugPrint("return position set "..ToString(self.leashedPosition))
        end
        self.autoReturning = false
        return self:GiveOrder(orderType, target:GetId(), target:GetOrigin(), nil, true, true) ~= kTechId.None  
    elseif self.leashedPosition and not self.autoReturning then
        self.autoReturning = true
        self:GiveOrder(kTechId.Move, nil, self.leashedPosition, nil, true, true)
        --DebugPrint("returning to "..ToString(self.leashedPosition))
    end
    
    return false
    
end
function MAC:OnUpdate(deltaTime)

    ScriptActor.OnUpdate(self, deltaTime)
    
    if Server and self:GetIsAlive() then

        -- assume we're not moving initially
        self.moving = false
    
        if not self:GetHasOrder() then
            FindSomethingToDo(self)
        else
            UpdateOrders(self, deltaTime)
        end
        
        self.constructing = Shared.GetTime() - self.timeOfLastConstruct < 0.5
        self.welding = Shared.GetTime() - self.timeOfLastWeld < 0.5

        if self.moving and not self.jetsSound:GetIsPlaying() then
            self.jetsSound:Start()
        elseif not self.moving and self.jetsSound:GetIsPlaying() then
            self.jetsSound:Stop()
        end
        
    -- client side build / weld effects
    elseif Client and self:GetIsAlive() then
    
        if self.constructing then
        
            if not self.timeLastConstructEffect or self.timeLastConstructEffect + MAC.kConstructRate < Shared.GetTime()  then
            
                self:TriggerEffects("mac_construct")
                self.timeLastConstructEffect = Shared.GetTime()
                
            end
            
        end
        
        if self.welding then
        
            if not self.timeLastWeldEffect or self.timeLastWeldEffect + MAC.kWeldRate < Shared.GetTime()  then
            
                self:TriggerEffects("mac_weld")
                self.timeLastWeldEffect = Shared.GetTime()
                
            end
            
        end
    
        if self:GetHasOrder() ~= self.clientHasOrder then
        
            self.clientHasOrder = self:GetHasOrder()
            
            if self.clientHasOrder then
                self:TriggerEffects("mac_set_order")
            end
            
        end

        if self.jetsCinematics then

            for id,cinematic in ipairs(self.jetsCinematics) do
                self.jetsCinematics[id]:SetIsActive(self.moving and self:GetIsVisible())
            end

        end

    end
    
end

Shared.LinkClassToMap("MAC", MAC.kMapName, networkVars)