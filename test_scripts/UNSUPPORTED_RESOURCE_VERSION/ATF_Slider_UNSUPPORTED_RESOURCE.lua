Test = require('user_modules/connecttestUIUnavailable')
require('cardinalities')
local events = require('events')
local mobile_session = require('mobile_session')

local hmi_connection = require('hmi_connection')
local websocket      = require('websocket_connection')
local module         = require('testbase')
local mobile  = require('mobile_connection')
local tcp = require('tcp_connection')
local file_connection  = require('file_connection')


---------------------------------------------------------------------------------------------
-----------------------------Required Shared Libraries---------------------------------------
---------------------------------------------------------------------------------------------
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local policyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')
require('user_modules/AppTypes')

APIName = "Slider" -- set request name


---------------------------------------------------------------------------------------------
-------------------------------------------Preconditions-------------------------------------
---------------------------------------------------------------------------------------------

	--1. Activate application
	commonSteps:ActivationApp()

	--2. Update policy to allow request
	--local keep_context = true
	--local steal_focus = true
	policyTable:precondition_updatePolicy_AllowFunctionInHmiLeves({"BACKGROUND", "FULL", "LIMITED", "NONE"})
	--policyTable:updatePolicyAndAllowFunctionGroup({"FULL"}, keep_context, steal_focus)



-----------------------------------------------------------------------------------------------
-------------------------------------------TEST BLOCK V----------------------------------------
-------------------------------------Checks All Result Codes-----------------------------------
-----------------------------------------------------------------------------------------------

--Begin Test suit ResultCodeChecks
--Description: Check UNSUPPORTED_RESOURCE resultCode

	--Requirement id in JAMA: SDLAQ-CRS-1032

    --Verification criteria:  When the request is sent and UI isn't avaliable at the moment on current HMI, UNSUPPORTED_RESOURCE is returned as a result of request. Info parameter provides additional information about the case. General request result success=false.

		function Test:Slider_UNSUPPORTED_RESOURCE()

			--mobile side: request parameters
			local Request =
			{
				numTicks = 3,
				position = 2,
				sliderHeader ="sliderHeader",
				sliderFooter = {"1", "2", "3"},
				timeout = 5000
			}

		--request from mobile side
		local cid= self.mobileSession:SendRPC("Slider", Request)

		--response on mobile side
		EXPECT_RESPONSE(cid, { success = false, resultCode = "UNSUPPORTED_RESOURCE", info = "Destination controller not found!"})
		:Timeout(12000)
	end
--End Test suit ResultCodeChecks


--Postcondition: restore sdl_preloaded_pt.json
policyTable:Restore_preloaded_pt()

return Test
