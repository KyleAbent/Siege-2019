  local orig = NS2Gamerules.OnCreate

  function NS2Gamerules:OnCreate()
          orig(self)
      self:SetGameStarted()
       
    end

