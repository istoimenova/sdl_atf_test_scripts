
-- Requirement: APPLINK-16899 "New trigger for changing the value of "preloaded_pt" field to 'false'"
-- Goal is to test if value of "preload_pt" saved in localPT changes: 
-- on initial start it should be true, which means that PTU should start.
-- SDL must change value of "preloadedPT" param to "false" after PTU is applied
------------------------------------------------------------------------------------------------------
------------------------------------General Settings for Configuration--------------------------------
------------------------------------------------------------------------------------------------------
--ToDo: shall be removed when APPLINK-16610 is fixed
config.defaultProtocolVersion = 2

config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"
Test = require('connecttest')
require('cardinalities')
local mobile_session = require('mobile_session')
local tcp = require('tcp_connection')
local file_connection  = require('file_connection')
local mobile  = require('mobile_connection')
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonPreconditions = require('user_modules/shared_testcases/commonPreconditions')
local SDLStoragePath = config.pathToSDL .. "storage/"
Test.HMIappId = nil
------------------------------------------------------------------------------------------------------
----------------------------------Steps before start ATF----------------------------------------------
------------------------------------------------------------------------------------------------------
-- delete sdl_snapshot
os.execute( "rm -f /tmp/fs/mp/images/ivsu_cache/sdl_snapshot.json" )
-- delete app_info.dat, SmartDeviceLinkCore.log, TransportManager.log, ProtocolFordHandling.log, 
-- HmiFrameworkPlugin.log and policy.sqlite
commonSteps:DeleteLogsFileAndPolicyTable()

------------------------------------------------------------------------------------------------------
---------------------------------------Functions used-------------------------------------------------
------------------------------------------------------------------------------------------------------
local function RestartSDL(prefix, DeleteStorageFolder)

	Test["Precondition_StopSDL_" .. tostring(prefix) ] = function(self)
		commonFunctions:userPrint(35, "================= Precondition ==================")
		StopSDL()
	end

	if DeleteStorageFolder then
		Test["Precondition_DeleteStorageFolder_" .. tostring(prefix)] = function(self)
			commonSteps:DeleteLogsFileAndPolicyTable()
		end
	end

	Test["Precondition_StartSDL_" .. tostring(prefix) ] = function(self)
		StartSDL(config.pathToSDL, config.ExitOnCrash)
	end

	Test["Precondition_InitHMI_" .. tostring(prefix) ] = function(self)
		self:initHMI()
	end

	Test["Precondition_InitHMI_onReady_" .. tostring(prefix) ] = function(self)
		self:initHMI_onReady()
	end

	Test["Precondition_ConnectMobile_" .. tostring(prefix) ] = function(self)
  		self:connectMobile()
	end

	Test["Precondition_StartSessionRegisterApp_" .. tostring(prefix) ] = function(self)
  		self:startSession()
	end

end


function DelayedExp(time)
  local event = events.Event()
  event.matches = function(self, e) return self == e end
  EXPECT_EVENT(event, "Delayed event")
  :Timeout(time+1000)
  RUN_AFTER(function()
              RAISE_EVENT(event, event)
            end, time)
end


local function get_preloaded_pt_value(self)   

  local sql_select = "sqlite3 " .. tostring(SDLStoragePath) .. "policy.sqlite \"SELECT preloaded_pt FROM module_config WHERE rowid = 1\""
   
           local aHandle = assert( io.popen( sql_select , 'r'))
    sql_output = aHandle:read( '*l' )
 
    if sql_output then
       print (sql_output) 
       if tonumber(sql_output) == 1 then
        return true
      else
        return false
      end 
    end
  return nul
end


