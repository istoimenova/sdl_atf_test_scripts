Test = require('user_modules/connecttest_GetSystemInfo')
require('cardinalities')
-- local events = require('events')
local mobile_session = require('mobile_session')
-- local mobile  = require('mobile_connection')
-- local tcp = require('tcp_connection')
-- local file_connection  = require('file_connection')
-- local config = require('config')
-- local module = require('testbase')

---------------------------------------------------------------------------------------------
-------------------------------------------Functions-------------------------------------
---------------------------------------------------------------------------------------------

local query = "sqlite3 " .. config.pathToSDL .. "storage/policy.sqlite".. " \"select ccpu_version from module_meta;\""

local function CreateSession( self)
  self.mobileSession = mobile_session.MobileSession(
        self,
        self.mobileConnection)
end

local function userPrint( color, message)
  print ("\27[" .. tostring(color) .. "m " .. tostring(message) .. " \27[0m")
end

local function sleep(sec)
  -- body
  os.execute("sleep " .. sec)
end

local function RegisterApp(self, passCriteria)
  local correlationId = self.mobileSession:SendRPC("RegisterAppInterface", config.application1.registerAppInterfaceParams)

  EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered")
    :Do(function(_,data)
      HMIAppID = data.params.application.appID
      self.applications[config.application1.registerAppInterfaceParams.appName] = data.params.application.appID
    end)

  -- self.mobileSession:ExpectResponse(correlationId, { success = true })
  EXPECT_RESPONSE(correlationId, { success = true })
  :ValidIf(function (_,data)
    if data.payload.systemSoftwareVersion == passCriteria then
      return true
    else
      return false
    end
  end)

end

function RestartSDL(self, suffix, ccpu)
  -- body
  
  Test["StopSDL"..tostring(suffix)] = function (self)
    StopSDL()
  end

  Test["StartSDL" .. tostring(suffix)] = function (self)
    StartSDL(config.pathToSDL, config.ExitOnCrash)
  end

  Test["TestInitHMI" .. tostring(suffix)] = function (self)
    self:initHMI()
  end

  Test["TestInitHMIOnReady" .. tostring(suffix)] = function (self)
    self:initHMI_onReady(ccpu)
  end

end


function Check_ccpu_version(self, suffix, ccpu)
  
  -- Test to check ccpu_version parameter in policy DB
  Test["CheckPolicyDB"..tostring(suffix)] = function (self, ccpu)
    -- body
    sleep(1)
    local handler = io.popen(query)
    local result = handler:read("*a")
    handler:close()

    if result == ccpu then
      --do
      return true
    else
      return false    
    end
  end

end

	
	
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------

--Check that SDL request ccpu_version on start of each ignition cycle
local version = ''
local indexOfTests = 1

Test["Test-wrapper-for-test-name"] = function ()
  -- body
  userPrint(33, "===Test start - SDL request ccpu_version on start of each ignition cycle===")
  return true
end

for i=indexOfTests, indexOfTests + 2 do
  version = tostring(i) .. '.0'
  RestartSDL(self, i, version)
  Check_ccpu_version(self, i, version)
end

Test["Test-wrapper-for-test-name"] = function ()
  -- body
  userPrint(33, "===Test end - SDL request ccpu_version on start of each ignition cycle===")
  return true
end

indexOfTests = indexOfTests + 1

function Test:ConnectMobile()
  self:connectMobile()
end

function Test:StartSession()
   CreateSession(self)
end

function Test:RegisterApp()
  self.mobileSession:StartService(7)
  :Do(function (_,data)
    RegisterApp(self, "3.0")
  end)
end

--ccpu_version is empty in response
RestartSDL(self, indexOfTests, "")
Test["ConnectMobile" .. tostring(indexOfTests)] = function (self)
  userPrint(33, "===Test start - ccpu_version is empty in response===")
  self:connectMobile()
end
Test["StartSession" .. tostring(indexOfTests)] = function (self)
  CreateSession(self)
end
Test["RegisterApp" .. tostring(indexOfTests)] = function (self)
  self.mobileSession:StartService(7)
  :Do(function (_,data)
    RegisterApp(self, "3.0")
  end)
  userPrint(33, "===Test end - ccpu_version is empty in response===")
end
indexOfTests = indexOfTests + 1

--ccpu_version is not valid in response
RestartSDL(self, indexOfTests, 123)
Test["ConnectMobile" .. tostring(indexOfTests)] = function (self)
  userPrint(33, "===Test start - ccpu_version is not valid in response===")
  self:connectMobile()
end
Test["StartSession" .. tostring(indexOfTests)] = function (self)
  CreateSession(self)
end
Test["RegisterApp" .. tostring(indexOfTests)] = function (self)
  self.mobileSession:StartService(7)
  :Do(function (_,data)
    RegisterApp(self, "3.0")
  end)
  userPrint(33, "===Test end - ccpu_version is not valid in response===")
end
indexOfTests = indexOfTests + 1

--ccpu_version is absent in response
RestartSDL(self, indexOfTests, "absent")
Test["ConnectMobile" .. tostring(indexOfTests)] = function (self)
  userPrint(33, "===Test start - ccpu_version is absent in response===")
  self:connectMobile()
