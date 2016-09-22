-- ATF version: 2.2
-- CRQ: APPLINK-23652 [F-S] UI/TTS.SetGlobalProperties: mobile app does NOT send <vrHelp> and <helpPrompt> during 10 sec timer
-- Specified by: 
--		APPLINK-23759 [SetGlobalProperties] Mobile app does NOT send request and has registered Add/DeleteCommands
--		APPLINK-23760 [SetGlobalProperties] Mobile app does NOT send request and has NO registered Add/DeleteCommands
--			APPLINK-19475 [SetGlobalProperties]: Default values of <vrHelp> and <helpPrompt> 
--		APPLINK-23761 [SetGlobalProperties] Conditions for SDL to send updated values of "vrHelp" and/or "helpPrompt" to HMI
--		APPLINK-23762 [SetGlobalProperties] SDL sends request by itself and HMI respond with any errorCode
--		APPLINK-23763 [SetGlobalProperties] SDL sends request by itself and HMI does NOT respond during <DefaultTimeout>
---------------------------------------------------
os.execute("ps aux | grep -e smartDeviceLinkCore | awk '{print$2}'")
os.execute("kill -9 $(ps aux | grep -e smartDeviceLinkCore | awk '{print$2}')")

Test = require('connecttest')
require('cardinalities')
local events = require('events')
local mobile_session = require('mobile_session')
local mobile = require('mobile_connection')
local tcp = require('tcp_connection')
local file_connection = require('file_connection')

---------------------------------------------------------------------------------------------
-----------------------------Required Shared Libraries---------------------------------------
---------------------------------------------------------------------------------------------
require('user_modules/AppTypes')
local commonTestCases = require('user_modules/shared_testcases/commonTestCases')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
local commonPreconditions = require('user_modules/shared_testcases/commonPreconditions')

APIName = "SetGlobalProperties" -- set for required scripts
strMaxLengthFileName255 = string.rep("a", 251) .. ".png" -- set max length file name

local iTimeout = 5000
local TimeRAISuccess = 0
config.defaultProtocolVersion = 2
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"
local strAppFolder = config.pathToSDL .. "storage/" ..config.application1.registerAppInterfaceParams.appID.. "_" .. config.deviceMAC.. "/"

---------------------------------------------------------------------------------------------
--------------------------------------Delete/update files------------------------------------
---------------------------------------------------------------------------------------------
--Print new line to separate Preconditions
commonFunctions:newTestCasesGroup("Preconditions")

--Delete app_info.dat, logs and policy table
commonSteps:DeleteLogsFileAndPolicyTable()

function UpdatePolicy()
	commonPreconditions:BackupFile("sdl_preloaded_pt.json")
	local src_preloaded_json = config.pathToSDL .."sdl_preloaded_pt.json"
	local dest = "files/SetGlobalProperties_DISALLOWED.json"
	
	local filecopy = "cp " .. dest .." " .. src_preloaded_json
	
	os.execute(filecopy)
end

UpdatePolicy()

---------------------------------------------------------------------------------------------
---------------------------------------Common functions--------------------------------------
--------------------------------------------------------------------------------------------- 
--User prints
function userPrint( color, message)
	print ("\27[" .. tostring(color) .. "m " .. tostring(message) .. " \27[0m")
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

--Registering application

