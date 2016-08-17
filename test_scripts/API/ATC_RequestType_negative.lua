-- --------------------------------------------------------------------------------
-- -- Preconditions
-- --------------------------------------------------------------------------------
-- local commonPreconditions = require('user_modules/shared_testcases/commonPreconditions')
-- --------------------------------------------------------------------------------
-- --Precondition: preparation connecttest_RAI.lua
-- commonPreconditions:Connecttest_without_ExitBySDLDisconnect("connecttest_malformed.lua")
local commonPreconditions = require('user_modules/shared_testcases/commonPreconditions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')

--------------------------------------------------------------------------------
--Precondition: preparation connecttest_OnAppUnregistered.lua
commonPreconditions:Connecttest_without_ExitBySDLDisconnect("connecttest_RequestType.lua")
commonSteps:DeleteLogsFileAndPolicyTable()

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

function Test:convertPreloadedToJson()
  -- body
  -- Create PTU from sdl_preloaded_pt.json
  pathToFile = config.pathToSDL .. "sdl_preloaded_pt.json"
  local file  = io.open(pathToFile, "r")
  local json_data = file:read("*all") -- may be abbreviated to "*a";
  file:close()

  local json = require("json")
   
  local data = json.decode(json_data)

  local function has_value (tab, val)
    for index, value in ipairs (tab) do
        if value == val then
            return true
        end
    end

    return false
  end

  for k,v in pairs(data.policy_table.functional_groupings) do
    if  has_value(data.policy_table.app_policies.default.groups, k) or 
        has_value(data.policy_table.app_policies.pre_DataConsent.groups, k) then 
    else 
      data.policy_table.functional_groupings[k] = nil 
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
    appName = "App1",
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
  EXPECT_NOTIFICATION("OnPermissionsChange")
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

  EXPECT_NOTIFICATION("OnAppInterfaceUnregistered")
  :Times(0)
  :ValidIf(function(exp, data)
    if 
      exp.occurences == 1 then
        self:FailTestCase("UnexpectedDisconnect")
    end
  end)
end

function Test:CheckOnAppRegisteredHasEmptyRequestType( ... )
  self:checkOnAppRegistered({})
end

function Test:checkRequestTypeInSystemRequest(request_type)
  userPrint(34, "=================== Test Case ===================")
    local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest",
        {
          fileName = "PolicyTableUpdate",
          requestType = request_type
        },
      "files/jsons/QUERY_APP/query_app_response.json")

    local systemRequestId
    --hmi side: expect SystemRequest request
    if request_type ~= "QUERY_APPS" and request_type ~= "LAUNCH_APP" then
      EXPECT_HMICALL("BasicCommunication.SystemRequest")
      :ValidIf(function (self, data)
            -- body
            if data.params.requestType == request_type then
              return true
            else
              return false
            end
      end)
      :Do(function(_,data)
            --hmi side: sending SystemRequest response
          self.hmiConnection:SendResponse(data.id,"BasicCommunication.SystemRequest", "SUCCESS", {})
      end)
    end
    if request_type ~= "QUERY_APPS" and request_type ~= "LAUNCH_APP" then
      EXPECT_RESPONSE(CorIdSystemRequest, { success = true, resultCode = "SUCCESS"})        
      :Timeout(5000)
    else
      if request_type == "LAUNCH_APP" then
        userPrint(40, "open question \"What response should be for requstType LAUNCH_APP if SDL4.0 is ommited in implementation\",\nassumption is DISALLOWED result code")
        EXPECT_RESPONSE(CorIdSystemRequest, { success = false, resultCode = "DISALLOWED"})        
        :Timeout(5000)
      else
        -- according to CRQ "SDL behaviour in case SDL 4.0 feature is required to be ommited in implementation"
        EXPECT_RESPONSE(CorIdSystemRequest, { success = false, resultCode = "UNSUPPORTED_RESOURCE"})        
        :Timeout(5000)
      end
    end
end


local requestTypeEnum = {"HTTP", "FILE_RESUME", "AUTH_REQUEST", "AUTH_CHALLENGE", 
  "AUTH_ACK", "PROPRIETARY", "QUERY_APPS", "LAUNCH_APP", "LOCK_SCREEN_ICON_URL", 
  "TRAFFIC_MESSAGE_CHANNEL", "DRIVER_PROFILE", "VOICE_SEARCH", "NAVIGATION", 
  "PHONE", "CLIMATE", "SETTINGS", "VEHICLE_DIAGNOSTICS", "EMERGENCY", "MEDIA", "FOTA"}

