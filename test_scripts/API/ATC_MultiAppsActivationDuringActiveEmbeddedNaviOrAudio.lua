Test = require('connecttest')
require('cardinalities')
local events = require('events')
local mobile_session = require('mobile_session')
-- local mobile  = require('mobile_connection')
-- local tcp = require('tcp_connection')
-- local file_connection  = require('file_connection')

local commonSteps = require('user_modules/shared_testcases/commonSteps')
commonSteps:DeletePolicyTable()

config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

-- Used Apps
function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

local media_app_1 = {}
media_app_1 = deepcopy(config.application1.registerAppInterfaceParams)
media_app_1.isMediaApplication = true
media_app_1.appHMIType = nil
media_app_1.appName = "media_app_1"
media_app_1.appID = "media_app_1"

local navigation_app_1 = {}
navigation_app_1 = deepcopy(config.application1.registerAppInterfaceParams)
navigation_app_1.isMediaApplication = false
navigation_app_1.appHMIType = {"NAVIGATION"}
navigation_app_1.appName = "navigation_app_1"
navigation_app_1.appID = "navigation_app_1"

local non_media_app_1 = {}
non_media_app_1 = deepcopy(config.application1.registerAppInterfaceParams)
non_media_app_1.isMediaApplication = false
non_media_app_1.appHMIType = nil
non_media_app_1.appName = "non_media_app_1"
non_media_app_1.appID = "non_media_app_1"

local hmi_ids_of_applications = {}

-- common functions
local function userPrint( color, message)
  print ("\27[" .. tostring(color) .. "m " .. tostring(message) .. " \27[0m")
end

-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

--Begin Test case TC.1
      --Description: This test is intended to check SDL behavior during active embedded navigation 

      --Requirement id: Multiple media, navigation and non-media apps activation during 
      --  				active embedded audio source+audio mixing supported

function Test:UnregisterApp( ... )
  userPrint(35, "================= Precondition ==================")
  --mobile side: UnregisterAppInterface request 
  local CorIdUAI = self.mobileSession:SendRPC("UnregisterAppInterface",{}) 

  --hmi side: expect OnAppUnregistered notification 
  EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered")
 

  --mobile side: UnregisterAppInterface response 
  EXPECT_RESPONSE(CorIdUAI, { success = true, resultCode = "SUCCESS"})
  :Timeout(200)
end

function Test:registerApp(session, params)
  -- body
  -- userPrint(34, "=================== Test Case ===================")

  local registerAppInterfaceID = session:SendRPC("RegisterAppInterface", params)

  -- hmi side: SDL notifies HMI about registered App
  EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", 
  	{application = {appName = params.appName}})
  :Do(function(_,data)
  	-- body
  	-- remember HMI appID of registered App
  	hmi_ids_of_applications[params.appName] = data.params.application.appID
  end)

  session:ExpectResponse(registerAppInterfaceID, { success = true, resultCode = "SUCCESS"})
  :Timeout(2000)

  -- todo: make precondition to have NONE as default level
  session:ExpectNotification("OnHMIStatus", {hmiLevel = "NONE"})
  :Times(1)
  session:ExpectNotification("OnPermissionsChange")
  :Times(1)
end

-- function Test:connectMobileStartSession()
-- 	local tcpConnection = tcp.Connection(config.mobileHost, config.mobilePort)
-- 	local fileConnection = file_connection.FileConnection("mobile.out", tcpConnection)
-- 	self.mobileConnection = mobile.MobileConnection(fileConnection)
-- 	self.mobileSession= mobile_session.MobileSession(
-- 	self,
-- 	self.mobileConnection)
-- 	event_dispatcher:AddConnection(self.mobileConnection)
-- 	self.mobileSession:ExpectEvent(events.connectedEvent, "Connection started")
-- 	self.mobileConnection:Connect()
-- 	self.mobileSession:StartService(7)	
-- end

-- function Test:PrecondConnectPhoneTC1( ... )
-- 	-- body
-- 	self:connectMobileStartSession()
-- end

-- register all Apps
function Test:PrecondRegisterMediaApp1TC1( ... )
	-- body
	self:registerApp(self.mobileSession, media_app_1)
end

function Test:PrecondNaviAppOpenSessionTC1()
	-- Connected expectation
	self.mobileSession2 = mobile_session.MobileSession(
		self,
		self.mobileConnection)
	self.mobileSession2:StartService(7)
end

function Test:PrecondRegisterNaviApp1TC1( ... )
	-- body
	self:registerApp(self.mobileSession2, navigation_app_1)
end

function Test:PrecondNonMediaAppOpenSessionTC1()
	-- Connected expectation
	self.mobileSession3 = mobile_session.MobileSession(
		self,
		self.mobileConnection)
	self.mobileSession3:StartService(7)