function Precondition_RegisterApp_Delete(self, nameTC)
	
	commonSteps:UnregisterApplication(nameTC .."_UnregisterApplication") 
	
	commonSteps:StartSession(nameTC .."_StartSession")
	
	Test[nameTC .."_RegisterApp"] = function(self)
		
		self.mobileSession:StartService(7)
		:Do(function() 
			local CorIdRegister = self.mobileSession:SendRPC("RegisterAppInterface", config.application1.registerAppInterfaceParams)
			EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", 
			{ application = { appName = config.application1.registerAppInterfaceParams.appName }})
			:Do(function(_,data)
				TimeRAISuccess = timestamp()
				self.applications[data.params.application.appName] = data.params.application.appID
				return TimeRAISuccess
			end)
			
			self.mobileSession:ExpectResponse(CorIdRegister, { success = true, resultCode = "SUCCESS" })
			:Timeout(2000)
			
			self.mobileSession:ExpectNotification("OnHMIStatus", {hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
		end)
		
		if(TimeRAISuccess == nil) then
			TimeRAISuccess = 0
			userPrint(31, "TimeRAISuccess is nil. Will be assigned 0")
		end
	end 
end

--Registering application without Underregistration

function Precondition_RegisterAppWithoutUnregister(self, nameTC)
	
	Test[nameTC .."_RegisterApp"] = function(self)
		
		config.application1.registerAppInterfaceParams.hashID = self.currentHashID
		
		
		self.mobileSession:StartService(7)
		:Do(function() 
			local CorIdRegister = self.mobileSession:SendRPC("RegisterAppInterface", config.application1.registerAppInterfaceParams)
			EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", 
			{ application = { appName = config.application1.registerAppInterfaceParams.appName }})
			:Do(function(_,data)
				TimeRAISuccess = timestamp()
				self.applications[data.params.application.appName] = data.params.application.appID
				return TimeRAISuccess
			end)
			
			self.mobileSession:ExpectResponse(CorIdRegister, { success = true, resultCode = "SUCCESS" })
			:Timeout(2000)
			
			self.mobileSession:ExpectNotification("OnHMIStatus", {hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
		end)
		
		if(TimeRAISuccess == nil) then
			TimeRAISuccess = 0
			userPrint(31, "TimeRAISuccess is nil. Will be assigned 0")
		end
	end 
end



--Activation application

local TimeOfActivation
function ActivationApp(self, nameTC)
	
	Test[nameTC .."_ActivationApp"] = function(self)
		
		--hmi side: sending SDL.ActivateApp request
		local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications[config.application1.registerAppInterfaceParams.appName]})
		
		EXPECT_HMIRESPONSE(RequestId)
		:Do(function(_,data)
			if data.result.isSDLAllowed ~= true then
				local RequestId = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "EN-US", messageCodes = {"DataConsent"}})
				--hmi side: expect SDL.GetUserFriendlyMessage message response
				--TODO: update after resolving APPLINK-16094.
				--EXPECT_HMIRESPONSE(RequestId,{result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
				EXPECT_HMIRESPONSE(RequestId)
				:Do(function(_,data) 
					--hmi side: send request SDL.OnAllowSDLFunctionality
					self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality", {allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}})
					
					--hmi side: expect BasicCommunication.ActivateApp request
					EXPECT_HMICALL("BasicCommunication.ActivateApp")
					:Do(function(_,data)
						--hmi side: sending BasicCommunication.ActivateApp response
						self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})
					end)
					:Times(AnyNumber())
				end)
				
			end
		end)
		
		--mobile side: expect notification
		EXPECT_NOTIFICATION("OnHMIStatus", {hmiLevel = "FULL", systemContext = "MAIN"})
		:Do(function(_,data)
			TimeOfActivation = timestamp()
		end)
	end
end


local function AddCommand(self, icmdID)
	local TimeAddCmdSuccess = 0
	local cid = self.mobileSession:SendRPC("AddCommand",
	{
		cmdID = icmdID,
		menuParams = 
		{
			menuName ="Command" .. tostring(icmdID)
		}, 
		vrCommands = {"VRCommand" .. tostring(icmdID)}
	})
	
	--hmi side: expect UI.AddCommand request 
	EXPECT_HMICALL("UI.AddCommand", 
	{ 
		cmdID = icmdID,
		menuParams = 
		{
			menuName ="Command" .. tostring(icmdID)
		}, 
		--vrCommands = {"VRCommand" .. tostring(icmdID)}
	})
	:Do(function(_,data)
		--hmi side: sending UI.AddCommand response
		self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
	end)
	
	--hmi side: expect VR.AddCommand request 
	EXPECT_HMICALL("VR.AddCommand", 
	{ 
		cmdID = icmdID,
		type = "Command",
		vrCommands = {
			"VRCommand" .. tostring(icmdID)
		}
	})
	:Do(function(_,data)
		--hmi side: sending VR.AddCommand response
		self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
	end) 
	--mobile side: expect AddCommand response
	EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
	
	--mobile side: expect OnHashChange notification
	EXPECT_NOTIFICATION("OnHashChange")
	:Do(function(_, data)
		self.currentHashID = data.payload.hashID
	end)
	
end




-- Delete existed command by cmdID
-- iCmdID : id of command to be deleted
function DeleteCommand(self, iCmdID)
	--mobile side: sending DeleteCommand request
	local cid = self.mobileSession:SendRPC("DeleteCommand",
	{
		cmdID = iCmdID
	})
	
	--hmi side: expect UI.DeleteCommand request
	EXPECT_HMICALL("UI.DeleteCommand", 
	{ 
		cmdID = iCmdID
	})
	:Do(function(_,data)
		--hmi side: sending UI.DeleteCommand response
		self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
	end)
	
	--hmi side: expect VR.DeleteCommand request
	EXPECT_HMICALL("VR.DeleteCommand", 
	{ 
		cmdID = iCmdID
	})
	:Do(function(_,data)
		--hmi side: sending VR.DeleteCommand response
		self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
	end)
	
	--mobile side: expect DeleteCommand response 
	EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
	
	--mobile side: expect OnHashChange notification
	EXPECT_NOTIFICATION("OnHashChange") 
