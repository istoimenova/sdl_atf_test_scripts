-- --------------------------------------------------------------------------------
-- -- Preconditions
-- --------------------------------------------------------------------------------
-- local commonPreconditions = require('user_modules/shared_testcases/commonPreconditions')
-- --------------------------------------------------------------------------------
-- --Precondition: preparation connecttest_RAI.lua
-- commonPreconditions:Connecttest_without_ExitBySDLDisconnect("connecttest_malformed.lua")
local commonPreconditions = require('user_modules/shared_testcases/commonPreconditions')

--------------------------------------------------------------------------------
--Precondition: preparation connecttest_OnAppUnregistered.lua
commonPreconditions:Connecttest_without_ExitBySDLDisconnect("connecttest_RequestType.lua")

--ToDo: shall be removed when APPLINK-16610 is fixed
config.defaultProtocolVersion = 2

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

Test = require('user_modules/connecttest_RequestType')
require('cardinalities')

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local mobile_session = require('mobile_session')
local tcp = require('tcp_connection')
local file_connection  = require('file_connection')
local mobile  = require('mobile_connection')

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

local notificationState = {VRSession = false, EmergencyEvent = false, PhoneCall = false}

local function SUSPEND(self, targetLevel)

   if 
      targetLevel == "FULL" and
      self.hmiLevel ~= "FULL" then
            ActivationApp(self)
            EXPECT_NOTIFICATION("OnHMIStatus", {hmiLevel = "FULL", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
              :Do(function(_,data)
                self.hmiConnection:SendNotification("BasicCommunication.OnExitAllApplications",
                  {
                    reason = "SUSPEND"
                  })

                -- hmi side: expect OnSDLPersistenceComplete notification
                EXPECT_HMINOTIFICATION("BasicCommunication.OnSDLPersistenceComplete")

              end)
    elseif 
      targetLevel == "LIMITED" and
      self.hmiLevel ~= "LIMITED" then
        if self.hmiLevel ~= "FULL" then
          ActivationApp(self)
          EXPECT_NOTIFICATION("OnHMIStatus",
            {hmiLevel = "FULL", audioStreamingState = "AUDIBLE", systemContext = "MAIN"},
            {hmiLevel = "LIMITED", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
            :Do(function(exp,data)
              if exp.occurences == 2 then
                self.hmiConnection:SendNotification("BasicCommunication.OnExitAllApplications",
                  {
                    reason = "SUSPEND"
                  })

                -- hmi side: expect OnSDLPersistenceComplete notification
                EXPECT_HMINOTIFICATION("BasicCommunication.OnSDLPersistenceComplete")
              end
            end)

            -- hmi side: sending BasicCommunication.OnAppDeactivated notification
            self.hmiConnection:SendNotification("BasicCommunication.OnAppDeactivated", {appID = self.applications["Test Application"], reason = "GENERAL"})
        else 
            -- hmi side: sending BasicCommunication.OnAppDeactivated notification
            self.hmiConnection:SendNotification("BasicCommunication.OnAppDeactivated", {appID = self.applications["Test Application"], reason = "GENERAL"})

            EXPECT_NOTIFICATION("OnHMIStatus",
            {hmiLevel = "LIMITED", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
            :Do(function(exp,data)
                self.hmiConnection:SendNotification("BasicCommunication.OnExitAllApplications",
                  {
                    reason = "SUSPEND"
                  })

                -- hmi side: expect OnSDLPersistenceComplete notification
                EXPECT_HMINOTIFICATION("BasicCommunication.OnSDLPersistenceComplete")
            end)
        end
    elseif 
      (targetLevel == "LIMITED" and
      self.hmiLevel == "LIMITED") or
      (targetLevel == "FULL" and
      self.hmiLevel == "FULL") or
      targetLevel == nil then
        self.hmiConnection:SendNotification("BasicCommunication.OnExitAllApplications",
          {
            reason = "SUSPEND"
          })

        -- hmi side: expect OnSDLPersistenceComplete notification
        EXPECT_HMINOTIFICATION("BasicCommunication.OnSDLPersistenceComplete")
    end

end

local function IGNITION_OFF(self, appNumber)
	StopSDL()

	if appNumber == nil then 
		appNumber = 1
	end

	-- hmi side: sends OnExitAllApplications (SUSPENDED)
	self.hmiConnection:SendNotification("BasicCommunication.OnExitAllApplications",
		{
		  reason = "IGNITION_OFF"
		})

	-- hmi side: expect OnSDLClose notification
	EXPECT_HMINOTIFICATION("BasicCommunication.OnSDLClose")

	-- hmi side: expect OnAppUnregistered notification
	EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered")
		:Times(appNumber)
end

local function RegisterApplication(self, registerParams)

    local CorIdRegister = self.mobileSession:SendRPC("RegisterAppInterface", registerParams)

    EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered")
    :Do(function(_,data)
        self.applications[registerParams.appName] = data.params.application.appID
    end)


    self.mobileSession:ExpectResponse(CorIdRegister, 
    	{ 
    		success = true, 
    		resultCode = "SUCCESS"
    	})

	EXPECT_NOTIFICATION("OnHMIStatus", {hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})

end

local function ActivationApp(self)

  if 
    notificationState.VRSession == true then
      self.hmiConnection:SendNotification("VR.Stopped", {})
  elseif 
    notificationState.EmergencyEvent == true then
      self.hmiConnection:SendNotification("BasicCommunication.OnEmergencyEvent", {enabled = false})
  elseif
    notificationState.PhoneCall == true then
      self.hmiConnection:SendNotification("BasicCommunication.OnPhoneCall", {isActive = false})
  end

    -- hmi side: sending SDL.ActivateApp request
      local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications[config.application1.registerAppInterfaceParams.appName]})

    -- hmi side: expect SDL.ActivateApp response
    EXPECT_HMIRESPONSE(RequestId)
      	:Do(function(_,data)
        -- In case when app is not allowed, it is needed to allow app
          	if
              data.result.isSDLAllowed ~= true then

                -- hmi side: sending SDL.GetUserFriendlyMessage request
                  local RequestId = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", 
                          {language = "EN-US", messageCodes = {"DataConsent"}})

                -- hmi side: expect SDL.GetUserFriendlyMessage response
                -- TODO: comment until resolving APPLINK-16094
                -- EXPECT_HMIRESPONSE(RequestId,{result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
                EXPECT_HMIRESPONSE(RequestId)
                    :Do(function(_,data)

	                    -- hmi side: send request SDL.OnAllowSDLFunctionality
	                    self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality", 
                      		{allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}})

	                    -- hmi side: expect BasicCommunication.ActivateApp request
	                      EXPECT_HMICALL("BasicCommunication.ActivateApp")
	                        :Do(function(_,data)

	                          -- hmi side: sending BasicCommunication.ActivateApp response
	                          self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})

	                      end)
	                      :Times(2)
                      end)

        	end
        end)

end

local function CreateSession( self)
	self.mobileSession = mobile_session.MobileSession(
        self,
        self.mobileConnection)
end

local function userPrint( color, message)
  print ("\27[" .. tostring(color) .. "m " .. tostring(message) .. " \27[0m")
end

local function OpenConnectionCreateSession(self)
	local tcpConnection = tcp.Connection(config.mobileHost, config.mobilePort)
	local fileConnection = file_connection.FileConnection("mobile.out", tcpConnection)
	self.mobileConnection = mobile.MobileConnection(fileConnection)
	self.mobileSession= mobile_session.MobileSession(
	self,
	self.mobileConnection)
	event_dispatcher:AddConnection(self.mobileConnection)
	self.mobileSession:ExpectEvent(events.connectedEvent, "Connection started")
	self.mobileConnection:Connect()
	self.mobileSession:StartService(7)
end







-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------
------------------------- General Precondition before ATF start -----------------------------
---------------------------------------------------------------------------------------------
function Test:SuspendFromHMI()
	self.hmiConnection:SendNotification("BasicCommunication.OnExitAllApplications", {reason = "SUSPEND"})

	-- hmi side: expect OnSDLPersistenceComplete notification
	EXPECT_HMINOTIFICATION("BasicCommunication.OnSDLPersistenceComplete")
end

function Test:IgnitionOffFromHMI()
	IGNITION_OFF(self,appNumberForIGNOFF)
end

local function CreatePtuFile()
  -- body
  local json = require("json")
  
  local data = {}
  data.policy_table = {}
  
  data.policy_table.module_config = {}
  data.policy_table.module_config.preloaded_pt = true
  data.policy_table.module_config.preloaded_date = 2015-12-02
  data.policy_table.module_config.exchange_after_x_ignition_cycles = 100
  data.policy_table.module_config.exchange_after_x_kilometers = 1800
  data.policy_table.module_config.exchange_after_x_days = 30
  data.policy_table.module_config.timeout_after_x_seconds = 60
  
  data.policy_table.module_config.seconds_between_retries = {}
  data.policy_table.module_config.seconds_between_retries[1] = 1
  data.policy_table.module_config.seconds_between_retries[2] = 5
  data.policy_table.module_config.seconds_between_retries[3] = 25
  data.policy_table.module_config.seconds_between_retries[4] = 125
  data.policy_table.module_config.seconds_between_retries[5] = 625

  data.policy_table.module_config.endpoints = {}
  data.policy_table.module_config.endpoints["0x07"] = {}
  data.policy_table.module_config.endpoints["0x07"].default = {}
  data.policy_table.module_config.endpoints["0x07"].default[1] = "http://policies.telematics.ford.com/api/policies"
  data.policy_table.module_config.endpoints["0x04"] = {}
  data.policy_table.module_config.endpoints["0x04"].default = {}
  data.policy_table.module_config.endpoints["0x04"].default[1] = "http://ivsu.software.ford.com/api/getsoftwareupdates"
  
  data.policy_table.module_config.notifications_per_minute_by_priority = {}
  data.policy_table.module_config.notifications_per_minute_by_priority.EMERGENCY = 60
  data.policy_table.module_config.notifications_per_minute_by_priority.NAVIGATION = 15
  data.policy_table.module_config.notifications_per_minute_by_priority.VOICECOM = 20
  data.policy_table.module_config.notifications_per_minute_by_priority.COMMUNICATION = 6
  data.policy_table.module_config.notifications_per_minute_by_priority.NORMAL = 4
  data.policy_table.module_config.notifications_per_minute_by_priority.NONE = 0

  data.policy_table.functional_groupings = {}

  func_groups = { PreDataConsent = {"RegisterAppInterface", "UnregisterAppInterface", "OnHMIStatus", "OnPermissionsChange", "SystemRequest"}, 
                DefaultRpcs = {"RegisterAppInterface", "UnregisterAppInterface", "OnHMIStatus", "OnPermissionsChange", "SystemRequest", "ListFiles"}}

  for k in pairs( func_groups ) do
    data.policy_table.functional_groupings[k] = {}
    data.policy_table.functional_groupings[k].rpcs = {}
  end

  for k, v in pairs( func_groups ) do
    for key,value in pairs(v) do
      -- print(value)
      data.policy_table.functional_groupings[k].rpcs[value] = {}
      data.policy_table.functional_groupings[k].rpcs[value].hmi_levels = {}
      data.policy_table.functional_groupings[k].rpcs[value].hmi_levels[1] = "NONE"
      data.policy_table.functional_groupings[k].rpcs[value].hmi_levels[2] = "BACKGROUND"
      data.policy_table.functional_groupings[k].rpcs[value].hmi_levels[3] = "LIMITED"
      data.policy_table.functional_groupings[k].rpcs[value].hmi_levels[4] = "FULL"
    end
  end

  data.policy_table.consumer_friendly_messages = {}
  data.policy_table.consumer_friendly_messages.version = "001.001.021"
  data.policy_table.consumer_friendly_messages.messages = {}
  data.policy_table.consumer_friendly_messages.messages.AppPermissions = {}
  data.policy_table.consumer_friendly_messages.messages.AppPermissions.languages = {}
  data.policy_table.consumer_friendly_messages.messages.AppPermissions.languages["en-us"] = {}
  data.policy_table.consumer_friendly_messages.messages.AppPermissions.languages["en-us"].tts = "%appName% is and permissions: %functionalGroupLabels%. Press yes"
  data.policy_table.consumer_friendly_messages.messages.AppPermissions.languages["en-us"].line1 = "Allowed"
  data.policy_table.consumer_friendly_messages.messages.AppPermissions.languages["en-us"].line2 = "What?"
  data.policy_table.consumer_friendly_messages.messages.AppPermissions.languages["en-us"].textBody = "Text"

  applications_policies = {"default", "device", "pre_DataConsent"}
  
  data.policy_table.app_policies = {}

  for k,v in pairs(applications_policies) do
    data.policy_table.app_policies[v] = {}
    data.policy_table.app_policies[v].keep_context = false
    data.policy_table.app_policies[v].steal_focus = false
    data.policy_table.app_policies[v].priority = "NONE"
    data.policy_table.app_policies[v].default_hmi = "NONE"
    data.policy_table.app_policies[v].RequestType = {}
  end

  data.policy_table.app_policies.default.groups = {}
  data.policy_table.app_policies.default.groups[1] = "DefaultRpcs"

  data.policy_table.app_policies.device.groups = {}
  data.policy_table.app_policies.device.groups[1] = "PreDataConsent"

  data.policy_table.app_policies.pre_DataConsent.groups = {}
  data.policy_table.app_policies.pre_DataConsent.groups[1] = "PreDataConsent"

  data.policy_table.app_policies.default.RequestType = {"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"}
  data.policy_table.app_policies.pre_DataConsent.RequestType = {"PROPRIETARY"}
  data.policy_table.app_policies.device.RequestType = {"PROPRIETARY"}

  data = json.encode(data)

  pathToFile = "/tmp/ptu_update.json"
  file = io.open(pathToFile, "w")
  file:write(data)
  file:close()
end

function Test:convertPreloadedToJson()
  -- body
  -- Create PTU from sdl_preloaded_pt.json
  pathToFile = config.pathToSDL .. "sdl_preloaded_pt.json"
  local file  = io.open(pathToFile, "r")
  local json_data = file:read("*all") -- may be abbreviated to "*a";
  file:close()

  local json = require("json")
   
  local data = json.decode(json_data)

  for k,v in pairs(data.policy_table.functional_groupings) do
    if (data.policy_table.functional_groupings[k].rpcs == nil) then
        --do
        data.policy_table.functional_groupings[k] = nil
    else
        --do
        local count = 0
        for _ in pairs(data.policy_table.functional_groupings[k].rpcs) do count = count + 1 end
        if (count < 30) then
            --do
        data.policy_table.functional_groupings[k] = nil
        end
    end
  end

  return data
end

local odometerValue = 0
local exchange_after_x_kilometers = 0

function Test:GetExchangeAfterXKilometers( ... )
  -- body
  local commandToExecute = "sqlite3 " .. config.pathToSDL .. "/storage/policy.sqlite 'select exchange_after_x_kilometers from module_config;'"
  local f = assert(io.popen(commandToExecute, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  exchange_after_x_kilometers = tonumber(tostring(s))
end

function Test:CreatePTUEmptyRequestTypeDefault(...)
  -- body
  -- Create PTU from sdl_preloaded_pt.json
  local data = self:convertPreloadedToJson()

  -- data.policy_table.app_policies.default.RequestType = {"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"}
  data.policy_table.app_policies.default.RequestType = {}
  data.policy_table.app_policies.device.RequestType = {"PROPRIETARY"}
  data.policy_table.app_policies.pre_DataConsent.RequestType = {"PROPRIETARY"}

  local json = require("json")
  data = json.encode(data)
  -- print(data)
  -- for i=1, #data.policy_table.app_policies.default.groups do
  --  print(data.policy_table.app_policies.default.groups[i])
  -- end
  file = io.open("/tmp/ptu_update.json", "w")
  file:write(data)
  file:close()

end

function Test:StartSdlAfterChangeIniFile()
	StartSDL(config.pathToSDL, config.ExitOnCrash)
end

function Test:InitHmiAfterChangeIniFile()
	self:initHMI()
end

function Test:InitHmiOnReadyAfterChangeIniFile()
	self:initHMI_onReady()
end

function Test:ConnectMobileAfterChangeIniFile()
	self:connectMobile()
end

function Test:StartSesionAfterChangeIniFile()
	CreateSession(self)
end

-- function Test:PreconditionClearLog(...)
-- 	-- body
-- 	os.execute("cat /dev/null > " .. tostring(config.pathToSDL) .. "SmartDeviceLinkCore.log")
-- end

-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

--Begin Test case TC.1
      --Description: This test is intended to check case PTU with "<default>" policies comes and "RequestType" array is empty 

      --Requirement id: APPLINK-14724

      --Verification criteria: PoliciesManager must: 
        -- leave "RequestType" as empty array
        -- allow any request type for such app. 


function Test:makeDeviceUntrusted()
  -- body

  userPrint(35, "================= Precondition ==================")

  -- hmi side: Send SDL.OnAllowSDLFunctionality
  self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality",
    { device = {
        name = "127.0.0.1",
        id = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"
      }, 
      allowed = false,
      source = "GUI" })
end

function Test:PrecondMakeDeviceUntrusted()
  self:makeDeviceUntrusted()
end

local applicationRegisterParams = 
  {
    syncMsgVersion =
    {
      majorVersion = 3,
      minorVersion = 0
    },
    appName = "Test Application",
    isMediaApplication = true,
    languageDesired = 'EN-US',
    hmiDisplayLanguageDesired = 'EN-US',
    appID = "App1",
    deviceInfo =
    {
      os = "Android",
      carrier = "Megafon",
      firmwareRev = "Name: Linux, Version: 3.4.0-perf",
      osVersion = "4.4.2",
      maxNumberRFCOMMPorts = 1
    }
  }

function Test:PrecondRegisterApp1(...)
	-- body
	userPrint(35, "================= Precondition ==================")

	self.mobileSession:StartService(7)
		:Do(function(_,data)
			RegisterApplication(self, applicationRegisterParams)
      -- RegisterApplication(self, config.application1.registerAppInterfaceParams)
		end)
end

-- function Test:PreconditionClearLog(...)
--  -- body
--  os.execute("cat /dev/null > " .. tostring(config.pathToSDL) .. "SmartDeviceLinkCore.log")
-- end

function Test:ptu()

  userPrint(35, "================= Precondition ==================")

  -- hmi side: Send SDL.OnAllowSDLFunctionality
  self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality",
    { device = {
        name = "127.0.0.1",
        id = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"
      }, 
      allowed = true,
      source = "GUI" })

  -- hmi side: sending SDL.ActivateApp request
  -- local updateSdlId = self.hmiConnection:SendRequest("SDL.UpdateSDL",{})

  -- hmi side: expect SDL.ActivateApp response
  EXPECT_HMICALL("BasicCommunication.PolicyUpdate")
  :Do(function(_,data)
    local RequestIdGetURLS = self.hmiConnection:SendRequest("SDL.GetURLS", { service = 7 })
    --hmi side: expect SDL.GetURLS response from HMI
    EXPECT_HMIRESPONSE(RequestIdGetURLS)
    :Do(function(_,data)
      --hmi side: sending BasicCommunication.OnSystemRequest request to SDL
      urlOfCloud = tostring(data.result.urls[1].url)
      self.hmiConnection:SendNotification("BasicCommunication.OnSystemRequest",
        {
          requestType = "PROPRIETARY",
          fileName = "filename",
          -- url = urlOfCloud
        }
      )

      EXPECT_NOTIFICATION("OnSystemRequest", { requestType = "PROPRIETARY" })
      :Do(function(_,data)
        --mobile side: sending SystemRequest request 
        local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest",
          {
            fileName = "PolicyTableUpdate",
            requestType = "PROPRIETARY"
          }, "/tmp/ptu_update.json")
        
        local systemRequestId
        --hmi side: expect SystemRequest request
        EXPECT_HMICALL("BasicCommunication.SystemRequest")
        :Do(function(_,data)
          systemRequestId = data.id
          
          --hmi side: sending BasicCommunication.OnSystemRequest request to SDL
          self.hmiConnection:SendNotification("SDL.OnReceivedPolicyUpdate",
            {
              policyfile = "/tmp/ptu_update.json"
            }
          )
          
          function to_run()
            --hmi side: sending SystemRequest response
            self.hmiConnection:SendResponse(systemRequestId,"BasicCommunication.SystemRequest", "SUCCESS", {})
          end
          
          RUN_AFTER(to_run, 500)
          EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate", {status = "UP_TO_DATE"})
        end)
      end)
    end)
  end)
