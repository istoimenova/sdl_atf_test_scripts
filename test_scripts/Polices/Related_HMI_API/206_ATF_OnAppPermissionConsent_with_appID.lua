---------------------------------------------------------------------------------------------
-- Requirement summary:
-- [Policies]: User consent storage in LocalPT (OnAppPermissionConsent with appID)
-- [HMI API] OnAppPermissionConsent notification
--
-- Description:
-- On getting user consent information from HMI via OnAppPermissionConsent(PernissionItem[], appID, source)
-- notification, PoliciesManager must:
--
-- 1) store the User`s consent for app specific group records in "<appID>" subsection of
-- "user_consent_records" subsection of "<device_identifier>" section of "device_data" section in Local PT
-- and apply the appropriate policies.
-- "true/false" value must be set-up for appropriate "consent_groups" in LocalPT conrrespondingly
-- to the parameters of "consentedFunctions" id<->allowed pair consented/not consented by the user on HMI.
--
-- 2) update "input" key value with "source" parameter value in "<appID>" subsection of
-- "user_consent_records" subsection of "<device_identifier>" section of "device_data" section in Local PT
--
--
-- 1. Used preconditions:
-- SDL and HMI are running
-- <Device> is connected to SDL and consented by the User, <App> is running on that device.
-- <App> is registered with SDL and is present in HMI list of registered aps.
-- Local PT has permissions for <App> that require User`s consent
-- 2. Performed steps:
-- 2.1. HMI->SDL: SDL.ActivateApp {appID}
-- 2.2. HMI->SDL: GetUserFriendlyMessage{params},
-- 2.3. HMI->SDL: GetListOfPermissions{appID}
-- 2.4. HMI->SDL: OnAppPermissionConsent {params}
--
-- Expected result:
-- 1. SDL->HMI: SDL.ActivateApp_response{isPermissionsConsentNeeded: true, params}
-- 2. SDL->HMI: GetUserFriendlyMessage_response{params}
-- 3. SDL->HMI: GetListOfPermissions_response{}
-- 4. PoliciesManager: update "<appID>" subsection of "user_consent_records" subsection
-- of "<device_identifier>" section of "device_data" section in Local PT
---------------------------------------------------------------------------------------------
--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonPreconditions = require('user_modules/shared_testcases/commonPreconditions')
local testCasesForPolicyTableSnapshot = require('user_modules/shared_testcases/testCasesForPolicyTableSnapshot')
local testCasesForPolicyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')
local json = require('json')

--[[ Local Functions ]]
--[[@update_preloaded_pt: creates PTU file for specific application permissions]]
local function update_preloaded_pt()
  local config_path = commonPreconditions:GetPathToSDL()
  local pathToFile = config_path .. 'sdl_preloaded_pt.json'
  commonPreconditions:BackupFile("sdl_preloaded_pt.json")

  local file = io.open(pathToFile, "r")
  local json_data = file:read("*all")
  file:close()

  local data = json.decode(json_data)

  if(data.policy_table.functional_groupings["DataConsent-2"]) then
    data.policy_table.functional_groupings["DataConsent-2"].rpcs = json.null
  end

  data.policy_table.app_policies[config.application1.registerAppInterfaceParams.appID] = nil
  data.policy_table.app_policies[config.application1.registerAppInterfaceParams.appID] =
  {
    keep_context = false,
    steal_focus = false,
    priority = "NONE",
    default_hmi = "NONE",
    groups = {"Base-4", "Notifications", "Location-1"}
  }

  data = json.encode(data)
  file = io.open(pathToFile, "w")
  file:write(data)
  file:close()
end

--[[ General Precondition before ATF start ]]
commonSteps:DeleteLogsFiles()
commonSteps:DeletePolicyTable()
update_preloaded_pt()

Test = require('connecttest')
require('cardinalities')
require('user_modules/AppTypes')

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")
function Test:Precondition_trigger_getting_device_consent()
  testCasesForPolicyTable:trigger_getting_device_consent(self,
    config.application1.registerAppInterfaceParams.appName, config.deviceMAC)
end

function Test:Precondition_ExitApplication()
  self.hmiConnection:SendNotification("BasicCommunication.OnExitApplication",
    {appID = self.applications["Test Application"], reason = "USER_EXIT"})
  EXPECT_NOTIFICATION("OnHMIStatus", { systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE"})
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:TestStep_User_consent_on_activate_app()
  local RequestId1 = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage",
    {language = "EN-US", messageCodes = {"Notifications", "Location"}})

  EXPECT_HMIRESPONSE( RequestId1, {result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
  :Do(function()
      local request_id_list_of_permissions = self.hmiConnection:SendRequest("SDL.GetListOfPermissions",
        { appID = self.applications[config.application1.registerAppInterfaceParams.appName] })

      EXPECT_HMIRESPONSE(request_id_list_of_permissions)
      :Do(function(_,data)
          local groups = {}
          if #data.result.allowedFunctions > 0 then
            for i = 1, #data.result.allowedFunctions do
              groups[i] = {
                name = data.result.allowedFunctions[i].name,
                id = data.result.allowedFunctions[i].id,
                allowed = true}
            end
          end

          self.hmiConnection:SendNotification("SDL.OnAppPermissionConsent",
            {appID = self.applications[config.application1.registerAppInterfaceParams.appName],
              consentedFunctions = groups, source = "GUI"})
          EXPECT_NOTIFICATION("OnPermissionsChange")
        end)
    end)
end

function Test:TestStep_check_LocalPT_for_updates()
  local is_test_fail = false
  self.hmiConnection:SendNotification("SDL.OnPolicyUpdate", {} )

  EXPECT_HMICALL("BasicCommunication.PolicyUpdate",{})
  :Do(function(_,data)
      testCasesForPolicyTableSnapshot:extract_pts(
        {self.applications[config.application1.registerAppInterfaceParams.appName]})

      local app_consent_location = testCasesForPolicyTableSnapshot:get_data_from_PTS(
        "device_data." .. config.deviceMAC .. ".user_consent_records." ..
        config.application1.registerAppInterfaceParams.appID .. ".consent_groups.Location-1")

      local app_consent_notifications = testCasesForPolicyTableSnapshot:get_data_from_PTS(
        "device_data." .. config.deviceMAC .. ".user_consent_records." ..
        config.application1.registerAppInterfaceParams.appID .. ".consent_groups.Notifications")

      if(true ~= app_consent_location) then
        commonFunctions:printError("Error: consent_groups.Location function for appID should be true")
        is_test_fail = true
      end

      if(true ~= app_consent_notifications) then
        commonFunctions:printError("Error: consent_groups.Notifications function for appID should be true")
        is_test_fail = true
      end

      self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})

      if(true == is_test_fail) then
        self:FailTestCase("Test is FAILED. See prints.")
      end
    end)
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")
testCasesForPolicyTable:Restore_preloaded_pt()

function Test.Postcondition_Stop()
  StopSDL()
end

return Test