end


local function CheckUpdateFile_Delete(self, SGP_helpPrompt, SGP_vrHelp)
	local cid = self.mobileSession:SendRPC("SetGlobalProperties",{ menuTitle = "Menu Title"})
	
	--hmi side: expect UI.SetGlobalProperties request
	EXPECT_HMICALL("UI.SetGlobalProperties",
	{
		vrHelpTitle = config.application1.registerAppInterfaceParams.appName,
		vrHelp = { SGP_vrHelp },
		appID = self.applications[config.application1.registerAppInterfaceParams.appName]
	})
	:Do(function(_,data)
		--hmi side: sending UI.SetGlobalProperties response
		self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
	end)
	
	--hmi side: expect TTS.SetGlobalProperties request
	EXPECT_HMICALL("TTS.SetGlobalProperties",
	{
		helpPrompt = { SGP_helpPrompt },
		appID = self.applications[config.application1.registerAppInterfaceParams.appName]
	})
	:Do(function(_,data)
		--hmi side: sending UI.SetGlobalProperties response
		self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
	end) 
	
	--mobile side: expect SetGlobalProperties response
	EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
	
	--mobile side: expect OnHashChange notification
	EXPECT_NOTIFICATION("OnHashChange")
	
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


---------------------------------------------------------------------------------------------
-------------------------------------------PreConditions-------------------------------------
---------------------------------------------------------------------------------------------

function GetValueInIniFile(FindExpression)
	
	local SDLini = config.pathToSDL .. "smartDeviceLink.ini"
	
	f = assert(io.open(SDLini, "r"))
	if f then
		fileContent = f:read("*all")
		
		fileContentFind = fileContent:match(FindExpression)
		
		if fileContentFind then
			--Get the first line
			local temp = fileContentFind:match("[^\n]*") 
			
			--Return message from the end of line to "="
			return temp:match("[^=]*$") 
		else
			commonFunctions:printError("Parameter is not found")
		end
		f:close()
	else
		commonFunctions:printError("Cannot open file")
	end
	
	
end

local default_HelpPromt = GetValueInIniFile("HelpProm%a*%s*=[%s*%a*%p*]*")
print("=================Value of HelpPrompt in ini file is '" .. default_HelpPromt .. "'")


---------------------------------------------------------------------------------------------
----------------------------------------------Body-------------------------------------------
---------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------
-- req #1: value from list
-- APPLINK-23759 [SetGlobalProperties] Mobile app does NOT send request and has registered Add/DeleteCommands
-- Verification criteria:
-- In case:
-- 		mobile app does NOT send SetGlobalProperties_request at all with <vrHelp> and <helpPrompt> during 10 sec timer
-- 		and this mobile app has successfully registered AddCommands 
-- 		and/or DeleteCommands requests (previously added OR resumed within data resumption)
-- SDL must:
-- 		provide the value of <helpPrompt> and <vrHelp> from internal list based on registered AddCommands and DeleteCommands requests to HMI (please see APPLINK-19474)

---------------------------------------------------------------------------------------------

local function Req1_APPLINK_23759_Add_DeleteCommand(TestName)
	
	commonSteps:UnregisterApplication(TestName .. "_Precondition_UnregisterApp")
	commonSteps:RegisterAppInterface(TestName .. "_RegisterApp")
	commonSteps:ActivationApp(_, TestName .. "_ActivationApp")	
	
	-- Add 2 commands
	for cmdCount = 1, 2 do
		Test[TestName .. "_Precondition_AddCommand_" .. tostring(cmdCount)] = function(self)
			AddCommand(self, cmdCount)
		end
	end 
	
	-- Delete 1 of added Commands
	Test[TestName .. "_Precondition_DeleteCommand_1"] = function(self)
		DeleteCommand(self, 1)
	end
	
	Test[TestName .. "_NoSGPvrHelphelpPrompt_from_intList_" .. tostring(cmdCount)] = function(self)
		
		--hmi side: expect TTS.SetGlobalProperties request
		EXPECT_HMICALL("TTS.SetGlobalProperties",
		{
			helpPrompt = 
			{
				{
					text = "VRCommand2",
					type = "TEXT"
				}
			},
			appID = self.applications[config.application1.registerAppInterfaceParams.appName]
		})
		
		:Do(function(_,data)
			--hmi side: sending TTS.SetGlobalProperties response
			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
		end)
		
		
		--hmi side: expect UI.SetGlobalProperties request
		EXPECT_HMICALL("UI.SetGlobalProperties",
		{
			vrHelpTitle = config.application1.registerAppInterfaceParams.appName,
			vrHelp = { 
				{
					text = config.application1.registerAppInterfaceParams.appName,
					position = 1
				} 
			}, 
		})
		:Do(function(_,data)
			--hmi side: sending UI.SetGlobalProperties response
			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
		end)
	end
	
	
	