end

function Test:PrecondPTU()
  self:ptu()
end

function Test:unregisterApp( ... )
  userPrint(35, "================= Precondition ==================")
  --mobile side: UnregisterAppInterface request 
  local CorIdUAI = self.mobileSession:SendRPC("UnregisterAppInterface",{}) 

  --hmi side: expect OnAppUnregistered notification 
  EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered", {appID = self.applications[applicationRegisterParams.appName], unexpectedDisconnect = false})
 

  --mobile side: UnregisterAppInterface response 
  EXPECT_RESPONSE(CorIdUAI, { success = true, resultCode = "SUCCESS"})
  :Timeout(2000)
end

function Test:PrecondExitApp1()
  self:unregisterApp()
end

local language_change = false

function Test:checkOnAppRegistered(params)
  -- body

  userPrint(34, "=================== Test Case ===================")

  local registerAppInterfaceID = self.mobileSession:SendRPC("RegisterAppInterface", applicationRegisterParams)

  -- hmi side: SDL notifies HMI about registered App
  EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", {
    application = {
      appName = applicationRegisterParams.appName,
      requestType = params
    }})

  EXPECT_RESPONSE(registerAppInterfaceID, { success = true, resultCode = "SUCCESS"})
  :Timeout(2000)

  -- EXPECT_NOTIFICATION("OnAppInterfaceUnregistered", {reason = "LANGUAGE_CHANGE"})
  EXPECT_NOTIFICATION("OnAppInterfaceUnregistered")
  :ValidIf(function(exp, data)
    if 
      exp.occurences == 1 then
        language_change = true
        self:FailTestCase("UnexpectedDisconnect")
    end
  end)
