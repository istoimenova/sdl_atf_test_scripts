---------------------------------------------------------------------------------------------
-- Requirement summary:
-- [Policies] GetListOfPermissions without appID
-- [HMI API] GetListOfPermissions request/response
--
-- Description:
-- On getting SDL.GetListOfPermissions without appID parameter,
-- PoliciesManager must respond with the list of <groupName>s
-- that have the field "user_consent_prompt" in corresponding <functional grouping>
-- and are assigned to the currently registered applications (section "<appID>" -> "groups")
--
-- 1. Preconditions:
-- SDL and HMI are running.
-- Local PT contains in "appID_1" section: "groupName_11", "groupName_12" groups;
-- and in "appID_2" section: "groupName_21", "groupName_22" groups;
-- Register applications with appID_1 and appID_2
-- Activate appID_1 and consent device
--
-- 2. Performed steps:
-- 2.1. HMI -> SDL: GetListOfpermissions ()// without appID
-- 2.2. Allow groupName_11 and disallow groupName_12
-- 2.3. Allow groupName_21 and disallow groupName_22
-- 2.4. HMI -> SDL: GetListOfpermissions ()// without appID
--
-- Expected result:
-- 1. SDL->HMI: GetListOfPermissions
-- (allowedFunctions [{<groupName_11>, allowed:nil}, {<groupName_12>, allowed:nil},
-- {<groupName_11>, allowed:nil}, {<groupName_12>, allowed:nil}])
-- 3. SDL->HMI: GetListOfPermissions
-- (allowedFunctions [{<groupName_11>, allowed:true}, {<groupName_12>, allowed:false}])
--
---------------------------------------------------------------------------------------------
--[[ General configuration parameters ]]
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"
--TODO(istoimenova): remove when issue: "ATF does not stop HB timers by closing session and connection" is fixed
config.defaultProtocolVersion = 2

--[[ Required Shared libraries ]]
local commonFunctions = require ('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonPreconditions = require('user_modules/shared_testcases/commonPreconditions')
local testCasesForPolicyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')
local json = require('json')
local mobile_session = require('mobile_session')

--[[ Local variables]]
local id_group_1 = 0
local id_group_2 = 0
local id_group_3 = 0
local id_group_4 = 0

--[[ Local Functions ]]
--[[@create_ptu_file: creates PTU file for specific application permissions.
! @parameters:
! app_id - Id of application that will be included tmp.json
]]
local function update_preloaded_pt()
  local config_path = commonPreconditions:GetPathToSDL()
  local pathToFile = config_path .. 'sdl_preloaded_pt.json'
  commonPreconditions:BackupFile("sdl_preloaded_pt.json")

  local file = io.open(pathToFile, "r")
  local json_data = file:read("*all")
  file:close()

  local data = json.decode(json_data)

  -- Add user consent groups
  data.policy_table.functional_groupings["groupName_11"] = {
    user_consent_prompt = "groupName_11",
    rpcs = {}
  }
  data.policy_table.functional_groupings["groupName_12"] = {
    user_consent_prompt = "groupName_12",
    rpcs = {}
  }
  data.policy_table.functional_groupings["groupName_21"] = {
    user_consent_prompt = "groupName_21",
    rpcs = {}
  }
  data.policy_table.functional_groupings["groupName_22"] = {
    user_consent_prompt = "groupName_22",
    rpcs = {}
  }

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
    groups = {"Base-4", "groupName_11", "groupName_12"}
  }

  data.policy_table.app_policies[config.application2.registerAppInterfaceParams.appID] = nil
  data.policy_table.app_policies[config.application2.registerAppInterfaceParams.appID] =
  {
    keep_context = false,
    steal_focus = false,
    priority = "NONE",
    default_hmi = "NONE",
    groups = {"Base-4", "groupName_21", "groupName_21"}
  }

  data = json.encode(data)
  file = io.open(pathToFile, "w")
  file:write(data)
  file:close()
end

--[[ General Settings for configuration ]]
commonSteps:DeleteLogsFiles()
commonSteps:DeletePolicyTable()
update_preloaded_pt()

Test = require('connecttest')
require('cardinalities')
require('user_modules/AppTypes')

--[[ Preconditions ]]
commonFunctions:newTestCasesGroup("Preconditions")