end

local function Req1_APPLINK_23759_Resumption(TestName)
	
	
	commonSteps:UnregisterApplication("APPLINK_23759_Resumption_Precondition_UnregisterApp")
	commonSteps:RegisterAppInterface("APPLINK_23759_Resumption_RegisterApp")
	commonSteps:ActivationApp(_, "APPLINK_23759_Resumption_ActivationApp")	
	
	-- App has registered, add 2 commands
	for cmdCount = 1, 2 do
		Test[TestName .. "_Precondition_AddCommandInitial_" .. cmdCount] = function(self)
			AddCommand(self, cmdCount)
		end
	end 
	
	-- IGN_OFF: 1. SUSPEND, 2. IGN_OFF
	Test[TestName .. "_Precondition_SuspendFromHMI"] = function(self)
		self.hmiConnection:SendNotification("BasicCommunication.OnExitAllApplications", {reason = "SUSPEND"})
		
		-- hmi side: expect OnSDLPersistenceComplete notification
		EXPECT_HMINOTIFICATION("BasicCommunication.OnSDLPersistenceComplete")
	end
	
	Test[TestName .. "_Precondition_IGN_OFF"] = function(self)
		IGNITION_OFF(self, 0)
	end
	
	-- Start SDL
	Test[TestName .. "_Precondition_StartSDL"] = function(self)
		StartSDL(config.pathToSDL, config.ExitOnCrash)
		DelayedExp(1000)
	end
	
	Test[TestName .. "_Precondition_InitHMI"] = function(self)
		self:initHMI()
	end
	
	Test[TestName .. "_Precondition_InitHMI_onReady"] = function(self)
		self:initHMI_onReady()
	end
	
	Test[TestName .. "_Precondition_ConnectMobile"] = function(self)
		self:connectMobile()
	end
	
	Test[TestName .. "_Precondition_StartSession"] = function(self)
		self.mobileSession = mobile_session.MobileSession(self, self.mobileConnection)
	end
	
	-- Register App
	Precondition_RegisterAppWithoutUnregister(self, TestName .. "_Precondition_RegisterApp")
	
	-- Activate registered App
	ActivationApp(self, TestName .. "_Precondition_ActivationApp")
	
	Test[TestName .. "_NoSGPvrHelphelpPrompt_from_intList"] = function(self)
		
		--hmi side: expect TTS.SetGlobalProperties request
		EXPECT_HMICALL("TTS.SetGlobalProperties",
		{
			helpPrompt = 
			{
				{
					text = "VRCommand1",
					type = "TEXT"
				},
				{
					text = "VRCommand2",
					type = "TEXT"
				},
			},
			appID = self.applications[config.application1.registerAppInterfaceParams.appName]
		})
		:Do(function(_,data)
			--hmi side: sending UI.SetGlobalProperties response
			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
		end)
		
		--hmi side: expect UI.SetGlobalProperties request
		EXPECT_HMICALL("UI.SetGlobalProperties",
		{
			vrHelpTitle = config.application1.registerAppInterfaceParams.appName,
			vrHelp = { 
				{
					text = config.application1.registerAppInterfaceParams.appName,
					position = 1
				} 
			}, 
		})
		
		:Do(function(_,data)
			--hmi side: sending UI.SetGlobalProperties response
			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
		end)
		
	end
	
	
end

--Print new line to separate Preconditions
commonFunctions:newTestCasesGroup("Req1_APPLINK_23759")		
Req1_APPLINK_23759_Add_DeleteCommand("Req1_APPLINK_23759_Add_DeleteCommand")
Req1_APPLINK_23759_Resumption("Req1_APPLINK_23759_Resumption")


