-- Script is developed by Byanova Irina
-- for ATF version 2.2


Test = require('user_modules/connecttest_without_ExitBySDLDisconnect_WithoutOpenConnectionRegisterApp')
require('cardinalities')
local mobile_session = require('mobile_session')
local tcp = require('tcp_connection')
local file_connection  = require('file_connection')
local mobile  = require('mobile_connection')

----------------------------------------------------------------------------
-- User required files

require('user_modules/AppTypes')
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')

----------------------------------------------------------------------------
-- User required variables

config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

-- Preconditions:
os.execute("sudo bash -ex ./files/CreateConnectionForNewDevice.sh")

local DeviceMacValues = {}

local Connections = {
	{connection = Test.mobileConnection1, session = Test.mobileSession1},
	{connection = Test.mobileConnection2, session = Test.mobileSession2},
	{connection = Test.mobileConnection3, session = Test.mobileSession3},
	{connection = Test.mobileConnection4, session = Test.mobileSession4},
	{connection = Test.mobileConnection5, session = Test.mobileSession5},
	{connection = Test.mobileConnection6, session = Test.mobileSession6},
	{connection = Test.mobileConnection7, session = Test.mobileSession7},
	{connection = Test.mobileConnection8, session = Test.mobileSession8},
	{connection = Test.mobileConnection9, session = Test.mobileSession9},
	{connection = Test.mobileConnection10, session = Test.mobileSession10},
	{connection = Test.mobileConnection11, session = Test.mobileSession11},
	{connection = Test.mobileConnection12, session = Test.mobileSession12},
	{connection = Test.mobileConnection13, session = Test.mobileSession13},
	{connection = Test.mobileConnection14, session = Test.mobileSession14},
	{connection = Test.mobileConnection15, session = Test.mobileSession15},
	{connection = Test.mobileConnection16, session = Test.mobileSession16},
	{connection = Test.mobileConnection17, session = Test.mobileSession17},
	{connection = Test.mobileConnection18, session = Test.mobileSession18},
	{connection = Test.mobileConnection19, session = Test.mobileSession19},
	{connection = Test.mobileConnection20, session = Test.mobileSession20},
	{connection = Test.mobileConnection21, session = Test.mobileSession21},
	{connection = Test.mobileConnection22, session = Test.mobileSession22},
	{connection = Test.mobileConnection23, session = Test.mobileSession23},
	{connection = Test.mobileConnection24, session = Test.mobileSession24},
	{connection = Test.mobileConnection25, session = Test.mobileSession25},
	{connection = Test.mobileConnection26, session = Test.mobileSession26},
	{connection = Test.mobileConnection27, session = Test.mobileSession27},
	{connection = Test.mobileConnection28, session = Test.mobileSession28},
	{connection = Test.mobileConnection29, session = Test.mobileSession29},
	{connection = Test.mobileConnection30, session = Test.mobileSession30},
	{connection = Test.mobileConnection31, session = Test.mobileSession31},
	{connection = Test.mobileConnection32, session = Test.mobileSession32},
	{connection = Test.mobileConnection33, session = Test.mobileSession33},
	{connection = Test.mobileConnection34, session = Test.mobileSession34},
	{connection = Test.mobileConnection35, session = Test.mobileSession35},
	{connection = Test.mobileConnection36, session = Test.mobileSession36},
	{connection = Test.mobileConnection37, session = Test.mobileSession37},
	{connection = Test.mobileConnection38, session = Test.mobileSession38},
	{connection = Test.mobileConnection39, session = Test.mobileSession39},
	{connection = Test.mobileConnection40, session = Test.mobileSession40},
	{connection = Test.mobileConnection41, session = Test.mobileSession41},
	{connection = Test.mobileConnection42, session = Test.mobileSession42},
	{connection = Test.mobileConnection43, session = Test.mobileSession43},
	{connection = Test.mobileConnection44, session = Test.mobileSession44},
	{connection = Test.mobileConnection45, session = Test.mobileSession45},
	{connection = Test.mobileConnection46, session = Test.mobileSession46},
	{connection = Test.mobileConnection47, session = Test.mobileSession47},
	{connection = Test.mobileConnection48, session = Test.mobileSession48},
	{connection = Test.mobileConnection49, session = Test.mobileSession49},
	{connection = Test.mobileConnection50, session = Test.mobileSession50},
	{connection = Test.mobileConnection51, session = Test.mobileSession51},
	{connection = Test.mobileConnection52, session = Test.mobileSession52},
	{connection = Test.mobileConnection53, session = Test.mobileSession53},
	{connection = Test.mobileConnection54, session = Test.mobileSession54},
	{connection = Test.mobileConnection55, session = Test.mobileSession55},
	{connection = Test.mobileConnection56, session = Test.mobileSession56},
	{connection = Test.mobileConnection57, session = Test.mobileSession57},
	{connection = Test.mobileConnection58, session = Test.mobileSession58},
	{connection = Test.mobileConnection59, session = Test.mobileSession59},
	{connection = Test.mobileConnection60, session = Test.mobileSession60},
	{connection = Test.mobileConnection61, session = Test.mobileSession61},
	{connection = Test.mobileConnection62, session = Test.mobileSession62},
	{connection = Test.mobileConnection63, session = Test.mobileSession63},
	{connection = Test.mobileConnection64, session = Test.mobileSession64},
	{connection = Test.mobileConnection65, session = Test.mobileSession65},
	{connection = Test.mobileConnection66, session = Test.mobileSession66},
	{connection = Test.mobileConnection67, session = Test.mobileSession67},
	{connection = Test.mobileConnection68, session = Test.mobileSession68},
	{connection = Test.mobileConnection69, session = Test.mobileSession69},
	{connection = Test.mobileConnection70, session = Test.mobileSession70},
	{connection = Test.mobileConnection71, session = Test.mobileSession71},
	{connection = Test.mobileConnection72, session = Test.mobileSession72},
	{connection = Test.mobileConnection73, session = Test.mobileSession73},
	{connection = Test.mobileConnection74, session = Test.mobileSession74},
	{connection = Test.mobileConnection75, session = Test.mobileSession75},
	{connection = Test.mobileConnection76, session = Test.mobileSession76},
	{connection = Test.mobileConnection77, session = Test.mobileSession77},
	{connection = Test.mobileConnection78, session = Test.mobileSession78},
	{connection = Test.mobileConnection79, session = Test.mobileSession79},
	{connection = Test.mobileConnection80, session = Test.mobileSession80},
	{connection = Test.mobileConnection81, session = Test.mobileSession81},
	{connection = Test.mobileConnection82, session = Test.mobileSession82},
	{connection = Test.mobileConnection83, session = Test.mobileSession83},
	{connection = Test.mobileConnection84, session = Test.mobileSession84},
	{connection = Test.mobileConnection85, session = Test.mobileSession85},
	{connection = Test.mobileConnection86, session = Test.mobileSession86},
	{connection = Test.mobileConnection87, session = Test.mobileSession87},
	{connection = Test.mobileConnection88, session = Test.mobileSession88},
	{connection = Test.mobileConnection89, session = Test.mobileSession89},
	{connection = Test.mobileConnection90, session = Test.mobileSession90},
	{connection = Test.mobileConnection91, session = Test.mobileSession91},
	{connection = Test.mobileConnection92, session = Test.mobileSession92},
	{connection = Test.mobileConnection93, session = Test.mobileSession93},
	{connection = Test.mobileConnection94, session = Test.mobileSession94},
	{connection = Test.mobileConnection95, session = Test.mobileSession95},
	{connection = Test.mobileConnection96, session = Test.mobileSession96},
	{connection = Test.mobileConnection97, session = Test.mobileSession97},
	{connection = Test.mobileConnection98, session = Test.mobileSession98},
	{connection = Test.mobileConnection99, session = Test.mobileSession99},
	{connection = Test.mobileConnection100, session = Test.mobileSession100},
	{connection = Test.mobileConnection101, session = Test.mobileSession101},
}