function Test:Precondition_StartSecondSession()
  self.mobileSession = mobile_session.MobileSession(self, self.mobileConnection)
  self.mobileSession:StartService(7)
end

function Test:Precondition_RegisterSecondApp()
  local CorIdRegister = self.mobileSession:SendRPC("RegisterAppInterface",
    config.application2.registerAppInterfaceParams)

  EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", {
      application = { appName = config.application2.registerAppInterfaceParams.appName }})
  :Do(function(_,data)
      self.applications[config.application2.registerAppInterfaceParams.appName] = data.params.application.appID
    end)

  EXPECT_RESPONSE(CorIdRegister, { success = true, resultCode = "SUCCESS" })
  EXPECT_NOTIFICATION("OnHMIStatus", { systemContext = "MAIN", hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE"})
end

function Test:Precondition_Device_Consented()
  testCasesForPolicyTable:trigger_getting_device_consent(self,
    config.application1.registerAppInterfaceParams.appName, config.deviceMAC)
end

function Test:Precondition_GetListOfPermissions_before_OnAppPermissionConsent()
  local request_id = self.hmiConnection:SendRequest("SDL.GetListOfPermissions")
  EXPECT_HMIRESPONSE(request_id,
    {allowedFunctions = {
        {name = "groupName_11"}, {name = "groupName_12"},
        {name = "groupName_21"}, {name = "groupName_22"}}})
  :ValidIf(function(_,data)
      -- 'allowed' values should be empty
      if (data.result.allowedFunctions[1].allowed ~= nil) or (data.result.allowedFunctions[2].allowed ~= nil) then
        self.FailTestCase("allowedFunctions's 'allowed' values are not empty.")
      else
        return true
      end
    end)
  :Do(function(_,data)
      if(data.result.allowedFunctions[1] ~= nil) then id_group_1 = data.result.allowedFunctions[1].id end
      if(data.result.allowedFunctions[2] ~= nil) then id_group_2 = data.result.allowedFunctions[2].id end
      if(data.result.allowedFunctions[3] ~= nil) then id_group_3 = data.result.allowedFunctions[3].id end
      if(data.result.allowedFunctions[4] ~= nil) then id_group_4 = data.result.allowedFunctions[4].id end
    end)
end

function Test:Precondition_ChangePermissions_appID_1()
  self.hmiConnection:SendNotification("SDL.OnAppPermissionConsent",
    { appID = self.applications[config.application1.registerAppInterfaceParams.appName],
      consentedFunctions = {
        {allowed = true, id = id_group_1, name = "groupName_11"},
        {allowed = false, id = id_group_2, name = "groupName_12"}
    }, source = "GUI"})
  EXPECT_NOTIFICATION("OnPermissionsChange")
end

function Test:Precondition_ChangePermissions_appID_2()
  self.hmiConnection:SendNotification("SDL.OnAppPermissionConsent",
    { appID = self.applications[config.application2.registerAppInterfaceParams.appName],
      consentedFunctions = {
        {allowed = true, id = id_group_3, name = "groupName_21"},
        {allowed = false, id = id_group_4, name = "groupName_22"}
    }, source = "GUI"})
  self.mobileSession:ExpectNotification("OnPermissionsChange")
end

--[[ Test ]]
commonFunctions:newTestCasesGroup("Test")

function Test:TestStep_GetListOfPermissions_without_appID()
  local request_id = self.hmiConnection:SendRequest("SDL.GetListOfPermissions",
    {appID = self.applications[config.application1.registerAppInterfaceParams.appName]})
  EXPECT_HMIRESPONSE(request_id,{
      result = {code = 0, method = "SDL.GetListOfPermissions",
        allowedFunctions = {
          {name = "groupName_11", id = id_group_1, allowed = true},
          {name = "groupName_12", id = id_group_2, allowed = false},
          {name = "groupName_21", id = id_group_1, allowed = true},
          {name = "groupName_22", id = id_group_1, allowed = false},
    }}})
end

--[[ Postconditions ]]
commonFunctions:newTestCasesGroup("Postconditions")

testCasesForPolicyTable:Restore_preloaded_pt()
function Test.Postcondition_StopSDL()
  StopSDL()
end

return Test