---------------------------------------------------------------------------------------------
-- req #2: Default value 
-- req: Happy Path
-- APPLINK-23760 [SetGlobalProperties] Mobile app does NOT send request and has NO registered Add/DeleteCommands
-- Verification criteria:
-- In case:
-- 		mobile app does NOT send SetGlobalProperties_request at all with <vrHelp> and <helpPrompt> during 10 sec timer
-- 		and this mobile app has NO registered AddCommands 
-- 		and/or DeleteCommands requests (previously added OR resumed during data resumption)
-- SDL must:
-- 		provide the default values of <helpPrompt> and <vrHelp> to HMI (Please see APPLINK-19475)

--	APPLINK-19475 [SetGlobalProperties]: Default values of <vrHelp> and <helpPrompt> 
---------------------------------------------------------------------------------------------

local function Req2_APPLINK_23760(TestCaseName)
	
	--Print new line to separate Preconditions
	commonFunctions:newTestCasesGroup(TestCaseName)		
	
	commonSteps:UnregisterApplication(TestCaseName .. "_Precondition_UnregisterApp")
	commonSteps:RegisterAppInterface(TestCaseName .. "_RegisterApp")
	commonSteps:ActivationApp(_, TestCaseName .. "_ActivationApp")	
	
	
	Test[TestCaseName .. "_NoSGP_from_App_SDL_Sends_SGP_After_10secTimer"] = function(self)
		
		--hmi side: expect UI.SetGlobalProperties request
		EXPECT_HMICALL("UI.SetGlobalProperties",
		{
			vrHelpTitle = config.application1.registerAppInterfaceParams.appName,
			vrHelp = { 
				{
					text = config.application1.registerAppInterfaceParams.appName,
					position = 1
				} 
			}
		})
		
		:Do(function(_,data)
			--hmi side: sending UI.SetGlobalProperties response
			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
		end)
		
		--hmi side: expect TTS.SetGlobalProperties request
		EXPECT_HMICALL("TTS.SetGlobalProperties",
		{
			helpPrompt = 
			{
				{
					text = default_HelpPromt,
					type = "TEXT"
				} 
			}
		})
		
		:Do(function(_,data)
			--hmi side: sending TTS.SetGlobalProperties response
			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
		end) 
		
	end
	
end

Req2_APPLINK_23760("Req2_APPLINK_23760")



---------------------------------------------------------------------------------------------
-- req #3: update list condition
-- APPLINK-23761 [SetGlobalProperties] Conditions for SDL to send updated values of "vrHelp" and/or "helpPrompt" to HMI
-- Verification criteria:
-- In case:
-- 		mobile app does NOT send SetGlobalProperties with <vrHelp> and <helpPrompt> to SDL during 10 sec timer
-- 		and SDL already sends by itself UI/TTS.SetGlobalProperties with values of <vrHelp> and <helpPrompt> to HMI
-- 		and mobile app sends AddCommand 
-- 		and/or DeleteCommand requests to SDL
-- SDL must:
-- 		update internal list with new values of "vrHelp" and "helpPrompt" params ONLY after successful response from HMI
-- 		send updated values of "vrHelp" and "helpPrompt" via TTS/UI.SetGlobalProperties to HMI till mobile app sends SetGlobalProperties request with valid <vrHelp> and <helpPrompt> params to SDL
---------------------------------------------------------------------------------------------