end
Test["StartSession" .. tostring(indexOfTests)] = function (self)
  CreateSession(self)
end
Test["RegisterApp" .. tostring(indexOfTests)] = function (self)
  self.mobileSession:StartService(7)
  :Do(function (_,data)
    RegisterApp(self, "3.0")
  end)
  userPrint(33, "===Test end - ccpu_version is absent in response===")
end
indexOfTests = indexOfTests + 1

--ccpu_version is more than 100 symbols
local sHundredPlusOne = "1qaz2wsx3edc4rfv5tgb6yhn7ujm8ik9ol0p1qaz2wsx3edc4r1qaz2wsx3edc4rfv5tgb6yhn7ujm8ik9ol0p1qaz2wsx3edc4rf"
local sHundred = "1qaz2wsx3edc4rfv5tgb6yhn7ujm8ik9ol0p1qaz2wsx3edc4r1qaz2wsx3edc4rfv5tgb6yhn7ujm8ik9ol0p1qaz2wsx3edc4r"
RestartSDL(self, indexOfTests, sHundredPlusOne)
Test["ConnectMobile" .. tostring(indexOfTests)] = function (self)
  userPrint(33, "===Test start - ccpu_version is more than 100 symbols")
  self:connectMobile()
end
Test["StartSession" .. tostring(indexOfTests)] = function (self)
  CreateSession(self)
end
Test["RegisterApp" .. tostring(indexOfTests)] = function (self)
  self.mobileSession:StartService(7)
  :Do(function (_,data)
    RegisterApp(self, sHundred)
  end)
  userPrint(33, "===Test end - ccpu_version is more than 100 symbols")
end
indexOfTests = indexOfTests + 1

--ccpu_version is empty in Policy DB

Test["StopSDL"..tostring(indexOfTests)] = function (self)
  userPrint(33, "===Test start - ccpu_version is empty in policy DB===")
  StopSDL()
end

function Test:PreconditionRemoveDB(...)
  -- body
  local result = os.execute("rm " .. config.pathToSDL .. "storage/policy.sqlite") 
  return result
end

Test["StartSDL" .. tostring(indexOfTests)] = function (self)
  StartSDL(config.pathToSDL, config.ExitOnCrash)
  sleep(2)
end

Test["TestInitHMI" .. tostring(indexOfTests)] = function (self)
  self:initHMI()
end

Test["TestInitHMIOnReady" .. tostring(indexOfTests)] = function (self)
  self:initHMI_onReady("absent")
end

Test["ConnectMobile" .. tostring(indexOfTests)] = function (self)
  self:connectMobile()
end
Test["StartSession" .. tostring(indexOfTests)] = function (self)
  CreateSession(self)
end
Test["RegisterApp" .. tostring(indexOfTests)] = function (self)
  self.mobileSession:StartService(7)
  :Do(function (_,data)
    RegisterApp(self, nil)
  end)
  userPrint(33, "===Test end - ccpu_version is empty in policy DB===")
end
indexOfTests = indexOfTests + 1

local errorneousCodes = { "UNSUPPORTED_REQUEST", "UNSUPPORTED_RESOURCE", "DISALLOWED", "REJECTED", "ABORTED", 
                          "IGNORED", "RETRY", "IN_USE", "DATA_NOT_AVAILABLE", "TIMED_OUT", "INVALID_DATA", 
                          "CHAR_LIMIT_EXCEEDED", "INVALID_ID", "DUPLICATE_NAME", "APPLICATION_NOT_REGISTERED", 
                          "WRONG_LANGUAGE", "OUT_OF_MEMORY", "TOO_MANY_PENDING_REQUESTS", "NO_APPS_REGISTERED", 
                          "NO_DEVICES_CONNECTED", "WARNINGS", "GENERIC_ERROR", "USER_DISALLOWED", "TRUNCATED_DATA"}

for key,value in ipairs(errorneousCodes) do
  Test["StopSDL"..tostring(indexOfTests)] = function (self)
    userPrint(33, "===Test start - GetSystemInfo response code " .. value)
    StopSDL()
  end

  function Test:PreconditionRemoveDB(...)
    -- body
    local result = os.execute("rm " .. config.pathToSDL .. "storage/policy.sqlite") 
    return result
  end

  Test["StartSDL" .. tostring(indexOfTests)] = function (self)
    StartSDL(config.pathToSDL, config.ExitOnCrash)
    sleep(4)
  end

  Test["TestInitHMI" .. tostring(indexOfTests)] = function (self)
    self:initHMI()
  end

  Test["TestInitHMIOnReady" .. tostring(indexOfTests)] = function (self)
    self:initHMI_onReady("3.0", value)
  end

  Test["ConnectMobile" .. tostring(indexOfTests)] = function (self)
    self:connectMobile()
  end
  Test["StartSession" .. tostring(indexOfTests)] = function (self)
    CreateSession(self)
  end
  Test["RegisterApp" .. tostring(indexOfTests)] = function (self)
    userPrint(33, "===Test - GetSystemInfo error code: " .. tostring(value) .. "===")
    self.mobileSession:StartService(7)
    :Do(function (_,data)
      RegisterApp(self, nil)
    end)
    userPrint(33, "===Test end - GetSystemInfo response code " .. value)
  end
  indexOfTests = indexOfTests + 1
end