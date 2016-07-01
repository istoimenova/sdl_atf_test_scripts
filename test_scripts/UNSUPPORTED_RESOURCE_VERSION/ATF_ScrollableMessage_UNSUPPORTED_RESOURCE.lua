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
local commonPreconditions = require('user_modules/shared_testcases/commonPreconditions')
local policyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
local commonTestCases = require('user_modules/shared_testcases/commonTestCases')
require('user_modules/AppTypes')

APIName = "ScrollableMessage" -- set request name


---------------------------------------------------------------------------------------------
-------------------------------------------Preconditions-------------------------------------
---------------------------------------------------------------------------------------------


	--Print new line to separate Preconditions
	commonFunctions:newTestCasesGroup("Preconditions")

	--1. Delete app_info.dat, logs and policy table
	commonSteps:DeleteLogsFileAndPolicyTable()

	--1. Activate application
	commonSteps:ActivationApp()


	--2. PutFiles ("action.png")
	commonSteps:PutFile("PutFile_icon.png", "action.png")

-----------------------------------------------------------------------------------------------
-------------------------------------------TEST BLOCK V----------------------------------------
-------------------------------------Checks All Result Codes-----------------------------------
-----------------------------------------------------------------------------------------------

--Begin Test suit ResultCodeChecks


--Print new line to separate test suite
commonFunctions:newTestCasesGroup("Test suit For ResultCodeChecks")


--Description: Check UNSUPPORTED_RESOURCE resultCode

	--Requirement id in JAMA: SDLAQ-CRS-1036

    --Verification criteria:  Used if UI isn't available now (not supported). General request result "success" should be "false".

		function Test:ScrollableMessage_UNSUPPORTED_RESOURCE()

			local Request =
			{
				scrollableMessageBody = "abc",
				softButtons =
				{
					{
						softButtonID = 1,
						text = "Button1",
						type = "IMAGE",
						image =
						{
							value = "action.png",
							imageType = "DYNAMIC"
						},
						isHighlighted = false,
						systemAction = "DEFAULT_ACTION"
					}
				},
				timeout = 5000
			}

		--request from mobile side
		local cid= self.mobileSession:SendRPC("ScrollableMessage", Request)

		--response on mobile side
		EXPECT_RESPONSE(cid, { success = false, resultCode = "UNSUPPORTED_RESOURCE", info = "Destination controller not found!"})
		:Timeout(12000)
	end
--End Test suit ResultCodeChecks


---------------------------------------------------------------------------------------------
-------------------------------------------Postcondition-------------------------------------
---------------------------------------------------------------------------------------------

	--Print new line to separate Postconditions
	commonFunctions:newTestCasesGroup("Postconditions")


	--Restore sdl_preloaded_pt.json
	policyTable:Restore_preloaded_pt()



 return Test