local function Req3_APPLINK_23761_AddCommand_SUCCESS(TestCaseName)
	
	--Print new line to separate Preconditions
	commonFunctions:newTestCasesGroup(TestCaseName)		
	
	commonSteps:UnregisterApplication(TestCaseName .. "_Precondition_UnregisterApp")
	commonSteps:RegisterAppInterface(TestCaseName .. "_RegisterApp")
	commonSteps:ActivationApp(_, TestCaseName .. "_ActivationApp")	
	
	Test[TestCaseName .. "_NoSGP_from_App_SDL_Sends_SGP_After_10secTimer"] = function(self)
		
		
		--hmi side: expect UI.SetGlobalProperties request
		EXPECT_HMICALL("UI.SetGlobalProperties",
		{
			vrHelpTitle = config.application1.registerAppInterfaceParams.appName,
			vrHelp = { 
				{
					text = config.application1.registerAppInterfaceParams.appName,
					position = 1
				} 
			}
		})
		:Do(function(_,data)	
			--hmi side: sending UI.SetGlobalProperties response
			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
		end)
		
		--hmi side: expect TTS.SetGlobalProperties request
		EXPECT_HMICALL("TTS.SetGlobalProperties",
		{
			helpPrompt = 
			{
				{
					text = default_HelpPromt,
					type = "TEXT"
				} 
			}
		})		
		:Do(function(_,data)
			--hmi side: sending TTS.SetGlobalProperties response
			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
		end) 
		
	end
	
	Test[TestCaseName .. "_AddCommand_SUCCESS_SDL_Sends_SetGlobalProperties"] = function(self)
		
		local icmdID = 50
		local cid = self.mobileSession:SendRPC("AddCommand",
		{
			cmdID = icmdID,
			menuParams = 
			{
				menuName ="Command" .. tostring(icmdID)
			}, 
			vrCommands = {"VRCommand" .. tostring(icmdID)}
		})
		
		--hmi side: expect UI.AddCommand request 
		EXPECT_HMICALL("UI.AddCommand", 
		{ 
			cmdID = icmdID,
			menuParams = 
			{
				menuName ="Command" .. tostring(icmdID)
			}, 
			--vrCommands = {"VRCommand" .. tostring(icmdID)}
		})
		:Do(function(_,data)
			--hmi side: sending UI.AddCommand response
			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
		end)
		
		--hmi side: expect VR.AddCommand request 
		EXPECT_HMICALL("VR.AddCommand", 
		{ 
			cmdID = icmdID,
			type = "Command",
			vrCommands = {
				"VRCommand" .. tostring(icmdID)
			}
		})
		:Do(function(_,data)
			--hmi side: sending VR.AddCommand response
			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
		end) 
		
		
		--mobile side: expect AddCommand response
		EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
		:Do(function(_,data)
			
			--When AddCommand is returned SUCCESS, SDL will send SetGlobalProperties to UI and TTS.
			
			--hmi side: expect UI.SetGlobalProperties request
			EXPECT_HMICALL("UI.SetGlobalProperties",
			{
				vrHelpTitle = config.application1.registerAppInterfaceParams.appName,
				vrHelp = { 
					{
						text = config.application1.registerAppInterfaceParams.appName,
						position = 1
					} 
				}
				--ToDo: Update detail expected result here.
			})
			:Do(function(_,data)	
				--hmi side: sending UI.SetGlobalProperties response
				self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
			end)
			
			--hmi side: expect TTS.SetGlobalProperties request
			EXPECT_HMICALL("TTS.SetGlobalProperties",
			{
				helpPrompt = 
				{
					{
						text = default_HelpPromt,
						type = "TEXT"
					} 
				}
				--ToDo: Update detail expected result here.
			})		
			:Do(function(_,data)
				--hmi side: sending TTS.SetGlobalProperties response
				self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
			end) 
		end)
		
		
		
		--mobile side: expect OnHashChange notification
		EXPECT_NOTIFICATION("OnHashChange")
		:Do(function(_, data)
			self.currentHashID = data.payload.hashID
		end)
		
	end
	
end

Req3_APPLINK_23761_AddCommand_SUCCESS("Req3_APPLINK_23761_AddCommand_SUCCESS")