end

function Test:CheckOnAppRegisteredHasEmptyRequestType( ... )
  self:checkOnAppRegistered({})
end

function Test:WAregisterAppAgain1( ... )
  -- body
  userPrint(35, "================= WorkAround ==================")
  if language_change == true then
    os.execute( "sleep 3" )
    self:checkOnAppRegistered({})
  end
end

function Test:WAregisterAppAgain2()
  -- body
  userPrint(35, "================= WorkAround ==================")
  language_change = false
end

local requestTypeEnum = {"HTTP", "FILE_RESUME", "AUTH_REQUEST", "AUTH_CHALLENGE", 
  "AUTH_ACK", "PROPRIETARY", "QUERY_APPS", "LAUNCH_APP", "LOCK_SCREEN_ICON_URL", 
  "TRAFFIC_MESSAGE_CHANNEL", "DRIVER_PROFILE", "VOICE_SEARCH", "NAVIGATION", 
  "PHONE", "CLIMATE", "SETTINGS", "VEHICLE_DIAGNOSTICS", "EMERGENCY", "MEDIA", "FOTA"}

for k, v in pairs( requestTypeEnum ) do
  Test["CheckDefaultRequestType" .. v] = function(self)
    userPrint(34, "=================== Test Case ===================")
    local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest",
        {
          fileName = "PolicyTableUpdate",
          requestType = v
        },
      "files/jsons/QUERY_APP/correctJSON.json")

    local systemRequestId
    --hmi side: expect SystemRequest request
    EXPECT_HMICALL("BasicCommunication.SystemRequest")
    :ValidIf(function (self, data)
          -- body
          if #data.params.application.requestType == v then
            return true
          else
            return false
          end
    end)
    :Do(function(_,data)
          --hmi side: sending SystemRequest response
        self.hmiConnection:SendResponse(data.id,"BasicCommunication.SystemRequest", "SUCCESS", {})
    end)

    EXPECT_RESPONSE(CorIdSystemRequest, { success = true, resultCode = "SUCCESS"})        
    :Timeout(5000)
  end
end

--End Test case TC.1

-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

--Begin Test case TC.2
      --Description: This test is intended to check case PTU with "<pre_DataConsent>" policies comes and "RequestType" array is empty 

      --Requirement id: APPLINK-14724

      --Verification criteria: PoliciesManager must: 
        -- leave "RequestType" as empty array
        -- allow any request type for such app.

function Test:CreatePTUEmptyRequestTypePreData(...)
  -- body
  userPrint(35, "================= Precondition ==================")

  -- Create PTU from sdl_preloaded_pt.json
  local data = self:convertPreloadedToJson()

  data.policy_table.app_policies.default.RequestType = {"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"}
  -- data.policy_table.app_policies.default.RequestType = {}
  data.policy_table.app_policies.device.RequestType = {"PROPRIETARY"}
  data.policy_table.app_policies.pre_DataConsent.RequestType = {}

  local json = require("json")
  data = json.encode(data)
  -- print(data)
  -- for i=1, #data.policy_table.app_policies.default.groups do
  --  print(data.policy_table.app_policies.default.groups[i])
  -- end
  file = io.open("/tmp/ptu_update.json", "w")
  file:write(data)
  file:close()

end

function Test:PrecondMakeDeviceUntrusted1( ... )
  self:makeDeviceUntrusted()
end

function Test:TriggerPTU( ... )
  -- body
  userPrint(35, "================= Precondition ==================")

  odometerValue = odometerValue + exchange_after_x_kilometers + 1
  self.hmiConnection:SendNotification("VehicleInfo.OnVehicleData", { odometer = odometerValue})
end

function Test:PrecondPTUPreData()
  self:ptu()
end

function Test:PrecondExitAppPreData()
  self:unregisterApp()
end

function Test:PrecondMakeDeviceUnTrusted2( ... )
  self:makeDeviceUntrusted()
end

function Test:CheckOnAppRegisteredHasEmptyRequestTypePreData( ... )
  self:checkOnAppRegistered({})
end

function Test:WAregisterAppAgain3( ... )
  -- body
  if language_change == true then
    self:checkOnAppRegistered({})
  end
end

function Test:WAregisterAppAgain4()
  -- body
  userPrint(35, "================= WorkAround ==================")

  language_change = false
end

for k, v in pairs( requestTypeEnum ) do
  Test["CheckPreDataRequestType" .. v] = function(self)
    userPrint(34, "=================== Test Case ===================")
    local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest",
        {
          fileName = "PolicyTableUpdate",
          requestType = v
        },
      "files/jsons/QUERY_APP/correctJSON.json")

    local systemRequestId
    --hmi side: expect SystemRequest request
    EXPECT_HMICALL("BasicCommunication.SystemRequest")
    :ValidIf(function (self, data)
          -- body
          -- userPrint(20, v)
          -- userPrint(20, data.params.requestType)
          if data.params.requestType == v then
            return true
          else
            return false
          end
    end)
    :Do(function(_,data)
          --hmi side: sending SystemRequest response
        self.hmiConnection:SendResponse(data.id,"BasicCommunication.SystemRequest", "SUCCESS", {})
    end)

    EXPECT_RESPONSE(CorIdSystemRequest, { success = true, resultCode = "SUCCESS"})        
    :Timeout(5000)
  end
