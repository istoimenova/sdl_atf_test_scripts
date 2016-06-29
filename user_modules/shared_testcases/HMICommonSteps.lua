
---------------------------------------------------------------------------------------------

local commonSteps = {}
local mobile_session = require('mobile_session')
local config = require('config')

---------------------------------------------------------------------------------------------



function SendOnSystemContext(self, Input_appID, Input_SystemContext)
  self.hmiConnection:SendNotification("UI.OnSystemContext",{ appID = Input_appID, systemContext = Input_SystemContext})
end
		
return commonSteps