end

function Test:PrecondRegisterNonMediaApp1TC1( ... )
	-- body
	self:registerApp(self.mobileSession3, non_media_app_1)
end

function Test:activateApp(self, hmi_app_id)

  -- if 
  --   notificationState.VRSession == true then
  --     self.hmiConnection:SendNotification("VR.Stopped", {})
  -- elseif 
  --   notificationState.EmergencyEvent == true then
  --     self.hmiConnection:SendNotification("BasicCommunication.OnEmergencyEvent", {enabled = false})
  -- elseif
  --   notificationState.PhoneCall == true then
  --     self.hmiConnection:SendNotification("BasicCommunication.OnPhoneCall", {isActive = false})
  -- end

    -- hmi side: sending SDL.ActivateApp request
      local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = hmi_app_id})

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
                -- according APPLINK-9283 we send "device" parameter, so expect "BasicCommunication.ActivateApp" one time
                :Times(1)
              end)																						
    	end
    end)

end

function Test:PrecondActivateNonMediaAppTC1( ... )
	-- body
	self:activateApp(self, hmi_ids_of_applications[non_media_app_1.appName])
	self.mobileSession3:ExpectNotification("OnHMIStatus", 
		{hmiLevel = "FULL", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
	:Times(1)

	-- other Apps without changes
	self.mobileSession2:ExpectNotification("OnHMIStatus", {systemContext = "MAIN"})
	:Times(0)
	self.mobileSession:ExpectNotification("OnHMIStatus", {systemContext = "MAIN"})
	:Times(0)
end

function Test:PrecondActivateNaviAppTC1( ... )
	-- body
	self:activateApp(self, hmi_ids_of_applications[navigation_app_1.appName])
	-- navi to FULL
	self.mobileSession2:ExpectNotification("OnHMIStatus", 
		{hmiLevel = "FULL", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
	:Times(1)

	--non-media to BACKGROUND
	self.mobileSession3:ExpectNotification("OnHMIStatus", 
		{hmiLevel = "BACKGROUND", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
	:Times(1)

	--media App without changes
	self.mobileSession:ExpectNotification("OnHMIStatus", {systemContext = "MAIN"})
	:Times(0)
end

function Test:PrecondActivateMediaAppTC1( ... )
	-- body
	self:activateApp(self, hmi_ids_of_applications[media_app_1.appName])
	-- media to FULL
	self.mobileSession:ExpectNotification("OnHMIStatus", 
		{hmiLevel = "FULL", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
	:Times(1)

	--navi to LIMITED, AUDIBLE
	self.mobileSession2:ExpectNotification("OnHMIStatus", 
		{hmiLevel = "LIMITED", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
	:Times(1)

	--non-media App without changes
	self.mobileSession3:ExpectNotification("OnHMIStatus", {systemContext = "MAIN"})
	:Times(0)
end

-- Action: User activates embedded navigation
function Test:PrecondDeactivateMediaAppTC1( ... )
	-- body
	self.hmiConnection:SendNotification("BasicCommunication.OnAppDeactivated", 
		{appID = hmi_ids_of_applications[media_app_1.appName]})

	-- expect Media will be in LIMITED, AUDIBLE
	self.mobileSession:ExpectNotification("OnHMIStatus", 
		{hmiLevel = "LIMITED", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
	:Times(1)

	-- other Apps without changes
	self.mobileSession2:ExpectNotification("OnHMIStatus", {systemContext = "MAIN"})
	:Times(0)
	self.mobileSession3:ExpectNotification("OnHMIStatus", {systemContext = "MAIN"})
	:Times(0)
end

function Test:PrecondActivateEmbeddedNaviTC1( ... )
	-- body
	self.hmiConnection:SendNotification("BasicCommunication.OnEventChanged", 
		{eventName = "EMBEDDED_NAVI", isActive = true})

	-- expect Media will be in LIMITED, AUDIBLE
	self.mobileSession2:ExpectNotification("OnHMIStatus", 
		{hmiLevel = "BACKGROUND", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
	:Times(1)

	-- other Apps without changes
	self.mobileSession:ExpectNotification("OnHMIStatus", {systemContext = "MAIN"})
	:Times(0)
	self.mobileSession3:ExpectNotification("OnHMIStatus", {systemContext = "MAIN"})
	:Times(0)
end

-- User activates Media App
function Test:UserActivatesMediaAppTC1( ... )
	-- body
	userPrint(34, "=================== Test Case ===================")
	self:activateApp(self, hmi_ids_of_applications[media_app_1.appName])

	self.mobileSession:ExpectNotification("OnHMIStatus", 
		{hmiLevel = "FULL", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
	:Times(1)

	-- other Apps without changes
	self.mobileSession2:ExpectNotification("OnHMIStatus", {systemContext = "MAIN"})
	:Times(0)
	self.mobileSession3:ExpectNotification("OnHMIStatus", {systemContext = "MAIN"})
	:Times(0)
end

-- User activates Navi App
function Test:UserActivatesNaviAppTC1( ... )
	-- body
	self.hmiConnection:SendNotification("BasicCommunication.OnEventChanged", 
		{eventName = "EMBEDDED_NAVI", isActive = false})
	self.hmiConnection:SendNotification("BasicCommunication.OnAppDeactivated", 
		{appID = hmi_ids_of_applications[media_app_1.appName]})
	self:activateApp(self, hmi_ids_of_applications[navigation_app_1.appName])

	-- media App moves to LIMITED, AUDIBLE
	self.mobileSession:ExpectNotification("OnHMIStatus", 
		{hmiLevel = "LIMITED", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
	:Times(1)

	-- navi App moves to FULL, AUDIBLE
	self.mobileSession2:ExpectNotification("OnHMIStatus", 
		{hmiLevel = "FULL", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
	:Times(1)

	-- non-media still in BACKGROUND
	self.mobileSession:ExpectNotification("OnHMIStatus", {systemContext = "MAIN"})
	:Times(0)
end

--todo: check statuses during streaming
function Test:PrecondCreateFileForStream( ... )
	-- body
	local file_path = config.pathToSDL .. "sample.txt"
	os.execute("openssl rand -out" .. file_path .. "-base64 $((5 * 1000 ))")
end

--todo: register defect - SDL is freezes if uncomment function below
-- function Test:PrecondStartAudioService( ... )
-- 	-- body
-- 	self.mobileSession2:StartService(10)
-- 	:Do(function ()
-- 		-- body
-- 		self.mobileSession2:StartStreaming(10, config.pathToSDL .. "sample.txt", 30 *1024)
-- 	end)

-- 	EXPECT_HMICALL("NAVIGATION.OnAudioDataStreaming", {{available = true}, {available = false}})

-- 	--todo: expect hmiLevels
-- end

function Test:PostCondRemoveFile( ... )
	-- body
	os.execute("rm " .. config.pathToSDL .. "sample.txt")
end


--todo: check also when user activate non-media, non-media receives FULL,NOT_AUDIBLE, others no change

--End Test case TC.1

-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

--Begin Test case TC.2
      --Description: This test is intended to check SDL behavior during active embedded audio 

      --Requirement id: Multiple media, navigation and non-media apps activation during 
      --  				active embedded audio source+audio mixing supported

function Test:unregisterApplication(session)
  --mobile side: UnregisterAppInterface request 
  local CorIdUAI = session:SendRPC("UnregisterAppInterface",{}) 

  --hmi side: expect OnAppUnregistered notification 
  EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered")
 

  --mobile side: UnregisterAppInterface response 
  session:ExpectResponse(CorIdUAI, { success = true, resultCode = "SUCCESS"})
  :Timeout(200)
end

function Test:PrecondUnregisterMediaAppTC2( ... )
	-- body
	userPrint(35, "================= Precondition ==================")
	self:unregisterApplication(self.mobileSession)
end

function Test:PrecondUnregisterNaviAppTC2( ... )
	-- body
	self:unregisterApplication(self.mobileSession2)
end

function Test:PrecondUnregisterNonMediaAppTC2( ... )
	-- body
	self:unregisterApplication(self.mobileSession3)
end

-- register all Apps
function Test:PrecondRegisterMediaApp1TC2( ... )
	-- body
	self:registerApp(self.mobileSession, media_app_1)
end

function Test:PrecondRegisterNaviApp1TC2( ... )
	-- body
	self:registerApp(self.mobileSession2, navigation_app_1)
end

function Test:PrecondRegisterNonMediaApp1TC2( ... )
	-- body
	self:registerApp(self.mobileSession3, non_media_app_1)
end

function Test:PrecondActivateNonMediaAppTC2( ... )
	-- body
	self:activateApp(self, hmi_ids_of_applications[non_media_app_1.appName])
	self.mobileSession3:ExpectNotification("OnHMIStatus", 
		{hmiLevel = "FULL", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
	:Times(1)

	-- other Apps without changes
	self.mobileSession2:ExpectNotification("OnHMIStatus", {systemContext = "MAIN"})
	:Times(0)
	self.mobileSession:ExpectNotification("OnHMIStatus", {systemContext = "MAIN"})
	:Times(0)
end

function Test:PrecondActivateNaviAppTC2( ... )
	-- body
	self:activateApp(self, hmi_ids_of_applications[navigation_app_1.appName])
	-- navi to FULL
	self.mobileSession2:ExpectNotification("OnHMIStatus", 
		{hmiLevel = "FULL", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
	:Times(1)

	--non-media to BACKGROUND
	self.mobileSession3:ExpectNotification("OnHMIStatus", 
		{hmiLevel = "BACKGROUND", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
	:Times(1)

	--media App without changes
	self.mobileSession:ExpectNotification("OnHMIStatus", {systemContext = "MAIN"})
	:Times(0)
end

function Test:PrecondActivateMediaAppTC2( ... )
	-- body
	self:activateApp(self, hmi_ids_of_applications[media_app_1.appName])
	-- media to FULL
	self.mobileSession:ExpectNotification("OnHMIStatus", 
		{hmiLevel = "FULL", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
	:Times(1)

	--navi to LIMITED, AUDIBLE
	self.mobileSession2:ExpectNotification("OnHMIStatus", 
		{hmiLevel = "LIMITED", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
	:Times(1)

	--non-media App without changes
	self.mobileSession3:ExpectNotification("OnHMIStatus", {systemContext = "MAIN"})
	:Times(0)
end

-- Action: User activates embedded audio
function Test:PrecondActivateEmbeddedAudio( ... )
	-- body
	self.hmiConnection:SendNotification("BasicCommunication.OnAppDeactivated", 
		{appID = hmi_ids_of_applications[media_app_1.appName]})
	self.hmiConnection:SendNotification("BasicCommunication.OnEventChanged", 
		{eventName = "AUDIO_SOURCE", isActive = true})

	-- expect Media will be in BACKGROUND, NOT_AUDIBLE
	self.mobileSession:ExpectNotification("OnHMIStatus", 
		{hmiLevel = "BACKGROUND", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
	:Times(1)

	-- other Apps without changes
	self.mobileSession2:ExpectNotification("OnHMIStatus", {systemContext = "MAIN"})
	:Times(0)
	self.mobileSession3:ExpectNotification("OnHMIStatus", {systemContext = "MAIN"})
	:Times(0)
end

-- Action: User activates navi App
function Test:PrecondActivatesNaviAppTC2( ... )
	-- body
	self:activateApp(self, hmi_ids_of_applications[navigation_app_1.appName])

	-- media App moves to LIMITED, AUDIBLE
	self.mobileSession2:ExpectNotification("OnHMIStatus", 
		{hmiLevel = "FULL", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
	:Times(1)

	-- other Apps without changes
	self.mobileSession:ExpectNotification("OnHMIStatus", {systemContext = "MAIN"})
	:Times(0)
	self.mobileSession3:ExpectNotification("OnHMIStatus", {systemContext = "MAIN"})
	:Times(0)
end

-- Action: User activates media App
function Test:PrecondActivatesMediaAppTC2( ... )
	-- body
	self.hmiConnection:SendNotification("BasicCommunication.OnEventChanged", 
		{eventName = "AUDIO_SOURCE", isActive = false})
	self.hmiConnection:SendNotification("BasicCommunication.OnAppDeactivated", 
		{appID = hmi_ids_of_applications[navigation_app_1.appName]})
	self:activateApp(self, hmi_ids_of_applications[media_app_1.appName])

	-- media App moves to FULL, AUDIBLE
	self.mobileSession:ExpectNotification("OnHMIStatus", 
		{hmiLevel = "FULL", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
	:Times(1)

	-- navi App moves to LIMITED, AUDIBLE
	self.mobileSession2:ExpectNotification("OnHMIStatus", 
		{hmiLevel = "LIMITED", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
	:Times(1)

	-- non-media Apps without changes
	self.mobileSession3:ExpectNotification("OnHMIStatus", {systemContext = "MAIN"})
	:Times(0)
end

function Test:UserActivatesNonMediaApp( ... )
	-- body
	userPrint(34, "=================== Test Case ===================")
	self.hmiConnection:SendNotification("BasicCommunication.OnAppDeactivated", 
		{appID = hmi_ids_of_applications[media_app_1.appName]})
	self:activateApp(self, hmi_ids_of_applications[non_media_app_1.appName])

	-- non-media App moves to FULL, NOT_AUDIBLE
	self.mobileSession3:ExpectNotification("OnHMIStatus", 
		{hmiLevel = "FULL", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
	:Times(1)

	-- media App moves to LIMITED, AUDIBLE
	self.mobileSession:ExpectNotification("OnHMIStatus", 
		{hmiLevel = "LIMITED", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
	:Times(1)

	-- navi App without changes
	self.mobileSession2:ExpectNotification("OnHMIStatus", {systemContext = "MAIN"})
	:Times(0)
end

--End Test case TC.2