end

--End Test case TC.2

-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

--Begin Test case TC.3
      --Description: This test is intended to check case PTU with "<default>" policies comes with ommited "RequestType" array

      --Requirement id: APPLINK-14723

      -- Verification criteria: PoliciesManager must: 
      -- assign "RequestType" field from "<default>" or 
      -- "<pre_DataConsent>" section of PolicyDataBase to such app 

function Test:CreatePTUValidRequestTypeDefault(...)
  userPrint(35, "================= Precondition ==================")
  -- body
  -- Create PTU from sdl_preloaded_pt.json
  local data = self:convertPreloadedToJson()

  data.policy_table.app_policies.default.RequestType = {"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"}
  -- data.policy_table.app_policies.default.RequestType = {}
  data.policy_table.app_policies.device.RequestType = {"PROPRIETARY"}
  data.policy_table.app_policies.pre_DataConsent.RequestType = {"PROPRIETARY"}

  local json = require("json")
  data = json.encode(data)
  -- print(data)
  -- for i=1, #data.policy_table.app_policies.default.groups do
  --  print(data.policy_table.app_policies.default.groups[i])
  -- end
  file = io.open("/tmp/ptu_update.json", "w")
  file:write(data)
  file:close()

end

function Test:TriggerPTU( ... )
  -- body
  userPrint(35, "================= Precondition ==================")

  odometerValue = odometerValue + exchange_after_x_kilometers + 1
  self.hmiConnection:SendNotification("VehicleInfo.OnVehicleData", { odometer = odometerValue})
end

function Test:PrecondPTUPreData()
  self:ptu()
end

-- --DB query
-- local function Exec(cmd) 
--     local function trim(s)
--       return s:gsub("^%s+", ""):gsub("%s+$", "")
--     end
--     local aHandle = assert(io.popen(cmd , 'r'))
--     local output = aHandle:read( '*a' )
--     return trim(output)
-- end

-- local function DataBaseQuery(self,  DBQueryV)

--     local function query_success(output)
--         if output == "" or DBQueryValue == " " then return false end
--         local f, l = string.find(output, "Error:")
--         if f == 1 then return false end
--         return true;
--     end
--     for i=1,10 do 
--         local DBQuery = 'sqlite3 ' .. config.pathToSDL .. StoragePath .. '/policy.sqlite "' .. tostring(DBQueryV) .. '"'
--         DBQueryValue = Exec(DBQuery)
--         if query_success(DBQueryValue) then
--             return DBQueryValue
--         end
--         os.execute(" sleep 1 ")
--     end
--     return false
-- end

function Test:checkPolicyDb(checkedParams)
  userPrint(34, "=================== Test Case ===================")
  -- body
  local commandtoExecute = "sqlite3 " .. config.pathToSDL .. "/storage/policy.sqlite 'select * from request_type;'"
  local f = assert(io.popen(commandtoExecute, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  -- print(s)
  local function query_success(output)
    if output == "" or DBQueryValue == " " then return false end
    local f, l = string.find(output, "Error:")
    if f == 1 then return false end
    return true;
  end
  local is_db_locked = true
  for i = 1, 10 do
    if query_success(s) then 
      is_db_locked = false
      break 
    else 
      os.execute("sleep 1") 
    end
  end

  if is_db_locked == false then
    self:FailTestCase("DB is locked")
  end

  if string.find(tostring(s), checkedParams[1]) ~= nil
      and string.find(tostring(s), checkedParams[2]) ~= nil
      and string.find(tostring(s), checkedParams[3]) ~= nil then
      --do
      return true
  else
    self:FailTestCase("Policy DB was not updated") 
  end
end

function Test:CheckPolicyDB1()
  self:checkPolicyDb({"PROPRIETARY|default", "QUERY_APPS|default", "LAUNCH_APP|default"})
end

function Test:PrecondExitAppPreData()
  self:unregisterApp()
end

function Test:CheckOnAppRegisteredHasDeafultRequestType()
  self:checkOnAppRegistered({"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"})
end

function Test:WAregisterAppAgain5( ... )
  -- body
  userPrint(35, "================= WorkAround ==================")

  if language_change == true then
    self:checkOnAppRegistered({})
  end
end

function Test:WAregisterAppAgain6()
  -- body
  userPrint(35, "================= WorkAround ==================")
  language_change = false
end

local temp = {}

for k,v in pairs(requestTypeEnum) do
  if v ~= "PROPRIETARY" and v ~= "QUERY_APPS" and v ~= "LAUNCH_APP" then
      --do
      temp[k] = requestTypeEnum[k]
  end
end

for k, v in pairs( temp ) do
  Test["CheckRequestTypeRemainsDefault" .. v] = function(self)
    userPrint(34, "=================== Test Case ===================")
    local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest",
        {
          fileName = "PolicyTableUpdate",
          requestType = v
        },
      "files/jsons/QUERY_APP/correctJSON.json")

    local systemRequestId
    --hmi side: expect SystemRequest request
    EXPECT_HMICALL("BasicCommunication.SystemRequest")
    :Times(0)

    EXPECT_RESPONSE(CorIdSystemRequest, { success = false, resultCode = "DISALLOWED"})        
    :Timeout(5000)
  end
end

for k, v in pairs( {"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"} ) do
  Test["CheckRequestTypeRemainsDefault" .. v] = function(self)
    userPrint(34, "=================== Test Case ===================")
    local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest",
        {
          fileName = "PolicyTableUpdate",
          requestType = v
        },
      "files/jsons/QUERY_APP/correctJSON.json")

    local systemRequestId
    --hmi side: expect SystemRequest request
    EXPECT_HMICALL("BasicCommunication.SystemRequest")
    :ValidIf(function (self, data)
          -- body
          -- userPrint(20, data.params.requestType)
          -- userPrint(20, v)
          if data.params.requestType == v then
            return true
          else
            return false
          end
    end)
    :Do(function(_,data)
          --hmi side: sending SystemRequest response
        self.hmiConnection:SendResponse(data.id,"BasicCommunication.SystemRequest", "SUCCESS", {})
    end)

    EXPECT_RESPONSE(CorIdSystemRequest, { success = true, resultCode = "SUCCESS"})        
    :Timeout(5000)
  end
end

function Test:CreatePTUOmmitedRequestTypeDefault(...)
  userPrint(35, "================= Precondition ==================")
  -- body
  -- Create PTU from sdl_preloaded_pt.json
  local data = self:convertPreloadedToJson()

  -- data.policy_table.app_policies.default.RequestType = {"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"}
  data.policy_table.app_policies.default.RequestType = nil
  data.policy_table.app_policies.device.RequestType = {"PROPRIETARY"}
  data.policy_table.app_policies.pre_DataConsent.RequestType = {"PROPRIETARY"}

  local json = require("json")
  data = json.encode(data)
  -- print(data)
  -- for i=1, #data.policy_table.app_policies.default.groups do
  --  print(data.policy_table.app_policies.default.groups[i])
  -- end
  file = io.open("/tmp/ptu_update.json", "w")
  file:write(data)
  file:close()

end

function Test:PrecondMakeDeviceUntrustedOmmited( ... )
  -- body
  self:makeDeviceUntrusted()
end

function Test:TriggerPTU( ... )
  -- body
  userPrint(35, "================= Precondition ==================")

  odometerValue = odometerValue + exchange_after_x_kilometers + 1
  self.hmiConnection:SendNotification("VehicleInfo.OnVehicleData", { odometer = odometerValue})
end


function Test:PrecondPTUWithOmmitedDefault()
  self:ptu()
end

for k, v in pairs( temp ) do
  Test["CheckRequestTypeRemainsDefault" .. v] = function(self)
    userPrint(34, "=================== Test Case ===================")
    local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest",
        {
          fileName = "PolicyTableUpdate",
          requestType = v
        },
      "files/jsons/QUERY_APP/correctJSON.json")

    local systemRequestId
    --hmi side: expect SystemRequest request
    EXPECT_HMICALL("BasicCommunication.SystemRequest")
    :Times(0)

    EXPECT_RESPONSE(CorIdSystemRequest, { success = false, resultCode = "DISALLOWED"})        
    :Timeout(5000)
  end
end

for k, v in pairs( {"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"} ) do
  Test["CheckRequestTypeRemainsDefault" .. v] = function(self)
    userPrint(34, "=================== Test Case ===================")

    local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest",
        {
          fileName = "PolicyTableUpdate",
          requestType = v
        },
      "files/jsons/QUERY_APP/correctJSON.json")

    local systemRequestId
    --hmi side: expect SystemRequest request
    EXPECT_HMICALL("BasicCommunication.SystemRequest")
    :ValidIf(function (self, data)
          -- body
          -- userPrint(20, data.params.requestType)
          -- userPrint(20, v)
          if data.params.requestType == v then
            return true
          else
            return false
          end
    end)
    :Do(function(_,data)
          --hmi side: sending SystemRequest response
        self.hmiConnection:SendResponse(data.id,"BasicCommunication.SystemRequest", "SUCCESS", {})
    end)

    EXPECT_RESPONSE(CorIdSystemRequest, { success = true, resultCode = "SUCCESS"})        
    :Timeout(5000)
  end