local function UpdatePolicy(self, PTName)
--hmi side: sending SDL.GetURLS request
local RequestIdGetURLS = self.hmiConnection:SendRequest("SDL.GetURLS", { service = 7 })
--hmi side: expect SDL.GetURLS response from HMI
EXPECT_HMIRESPONSE(RequestIdGetURLS,{result = {code = 0, method = "SDL.GetURLS", urls = {{url = "http://policies.telematics.ford.com/api/policies"}}}})
  :Do(function(_,data)
	print("SDL.GetURLS response is received")
	--hmi side: sending BasicCommunication.OnSystemRequest request to SDL
	self.hmiConnection:SendNotification("BasicCommunication.OnSystemRequest",
		{   
		    requestType = "PROPRIETARY",
		    url="http://policies.telematics.ford.com/api/policies",
		    fileName = "/tmp/fs/mp/images/ivsu_cache/sdl_snapshot.json",
			appID = self.applications["Test Application"]				
		}
	)
	--mobile side: expect OnSystemRequest notification
	self.mobileSession:ExpectNotification("OnReceivedPolicyUpdate", 
		{ 
		  requestType = "PROPRIETARY",
		  url="http://policies.telematics.ford.com/api/policies",
		  fileName = "/tmp/fs/mp/images/ivsu_cache/sdl_snapshot.json"

		 })
	end)
	:Do(function(_,data)				
    --mobile side: sending SystemRequest request
		local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest",
			{
				fileName = "PolicyTableUpdate",
				requestType = "PROPRIETARY"
			},
			"files/" .. "PTU_UpdateNeeded.json")

		local systemRequestId
		--hmi side: expect SystemRequest request
		EXPECT_HMICALL("BasicCommunication.SystemRequest")
		:Do(function(_,data)
			systemRequestId = data.id
			--hmi side: sending BasicCommunication.OnSystemRequest request to SDL
			self.hmiConnection:SendNotification("SDL.OnReceivedPolicyUpdate",
				{
					policyfile = "/tmp/fs/mp/images/ivsu_cache/PolicyTableUpdate"
				}
			)
			function to_run()
				--hmi side: sending SystemRequest response
				self.hmiConnection:SendResponse(systemRequestId,"BasicCommunication.SystemRequest", "SUCCESS", {})
			end

			RUN_AFTER(to_run, 500)
		end)

		--hmi side: expect SDL.OnStatusUpdate
		EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate")
		:ValidIf(function(exp,data)
			if
				exp.occurences == 1 and
				data.params.status == "UP_TO_DATE" then
					return true
			elseif
				exp.occurences == 1 and
				data.params.status == "UPDATING" then
					return true
			elseif
				exp.occurences == 2 and
				data.params.status == "UP_TO_DATE" then
					return true
			else
				if
					exp.occurences == 1 then
						print ("\27[31m SDL.OnStatusUpdate came with wrong values. Expected in first occurrences status 'UP_TO_DATE' or 'UPDATING', got '" .. tostring(data.params.status) .. "' \27[0m")
				elseif exp.occurences == 2 then
						print ("\27[31m SDL.OnStatusUpdate came with wrong values. Expected in second occurrences status 'UP_TO_DATE', got '" .. tostring(data.params.status) .. "' \27[0m")
				end
				return false
			end
		end)
		:Times(Between(1,2))

		--mobile side: expect SystemRequest response
		self.mobileSession:ExpectResponse(CorIdSystemRequest, { success = true, resultCode = "SUCCESS"})
		:Do(function(_,data)
			--hmi side: sending SDL.GetUserFriendlyMessage request to SDL
			local RequestIdGetUserFriendlyMessage = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "EN-US", messageCodes = {"StatusUpToDate"}})

			--hmi side: expect SDL.GetUserFriendlyMessage response
			EXPECT_HMIRESPONSE(RequestIdGetUserFriendlyMessage,{result = {code = 0, method = "SDL.GetUserFriendlyMessage", messages = {{line1 = "Up-To-Date", messageCode = "StatusUpToDate", textBody = "Up-To-Date"}}}})
			:Do(function(_,data)
			end)
		end)

	end)
end

local function MASTER_RESET(self, appNumber)
	StopSDL()

	if appNumber == nil then 
		appNumber = 1
	end

	-- hmi side: sends OnExitAllApplications (SUSPENDED)
	self.hmiConnection:SendNotification("BasicCommunication.OnExitAllApplications",
		{
		  reason = "MASTER_RESET"
		})

	-- hmi side: expect OnSDLClose notification
	EXPECT_HMINOTIFICATION("BasicCommunication.OnSDLClose", {})

	-- hmi side: expect OnAppUnregistered notification
	-- will be uncommented after fixinf defect: APPLINK-21931
	--EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered")
      :Times(1)
	DelayedExp(1000)
end