local function UI_or_TTS_AddCommand_responds_error(TestCaseName, Interface, ErrorCode)
	
	--Print new line to separate Preconditions
	commonFunctions:newTestCasesGroup(TestCaseName)		
	
	commonSteps:UnregisterApplication(TestCaseName .. "_Precondition_UnregisterApp")
	commonSteps:RegisterAppInterface(TestCaseName .. "_RegisterApp")
	commonSteps:ActivationApp(_, TestCaseName .. "_ActivationApp")	
	
	Test[TestCaseName .. "_NoSGP_from_App_SDL_Sends_SGP_After_10secTimer"] = function(self)
		
		
		--hmi side: expect UI.SetGlobalProperties request
		EXPECT_HMICALL("UI.SetGlobalProperties",
		{
			vrHelpTitle = config.application1.registerAppInterfaceParams.appName,
			vrHelp = { 
				{
					text = config.application1.registerAppInterfaceParams.appName,
					position = 1
				} 
			}
		})
		:Do(function(_,data)	
			--hmi side: sending UI.SetGlobalProperties response
			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
		end)
		
		--hmi side: expect TTS.SetGlobalProperties request
		EXPECT_HMICALL("TTS.SetGlobalProperties",
		{
			helpPrompt = 
			{
				{
					text = default_HelpPromt,
					type = "TEXT"
				} 
			}
		})		
		:Do(function(_,data)
			--hmi side: sending TTS.SetGlobalProperties response
			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
		end) 
		
	end
	
	
	Test[TestCaseName .. "_AddCommand_FAILED_SDL_DOES_NOT_Send_SetGlobalProperties"] = function(self)
		
		local icmdID = 60
		local cid = self.mobileSession:SendRPC("AddCommand",
		{
			cmdID = icmdID,
			menuParams = 
			{
				menuName ="Command" .. tostring(icmdID)
			}, 
			vrCommands = {"VRCommand" .. tostring(icmdID)}
		})
		
		--hmi side: expect UI.AddCommand request 
		EXPECT_HMICALL("UI.AddCommand", 
		{ 
			cmdID = icmdID,
			menuParams = 
			{
				menuName ="Command" .. tostring(icmdID)
			}, 
			--vrCommands = {"VRCommand" .. tostring(icmdID)}
		})
		:Do(function(_,data)
			--hmi side: sending UI.AddCommand response
			if Interface == "UI" then 
				if ErrorCode == nil then
					--UI does not respond
				else
					self.hmiConnection:SendError(data.id, data.method, ErrorCode, "Error message")
				end
			else
				self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
			end	
			
		end)
		
		--hmi side: expect VR.AddCommand request 
		EXPECT_HMICALL("VR.AddCommand", 
		{ 
			cmdID = icmdID,
			type = "Command",
			vrCommands = {
				"VRCommand" .. tostring(icmdID)
			}
		})
		:Do(function(_,data)
			--hmi side: sending VR.AddCommand response
			if Interface == "VR" then 
				if ErrorCode == nil then
					--VR does not respond
				else
					self.hmiConnection:SendError(data.id, data.method, ErrorCode, "Error message")
				end
			else
				self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
			end	
		end) 
		
		
		--mobile side: expect AddCommand response
		EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
		:Do(function(_,data)
			
			--When AddCommand is returned SUCCESS, SDL will send SetGlobalProperties to UI and TTS.
			
			--hmi side: expect UI.SetGlobalProperties request
			EXPECT_HMICALL("UI.SetGlobalProperties",
			{
				vrHelpTitle = config.application1.registerAppInterfaceParams.appName,
				vrHelp = { 
					{
						text = config.application1.registerAppInterfaceParams.appName,
						position = 1
					} 
				}
				--ToDo: Update detail expected result here.
			})
			:Do(function(_,data)	
				--hmi side: sending UI.SetGlobalProperties response
				self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
			end)
			
			--hmi side: expect TTS.SetGlobalProperties request
			EXPECT_HMICALL("TTS.SetGlobalProperties",
			{
				helpPrompt = 
				{
					{
						text = default_HelpPromt,
						type = "TEXT"
					} 
				}
				--ToDo: Update detail expected result here.
			})		
			:Do(function(_,data)
				--hmi side: sending TTS.SetGlobalProperties response
				self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
			end) 
		end)
		
		
		
		--mobile side: expect OnHashChange notification
		EXPECT_NOTIFICATION("OnHashChange")
		:Do(function(_, data)
			self.currentHashID = data.payload.hashID
		end)
		
	end
	
	
end


local function Req3_APPLINK_23761_AddCommand_FAILED(TestCaseName)
	
	local Interfaces = {"UI", "VR"}
	local ErrorCodes = {
		"INVALID_DATA",
		"REJECTED",
		"DUPLICATE_NAME",
		"DISALLOWED",
		"OUT_OF_MEMORY",
		"TOO_MANY_PENDING_REQUESTS",
		"INVALID_ID",
		"UNSUPPORTED_RESOURCE",
		"WARNINGS",
		"GENERIC_ERROR",
		"APPLICATION_NOT_REGISTERED"
	}
	
	for i = 1, #Interfaces do
		for j =1, #ErrorCodes do
			local TestName = TestCaseName .. "_" .. Interfaces[i] .. "_AddCommand_" .. ErrorCodes[j]
			UI_or_TTS_AddCommand_responds_error(TestName, Interfaces[i], ErrorCodes[j])
		end
		
	end
	
end

Req3_APPLINK_23761_AddCommand_FAILED("Req3_APPLINK_23761")



---------------------------------------------------------------------------------------------
-- req #4: UI/TTS responds error
-- APPLINK-23762 [SetGlobalProperties] SDL sends request by itself and HMI respond with any errorCode
-- Verification criteria:
-- In case
-- 		mobile app does NOT send SetGlobalProperties with <vrHelp> and <helpPrompt> to SDL during 10 sec timer
-- 		and SDL already sends by itself UI/TTS.SetGlobalProperties with values of <vrHelp> and <helpPrompt> from to HMI
-- 		and SDL receives any <errorCode> at response from HMI at least to one TTS/UI.SetGlobalProperties
-- SDL must:
-- 		log corresponding error internally
-- 		continue work as assigned (due to existing requirements)
---------------------------------------------------------------------------------------------