end

--End Test case TC.3

-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

--Begin Test case TC.4
      --Description: This test is intended to check case PTU with "<pre_DataConsent>" policies comes with ommited "RequestType" array

      --Requirement id: APPLINK-14723

      -- Verification criteria: PoliciesManager must: 
      -- assign "RequestType" field from "<default>" or 
      -- "<pre_DataConsent>" section of PolicyDataBase to such app 

function Test:CreatePTUValidRequestTypeDefault(...)
  userPrint(35, "================= Precondition ==================")
  -- body
  -- Create PTU from sdl_preloaded_pt.json
  local data = self:convertPreloadedToJson()

  -- data.policy_table.app_policies.default.RequestType = {"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"}
  data.policy_table.app_policies.default.RequestType = {"PROPRIETARY"}
  data.policy_table.app_policies.device.RequestType = {"PROPRIETARY"}
  data.policy_table.app_policies.pre_DataConsent.RequestType = {"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"}

  local json = require("json")
  data = json.encode(data)
  -- print(data)
  -- for i=1, #data.policy_table.app_policies.default.groups do
  --  print(data.policy_table.app_policies.default.groups[i])
  -- end
  file = io.open("/tmp/ptu_update.json", "w")
  file:write(data)
  file:close()

end

function Test:PrecondMakeDeviceUntrustedOmmitedPreData( ... )
  self:makeDeviceUntrusted()
end

function Test:TriggerPTU( ... )
  -- body
  userPrint(35, "================= Precondition ==================")

  odometerValue = odometerValue + exchange_after_x_kilometers + 1
  self.hmiConnection:SendNotification("VehicleInfo.OnVehicleData", { odometer = odometerValue})
end


function Test:PrecondPTUPreDataWithValidValues()
  self:ptu()
end

function Test:CheckPolicyDB2()
  self:checkPolicyDb({"PROPRIETARY|pre_DataConsent", "QUERY_APPS|pre_DataConsent", "LAUNCH_APP|pre_DataConsent"})
end

function Test:PrecondExitAppPreData()
  self:unregisterApp()
end

function Test:PrecondMakeDeviceUntrustedOmmitedPreData2( ... )
  self:makeDeviceUntrusted()
end

function Test:CheckOnAppRegisteredHasEmptyRequestTypePreData( ... )
  self:checkOnAppRegistered({"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"})
end

function Test:WAregisterAppAgain7( ... )
  -- body
  userPrint(35, "================= WorkAround ==================")

  if language_change == true then
    self:checkOnAppRegistered({})
  end
end

function Test:WAregisterAppAgain8()
  -- body
  userPrint(35, "================= WorkAround ==================")

  language_change = false
end

for k, v in pairs( temp ) do
  Test["CheckRequestTypeRemainsDefault" .. v] = function(self)
  userPrint(34, "=================== Test Case ===================")
    local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest",
        {
          fileName = "PolicyTableUpdate",
          requestType = v
        },
      "files/jsons/QUERY_APP/correctJSON.json")

    local systemRequestId
    --hmi side: expect SystemRequest request
    EXPECT_HMICALL("BasicCommunication.SystemRequest")
    :Times(0)

    EXPECT_RESPONSE(CorIdSystemRequest, { success = false, resultCode = "DISALLOWED"})        
    :Timeout(5000)
  end
end

for k, v in pairs( {"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"} ) do
  Test["CheckRequestTypeRemainsDefault" .. v] = function(self)
    userPrint(34, "=================== Test Case ===================")
    local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest",
        {
          fileName = "PolicyTableUpdate",
          requestType = v
        },
      "files/jsons/QUERY_APP/correctJSON.json")

    local systemRequestId
    --hmi side: expect SystemRequest request
    EXPECT_HMICALL("BasicCommunication.SystemRequest")
    :ValidIf(function (self, data)
          -- body
          -- userPrint(20, data.params.requestType)
          -- userPrint(20, v)
          if data.params.requestType == v then
            return true
          else
            return false
          end
    end)
    :Do(function(_,data)
          --hmi side: sending SystemRequest response
        self.hmiConnection:SendResponse(data.id,"BasicCommunication.SystemRequest", "SUCCESS", {})
    end)

    EXPECT_RESPONSE(CorIdSystemRequest, { success = true, resultCode = "SUCCESS"})        
    :Timeout(5000)
  end
end

function Test:CreatePTUOmmitedRequestTypePreData(...)
  userPrint(35, "================= Precondition ==================")
  -- body
  -- Create PTU from sdl_preloaded_pt.json
  local data = self:convertPreloadedToJson()

  data.policy_table.app_policies.default.RequestType = {"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"}
  -- data.policy_table.app_policies.default.RequestType = nil
  data.policy_table.app_policies.device.RequestType = {"PROPRIETARY"}
  data.policy_table.app_policies.pre_DataConsent.RequestType = nil

  local json = require("json")
  data = json.encode(data)
  -- print(data)
  -- for i=1, #data.policy_table.app_policies.default.groups do
  --  print(data.policy_table.app_policies.default.groups[i])
  -- end
  file = io.open("/tmp/ptu_update.json", "w")
  file:write(data)
  file:close()

end

function Test:TriggerPTU( ... )
  -- body
  userPrint(35, "================= Precondition ==================")

  odometerValue = odometerValue + exchange_after_x_kilometers + 1
  self.hmiConnection:SendNotification("VehicleInfo.OnVehicleData", { odometer = odometerValue})
end

function Test:PrecondPTUWithOmmitedRequestTypePreData()
  self:ptu()
end

function Test:PrecondMakeDeviceUntrustedOmmitedPreData3( ... )
  self:makeDeviceUntrusted()
end

for k, v in pairs( temp ) do
  Test["CheckRequestTypeRemainsDefault" .. v] = function(self)
    userPrint(34, "=================== Test Case ===================")

    local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest",
        {
          fileName = "PolicyTableUpdate",
          requestType = v
        },
      "files/jsons/QUERY_APP/correctJSON.json")

    local systemRequestId
    --hmi side: expect SystemRequest request
    EXPECT_HMICALL("BasicCommunication.SystemRequest")
    :Times(0)

    EXPECT_RESPONSE(CorIdSystemRequest, { success = false, resultCode = "DISALLOWED"})        
    :Timeout(5000)
  end
end

for k, v in pairs( {"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"} ) do
  Test["CheckRequestTypeRemainsDefault" .. v] = function(self)
    userPrint(34, "=================== Test Case ===================")

    local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest",
        {
          fileName = "PolicyTableUpdate",
          requestType = v
        },
      "files/jsons/QUERY_APP/correctJSON.json")

    local systemRequestId
    --hmi side: expect SystemRequest request
    EXPECT_HMICALL("BasicCommunication.SystemRequest")
    :ValidIf(function (self, data)
          -- body
          -- userPrint(20, data.params.requestType)
          -- userPrint(20, v)
          if data.params.requestType == v then
            return true
          else
            return false
          end
    end)
    :Do(function(_,data)
          --hmi side: sending SystemRequest response
        self.hmiConnection:SendResponse(data.id,"BasicCommunication.SystemRequest", "SUCCESS", {})
    end)

    EXPECT_RESPONSE(CorIdSystemRequest, { success = true, resultCode = "SUCCESS"})        
    :Timeout(5000)
  end
end

--End Test case TC.4

-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

--Begin Test case TC.5
      --Description: This test is intended to check case PTU comes with several values in "RequestType" array of "<default>" policies 
      --and at least one of the values is invalid 


      --Requirement id: APPLINK-14722

      -- Verification criteria: Policies Manager must: 
      -- ignore invalid values in "RequestType" array of "<default>" or "<pre_DataConsent>" policies 
      -- copy valid values of "RequestType" array of "<default>" or "<pre_DataConsent>" policies
 
function Test:CreatePTUValidRequestTypeDefault(...)
  userPrint(35, "================= Precondition ==================")
  -- body
  -- Create PTU from sdl_preloaded_pt.json
  local data = self:convertPreloadedToJson()

  data.policy_table.app_policies.default.RequestType = {"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"}
  -- data.policy_table.app_policies.default.RequestType = {}
  data.policy_table.app_policies.device.RequestType = {"PROPRIETARY"}
  data.policy_table.app_policies.pre_DataConsent.RequestType = {"PROPRIETARY"}

  local json = require("json")
  data = json.encode(data)
  -- print(data)
  -- for i=1, #data.policy_table.app_policies.default.groups do
  --  print(data.policy_table.app_policies.default.groups[i])
  -- end
  file = io.open("/tmp/ptu_update.json", "w")
  file:write(data)
  file:close()

end

function Test:TriggerPTU( ... )
  -- body
  userPrint(35, "================= Precondition ==================")

  odometerValue = odometerValue + exchange_after_x_kilometers + 1
  self.hmiConnection:SendNotification("VehicleInfo.OnVehicleData", { odometer = odometerValue})
end

function Test:PrecondPTUWithValidValuesRequestTypeDefault1()
  self:ptu()