------------------------------------------------------------------------------------------------------
------------------------------------------Tests-------------------------------------------------------
------------------------------------------------------------------------------------------------------
-- Verification criteria: on the first App connection value of "preloaded_pt" = true, which means that PTU should start after tigger. 
-- After PTU is applied "preloaded_pt" in localPT chould become false

function Test:Precondition_restartSDL()
	commonFunctions:userPrint(35, "\n================= Precondition ==================")
	RestartSDL("InitialStart", false)
  end

-- activate App
function Test:Check1_ActivationOfApplication()
	commonFunctions:userPrint(34, "=================== Test Case Check 1 ===================")
	commonSteps:ActivationApp(nil, "Activating_App")

	DelayedExp(3000)	
 end

-- check localpt created
function Test:Check1_LocalPTCreated()
	
		if commonSteps:file_exists(SDLStoragePath .. "policy.sqlite") == true then
				commonFunctions:userPrint(33, "localPT is created")
		else
			commonFunctions:userPrint(31, "localPT wasn't created")
	end
 end

--check value of "preloaded_pt" in storage/policy.sqlite. It should be true. That means that LocalPT should be updated
function Test:CheckValueOfPreloaded()  
  preloaded_pt = get_preloaded_pt_value()

  if (preloaded_pt == nil or preloaded_pt) then
  	print (preloaded_pt)
    commonFunctions:userPrint(31, "preloaded_pt in localPT is true, should be false")
  end
 end

-- after trigger occurs (in current case "timeout_after_x_seconds" = 60 secomds) PTU process should start
-- HMI requests From SDL URL to send PTSnapshot
function Test:UpdatePT()
--hmi side: sending SDL.UpdateSDL request
	local RequestIdUpdateSDL = self.hmiConnection:SendRequest("SDL.UpdateSDL")

	EXPECT_HMICALL("BasicCommunication.PolicyUpdate")
		:Do(function(_,data)
			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
		end)
	
	--hmi side: expect SDL.UpdateSDL response from HMI
	EXPECT_HMIRESPONSE(RequestIdUpdateSDL,{result = {code = 0, method = "SDL.UpdateSDL", result = "UPDATE_NEEDED" }})
		:Do(function()
			UpdatePolicy(self, "files/PTU_UpdateNeeded.json")
		end)

	DelayedExp(2000)
end

function Test:PTUSuccess()
	-- hmi side: sending BasicCommunication.OnSystemRequest request to SDL
	self.hmiConnection:SendNotification("SDL.OnReceivedPolicyUpdate",
		{
			policyfile = "/tmp/fs/mp/images/ivsu_cache/PolicyTableUpdate"
		})
	--hmi side: expect SDL.OnStatusUpdate ("UP_TO_DATE")
	EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate", { status = "UP_TO_DATE"})
	:Do(function(_,data)
		print("SDL.OnStatusUpdate is received")			               
	end)
	:Timeout(2000)
end

-- after localPT was updated, check value of "preloaded_pt". It should become false
function Test:CheckValueOfPreloaded()  
  preloaded_pt = get_preloaded_pt_value()

  if (preloaded_pt == nil or preloaded_pt) then
  	self:FailTestCase ("preloaded_pt in localPT is true, should be false")

  end
end

--///////////////////////////////////////////////////////////////////////////////////////////
-- the value of "preloaded_pt" should be true after MASTER_RESET (APPLINK-16899)
-- send master reset	
function Test:Check2_ExecuteMasterReset() 
	commonFunctions:userPrint(34, "=================== Test Case Check 2 ===================")
	--TODO: delete after APPLINK-19717 resolved
	commonFunctions:userPrint(34, "currently case fails due to APPLINK-19717")
       MASTER_RESET(self)
end
-- start SDL, register App
function Test:Check2_startSDLAfterMasterReset()
	RestartSDL("Restart after MASTER_RESET", false)
	--StartSDL_Without_stop("Restart after MASTER_RESET")
end

-- activate App
function Test:Check2_ActivationOfApplication()
	commonSteps:ActivationApp(nil, "Activating_App")

	DelayedExp(3000)	
end

-- check "preloaded_pt" in localPT became true after MASTER_RESET 
function Test:Check2_ValueOfPreloaded()  
  preloaded_pt = get_preloaded_pt_value()

  if (preloaded_pt == nil or preloaded_pt) then
    commonFunctions:userPrint(31, "preloaded_pt=true after MASTER_RESET")
  end
end