for k, v in pairs( requestTypeEnum ) do
  Test["CheckRequestTypeTC1_" .. v] = function(self)
    self:checkRequestTypeInSystemRequest(v)
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
  self:ptu()
  EXPECT_NOTIFICATION("OnPermissionsChange")
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


for k, v in pairs( requestTypeEnum ) do
  Test["CheckRequestTypeTC2_" .. v] = function(self)
    self:checkRequestTypeInSystemRequest(v)
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

  file = io.open("/tmp/ptu_update.json", "w")
  file:write(data)
  file:close()

end

function Test:TriggerPTUForOmmitedRequestType( ... )
  -- body
  userPrint(35, "================= Precondition ==================")

  odometerValue = odometerValue + exchange_after_x_kilometers + 1
  self.hmiConnection:SendNotification("VehicleInfo.OnVehicleData", { odometer = odometerValue})
  self:ptu()
  EXPECT_NOTIFICATION("OnPermissionsChange")
end


function Test:PrecondExitAppPreData()
  self:unregisterApp()
end

function Test:CheckOnAppRegisteredHasDeafultRequestTypeTC3()
  self:checkOnAppRegistered({"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"})
end

local temp = {}

for k,v in pairs(requestTypeEnum) do
  if v ~= "PROPRIETARY" and v ~= "QUERY_APPS" and v ~= "LAUNCH_APP" then
      --do
      temp[k] = requestTypeEnum[k]
  end
end

function Test:checkRequestTypeInSystemRequestIsDisallowed(request_type)
  userPrint(34, "=================== Test Case ===================")
  local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest",
      {
        fileName = "PolicyTableUpdate",
        requestType = request_type
      },
    "files/jsons/QUERY_APP/query_app_response.json")

  local systemRequestId
  --hmi side: expect SystemRequest request
  EXPECT_HMICALL("BasicCommunication.SystemRequest")
  :Times(0)

  EXPECT_RESPONSE(CorIdSystemRequest, { success = false, resultCode = "DISALLOWED"})        
  :Timeout(5000)
end

for k, v in pairs( temp ) do
  Test["CheckRequestTypeTC3_1_" .. v] = function(self)
    self:checkRequestTypeInSystemRequestIsDisallowed(v)
  end
end

for k, v in pairs( {"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"} ) do
  Test["CheckRequestTypeTC3_2_" .. v] = function(self)
    self:checkRequestTypeInSystemRequest(v)
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
  self:ptu()
  EXPECT_NOTIFICATION("OnPermissionsChange")
end

function Test:PrecondExitAppPreData()
  self:unregisterApp()
end

function Test:CheckOnAppRegisteredHasDeafultRequestTypeTC3_1()
  self:checkOnAppRegistered({"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"})
end

for k, v in pairs( temp ) do
  Test["CheckRequestTypeTC3_3_" .. v] = function(self)
    self:checkRequestTypeInSystemRequestIsDisallowed(v)
  end
end

for k, v in pairs( {"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"} ) do
  Test["CheckRequestTypeTC3_4_" .. v] = function(self)
    self:checkRequestTypeInSystemRequest(v)
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
      -- assign "RequestType" field from "<pre_DataConsent>" section of PolicyDataBase to such app 

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
  self:ptu()
  EXPECT_NOTIFICATION("OnPermissionsChange")
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

for k, v in pairs( temp ) do
  Test["CheckRequestTypeTC4_1_" .. v] = function(self)
    self:checkRequestTypeInSystemRequestIsDisallowed(v)
  end
end

for k, v in pairs( {"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"} ) do
  Test["CheckRequestTypeTC4_2_" .. v] = function(self)
    self:checkRequestTypeInSystemRequest(v)
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

  file = io.open("/tmp/ptu_update.json", "w")
  file:write(data)
  file:close()

end

function Test:TriggerPTU( ... )
  -- body
  userPrint(35, "================= Precondition ==================")

  odometerValue = odometerValue + exchange_after_x_kilometers + 1
  self.hmiConnection:SendNotification("VehicleInfo.OnVehicleData", { odometer = odometerValue})
  self:ptu()
  EXPECT_NOTIFICATION("OnPermissionsChange")
end

