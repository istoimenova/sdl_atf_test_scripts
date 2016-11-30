---------------------------------------------------------------------------------------------
-- Requirements summary:
-- [PolicyTableUpdate] OnStatusUpdate(UPDATE_NEEDED) on new PTU request
--
-- Note: copy PTUfilename - ptu.json on this way /tmp/fs/mp/images/ivsu_cache/
-- Description:
-- SDL should request PTU in case new application is registered and is not listed in PT
-- 1. Used preconditions
-- SDL is built with "-DEXTENDED_POLICY: PROPRIETARY" flag
-- Connect mobile phone over WiFi.
-- 2. Performed steps
-- Register new application
--
-- Expected result:
-- PTU is requested. PTS is created.
-- SDL->HMI: SDL.OnStatusUpdate(UPDATE_NEEDED)
-- SDL->HMI: BasicCommunication.PolicyUpdate
---------------------------------------------------------------------------------------------
--[[ General configuration parameters ]]
config.defaultProtocolVersion = 2
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local mobile_session = require('mobile_session')

--[[ Local Variables ]]
--NewTestSuiteNumber = 0

--[[ General Precondition before ATF start]]
commonSteps:DeleteLogsFileAndPolicyTable()

--[[ General Settings for configuration ]]
Test = require('connecttest')

--[[ Local Functions ]]
local registerAppInterfaceParams =
{
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Media Application",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = {"NAVIGATION"},
  appID = "MyApp",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
}

local function policyUpdate(self)
  local RequestIdGetURLS = self.hmiConnection:SendRequest("SDL.GetURLS", { service = 7 })
  EXPECT_HMIRESPONSE(RequestIdGetURLS,{result = {code = 0, method = "SDL.GetURLS", urls = {url = "http://policies.telematics.ford.com/api/policies"}}})
  :Do(function(_,_)
      self.hmiConnection:SendNotification("BasicCommunication.OnSystemRequest",
        {
          requestType = "PROPRIETARY",
          url = "http://policies.telematics.ford.com/api/policies",
          appID = self.applications ["MyTestApp"],
          fileName = "sdl_snapshot.json"
        },
        "/tmp/fs/mp/images/ivsu_cache/sdl_snapshot.json"
      )
    end)
  EXPECT_NOTIFICATION("OnSystemRequest", {requestType = "PROPRIETARY" })
  :Do(function(_,_)
      os.execute("cp /home/anikolaev/OpenSDL_AUTOMATION/test_run/files/ptu.json /tmp/fs/mp/images/ivsu_cache/")
      local CorIdSystemRequest = self.mobileSession:SendRPC ("SystemRequest",
        {
          requestType = "PROPRIETARY",
          fileName = "ptu.json"
        },
        "/tmp/fs/mp/images/ivsu_cache/ptu.json"
      )
      EXPECT_HMICALL("BasicCommunication.SystemRequest")
      :Do(function(_,data)
          self.hmiConnection:SendResponse(data.id,"BasicCommunication.SystemRequest", "SUCCESS", {})
        end)
      EXPECT_RESPONSE(CorIdSystemRequest, {success = true, resultCode = "SUCCESS"})
      :Do(function(_,_)
          self.hmiConnection:SendNotification("SDL.OnReceivedPolicyUpdate",
            {
              policyfile = "/tmp/fs/mp/images/ivsu_cache/ptu.json"
            })
        end)
      :Do(function(_,_)
          EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate", {status = "UP_TO_DATE"})
        end)
    end)
end

-- [[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")
function Test:Precondition_ActivateApplication()
  local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", {appID = self.applications["Test Application"]})
  EXPECT_HMIRESPONSE(RequestId)
  :Do(function(_,data)
      if data.result.isSDLAllowed ~= true then
        RequestId = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "EN-US", messageCodes = {"DataConsent"}})
        EXPECT_HMIRESPONSE(RequestId)
        :Do(function(_,_)
            self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality", {allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}})
            EXPECT_HMICALL("BasicCommunication.ActivateApp")
            :Do(function(_,_)
                self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})
              end)
            :Times(2)
          end)
      end
    end)
  EXPECT_NOTIFICATION("OnHMIStatus", {hmiLevel = "FULL", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
end

function Test:Precondition_MoveSystem_UP_TO_DATE()
  policyUpdate(self, "/tmp/fs/mp/images/ivsu_cache/ptu.json")
end

function Test:Precondition_OpenNewSession()
  self.mobileSession2 = mobile_session.MobileSession(self, self.mobileConnection)
  self.mobileSession2:StartService(7)
end

--[[ Test ]]
commonFunctions:newTestCasesGroup ("Test")
function Test:TestStep_RegisterApplication_In_NewSession_Expect_UPDATE_NEEDED()
  local corId = self.mobileSession2:SendRPC("RegisterAppInterface", registerAppInterfaceParams)
  EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", { application = { appName = "Media Application" }})
  self.mobileSession2:ExpectResponse(corId, { success = true, resultCode = "SUCCESS" })
  self.mobileSession2:ExpectNotification("OnPermissionsChange")
  EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate", {status = "UPDATE_NEEDED"})
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")
Test["StopSDL"] = function()
  StopSDL()
end