local deviceListArray = {}


---------------------------------------------------------------------------------------------
------------------------------------------Common functions-----------------------------------
---------------------------------------------------------------------------------------------

-- App registration
local function RegisterApp(self, RegisterData)

  local correlationId = self.mobileSession:SendRPC("RegisterAppInterface", RegisterData)

  EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered")
    :Do(function(_,data)
     self.HMIAppID = data.params.application.appID
    end)

  self.mobileSession:ExpectResponse(correlationId, { success = true, resultCode = "SUCCESS" })


  self.mobileSession:ExpectNotification("OnHMIStatus",
    {hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
end

-- Check direcrory existence
local function Directory_exist(DirectoryPath)
	local returnValue

	local Command = assert( io.popen(  "[ -d " .. tostring(DirectoryPath) .. " ] && echo \"Exist\" || echo \"NotExist\"" , 'r'))
	local CommandResult = tostring(Command:read( '*l' ))

	if
		CommandResult == "NotExist" then
			returnValue = false
	elseif
		CommandResult == "Exist" then
		returnValue =  true
	else
		commonFunctions:userPrint(31," Some unexpected result in Directory_exist function, CommandResult = " .. tostring(CommandResult))
		returnValue = false
	end

	return returnValue
end


local function RestartSDL(prefix, DeleteStorageFolder)

	Test["StopSDL_" .. tostring(prefix) ] = function(self)
		commonFunctions:userPrint(35, "\n================= Precondition ==================")
		StopSDL()
	end

	if DeleteStorageFolder then
		Test["DeleteStorageFolder_" .. tostring(prefix)] = function(self)
			local ExistDirectoryResult = Directory_exist( tostring(config.pathToSDL .. "storage"))
			if ExistDirectoryResult == true then
				local RmFolder  = assert( os.execute( "rm -rf " .. tostring(config.pathToSDL .. "storage" )))
				if RmFolder ~= true then
					commonFunctions:userPrint(31, "Folder 'storage' is not deleted")
				end
			else
				commonFunctions:userPrint(33, "Folder 'storage' is absent")
			end
		end
	end

	Test["StartSDL_" .. tostring(prefix) ] = function(self)
		StartSDL(config.pathToSDL, config.ExitOnCrash)
	end

	Test["InitHMI_" .. tostring(prefix) ] = function(self)
		self:initHMI()
	end

	Test["InitHMI_onReady_" .. tostring(prefix) ] = function(self)
		self:initHMI_onReady()
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

-- Consent device
function ConsentDevice(self, allowedValue, idValue, nameValue)
	--hmi side: sending SDL.GetUserFriendlyMessage request
	local RequestId = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage",
						{language = "EN-US", messageCodes = {"DataConsent"}})

	--hmi side: expect SDL.GetUserFriendlyMessage response
	--TODO: Update after resolving APPLINK-16094 EXPECT_HMIRESPONSE(RequestId,{result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
	EXPECT_HMIRESPONSE(RequestId)
		:Do(function(_,data)

			--hmi side: send request SDL.OnAllowSDLFunctionality
			self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality",
				{allowed = allowedValue, source = "GUI", device = {id = idValue, name = nameValue}})
		end)
end

local function DataBaseQuery(self,  DBQueryV)
	local i = 0
	local DBQueryValue
	repeat
	 	i= i+1
		os.execute(" sleep 1 ")
		local DBQuery = "sqlite3 " .. tostring(config.pathToSDL) .. "storage/policy.sqlite \"" .. tostring(DBQueryV) .. "\""

		local aHandle = assert( io.popen( DBQuery , 'r'))

		DBQueryValue = aHandle:read( '*l' )

		if i == 10 then
			break
		end
	print(".")
	until DBQueryValue ~= "" or DBQueryValue ~= " "

	if
		DBQueryValue == "" or DBQueryValue == " " then
		return false
	else
		return DBQueryValue
	end
end

local function CheckArrayValues(elementValue)
	for j=1, #DeviceMacValues do
		if elementValue == DeviceMacValues[j] then
			commonFunctions:userPrint(31, " Duplicated DeviceMAC values. Such device is is already existed!" )
		end
	end
end

-----------------------------------------------------------------------------------------------
-------------------------------------------TEST BLOCK I----------------------------------------
--------------------------------Check normal cases of Mobile request---------------------------
-----------------------------------------------------------------------------------------------

--Not Applicable


----------------------------------------------------------------------------------------------
-----------------------------------------TEST BLOCK II----------------------------------------
-----------------------------Check special cases of Mobile request----------------------------
----------------------------------------------------------------------------------------------

--Not Applicable

-----------------------------------------------------------------------------------------------
-------------------------------------------TEST BLOCK III--------------------------------------
---------------------------------Check normal cases of HMI response----------------------------
-----------------------------------------------------------------------------------------------

commonFunctions:newTestCasesGroup("Normal cases of HMI response with different result codes")

local resultCodes = {"SUCCESS", "UNSUPPORTED_REQUEST", "UNSUPPORTED_RESOURCE", "DISALLOWED", "REJECTED", "ABORTED", "IGNORED", "TIMED_OUT", "INVALID_DATA", "INVALID_ID", "OUT_OF_MEMORY", "TOO_MANY_PENDING_REQUESTS", "WARNINGS", "GENERIC_ERROR", "USER_DISALLOWED"}

for i=1, #resultCodes do
	Test[ "UpdateDeviceListResponse_" .. tostring(resultCodes[i]) ] = function(self)
		self.hmiConnection:SendNotification("BasicCommunication.OnStartDeviceDiscovery")

		EXPECT_HMICALL("BasicCommunication.UpdateDeviceList")
			:Do(function(_,data)
				if resultCodes[i] == "SUCCESS" then
					self.hmiConnection:SendResponse(data.id, data.method, resultCodes[i], { })
				else
					self.hmiConnection:SendError(data.id, data.method, resultCodes[i], " Error message " )
				end
			end)

		DelayedExp(1000)
	end
end

----------------------------------------------------------------------------------------------
-----------------------------------------TEST BLOCK IV----------------------------------------
----------------------------Check special cases of HMI response---------------------------
----------------------------------------------------------------------------------------------
commonFunctions:newTestCasesGroup("Special cases of HMI response")
--Requirement id in JAMA or JIRA:
	--APPLINK-14765: SDL must cut off the fake parameters from requests, responses and notifications received from HMI

-----------------------------------------------------------------------------------------------

--List of test cases for special cases of HMI response:
	--1. InvalidJsonSyntax
	--2. InvalidStructure
	--3. FakeParams
	--4. FakeParameterIsFromAnotherAPI
	--5. MissedmandatoryParameters
	--6. MissedAllParameters
	--7. SeveralResponses with the same values
	--8. SeveralResponses with different values
----------------------------------------------------------------------------------------------
local event = events.Event()
----------------------------------------------------------------------------------------------
-- InvalidJsonSyntax
function Test:UpdateDeviceListResponse_InvalidJsonSyntax()
	self.hmiConnection:SendNotification("BasicCommunication.OnStartDeviceDiscovery")

	EXPECT_HMICALL("BasicCommunication.UpdateDeviceList")
		:Do(function(_,data)
			--<<!-- missing ':' after id
			self.hmiConnection:Send('{"id"'..tostring(data.id)..',"jsonrpc":"2.0","result":{"method":"BasicCommunication.UpdateDeviceList", "code":0}}')
		end)

	DelayedExp(1000)
end

----------------------------------------------------------------------------------------------
-- InvalidStructure
function Test:UpdateDeviceListResponse_InvalidStructure()
	self.hmiConnection:SendNotification("BasicCommunication.OnStartDeviceDiscovery")

	EXPECT_HMICALL("BasicCommunication.UpdateDeviceList")
		:Do(function(_,data)
			--<<!-- method is not in result struct
			self.hmiConnection:Send('{"id":'..tostring(data.id)..',"jsonrpc":"2.0","method":"BasicCommunication.UpdateDeviceList", "result":{"code":0}}')
		end)

	DelayedExp(1000)
end


----------------------------------------------------------------------------------------------
-- FakeParams
function Test:UpdateDeviceListResponse_FakeParams()
	self.hmiConnection:SendNotification("BasicCommunication.OnStartDeviceDiscovery")

	EXPECT_HMICALL("BasicCommunication.UpdateDeviceList")
		:Do(function(_,data)
			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", { fake = "fake" })
		end)

	DelayedExp(1000)
end

----------------------------------------------------------------------------------------------
-- FakeParameterIsFromAnotherAPI
function Test:UpdateDeviceListResponse_FakeParameterIsFromAnotherAPI()
	self.hmiConnection:SendNotification("BasicCommunication.OnStartDeviceDiscovery")

	EXPECT_HMICALL("BasicCommunication.UpdateDeviceList")
		:Do(function(_,data)
			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", { sliderPosition = 5 })
		end)

	DelayedExp(1000)
end

----------------------------------------------------------------------------------------------
-- MissedmandatoryParameters: id
function Test:UpdateDeviceListResponse_missed_id()
	self.hmiConnection:SendNotification("BasicCommunication.OnStartDeviceDiscovery")

	EXPECT_HMICALL("BasicCommunication.UpdateDeviceList")
		:Do(function(_,data)
			self.hmiConnection:Send('{"jsonrpc":"2.0","result":{"method":"BasicCommunication.UpdateDeviceList", "code":0}}')
		end)

	DelayedExp(1000)
end

----------------------------------------------------------------------------------------------
-- MissedmandatoryParameters: method
function Test:UpdateDeviceListResponse_missed_method()
	self.hmiConnection:SendNotification("BasicCommunication.OnStartDeviceDiscovery")

	EXPECT_HMICALL("BasicCommunication.UpdateDeviceList")
		:Do(function(_,data)
			self.hmiConnection:Send('{"id":'..tostring(data.id)..', "jsonrpc":"2.0","result":{"code":0}}')
		end)

	DelayedExp(1000)
end

----------------------------------------------------------------------------------------------
-- MissedmandatoryParameters: code
function Test:UpdateDeviceListResponse_missed_code()
	self.hmiConnection:SendNotification("BasicCommunication.OnStartDeviceDiscovery")

	EXPECT_HMICALL("BasicCommunication.UpdateDeviceList")
		:Do(function(_,data)
			self.hmiConnection:Send('{"id":'..tostring(data.id)..', "jsonrpc":"2.0","result":{"method":"BasicCommunication.UpdateDeviceList"}}')
		end)

	DelayedExp(1000)
end

----------------------------------------------------------------------------------------------
-- MissedmandatoryParameters: result
function Test:UpdateDeviceListResponse_missed_result()
	self.hmiConnection:SendNotification("BasicCommunication.OnStartDeviceDiscovery")

	EXPECT_HMICALL("BasicCommunication.UpdateDeviceList")
		:Do(function(_,data)
			self.hmiConnection:Send('{"id":'..tostring(data.id)..', "jsonrpc":"2.0"')
		end)

	DelayedExp(1000)
end

----------------------------------------------------------------------------------------------
-- MissedAllParameters
function Test:UpdateDeviceListResponse_MissedAllParameters()
	self.hmiConnection:SendNotification("BasicCommunication.OnStartDeviceDiscovery")

	EXPECT_HMICALL("BasicCommunication.UpdateDeviceList")
		:Do(function(_,data)
			self.hmiConnection:Send('{}')
		end)

	DelayedExp(1000)
end

----------------------------------------------------------------------------------------------
-- SeveralResponses with the same values
function Test:UpdateDeviceListResponse_SameSeveralResponses()
	self.hmiConnection:SendNotification("BasicCommunication.OnStartDeviceDiscovery")

	EXPECT_HMICALL("BasicCommunication.UpdateDeviceList")
		:Do(function(_,data)
			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
		end)

	DelayedExp(1000)
end

----------------------------------------------------------------------------------------------
-- SeveralResponses with different values
function Test:UpdateDeviceListResponse_DifferentSeveralResponses()
	self.hmiConnection:SendNotification("BasicCommunication.OnStartDeviceDiscovery")

	EXPECT_HMICALL("BasicCommunication.UpdateDeviceList")
		:Do(function(_,data)
			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
			self.hmiConnection:SendResponse(data.id, data.method, "INVALID_DATA", {})
		end)

	DelayedExp(1000)
end

-----------------------------------------------------------------------------------------------
-------------------------------------------TEST BLOCK V----------------------------------------
-------------------------------------Checks All Result Codes-----------------------------------
-----------------------------------------------------------------------------------------------

--Not applicable

----------------------------------------------------------------------------------------------
-----------------------------------------TEST BLOCK VI----------------------------------------
-------------------------Sequence with emulating of user's action(s)--------------------------
----------------------------------------------------------------------------------------------
commonFunctions:newTestCasesGroup("Sequence with emulating of user's action(s)")

--======================================================================================--
--Initial precondition: Restart SDL
RestartSDL("InitialPrecondition", true)

-- APPLINK-18432: 01[P][MAN]_TC_SDL_sends_empty_deviceList
--======================================================================================--
-- SDL sends empty "deviceList" parameter in UpdateDeviceList request if no Apps were found during BT scan
--======================================================================================--

function Test:UpdateDeviceList_EmptyDeviceList()
	commonFunctions:userPrint(34, "=================== Test Case ===================")
	self.hmiConnection:SendNotification("BasicCommunication.OnStartDeviceDiscovery")

	EXPECT_HMICALL("BasicCommunication.UpdateDeviceList")
		:Do(function(_,data)
			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
		end)
		:ValidIf(function(_,data)
			if #data.params.deviceList ~= 0 then
				commonFunctions:userPrint(31, "deviceList array in UpdateDeviceList is not empty. Received elements number '" .. tostring(#data.params.deviceList) .. "'")
				return false
			else
			    return true
			end
		end)
end


-- APPLINK-18433: 02[P][MAN]_TC_SDL_sends_non-empty_deviceList
--======================================================================================--
-- SDL sends non-empty "deviceList" parameter in UpdateDeviceList request if no Apps were found during BT scan.
--======================================================================================--

function Test:ConnectDevice_NonEmptyDeviceList()
	commonFunctions:userPrint(35, "\n================= Precondition ==================")
	self:connectMobile()

	EXPECT_HMICALL("BasicCommunication.UpdateDeviceList",
		{
			deviceList = {
				{
					id = config.deviceMAC,
					isSDLAllowed = false,
					name = "127.0.0.1",
					transportType = "WIFI"
				}
			}
		})
		:Do(function(_,data)
			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
		end)
end

function Test:UpdateDeviceList_NonEmptyDeviceList()
	commonFunctions:userPrint(34, "=================== Test Case ===================")
	self.hmiConnection:SendNotification("BasicCommunication.OnStartDeviceDiscovery")

	EXPECT_HMICALL("BasicCommunication.UpdateDeviceList",
		{
			deviceList = {
				{
					id = config.deviceMAC,
					isSDLAllowed = false,
					name = "127.0.0.1",
					transportType = "WIFI"
				}
			}
		})
		:DoOnce(function(_,data)
			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})

			self.hmiConnection:SendNotification("BasicCommunication.OnDeviceChosen",
				{
					deviceInfo = {
						id = data.params.deviceList[1].id,
						name = data.params.deviceList[1].name
					}
				})

			self.hmiConnection:SendNotification("BasicCommunication.OnFindApplications",
				{
					deviceInfo = {
						id = data.params.deviceList[1].id,
						name = data.params.deviceList[1].name
					}
				})

		end)
		:ValidIf(function(_,data)
			if #data.params.deviceList ~= 1 then
				commonFunctions:userPrint(31, "deviceList array in UpdateDeviceList contains not one device in list. Received elements number '" .. tostring(#data.params.deviceList) .. "'")
				return false
			else
			    return true
			end
		end)

	EXPECT_HMICALL("BasicCommunication.UpdateAppList")
		:ValidIf(function(_,data)
			if #data.params.applications ~= 0 then
				commonFunctions:userPrint(31, "Number of applications in UpdateAppList in not 0, received number '" .. tostring(#data.params.applications) .. "'")
				return false
			else
				return true
			end
		end)
end

-- APPLINK-18434: 03[P][MAN]_TC_SDL_sends_empty_deviceList_no_BT_device_connected_during_scan
--======================================================================================--
-- SDL sends empty "deviceList" parameter in UpdateDeviceList request if no one BT device is connected during scan
--======================================================================================--

function Test:CloseConnection()
	commonFunctions:userPrint(35, "\n================= Precondition ==================")
	self.mobileConnection:Close()

	DelayedExp(1000)
end

function Test:UpdateDeviceList_EmptyDeviceList_AfterConnectionIsClosed()
	commonFunctions:userPrint(34, "=================== Test Case ===================")
	self.hmiConnection:SendNotification("BasicCommunication.OnStartDeviceDiscovery")

	EXPECT_HMICALL("BasicCommunication.UpdateDeviceList")
		:Do(function(_,data)
			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
		end)
		:ValidIf(function(_,data)
			if #data.params.deviceList ~= 0 then
				commonFunctions:userPrint(31, "deviceList array in UpdateDeviceList is not empty. Received elements number '" .. tostring(#data.params.deviceList) .. "'")
				return false
			else
			    return true
			end
		end)

end

-- APPLINK-18434: 03[P][MAN]_TC_SDL_sends_empty_deviceList_no_BT_device_connected_during_scan
--======================================================================================--
-- SDL sends empty "deviceList" parameter in UpdateDeviceList request if no one BT device is connected during scan and in previous cycles the were some connected devices.
--======================================================================================--

--======================================================================================--
--Precondition: Restart SDL
RestartSDL("Initial_InPreviosIGNCycleWasConnectedDevice")


--======================================================================================--
-- Precondition: Check UpdateDeviceList after connection device
function Test:UpdateDeviceList_InPreviosIGNCycleWasConnectedDevice()
	-- connect device
	self:connectMobile()

	EXPECT_HMICALL("BasicCommunication.UpdateDeviceList",
		{
			deviceList = {
				{
					id = config.deviceMAC,
					isSDLAllowed = false,
					name = "127.0.0.1",
					transportType = "WIFI"
				}
			}
		})
		:DoOnce(function(_,data)
			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})

		end)
		:ValidIf(function(_,data)
			if #data.params.deviceList ~= 1 then
				commonFunctions:userPrint(31, "deviceList array in UpdateDeviceList contains not one device in list. Received elements number '" .. tostring(#data.params.deviceList) .. "'")
				return false
			else
			    return true
			end
		end)


end

--======================================================================================--
--Precondition: Restart SDL
RestartSDL("InPreviosIGNCycleWasConnectedDevice")


--======================================================================================--
-- SDL sends empty UpdateDeviceList in case some devicewas connected in previos ignition cycle
function Test:UpdateDeviceList_EmptyDeviceList_InPreviosIGNCycleWasConnectedDevice()
	commonFunctions:userPrint(34, "=================== Test Case ===================")
	self.hmiConnection:SendNotification("BasicCommunication.OnStartDeviceDiscovery")

	EXPECT_HMICALL("BasicCommunication.UpdateDeviceList")
		:Do(function(_,data)
			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
		end)
		:ValidIf(function(_,data)
			if #data.params.deviceList ~= 0 then
				commonFunctions:userPrint(31, "deviceList array in UpdateDeviceList is not empty. Received elements number '" .. tostring(#data.params.deviceList) .. "'")
				return false
			else
			    return true
			end
		end)

end


-- APPLINK-18168: 16[P][MAN]_TC_IsSDLAllowed_in_DeviceInfo_saved_after_igni_cycle
--======================================================================================--
-- IsSDLAllowed value in DeviceInfo of device (w/o started apps on it) saved correctly after ignition_cycle (expected behavior under clarifying APPLINK-11862).
--======================================================================================--

--Precondition: Restart SDL, delete storage folder
RestartSDL("DeleteStorageFolder_AfterDeviceIsAllowed", true)

function Test:ConnectMobile_AfterDeviceIsAllowed()
	self:connectMobile()

	DelayedExp(1500)
end

--======================================================================================--
function Test:UpdateDeviceLisat_AfterDeviceIsAllowed()
	commonFunctions:userPrint(34, "=================== Test Case ===================")
	self.hmiConnection:SendNotification("BasicCommunication.OnStartDeviceDiscovery")

	EXPECT_HMICALL("BasicCommunication.UpdateDeviceList",
		{
			deviceList = {
				{
					id = config.deviceMAC,
					isSDLAllowed = false,
					name = "127.0.0.1",
					transportType = "WIFI"
				}
			}
		},
		{
			deviceList = {
				{
					id = config.deviceMAC,
					isSDLAllowed = true,
					name = "127.0.0.1",
					transportType = "WIFI"
				}
			}
		})
		:Do(function(exp,data)
			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})

				if exp.occurences == 1 then

					local deviceIdPTValue = DataBaseQuery(self, "SELECT id FROM device WHERE rowid = 1")

				    if not deviceIdPTValue then
				    	self:FailTestCase(" DB query to device.id is failed")
				    elseif deviceIdPTValue ~= config.deviceMAC then
				    	self:FailTestCase("Device id in PT is unexpected = '" .. tostring(deviceIdPTValue) ..  "', expected value is '" .. tostring(config.deviceMAC) .. "'")
				    end

					self.hmiConnection:SendNotification("BasicCommunication.OnDeviceChosen",
						{
							deviceInfo = {
								id = data.params.deviceList[1].id,
								name = data.params.deviceList[1].name
							}
						})

					ConsentDevice(self, true, data.params.deviceList[1].id, data.params.deviceList[1].name)

					local function DeviceDiscovery()

						self.hmiConnection:SendNotification("BasicCommunication.OnStartDeviceDiscovery")
					end

					RUN_AFTER(DeviceDiscovery, 500)

				elseif
					exp.occurences == 2 then

						local function DBQuery()

							local IsConsentedPTValue = DataBaseQuery(self, "SELECT is_consented FROM device_consent_group WHERE rowid = 1")

							if not IsConsentedPTValue then
						    	self:FailTestCase(" DB query to device_consent_group.is_consented is failed")
							elseif tonumber(IsConsentedPTValue) ~= 1 then
					    		self:FailTestCase("is_consent value in PT is unexpected = '" .. tostring(IsConsentedPTValue) ..  "', expected value is '1'")
					    	end
						end

						RUN_AFTER(DBQuery, 1500)
				end

		end)
		:ValidIf(function(_,data)
			if #data.params.deviceList ~= 1 then
				commonFunctions:userPrint(31, "deviceList array in UpdateDeviceList contains not one device in list. Received elements number '" .. tostring(#data.params.deviceList) .. "'")
				return false
			else
			    return true
			end
		end)
		:Times(2)

	DelayedExp(5000)
end

--======================================================================================--
--Precondition: Restart SDL
RestartSDL("AfterIGNOFF_ConsentedDevice")

--======================================================================================--
function Test:ConnectMobile_AfterIGNOFF_ConsentedDevice()
	self:connectMobile()

	DelayedExp(1500)
end

--======================================================================================--
function Test:UpdateDeviceList_AfterIGNOFF_ConsentedDevice()
	commonFunctions:userPrint(34, "=================== Test Case ===================")

	self.hmiConnection:SendNotification("BasicCommunication.OnStartDeviceDiscovery")

	EXPECT_HMICALL("BasicCommunication.UpdateDeviceList",
		{
			deviceList = {
				{
					id = config.deviceMAC,
					isSDLAllowed = true,
					name = "127.0.0.1",
					transportType = "WIFI"
				}
			}
		})
		:Do(function(exp,data)
			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})

			local IsConsentedPTValue
			local deviceIdPTValue
			local ErrorMessage = ""

			deviceIdPTValue = DataBaseQuery(self, "SELECT id FROM device WHERE rowid = 1")

			IsConsentedPTValue = DataBaseQuery(self, "SELECT is_consented FROM device_consent_group WHERE rowid = 1")

			if not deviceIdPTValue then
				ErrorMessage = ErrorMessage .. "DB query to device.id is failed"
			elseif
				deviceIdPTValue ~= config.deviceMAC then
				    ErrorMessage = ErrorMessage .. "Device id in PT is unexpected = '" .. tostring(deviceIdPTValue) ..  "', expected value is '." .. tostring(config.deviceMAC) .. "'"
			end

			if not IsConsentedPTValue then
				ErrorMessage = ErrorMessage .. "DB query to device_consent_group.is_consented is failed"
			elseif
				tonumber(IsConsentedPTValue) ~= 1 then
	    			ErrorMessage = ErrorMessage .. " is_consent value in PT is unexpected = '" .. tostring(IsConsentedPTValue) ..  "', expected value is '1'"
	    	end

	    	if ErrorMessage and
	    		ErrorMessage ~= "" then
	    		self:FailTestCase(ErrorMessage)
	    	end


		end)

end

--======================================================================================--
-- IsSDLAllowed value in DeviceInfo of device (w/o started apps on it) after Device is not consented
--======================================================================================--

--Precondition: Restart SDL
RestartSDL("NotConsentedDevice")

function Test:ConnectMobile_NotConsentedDevice()
	self:connectMobile()

	DelayedExp(1500)
end

function Test:CheckDeviceStatus_NotConsentedDevice()

	self.hmiConnection:SendNotification("BasicCommunication.OnStartDeviceDiscovery")

	EXPECT_HMICALL("BasicCommunication.UpdateDeviceList",
		{
			deviceList = {
				{
					id = config.deviceMAC,
					name = "127.0.0.1",
					transportType = "WIFI"
				}
			}
		})
		:Do(function(_,data)
			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})

			if data.params.deviceList[1].isSDLAllowed ~= true then
				ConsentDevice(self, true, data.params.deviceList[1].id, data.params.deviceList[1].name)
			end
		end)

	DelayedExp(1500)

end

function Test:UpdateDeviceList_NotConsentedDevice()
	commonFunctions:userPrint(34, "=================== Test Case ===================")
	self.hmiConnection:SendNotification("BasicCommunication.OnStartDeviceDiscovery")

	EXPECT_HMICALL("BasicCommunication.UpdateDeviceList",
		{
			deviceList = {
				{
					id = config.deviceMAC,
					isSDLAllowed = true,
					name = "127.0.0.1",
					transportType = "WIFI"
				}
			}
		},
		{
			deviceList = {
				{
					id = config.deviceMAC,
					isSDLAllowed = false,
					name = "127.0.0.1",
					transportType = "WIFI"
				}
			}
		})
		:Do(function(exp,data)
			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})

				if exp.occurences == 1 then

					local deviceIdPTValue = DataBaseQuery(self, "SELECT id FROM device WHERE rowid = 1")

				    if not deviceIdPTValue then
				    	self:FailTestCase(" DB query to device.id is failed")
				    elseif
				    	deviceIdPTValue ~= config.deviceMAC then
				    	self:FailTestCase("Device id in PT is unexpected = '" .. tostring(deviceIdPTValue) ..  "', expected value is '" .. tostring(config.deviceMAC) .. "'")
				    end

					self.hmiConnection:SendNotification("BasicCommunication.OnDeviceChosen",
						{
							deviceInfo = {
								id = data.params.deviceList[1].id,
								name = data.params.deviceList[1].name
							}
						})

					ConsentDevice(self, false, data.params.deviceList[1].id, data.params.deviceList[1].name)

					local function DeviceDiscovery()

						self.hmiConnection:SendNotification("BasicCommunication.OnStartDeviceDiscovery")
					end

					RUN_AFTER(DeviceDiscovery, 500)

				elseif
					exp.occurences == 2 then

						local function DBQuery()
							local IsConsentedPTValue = DataBaseQuery(self, "SELECT is_consented FROM device_consent_group WHERE rowid = 1")

							if tonumber(IsConsentedPTValue) ~= 0 then
					    		self:FailTestCase("is_consent value in PT is unexpected = '" .. tostring(IsConsentedPTValue) ..  "', expected value is '0'")
					    	end
						end

						RUN_AFTER(DBQuery, 1500)
				end

		end)
		:ValidIf(function(_,data)
			if #data.params.deviceList ~= 1 then
				commonFunctions:userPrint(31, "deviceList array in UpdateDeviceList contains not one device in list. Received elements number '" .. tostring(#data.params.deviceList) .. "'")
				return false
			else
			    return true
			end
		end)
		:Times(2)

	DelayedExp(4000)
end


--======================================================================================--
-- UpdateDeviceList after clossing connnection on device with registered app
--======================================================================================--

--Precondition: Restart SDL, delete storage folder
RestartSDL("DeleteStorageFolder_AfterClosingConnectionWithRegisteredApp", true)

function Test:ConnectMobile_AfterClosingConnectionWithRegisteredApp()
	self:connectMobile()

	EXPECT_HMICALL("BasicCommunication.UpdateDeviceList",
		{
			deviceList = {
				{
					id = config.deviceMAC,
					isSDLAllowed = false,
					name = "127.0.0.1",
					transportType = "WIFI"
				}
			}
		})
	:Do(function()
		self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})

		ConsentDevice(self, true, config.deviceMAC, "127.0.0.1")
	end)

	DelayedExp(1500)
end

function Test:RegisterApplication()
	self.mobileSession = mobile_session.MobileSession(
	      self,
	      self.mobileConnection)

	self.mobileSession:StartService(7)
	:Do(function()
		RegisterApp(self, config.application1.registerAppInterfaceParams)

		EXPECT_HMICALL("BasicCommunication.UpdateDeviceList")
			:Times(0)

		DelayedExp(1000)
	end)
end

function Test:UpdateDeviceList_AfterClosingConnectionWithRegisteredApp()
	commonFunctions:userPrint(34, "=================== Test Case ===================")
	-- close connection
	self.mobileConnection:Close()

	EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered", {unexpectedDisconnect = true})

	EXPECT_HMICALL("BasicCommunication.UpdateAppList")
			:Do(function(_,data)
				self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
			end)
			:ValidIf(function(_,data)
				if #data.params.applications ~= 0 then
					commonFunctions:userPrint(31, "applications array in UpdateAppList is not empty. Received elements number '" .. tostring(#data.params.applications) .. "'")
					return false
				else
				    return true
				end
			end)


	local function DeviceDiscovery()

		self.hmiConnection:SendNotification("BasicCommunication.OnStartDeviceDiscovery")

		EXPECT_HMICALL("BasicCommunication.UpdateDeviceList")
			:Do(function(_,data)
				self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
			end)
			:ValidIf(function(_,data)
				if #data.params.deviceList ~= 0 then
					commonFunctions:userPrint(31, "deviceList array in UpdateDeviceList is not empty. Received elements number '" .. tostring(#data.params.deviceList) .. "'")
					return false
				else
				    return true
				end
			end)
	end

	RUN_AFTER(DeviceDiscovery, 1000)

	DelayedExp(2000)
end


--======================================================================================--
-- Different "deviceID" values in UpdateDeviceList for devices connected via WiFi
--======================================================================================--
--Precondition: Restart SDL, delete storage folder
RestartSDL("DeleteStorageFolder_DifferentDeviceId", true)

function Test:CreateFirstConnection_DifferentDeviceId()
	self:connectMobile()

	EXPECT_HMICALL("BasicCommunication.UpdateDeviceList",
		{
			deviceList = {
				{
					id = config.deviceMAC,
					isSDLAllowed = false,
					name = "127.0.0.1",
					transportType = "WIFI"
				}
			}
		})
		:Do(function(_,data)
			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
		end)
end

function Test:UpdateDeviceList_DifferentDeviceId()
	commonFunctions:userPrint(34, "=================== Test Case ===================")
	local tcpConnection = tcp.Connection("1.0.0.1", config.mobilePort)
    local fileConnection = file_connection.FileConnection("mobile.out", tcpConnection)
    self.mobileConnection2 = mobile.MobileConnection(fileConnection)
    self.mobileSession2= mobile_session.MobileSession(
    self,
    self.mobileConnection2)
    event_dispatcher:AddConnection(self.mobileConnection2)
    self.mobileSession2:ExpectEvent(events.connectedEvent, "Connection started")
    self.mobileConnection2:Connect()

    EXPECT_HMICALL("BasicCommunication.UpdateDeviceList",
		{
			deviceList = {
				{
					id = config.deviceMAC,
					isSDLAllowed = false,
					name = "127.0.0.1",
					transportType = "WIFI"
				},
				{
					id = "54286cb92365be544aa7008b92854b9648072cf8d8b17b372fd0786bef69d7a2",
					isSDLAllowed = false,
					name = "1.0.0.1",
					transportType = "WIFI"
				}
			}
		})
		:Do(function(_,data)
			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
		end)
end


--======================================================================================--
-- Device is still present in UpdateDeviceList after all apps are unregistered
--======================================================================================--
--Precondition: Restart SDL, delete storage folder
RestartSDL("DeleteStorageFolder_afterAllAppsAreUnregisteredFromDevice", true)

function Test:CreateConnection_afterAllAppsAreUnregisteredFromDevice()
	self:connectMobile()
end

function Test:RegisterApplication_afterAllAppsAreUnregisteredFromDevice()
	self.mobileSession = mobile_session.MobileSession(
	      self,
	      self.mobileConnection)

	self.mobileSession:StartService(7)
	:Do(function()
		RegisterApp(self, config.application1.registerAppInterfaceParams)
	end)
end

function Test:UpdateDeviceList_afterAllAppsAreUnregisteredFromDevice()
	commonFunctions:userPrint(34, "=================== Test Case ===================")
	--mobile side: UnregisterAppInterface request
  	local CorIdURAI = self.mobileSession:SendRPC("UnregisterAppInterface", {})

  	--hmi side: expected  BasicCommunication.OnAppUnregistered
  	EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered", {unexpectedDisconnect = false})

  	--mobile side: UnregisterAppInterface response
  	self.mobileSession:ExpectResponse("UnregisterAppInterface", {success = true , resultCode = "SUCCESS"})
  	:Do(function()

  		-- Close session
  		self.mobileSession:Stop()

  		local function DeviceDiscovery()

			self.hmiConnection:SendNotification("BasicCommunication.OnStartDeviceDiscovery")

			EXPECT_HMICALL("BasicCommunication.UpdateDeviceList",
			{
				deviceList = {
					{
						id = config.deviceMAC,
						isSDLAllowed = false,
						name = "127.0.0.1",
						transportType = "WIFI"
					}
				}
			})
			:Do(function(_,data)
				self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
			end)
		end

		RUN_AFTER(DeviceDiscovery, 1000)
  	end)

  	EXPECT_HMICALL("BasicCommunication.UpdateAppList")
		:Do(function(_,data)
			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
		end)
		:ValidIf(function(_,data)
			if #data.params.applications ~= 0 then
				commonFunctions:userPrint(31, "applications array in UpdateAppList is not empty. Received elements number '" .. tostring(#data.params.applications) .. "'")
				return false
			else
			    return true
			end
		end)

	DelayedExp(3000)
end


--======================================================================================--
-- Connect 101 device, UpdateDeviceListAfter each connection, 101 element is out bound value for deviceList array
--======================================================================================--
-- Precondition restart SDL, delete storage folder
RestartSDL("Connection101Devices", true )

--Connect 101 device
for i=1, 101 do
	Test["UpdateDeviceList_Device" .. tostring(i)] = function(self)
	commonFunctions:userPrint(34, "=================== Test Case ===================")
		local mobileHost = tostring(i) .. ".0.0.1"
		local tcpConnection = tcp.Connection(mobileHost, config.mobilePort)
	    local fileConnection = file_connection.FileConnection("mobile.out", tcpConnection)
	    Connections[i].connection = mobile.MobileConnection(fileConnection)
	    Connections[i].session = mobile_session.MobileSession(
	    self,
	    Connections[i].connection)
	    event_dispatcher:AddConnection(Connections[i].connection)
	    Connections[i].session :ExpectEvent(events.connectedEvent, "Connection started")
	    Connections[i].connection:Connect()

	    if i <=100 then
		    value = {
				isSDLAllowed = false,
				name = mobileHost,
				transportType = "WIFI"
			}
		    table.insert (deviceListArray, value)

		    if deviceListArray[i-1] then

		    	deviceListArray[i-1].id = DeviceMacValues[i-1]
		    end
		end



	    EXPECT_HMICALL("BasicCommunication.UpdateDeviceList",
			{
				deviceList = deviceListArray
			})
			:Do(function(_,data)
				self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})

				CheckArrayValues(data.params.deviceList[i].id)

				DeviceMacValues[i] = data.params.deviceList[i].id
			end)
			:ValidIf(function(_,data)
				if i <= 100 then
					if #data.params.deviceList ~= i then
						commonFunctions:userPrint(31, " deviceList array in UpdateDeviceList contains unexpected element number. Expected number is '" .. tostring(i) .. "', actual value is '" .. tostring(#data.params.deviceList) .. "'" )
						return false
					else
						return true
					end
				else
					if #data.params.deviceList ~= 100 then
						commonFunctions:userPrint(31, " deviceList array in UpdateDeviceList contains unexpected element number. Expected number is '100', actual value is '" .. tostring(#data.params.deviceList) .. "'" )
						return false
					else
						return true
					end
				end
			end)
	end

end

--======================================================================================--
-- Allow all connected devicese by OnAllowSDLFunctionality(allowed = true) without device parameter
--======================================================================================--

function Test:AllowAllConnectedDevices()
	commonFunctions:userPrint(34, "=================== Test Case ===================")

	for i=1,#deviceListArray do
		deviceListArray[i].isSDLAllowed = true
	end

	--hmi side: send request SDL.OnAllowSDLFunctionality
	self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality",
				{allowed = true, source = "GUI"})

	self.hmiConnection:SendNotification("BasicCommunication.OnStartDeviceDiscovery")

	EXPECT_HMICALL("BasicCommunication.UpdateDeviceList",
		{
			deviceList = deviceListArray
		})
		:Do(function(_,data)
			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
		end)
		:ValidIf(function(_,data)
			if #data.params.deviceList ~= 100 then
				commonFunctions:userPrint(31, " Expected number of elements in deviceList array is '100', got '" .. tostring(#data.params.deviceList ) .. "'")
				return false
			else
				return true
			end
		end)
end

--======================================================================================--
-- Disallow all connected devicese by OnAllowSDLFunctionality(allowed = false) without device parameter
--======================================================================================--

function Test:DisallowAllConnectedDevices()
	commonFunctions:userPrint(34, "=================== Test Case ===================")

	for i=1,#deviceListArray do
		deviceListArray[i].isSDLAllowed = false
	end

	--hmi side: send request SDL.OnAllowSDLFunctionality
	self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality",
				{allowed = false, source = "GUI"})

	self.hmiConnection:SendNotification("BasicCommunication.OnStartDeviceDiscovery")

	EXPECT_HMICALL("BasicCommunication.UpdateDeviceList",
		{
			deviceList = deviceListArray
		})
		:Do(function(_,data)
			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
		end)
		:ValidIf(function(_,data)
			if #data.params.deviceList ~= 100 then
				commonFunctions:userPrint(31, " Expected number of elements in deviceList array is '100', got '" .. tostring(#data.params.deviceList ) .. "'")
				return false
			else
				return true
			end
		end)
end


--======================================================================================--
-- Disconnect all devices, UpdateDeviceListAfter after each disconnection
--======================================================================================--

for i=101, 1, -1 do

	Test["UpdateDeviceList_ByClossingConnectionDevice" .. tostring(i)] = function(self)
	commonFunctions:userPrint(34, "=================== Test Case ===================")

		Connections[i].connection:Close()

		self.hmiConnection:SendNotification("BasicCommunication.OnStartDeviceDiscovery")

		local mobileHost = tostring(i) .. ".0.0.1"

	    if i <=99 then
	    	table.remove (deviceListArray,i+1)
		end

	 	EXPECT_HMICALL("BasicCommunication.UpdateDeviceList",
			{
				deviceList = deviceListArray
			})
			:Do(function(_,data)
				self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})

			end)
			:ValidIf(function(_,data)
				if i <= 100 then
					if #data.params.deviceList ~= i then
						commonFunctions:userPrint(31, " deviceList array in UpdateDeviceList contains unexpected element number. Expected number is '" .. tostring(i) .. "', actual value is '" .. tostring(#data.params.deviceList) .. "'" )
						return false
					else
						return true
					end
				else
					if #data.params.deviceList ~= 100 then
						commonFunctions:userPrint(31, " deviceList array in UpdateDeviceList contains unexpected element number. Expected number is '100', actual value is '" .. tostring(#data.params.deviceList) .. "'" )
						return false
					else
						return true
					end
				end
			end)

	end
end


--======================================================================================--
-- UpdateDeviceList with empty deviceList when in previos IGN cycle were connected 101 devices
--======================================================================================--
RestartSDL("After100DevicesDisconnected")

function Test:UpdateDeviceList_EmptyDeviceList_After100DevicesWereConnectedInPrevIGNCycle()
	commonFunctions:userPrint(34, "=================== Test Case ===================")
	self.hmiConnection:SendNotification("BasicCommunication.OnStartDeviceDiscovery")

	EXPECT_HMICALL("BasicCommunication.UpdateDeviceList")
		:Do(function(_,data)
			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
		end)
		:ValidIf(function(_,data)
			if #data.params.deviceList ~= 0 then
				commonFunctions:userPrint(31, "deviceList array in UpdateDeviceList is not empty. Received elements number '" .. tostring(#data.params.deviceList) .. "'")
				return false
			else
			    return true
			end
		end)
end

function Test:ClearPreconditions()
	os.execute("sudo bash -ex files/DeleteConnectionForNewDevice.sh")
end