end

function Test:CheckPolicyDB3()
  self:checkPolicyDb({"PROPRIETARY|default", "QUERY_APPS|default", "LAUNCH_APP|default"})
end

function Test:PrecondExitApp()
  self:unregisterApp()
end

function Test:CheckOnAppRegisteredHasEmptyRequestTypePreData( ... )
  self:checkOnAppRegistered({"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"})
end

function Test:WAregisterAppAgain9( ... )
  -- body
  userPrint(35, "================= WorkAround ==================")

  if language_change == true then
    self:checkOnAppRegistered({})
  end
end

function Test:WAregisterAppAgain10()
  -- body
  userPrint(35, "================= WorkAround ==================")

  language_change = false
end

for k, v in pairs( temp ) do
  Test["CheckRequestTypeRemainsDefault" .. v] = function(self)
    userPrint(34, "=================== Test Case ===================")

    local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest",
        {
          fileName = "PolicyTableUpdate",
          requestType = v
        },
      "files/jsons/QUERY_APP/correctJSON.json")

    local systemRequestId
    --hmi side: expect SystemRequest request
    EXPECT_HMICALL("BasicCommunication.SystemRequest")
    :Times(0)

    EXPECT_RESPONSE(CorIdSystemRequest, { success = false, resultCode = "DISALLOWED"})        
    :Timeout(5000)
  end
end

for k, v in pairs( {"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"} ) do
  Test["CheckRequestTypeRemainsDefault" .. v] = function(self)
    userPrint(34, "=================== Test Case ===================")

    local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest",
        {
          fileName = "PolicyTableUpdate",
          requestType = v
        },
      "files/jsons/QUERY_APP/correctJSON.json")

    local systemRequestId
    --hmi side: expect SystemRequest request
    EXPECT_HMICALL("BasicCommunication.SystemRequest")
    :ValidIf(function (self, data)
          -- body
          -- userPrint(20, data.params.requestType)
          -- userPrint(20, v)
          if data.params.requestType == v then
            return true
          else
            return false
          end
    end)
    :Do(function(_,data)
          --hmi side: sending SystemRequest response
        self.hmiConnection:SendResponse(data.id,"BasicCommunication.SystemRequest", "SUCCESS", {})
    end)

    EXPECT_RESPONSE(CorIdSystemRequest, { success = true, resultCode = "SUCCESS"})        
    :Timeout(5000)
  end
end

function Test:CreatePTURequestTypeWithInvalidValuesDefault(...)
  userPrint(35, "================= Precondition ==================")
  -- body
  -- Create PTU from sdl_preloaded_pt.json
  local data = self:convertPreloadedToJson()

  -- data.policy_table.app_policies.default.RequestType = {"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"}
  data.policy_table.app_policies.default.RequestType = {"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP", "IVSU", "IGOR"}
  data.policy_table.app_policies.device.RequestType = {"PROPRIETARY"}
  data.policy_table.app_policies.pre_DataConsent.RequestType = {"PROPRIETARY"}

  local json = require("json")
  data = json.encode(data)
  -- print(data)
  -- for i=1, #data.policy_table.app_policies.default.groups do
  --  print(data.policy_table.app_policies.default.groups[i])
  -- end
  file = io.open("/tmp/ptu_update.json", "w")
  file:write(data)
  file:close()

end

function Test:PrecondMakeDeviceUntrustedOmmited( ... )
  self:makeDeviceUntrusted()
end

function Test:TriggerPTU( ... )
  -- body
  userPrint(35, "================= Precondition ==================")

  odometerValue = odometerValue + exchange_after_x_kilometers + 1
  self.hmiConnection:SendNotification("VehicleInfo.OnVehicleData", { odometer = odometerValue})
end


function Test:PrecondPTURequestTypeWithInvalidValuesDefault()
  self:ptu()
end

for k, v in pairs( temp ) do
  Test["CheckRequestTypeRemainsDefault" .. v] = function(self)
    userPrint(34, "=================== Test Case ===================")

    local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest",
        {
          fileName = "PolicyTableUpdate",
          requestType = v
        },
      "files/jsons/QUERY_APP/correctJSON.json")

    local systemRequestId
    --hmi side: expect SystemRequest request
    EXPECT_HMICALL("BasicCommunication.SystemRequest")
    :Times(0)

    EXPECT_RESPONSE(CorIdSystemRequest, { success = false, resultCode = "DISALLOWED"})        
    :Timeout(5000)
  end
end

for k, v in pairs( {"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"} ) do
  Test["CheckRequestTypeRemainsDefault" .. v] = function(self)
    userPrint(34, "=================== Test Case ===================")
    local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest",
        {
          fileName = "PolicyTableUpdate",
          requestType = v
        },
      "files/jsons/QUERY_APP/correctJSON.json")

    local systemRequestId
    --hmi side: expect SystemRequest request
    EXPECT_HMICALL("BasicCommunication.SystemRequest")
    :ValidIf(function (self, data)
          -- body
          -- userPrint(20, data.params.requestType)
          -- userPrint(20, v)
          if data.params.requestType == v then
            return true
          else
            return false
          end
    end)
    :Do(function(_,data)
          --hmi side: sending SystemRequest response
        self.hmiConnection:SendResponse(data.id,"BasicCommunication.SystemRequest", "SUCCESS", {})
    end)

    EXPECT_RESPONSE(CorIdSystemRequest, { success = true, resultCode = "SUCCESS"})        
    :Timeout(5000)
  end
end

--End Test case TC.5

-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

--Begin Test case TC.6
      --Description: This test is intended to check case PTU comes with several values in "RequestType" array of "<pre_DataConsent>" policies 
      --and at least one of the values is invalid 


      --Requirement id: APPLINK-14722

      -- Verification criteria: Policies Manager must: 
      -- ignore invalid values in "RequestType" array of "<default>" or "<pre_DataConsent>" policies 
      -- copy valid values of "RequestType" array of "<default>" or "<pre_DataConsent>" policies

function Test:CreatePTUValidRequestTypeDefault(...)
  userPrint(35, "================= Precondition ==================")
  -- body
  -- Create PTU from sdl_preloaded_pt.json
  local data = self:convertPreloadedToJson()

  -- data.policy_table.app_policies.default.RequestType = {"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"}
  data.policy_table.app_policies.default.RequestType = {"PROPRIETARY"}
  data.policy_table.app_policies.device.RequestType = {"PROPRIETARY"}
  data.policy_table.app_policies.pre_DataConsent.RequestType = {"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"}

  local json = require("json")
  data = json.encode(data)
  -- print(data)
  -- for i=1, #data.policy_table.app_policies.default.groups do
  --  print(data.policy_table.app_policies.default.groups[i])
  -- end
  file = io.open("/tmp/ptu_update.json", "w")
  file:write(data)
  file:close()

end

function Test:PrecondMakeDeviceUntrustedPreDataSomeInvalid( ... )
  self:makeDeviceUntrusted()
end

function Test:TriggerPTU( ... )
  -- body
  userPrint(35, "================= Precondition ==================")

  odometerValue = odometerValue + exchange_after_x_kilometers + 1
  self.hmiConnection:SendNotification("VehicleInfo.OnVehicleData", { odometer = odometerValue})
end

function Test:PrecondPTURequestTypeHasValidVauesPreData()
  self:ptu()
end

function Test:CheckPolicyDB4()
  self:checkPolicyDb({"PROPRIETARY|pre_DataConsent", "QUERY_APPS|pre_DataConsent", "LAUNCH_APP|pre_DataConsent"})
end

function Test:PrecondExitAppPreData()
  self:unregisterApp()
end

function Test:PrecondMakeDeviceUntrustedPreDataSomeInvalid2( ... )
  self:makeDeviceUntrusted()
end

function Test:CheckOnAppRegisteredHasEmptyRequestTypePreData( ... )
  self:checkOnAppRegistered({"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"})
end

function Test:WAregisterAppAgain11( ... )
  -- body
  userPrint(35, "================= WorkAround ==================")

  if language_change == true then
    self:checkOnAppRegistered({})
  end
end

function Test:WAregisterAppAgain12()
  -- body
  userPrint(35, "================= WorkAround ==================")
  language_change = false
end

for k, v in pairs( temp ) do
  Test["CheckRequestTypeRemainsDefault" .. v] = function(self)
    userPrint(34, "=================== Test Case ===================")

    local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest",
        {
          fileName = "PolicyTableUpdate",
          requestType = v
        },
      "files/jsons/QUERY_APP/correctJSON.json")

    local systemRequestId
    --hmi side: expect SystemRequest request
    EXPECT_HMICALL("BasicCommunication.SystemRequest")
    :Times(0)

    EXPECT_RESPONSE(CorIdSystemRequest, { success = false, resultCode = "DISALLOWED"})        
    :Timeout(5000)
  end
end