function Test:PrecondMakeDeviceUntrustedOmmitedPreData22()
  self:makeDeviceUntrusted()
end

function Test:PrecondExitAppPreData()
  self:unregisterApp()
end

function Test:CheckOnAppRegisteredHasDeafultRequestTypeTC4()
  self:checkOnAppRegistered({"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"})
end

for k, v in pairs( temp ) do
  Test["CheckRequestTypeTC4_3_" .. v] = function(self)
    self:checkRequestTypeInSystemRequestIsDisallowed(v)
  end
end

for k, v in pairs( {"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"} ) do
  Test["CheckRequestTypeTC4_4_" .. v] = function(self)
    self:checkRequestTypeInSystemRequest(v)
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
      -- ignore invalid values in "RequestType" array of "<default>" policies 
      -- copy valid values of "RequestType" array of "<default>" policies
 
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

  file = io.open("/tmp/ptu_update.json", "w")
  file:write(data)
  file:close()

end

function Test:TriggerPTU( ... )
  -- body
  userPrint(35, "================= Precondition ==================")

  odometerValue = odometerValue + exchange_after_x_kilometers + 1
  self.hmiConnection:SendNotification("VehicleInfo.OnVehicleData", { odometer = odometerValue})
  self:ptu()
  EXPECT_NOTIFICATION("OnPermissionsChange")
end

function Test:PrecondExitApp()
  self:unregisterApp()
end

function Test:CheckOnAppRegisteredHasEmptyRequestTypePreData( ... )
  self:checkOnAppRegistered({"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"})
end

for k, v in pairs( temp ) do
  Test["CheckRequestTypeTC5_1_" .. v] = function(self)
    self:checkRequestTypeInSystemRequestIsDisallowed(v)
  end
end

for k, v in pairs( {"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"} ) do
  Test["CheckRequestTypeTC5_2_" .. v] = function(self)
    self:checkRequestTypeInSystemRequest(v)
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
  self:ptu()
  EXPECT_NOTIFICATION("OnPermissionsChange")
end

function Test:PrecondExitAppPreData()
  self:unregisterApp()
end

function Test:CheckOnAppRegisteredHasDeafultRequestTypeTC5()
  self:checkOnAppRegistered({"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"})
end

for k, v in pairs( temp ) do
  Test["CheckRequestTypeTC5_3_" .. v] = function(self)
    self:checkRequestTypeInSystemRequestIsDisallowed(v)
  end
end

for k, v in pairs( {"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"} ) do
  Test["CheckRequestTypeTC5_4_" .. v] = function(self)
    self:checkRequestTypeInSystemRequest(v)
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
      -- ignore invalid values in "RequestType" array of "<pre_DataConsent>" policies 
      -- copy valid values of "RequestType" array of "<pre_DataConsent>" policies

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
  self:ptu()
  EXPECT_NOTIFICATION("OnPermissionsChange")
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

for k, v in pairs( temp ) do
  Test["CheckRequestTypeTC6_1_" .. v] = function(self)
    self:checkRequestTypeInSystemRequestIsDisallowed(v)
  end
end

for k, v in pairs( {"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"} ) do
  Test["CheckRequestTypeTC6_2_" .. v] = function(self)
    self:checkRequestTypeInSystemRequest(v)
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
  self:ptu()
  EXPECT_NOTIFICATION("OnPermissionsChange")
end

function Test:PrecondMakeDeviceUntrustedOmmitedPreData22()
  self:makeDeviceUntrusted()
end

function Test:PrecondExitAppPreData()
  self:unregisterApp()
end

function Test:CheckOnAppRegisteredHasDeafultRequestTypeTC6()
  self:checkOnAppRegistered({"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"})
end

for k, v in pairs( temp ) do
  Test["CheckRequestTypeTC6_3_" .. v] = function(self)
    self:checkRequestTypeInSystemRequestIsDisallowed(v)
  end
end

for k, v in pairs( {"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"} ) do
  Test["CheckRequestTypeTC6_4_" .. v] = function(self)
    self:checkRequestTypeInSystemRequest(v)
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
      -- ignore the invalid values in "RequestType" array of "<default>" policies 
      -- copy and assign the values of "RequestType" array of "<default>" policies from PolicyDataBase before updating without any changes

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
  
  file = io.open("/tmp/ptu_update.json", "w")
  file:write(data)
  file:close()

end