-- This function is used for req 4 and 5: UI/TTS responds errorCode or does not respond
-- ErrorCode = nil: UI/TTS does not respond.
local function UI_or_TTS_responds_error(TestCaseName, Interface, ErrorCode)
	
	--Print new line to separate Preconditions
	commonFunctions:newTestCasesGroup(TestCaseName)		
	
	commonSteps:UnregisterApplication(TestCaseName .. "_Precondition_UnregisterApp")
	commonSteps:RegisterAppInterface(TestCaseName .. "_RegisterApp")
	commonSteps:ActivationApp(_, TestCaseName .. "_ActivationApp")	
	
	
	Test[TestCaseName .. "_NoSGP_from_App_during_10secTimer"] = function(self)
		
		--hmi side: expect UI.SetGlobalProperties request
		EXPECT_HMICALL("UI.SetGlobalProperties",
		{
			vrHelpTitle = config.application1.registerAppInterfaceParams.appName,
			vrHelp = { 
				{
					text = config.application1.registerAppInterfaceParams.appName,
					position = 1
				} 
			}
		})
		
		:Do(function(_,data)
			--hmi side: sending UI.SetGlobalProperties response
			if Interface == "UI" then 
				if ErrorCode == nil then
					--UI does not respond
				else
					self.hmiConnection:SendError(data.id, data.method, ErrorCode, "Error message")
				end
			else
				self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
			end	
			
		end)
		
		--hmi side: expect TTS.SetGlobalProperties request
		EXPECT_HMICALL("TTS.SetGlobalProperties",
		{
			helpPrompt = 
			{
				{
					text = default_HelpPromt,
					type = "TEXT"
				} 
			}
		})
		
		:Do(function(_,data)
			--hmi side: sending TTS.SetGlobalProperties response
			if Interface == "TTS" then
				if ErrorCode == nil then
					--TTS does not respond
				else			
					self.hmiConnection:SendError(data.id, data.method, ErrorCode, "Error message")
				end
			else
				self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
			end	
			
		end) 
		
	end
	
end

local function Req4_APPLINK_23762()
	
	local Interfaces = {"UI", "TTS"}
	local ErrorCodes = {
		"INVALID_DATA",
		"REJECTED",
		"DISALLOWED",
		"USER_DISALLOWED",
		"OUT_OF_MEMORY",
		"TOO_MANY_PENDING_REQUESTS",
		"UNSUPPORTED_RESOURCE",
		"WARNINGS",
		"GENERIC_ERROR",
		"APPLICATION_NOT_REGISTERED",
		-- "POSTPONED (NOT YET IMPLEMENTED)"
	}
	
	for i = 1, #Interfaces do
		for j =1, #ErrorCodes do
			local TestName = "APPLINK_23762_" .. Interfaces[i] .. "_" .. ErrorCodes[j]
			UI_or_TTS_responds_error(TestName, Interfaces[i], ErrorCodes[j])
		end
		
	end
	
end

Req4_APPLINK_23762()


---------------------------------------------------------------------------------------------
-- req #5: UI/TTS does not respond
-- APPLINK-23763 [SetGlobalProperties] SDL sends request by itself and HMI does NOT respond during <DefaultTimeout>
-- Verification criteria:
-- In case
-- 		mobile app does NOT send SetGlobalProperties with <vrHelp> and <helpPrompt> to SDL during 10 sec timer
-- 		and SDL already sends by itself UI/TTS.SetGlobalProperties with values of <vrHelp> and <helpPrompt> to HMI
-- 		and SDL does NOT receive response from HMI at least to one TTS/UI.SetGlobalProperties during <DefaultTimeout> (the value defined at .ini file)
-- SDL must:
-- 		log corresponding error internally
-- 		continue work as assigned (due to existing requirements)
---------------------------------------------------------------------------------------------

local function Req5_APPLINK_23763()
	
	local Interfaces = {"UI", "TTS"}
	
	for i = 1, #Interfaces do
		local TestName = "APPLINK_23763_" .. Interfaces[i]
		UI_or_TTS_responds_error(TestName, Interfaces[i], nil) -- ErrorCode = nil means UI/TTS does not respond.
	end
end

Req5_APPLINK_23763()



---------------------------------------------------------------------------------------------
-------------------------------------------Postconditions------------------------------------
---------------------------------------------------------------------------------------------

function Test:Postcondition_remove_user_connecttest_restore_preloaded_file()
	userPrint(34, "================= Postcondition ==================")
	os.execute(" cp " .. config.pathToSDL .. "sdl_preloaded_pt_origin.json " .. config.pathToSDL .. "sdl_preloaded_pt.json" )
	os.execute(" rm -f " .. config.pathToSDL .. "/sdl_preloaded_pt_origin.json" ) 
end