for k, v in pairs( {"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"} ) do
  Test["CheckRequestTypeRemainsDefault" .. v] = function(self)
    userPrint(34, "=================== Test Case ===================")

    local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest",
        {
          fileName = "PolicyTableUpdate",
          requestType = v
        },
      "files/jsons/QUERY_APP/correctJSON.json")

    local systemRequestId
    --hmi side: expect SystemRequest request
    EXPECT_HMICALL("BasicCommunication.SystemRequest")
    :ValidIf(function (self, data)
          -- body
          -- userPrint(20, data.params.requestType)
          -- userPrint(20, v)
          if data.params.requestType == v then
            return true
          else
            return false
          end
    end)
    :Do(function(_,data)
          --hmi side: sending SystemRequest response
        self.hmiConnection:SendResponse(data.id,"BasicCommunication.SystemRequest", "SUCCESS", {})
    end)

    EXPECT_RESPONSE(CorIdSystemRequest, { success = true, resultCode = "SUCCESS"})        
    :Timeout(5000)
  end
end

function Test:CreatePTURequestTypeWithInvalidValuesPreData(...)
  userPrint(35, "================= Precondition ==================")
  -- body
  -- Create PTU from sdl_preloaded_pt.json
  local data = self:convertPreloadedToJson()

  -- data.policy_table.app_policies.default.RequestType = {"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"}
  data.policy_table.app_policies.default.RequestType = {"PROPRIETARY"}
  data.policy_table.app_policies.device.RequestType = {"PROPRIETARY"}
  data.policy_table.app_policies.pre_DataConsent.RequestType = {"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP", "IVSU", "IGOR"}

  local json = require("json")
  data = json.encode(data)
  -- print(data)
  -- for i=1, #data.policy_table.app_policies.default.groups do
  --  print(data.policy_table.app_policies.default.groups[i])
  -- end
  file = io.open("/tmp/ptu_update.json", "w")
  file:write(data)
  file:close()

end

function Test:PrecondMakeDeviceUntrustedOmmited( ... )
  self:makeDeviceUntrusted()
end

function Test:TriggerPTU( ... )
  -- body
  userPrint(35, "================= Precondition ==================")

  odometerValue = odometerValue + exchange_after_x_kilometers + 1
  self.hmiConnection:SendNotification("VehicleInfo.OnVehicleData", { odometer = odometerValue})
end

function Test:PrecondPTURequestTypeWithInvalidValuesPreData()
  self:ptu()
end

-- TODO: Add check of Policy DB

for k, v in pairs( temp ) do
  Test["CheckRequestTypeRemainsDefault" .. v] = function(self)
    userPrint(34, "=================== Test Case ===================")

    local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest",
        {
          fileName = "PolicyTableUpdate",
          requestType = v
        },
      "files/jsons/QUERY_APP/correctJSON.json")

    local systemRequestId
    --hmi side: expect SystemRequest request
    EXPECT_HMICALL("BasicCommunication.SystemRequest")
    :Times(0)

    EXPECT_RESPONSE(CorIdSystemRequest, { success = false, resultCode = "DISALLOWED"})        
    :Timeout(5000)
  end
end

for k, v in pairs( {"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"} ) do
  Test["CheckRequestTypeRemainsDefault" .. v] = function(self)
    userPrint(34, "=================== Test Case ===================")

    local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest",
        {
          fileName = "PolicyTableUpdate",
          requestType = v
        },
      "files/jsons/QUERY_APP/correctJSON.json")

    local systemRequestId
    --hmi side: expect SystemRequest request
    EXPECT_HMICALL("BasicCommunication.SystemRequest")
    :ValidIf(function (self, data)
          -- body
          -- userPrint(20, data.params.requestType)
          -- userPrint(20, v)
          if data.params.requestType == v then
            return true
          else
            return false
          end
    end)
    :Do(function(_,data)
          --hmi side: sending SystemRequest response
        self.hmiConnection:SendResponse(data.id,"BasicCommunication.SystemRequest", "SUCCESS", {})
    end)

    EXPECT_RESPONSE(CorIdSystemRequest, { success = true, resultCode = "SUCCESS"})        
    :Timeout(5000)
  end
end

--End Test case TC.6

-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

--Begin Test case TC.7
      --Description: This test is intended to check case PPTU comes with several values in "RequestType" array of "<default>" policies 
      -- and all these values are invalid 
 


      --Requirement id: APPLINK-14721

      -- Verification criteria: Policies Manager must: 
      -- ignore the invalid values in "RequestType" array of "<default>" or "<pre_DataConsent>" policies 
      -- copy and assign the values of "RequestType" array of "<default>" or "<pre_DataConsent>" policies from PolicyDataBase before updating without any changes

function Test:CreatePTUValidRequestTypeDefault(...)
  userPrint(35, "================= Precondition ==================")
  -- body
  -- Create PTU from sdl_preloaded_pt.json
  local data = self:convertPreloadedToJson()

  data.policy_table.app_policies.default.RequestType = {"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"}
  -- data.policy_table.app_policies.default.RequestType = {}
  data.policy_table.app_policies.device.RequestType = {"PROPRIETARY"}
  data.policy_table.app_policies.pre_DataConsent.RequestType = {"PROPRIETARY"}

  local json = require("json")
  data = json.encode(data)
  -- print(data)
  -- for i=1, #data.policy_table.app_policies.default.groups do
  --  print(data.policy_table.app_policies.default.groups[i])
  -- end
  file = io.open("/tmp/ptu_update.json", "w")
  file:write(data)
  file:close()

end

function Test:TriggerPTU( ... )
  -- body
  userPrint(35, "================= Precondition ==================")

  odometerValue = odometerValue + exchange_after_x_kilometers + 1
  self.hmiConnection:SendNotification("VehicleInfo.OnVehicleData", { odometer = odometerValue})
end

function Test:PrecondPTUWithValidValuesRequestTypeDefault1()
  self:ptu()
end

function Test:CheckPolicyDB5()
  self:checkPolicyDb({"PROPRIETARY|default", "QUERY_APPS|default", "LAUNCH_APP|default"})
end

function Test:PrecondExitApp()
  self:unregisterApp()
end

function Test:CheckOnAppRegisteredHasEmptyRequestTypePreData( ... )
  self:checkOnAppRegistered({"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"})
end

function Test:WAregisterAppAgain13( ... )
  -- body
  userPrint(35, "================= WorkAround ==================")

  if language_change == true then
    self:checkOnAppRegistered({})
  end
end

function Test:WAregisterAppAgain14()
  -- body
  userPrint(35, "================= WorkAround ==================")

  language_change = false
end

for k, v in pairs( temp ) do
  Test["CheckRequestTypeRemainsDefault" .. v] = function(self)
    userPrint(34, "=================== Test Case ===================")

    local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest",
        {
          fileName = "PolicyTableUpdate",
          requestType = v
        },
      "files/jsons/QUERY_APP/correctJSON.json")

    local systemRequestId
    --hmi side: expect SystemRequest request
    EXPECT_HMICALL("BasicCommunication.SystemRequest")
    :Times(0)

    EXPECT_RESPONSE(CorIdSystemRequest, { success = false, resultCode = "DISALLOWED"})        
    :Timeout(5000)
  end
end

for k, v in pairs( {"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"} ) do
  Test["CheckRequestTypeRemainsDefault" .. v] = function(self)
    userPrint(34, "=================== Test Case ===================")

    local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest",
        {
          fileName = "PolicyTableUpdate",
          requestType = v
        },
      "files/jsons/QUERY_APP/correctJSON.json")

    local systemRequestId
    --hmi side: expect SystemRequest request
    EXPECT_HMICALL("BasicCommunication.SystemRequest")
    :ValidIf(function (self, data)
          -- body
          -- -- userPrint(20, data.params.requestType)
          -- userPrint(20, v)
          if data.params.requestType == v then
            return true
          else
            return false
          end
    end)
    :Do(function(_,data)
          --hmi side: sending SystemRequest response
        self.hmiConnection:SendResponse(data.id,"BasicCommunication.SystemRequest", "SUCCESS", {})
    end)

    EXPECT_RESPONSE(CorIdSystemRequest, { success = true, resultCode = "SUCCESS"})        
    :Timeout(5000)
  end
end

function Test:CreatePTURequestTypeWithInvalidValuesDefault(...)
  userPrint(35, "================= Precondition ==================")
  -- body
  -- Create PTU from sdl_preloaded_pt.json
  local data = self:convertPreloadedToJson()

  -- data.policy_table.app_policies.default.RequestType = {"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"}
  data.policy_table.app_policies.default.RequestType = {"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP", "IVSU", "IGOR"}
  data.policy_table.app_policies.device.RequestType = {"PROPRIETARY"}
  data.policy_table.app_policies.pre_DataConsent.RequestType = {"PROPRIETARY"}

  local json = require("json")
  data = json.encode(data)
  -- print(data)
  -- for i=1, #data.policy_table.app_policies.default.groups do
  --  print(data.policy_table.app_policies.default.groups[i])
  -- end
  file = io.open("/tmp/ptu_update.json", "w")
  file:write(data)
  file:close()

end

function Test:PrecondMakeDeviceUntrustedOmmited( ... )
  self:makeDeviceUntrusted()
end

function Test:TriggerPTU( ... )
  -- body
  userPrint(35, "================= Precondition ==================")

  odometerValue = odometerValue + exchange_after_x_kilometers + 1
  self.hmiConnection:SendNotification("VehicleInfo.OnVehicleData", { odometer = odometerValue})