function Test:TriggerPTU( ... )
  -- body
  userPrint(35, "================= Precondition ==================")

  odometerValue = odometerValue + exchange_after_x_kilometers + 1
  self.hmiConnection:SendNotification("VehicleInfo.OnVehicleData", { odometer = odometerValue})
  self:ptu()
  EXPECT_NOTIFICATION("OnPermissionsChange")
end


function Test:PrecondExitApp()
  self:unregisterApp()
end

function Test:CheckOnAppRegisteredHasEmptyRequestTypePreData( ... )
  self:checkOnAppRegistered({"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"})
end

for k, v in pairs( temp ) do
  Test["CheckRequestTypeTC7_1_" .. v] = function(self)
    self:checkRequestTypeInSystemRequestIsDisallowed(v)
  end
end

for k, v in pairs( {"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"} ) do
  Test["CheckRequestTypeTC7_2_" .. v] = function(self)
    self:checkRequestTypeInSystemRequest(v)
  end
end

function Test:CreatePTURequestTypeWithInvalidValuesDefault(...)
  userPrint(35, "================= Precondition ==================")
  -- body
  -- Create PTU from sdl_preloaded_pt.json
  local data = self:convertPreloadedToJson()

  -- data.policy_table.app_policies.default.RequestType = {"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"}
  data.policy_table.app_policies.default.RequestType = {"IVSU", "IGOR"}
  data.policy_table.app_policies.device.RequestType = {"PROPRIETARY"}
  data.policy_table.app_policies.pre_DataConsent.RequestType = {"PROPRIETARY"}

  local json = require("json")
  data = json.encode(data)
  
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
  self:ptu()
  EXPECT_NOTIFICATION("OnPermissionsChange")
end

function Test:PrecondExitAppPreData()
  self:unregisterApp()
end

function Test:CheckOnAppRegisteredHasDeafultRequestTypeTC7()
  self:checkOnAppRegistered({"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"})
end

for k, v in pairs( temp ) do
  Test["CheckRequestTypeTC7_3_" .. v] = function(self)
    self:checkRequestTypeInSystemRequestIsDisallowed(v)
  end
end

for k, v in pairs( {"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"} ) do
  Test["CheckRequestTypeTC7_4_" .. v] = function(self)
    self:checkRequestTypeInSystemRequest(v)
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
      -- ignore the invalid values in "RequestType" array of "<pre_DataConsent>" policies 
      -- copy and assign the values of "RequestType" array of "<pre_DataConsent>" policies from PolicyDataBase before updating without any changes

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
  self:ptu()
  EXPECT_NOTIFICATION("OnPermissionsChange")
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

for k, v in pairs( temp ) do
  Test["CheckRequestTypeTC7_1_" .. v] = function(self)
    self:checkRequestTypeInSystemRequestIsDisallowed(v)
  end
end

for k, v in pairs( {"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"} ) do
  Test["CheckRequestTypeTC7_2_" .. v] = function(self)
    self:checkRequestTypeInSystemRequest(v)
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
  data.policy_table.app_policies.pre_DataConsent.RequestType = {"IVSU", "IGOR"}

  local json = require("json")
  data = json.encode(data)
  file = io.open("/tmp/ptu_update.json", "w")
  file:write(data)
  file:close()

end

function Test:TriggerPTU( ... )
  -- body
  userPrint(35, "================= Precondition ==================")

  odometerValue = odometerValue + exchange_after_x_kilometers + 1
  self.hmiConnection:SendNotification("VehicleInfo.OnVehicleData", { odometer = odometerValue})
  self:ptu()
  EXPECT_NOTIFICATION("OnPermissionsChange")
end

function Test:PrecondMakeDeviceUntrustedOmmited( ... )
  self:makeDeviceUntrusted()
end

function Test:PrecondExitAppPreData()
  self:unregisterApp()
end

function Test:CheckOnAppRegisteredHasDeafultRequestType()
  self:checkOnAppRegistered({"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"})
end

for k, v in pairs( temp ) do
  Test["CheckRequestTypeTC7_3_" .. v] = function(self)
    self:checkRequestTypeInSystemRequestIsDisallowed(v)
  end
end

for k, v in pairs( {"PROPRIETARY", "QUERY_APPS", "LAUNCH_APP"} ) do
  Test["CheckRequestTypeTC7_4_" .. v] = function(self)
    self:checkRequestTypeInSystemRequest(v)
  end
end

--End Test case TC.8