end


function Test:PrecondPTURequestTypeWithInvalidValuesDefault()
  self:ptu()
end

for k, v in pairs( temp ) do
  Test["CheckRequestTypeRemainsDefault" .. v] = function(self)
    userPrint(34, "=================== Test Case ===================")

    local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest",
        {
          fileName = "PolicyTableUpdate",
          requestType = v
        },
      "files/jsons/QUERY_APP/correctJSON.json")

    local systemRequestId
    --hmi side: expect SystemRequest request
    EXPECT_HMICALL("BasicCommunication.SystemRequest")
    :Times(0)

    EXPECT_RESPONSE(CorIdSystemRequest, { success = false, resultCode = "DISALLOWED"})        
    :Timeout(5000)
  end
end

for k, v in pairs( {"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"} ) do
  Test["CheckRequestTypeRemainsDefault" .. v] = function(self)
    userPrint(34, "=================== Test Case ===================")

    local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest",
        {
          fileName = "PolicyTableUpdate",
          requestType = v
        },
      "files/jsons/QUERY_APP/correctJSON.json")

    local systemRequestId
    --hmi side: expect SystemRequest request
    EXPECT_HMICALL("BasicCommunication.SystemRequest")
    :ValidIf(function (self, data)
          -- body
          -- userPrint(20, data.params.requestType)
          -- userPrint(20, v)
          if data.params.requestType == v then
            return true
          else
            return false
          end
    end)
    :Do(function(_,data)
          --hmi side: sending SystemRequest response
        self.hmiConnection:SendResponse(data.id,"BasicCommunication.SystemRequest", "SUCCESS", {})
    end)

    EXPECT_RESPONSE(CorIdSystemRequest, { success = true, resultCode = "SUCCESS"})        
    :Timeout(5000)
  end
end

--End Test case TC.7

-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

--Begin Test case TC.8
      --Description: This test is intended to check case PPTU comes with several values in "RequestType" array of "<pre_DataConsent>" policies 
      -- and all these values are invalid 
 


      --Requirement id: APPLINK-14721

      -- Verification criteria: Policies Manager must: 
      -- ignore the invalid values in "RequestType" array of "<default>" or "<pre_DataConsent>" policies 
      -- copy and assign the values of "RequestType" array of "<default>" or "<pre_DataConsent>" policies from PolicyDataBase before updating without any changes

function Test:CreatePTUValidRequestTypeDefault(...)
  userPrint(35, "================= Precondition ==================")
  -- body
  -- Create PTU from sdl_preloaded_pt.json
  local data = self:convertPreloadedToJson()

  data.policy_table.app_policies.default.RequestType = {"PROPRIETARY"}
  -- data.policy_table.app_policies.default.RequestType = {}
  data.policy_table.app_policies.device.RequestType = {"PROPRIETARY"}
  data.policy_table.app_policies.pre_DataConsent.RequestType = {"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"}

  local json = require("json")
  data = json.encode(data)
  -- print(data)
  -- for i=1, #data.policy_table.app_policies.default.groups do
  --  print(data.policy_table.app_policies.default.groups[i])
  -- end
  file = io.open("/tmp/ptu_update.json", "w")
  file:write(data)
  file:close()

end

function Test:PrecondMakeDeviceUntrustedSeveralValues( ... )
  self:makeDeviceUntrusted()
end

function Test:TriggerPTU( ... )
  -- body
  userPrint(35, "================= Precondition ==================")

  odometerValue = odometerValue + exchange_after_x_kilometers + 1
  self.hmiConnection:SendNotification("VehicleInfo.OnVehicleData", { odometer = odometerValue})
end

function Test:PrecondPTUWithValidValuesRequestTypeDefault1()
  self:ptu()
end

function Test:CheckPolicyDB5()
  self:checkPolicyDb({"PROPRIETARY|pre_DataConsent", "QUERY_APPS|pre_DataConsent", "LAUNCH_APP|pre_DataConsent"})
end

function Test:PrecondExitApp()
  self:unregisterApp()
end

function Test:PrecondMakeDeviceUntrustedSeveralValues( ... )
  self:makeDeviceUntrusted()
end

function Test:CheckOnAppRegisteredHasEmptyRequestTypePreData( ... )
  self:checkOnAppRegistered({"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"})
end

function Test:WAregisterAppAgain13( ... )
  -- body
  userPrint(35, "================= WorkAround ==================")

  if language_change == true then
    self:checkOnAppRegistered({})
  end
end

function Test:WAregisterAppAgain14()
  -- body
  userPrint(35, "================= WorkAround ==================")
  language_change = false
end

for k, v in pairs( temp ) do
  Test["CheckRequestTypeRemainsDefault" .. v] = function(self)
    userPrint(34, "=================== Test Case ===================")

    local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest",
        {
          fileName = "PolicyTableUpdate",
          requestType = v
        },
      "files/jsons/QUERY_APP/correctJSON.json")

    local systemRequestId
    --hmi side: expect SystemRequest request
    EXPECT_HMICALL("BasicCommunication.SystemRequest")
    :Times(0)

    EXPECT_RESPONSE(CorIdSystemRequest, { success = false, resultCode = "DISALLOWED"})        
    :Timeout(5000)
  end
end

for k, v in pairs( {"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"} ) do
  Test["CheckRequestTypeRemainsDefault" .. v] = function(self)
    userPrint(34, "=================== Test Case ===================")
    local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest",
        {
          fileName = "PolicyTableUpdate",
          requestType = v
        },
      "files/jsons/QUERY_APP/correctJSON.json")

    local systemRequestId
    --hmi side: expect SystemRequest request
    EXPECT_HMICALL("BasicCommunication.SystemRequest")
    :ValidIf(function (self, data)
          -- body
          -- -- userPrint(20, data.params.requestType)
          -- userPrint(20, v)
          if data.params.requestType == v then
            return true
          else
            return false
          end
    end)
    :Do(function(_,data)
          --hmi side: sending SystemRequest response
        self.hmiConnection:SendResponse(data.id,"BasicCommunication.SystemRequest", "SUCCESS", {})
    end)

    EXPECT_RESPONSE(CorIdSystemRequest, { success = true, resultCode = "SUCCESS"})        
    :Timeout(5000)
  end
end

function Test:CreatePTURequestTypeWithInvalidValuesDefault(...)
  userPrint(35, "================= Precondition ==================")
  -- body
  -- Create PTU from sdl_preloaded_pt.json
  local data = self:convertPreloadedToJson()

  -- data.policy_table.app_policies.default.RequestType = {"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"}
  data.policy_table.app_policies.default.RequestType = {"PROPRIETARY"}
  data.policy_table.app_policies.device.RequestType = {"PROPRIETARY"}
  data.policy_table.app_policies.pre_DataConsent.RequestType = {"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP", "IVSU", "IGOR"}

  local json = require("json")
  data = json.encode(data)
  -- print(data)
  -- for i=1, #data.policy_table.app_policies.default.groups do
  --  print(data.policy_table.app_policies.default.groups[i])
  -- end
  file = io.open("/tmp/ptu_update.json", "w")
  file:write(data)
  file:close()

end

function Test:TriggerPTU( ... )
  -- body
  userPrint(35, "================= Precondition ==================")

  odometerValue = odometerValue + exchange_after_x_kilometers + 1
  self.hmiConnection:SendNotification("VehicleInfo.OnVehicleData", { odometer = odometerValue})
end


function Test:PrecondPTURequestTypeWithInvalidValuesDefault()
  self:ptu()
end

for k, v in pairs( temp ) do
  Test["CheckRequestTypeRemainsDefault" .. v] = function(self)
    userPrint(34, "=================== Test Case ===================")

    local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest",
        {
          fileName = "PolicyTableUpdate",
          requestType = v
        },
      "files/jsons/QUERY_APP/correctJSON.json")

    local systemRequestId
    --hmi side: expect SystemRequest request
    EXPECT_HMICALL("BasicCommunication.SystemRequest")
    :Times(0)

    EXPECT_RESPONSE(CorIdSystemRequest, { success = false, resultCode = "DISALLOWED"})        
    :Timeout(5000)
  end
end

for k, v in pairs( {"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"} ) do
  Test["CheckRequestTypeRemainsDefault" .. v] = function(self)
    userPrint(34, "=================== Test Case ===================")
    
    local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest",
        {
          fileName = "PolicyTableUpdate",
          requestType = v
        },
      "files/jsons/QUERY_APP/correctJSON.json")

    local systemRequestId
    --hmi side: expect SystemRequest request
    EXPECT_HMICALL("BasicCommunication.SystemRequest")
    :ValidIf(function (self, data)
          -- body
          -- userPrint(20, data.params.requestType)
          -- userPrint(20, v)
          if data.params.requestType == v then
            return true
          else
            return false
          end
    end)
    :Do(function(_,data)
          --hmi side: sending SystemRequest response
        self.hmiConnection:SendResponse(data.id,"BasicCommunication.SystemRequest", "SUCCESS", {})
    end)

    EXPECT_RESPONSE(CorIdSystemRequest, { success = true, resultCode = "SUCCESS"})        
    :Timeout(5000)
  end
end

--End Test case TC.8