-- ATF verstion: 2.2
---------------------------------------------------
Test = require('connecttest')
require('cardinalities')
local events = require('events')
local mobile_session = require('mobile_session')
local mobile  = require('mobile_connection')
local tcp = require('tcp_connection')
local file_connection  = require('file_connection')

---------------------------------------------------------------------------------------------
-----------------------------Required Shared Libraries---------------------------------------
---------------------------------------------------------------------------------------------
require('user_modules/AppTypes')
local commonTestCases = require('user_modules/shared_testcases/commonTestCases')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
local commonPreconditions = require('user_modules/shared_testcases/commonPreconditions')

APIName = "SetGlobalProperties" -- set for required scripts
strMaxLengthFileName255 = string.rep("a", 251)  .. ".png" -- set max length file name

local iTimeout = 5000
local TimeRAISuccess = 0
config.defaultProtocolVersion = 2
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"
local strAppFolder = config.pathToSDL .. "storage/" ..config.application1.registerAppInterfaceParams.appID.. "_" .. config.deviceMAC.. "/"
-- Will be used for check if command was added within 10 sec after RAI; True - added
local AddCmdSuccess = {}
---------------------------------------------------------------------------------------------
--------------------------------------Delete/update files------------------------------------
---------------------------------------------------------------------------------------------
function DeleteLog_app_info_dat_policy()
    commonSteps:CheckSDLPath()
    local SDLStoragePath = config.pathToSDL .. "storage/"

    --Delete app_info.dat and log files and storage
    if commonSteps:file_exists(config.pathToSDL .. "app_info.dat") == true then
      os.remove(config.pathToSDL .. "app_info.dat")
    end

    if commonSteps:file_exists(config.pathToSDL .. "SmartDeviceLinkCore.log") == true then
      os.remove(config.pathToSDL .. "SmartDeviceLinkCore.log")
    end

    if commonSteps:file_exists(SDLStoragePath .. "policy.sqlite") == true then
      os.remove(SDLStoragePath .. "policy.sqlite")
    end

    if commonSteps:file_exists(config.pathToSDL .. "policy.sqlite") == true then
      os.remove(config.pathToSDL .. "policy.sqlite")
    end
print("path = " .."rm -r " ..config.pathToSDL .. "storage")
    os.execute("rm -r " ..config.pathToSDL .. "storage")
end

DeleteLog_app_info_dat_policy()

function UpdatePolicy()
    commonPreconditions:BackupFile("sdl_preloaded_pt.json")
    local src_preloaded_json = config.pathToSDL .."sdl_preloaded_pt.json"
    local dest               = "files/SetGlobalProperties_DISALLOWED.json"
    
    local filecopy = "cp " .. dest .."  " .. src_preloaded_json

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

function Precondition_RegisterApp(self, nameTC)

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

--Registering application without Unregistration

function Precondition_RegisterAppWithoutUnregister(self, nameTC)

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
end 

-- AddCommand FAIL 
  --Description: failed due mandatory parameter cmdID is missing
    local function AddCommandFAIL(self)
      --mobile side: sending AddCommand request
      local cid = self.mobileSession:SendRPC("AddCommand",
      {
        menuParams =  
        { 
          parentID = 1,
          position = 0,
          menuName ="Command1"
        }, 
        vrCommands = 
        { 
          "Voicerecognitioncommandone"
        }, 
        cmdIcon =   
        { 
          value ="icon.png",
          imageType ="DYNAMIC"
        }
      })    
      
      EXPECT_RESPONSE(cid, { success = false, resultCode = "INVALID_DATA" })
        
      --mobile side: expect OnHashChange notification is not send to mobile
      EXPECT_NOTIFICATION("OnHashChange")
      :Times(0)
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


  local function CheckUpdateFile(self, SGP_helpPrompt, SGP_vrHelp)
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
-----------------------------------------I TEST BLOCK----------------------------------------
--CommonRequestCheck: Check of mandatory/conditional request's parameters (mobile protocol)--
---------------------------------------------------------------------------------------------

   --These cases are covered in general script for testing API SetGlobalProperties.
   --See ATF_SetGlobalProperties.lua

---------------------------------------------------------------------------------------------
----------------------------------------II TEST BLOCK----------------------------------------
----------------------------------------Positive cases---------------------------------------
--Positive cases: Check of positive value of request/response parameters (HMI protocol)
---------------------------------------------------------------------------------------------

  --Begin Test suit PositiveResponseCheck
  -- Begin Test case PositiveResponseCheck.1
      --Description: Case when App does NOT send SetGlobalProperties request to SDL during 10 sec timer + values from internal list
      --Requirement id in JIRA: APPLINK-19474, APPLINK-26644, APPLINK-23652->reg_1
      --Verification criteria:
        --In case mobile app has registered AddCommands requests (previously added)
        -- SDL must provide the value of "helpPrompt" and "vrHelp" based on registered AddCommands and DeleteCommands requests to HMI: 
          -- SDL sends UI.SetGlobalProperties(<vrHelp_from_list>, params) and TTS.SetGlobalProperties(<helpPrompt_from_list>, params) to HMI 

            -- Precondition to PositiveResponseCheck.1.1
            function Test:PrintPrecondition()
              userPrint(35, "================= Precondition TC1.1 ==================")
            end
            -- Register App
            Precondition_RegisterApp(self, "TC1.1")
            -- Activate registered App
            ActivationApp(self, "TC1.1")
            -- App has registered 2 AddCommands
            for cmdCount = 1, 2 do
              Test["TC1.1_Precondition_AddCommandInitial_" .. tostring(cmdCount)] = function(self)
                AddCommand(self, cmdCount)
              end
            end            
            --End Precondition to PositiveResponseCheck.1

            -- Test Case PositiveResponseCheck.1.1
            function Test:TC1_1_NoSGPvrHelphelpPrompt_from_intList()
              userPrint(34, "================= Test Case 1.1 ==================")
            -- start main part of TC
            local time = timestamp()
            -- start 10 sec timer
            if (time - TimeRAISuccess) > 10000 then
                   
                      -- hmi side: expect UI.SetGlobalProperties request
                      local cid = self.hmiConnection:SendRequest("SetGlobalProperties",
                        {
                          vrHelp = 
                          {
                              {
                                text = "VRCommand1",
                                position = 1
                              }
                          },
                          
                          helpPrompt = 
                          {
                              {
                                text = "VRCommand1",
                                type = "TEXT"
                              },
                              {
                                text = "300",
                                type = "SILENCE"
                              }
                          },
                          vrHelpTitle = config.application1.registerAppInterfaceParams.appName,

                        })

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
                                      text = "300",
                                      type = "SILENCE"
                                    }    
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
         -- End Test case PositiveResponseCheck.1.1

    -- Begin Test case PositiveResponseCheck.1.2
      --Description: Case when App does NOT send SetGlobalProperties request to SDL during 10 sec timer + values from internal list
      --Requirement id in JIRA: APPLINK-19474, APPLINK-26644, APPLINK-23652->reg_1
      --Verification criteria:
        --In case mobile app has registered AddCommands requests (previously added) and 1 Command was deleted
        -- SDL must provide the value of "helpPrompt" and "vrHelp" based on registered AddCommands and DeleteCommands requests to HMI: 
          -- SDL sends UI.SetGlobalProperties(<vrHelp_from_list>, params) and TTS.SetGlobalProperties(<helpPrompt_from_list>, params) to HMI 

            -- Precondition to PositiveResponseCheck.1.2
            function Test:PrintPrecondition()
              userPrint(35, "================= Precondition TC1.2 ==================")
            end
            -- Register App
            Precondition_RegisterApp(self, "TC1.2")
            -- Activate registered App
            ActivationApp(self, "TC1.2")
            -- App has registered 2 AddCommands
                          for cmdCount = 1, 2 do
                Test["TC1.2_Precondition_AddCommandInitial_" .. cmdCount] = function(self)
                  AddCommand(self, cmdCount)
                end
              end 
            -- delete 1 of Added Commands
              Test["TC1.2_Precondition_DeleteCommand_1"] = function(self)
                DeleteCommand(self, 1)
              end

            --End Precondition to PositiveResponseCheck.1.2

      --  Test case PositiveResponseCheck.1.2
        function Test:TC1_2_NoSGPvrHelphelpPrompt_from_intList()
          userPrint(34, "================= Test Case 1.2 ==================")
            -- start main part of TC
            local time = timestamp()
            -- start 10 sec timer
            if (time - TimeRAISuccess) > 10000 then
                   
                      -- hmi side: expect UI.SetGlobalProperties request
                      local cid = self.hmiConnection:SendRequest("SetGlobalProperties",
                        {
                          vrHelp = 
                          {
                              {
                                text = "VRCommand1",
                                position = 1
                              }
                          },
                          
                          helpPrompt = 
                          {
                              {
                                text = "VRCommand1",
                                type = "TEXT"
                              },
                              {
                                text = "300",
                                type = "SILENCE"
                              }
                          },
                          vrHelpTitle = config.application1.registerAppInterfaceParams.appName,

                        })

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
                                      text = "300",
                                      type = "SILENCE"
                                    }    
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
         -- end Test case PositiveResponseCheck.1.2

    -- Begin Test case PositiveResponseCheck.1.3
      --Description: Case when App does NOT send SetGlobalProperties request to SDL during 10 sec timer + values from internal list
      --Requirement id in JIRA: APPLINK-19474, APPLINK-26644, APPLINK-23652->reg_1
      --Verification criteria:
        --In case mobile app has registered 2 AddCommands and both of them were Deleted
        -- SDL must provide the value of "helpPrompt" and "vrHelp" based on registered AddCommands and DeleteCommands requests to HMI: 
          -- SDL sends UI.SetGlobalProperties(<vrHelp_from_list>, params) and TTS.SetGlobalProperties(<helpPrompt_from_list>, params) to HMI 

            -- Precondition to PositiveResponseCheck.1.3
            function Test:PrintPrecondition()
              userPrint(35, "================= Precondition TC1.3 ==================")
            end
            -- Register App
            Precondition_RegisterApp(self, "TC1.3")
            -- Activate registered App
            ActivationApp(self, "TC1.3")
            -- App has registered 2 AddCommands
            for cmdCount = 1, 2 do
              Test["TC1.2_Precondition_AddCommandInitial_" .. cmdCount] = function(self)
                AddCommand(self, cmdCount)
              end
            end 
            -- delete both Added Commands
            for cmdCount = 1, 2 do
              Test["TC1.3_Precondition_DeleteCommand_" .. cmdCount] = function(self)
                DeleteCommand(self, cmdCount)
              end
            end
            --End Precondition to PositiveResponseCheck.1.3

        -- Test case PositiveResponseCheck.1.3

        function Test:TC1_3_NoSGPvrHelphelpPrompt_from_intList()
          userPrint(34, "================= Test Case 1.3 ==================")
            -- start main part of TC
            local time = timestamp()
            -- start 10 sec timer
            if (time - TimeRAISuccess) > 10000 then
                   
                      -- hmi side: expect UI.SetGlobalProperties request
                      local cid = self.hmiConnection:SendRequest("SetGlobalProperties",
                        {
                          vrHelp = 
                          {
                              {
                                text = "VRCommand1",
                                position = 1
                              }
                          },
                          
                          helpPrompt = 
                          {
                              {
                                text = "VRCommand1",
                                type = "TEXT"
                              },
                              {
                                text = "300",
                                type = "SILENCE"
                              }
                          },
                          vrHelpTitle = config.application1.registerAppInterfaceParams.appName,

                        })

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
                                      text = "300",
                                      type = "SILENCE"
                                    }    
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
         -- end Test case PositiveResponseCheck.1.3


    -- Begin Test case PositiveResponseCheck.1.4
      --Description: Case when App does NOT send SetGlobalProperties request to SDL during 10 sec timer + values from internal list
      --Requirement id in JIRA: APPLINK-19474, APPLINK-26644, APPLINK-23652->reg_1
      --Verification criteria:
        --In case mobile app has resumed AddCommands during resumption
        -- SDL must provide the value of "helpPrompt" and "vrHelp" based on registered AddCommands and DeleteCommands requests to HMI: 
          -- SDL sends UI.SetGlobalProperties(<vrHelp_from_list>, params) and TTS.SetGlobalProperties(<helpPrompt_from_list>, params) to HMI 

            -- Precondition to PositiveResponseCheck.1.4
           -- Begin Precondition 1
 
           function Test:PrintPrecondition()
            userPrint(35, "================= Precondition TC1.4 ==================")
           end
           -- 1. Register App
           Precondition_RegisterApp(self, "TC1.4_Precondition")
           -- 2. Activate App
           ActivationApp(self, "TC1.4_Precondition")
           -- 3. App has registered 2 AddCommands
            for cmdCount = 1, 2 do
              Test["TC1.4_Precondition_AddCommandInitial_" .. cmdCount] = function(self)
                AddCommand(self, cmdCount)
              end
            end 
           -- 6. IGN_OFF: 1. SUSPEND, 2. IGN_OFF
           Test["Precondition_SuspendFromHMI_TC1.4"] = function(self)
            self.hmiConnection:SendNotification("BasicCommunication.OnExitAllApplications", {reason = "SUSPEND"})

            -- hmi side: expect OnSDLPersistenceComplete notification
            EXPECT_HMINOTIFICATION("BasicCommunication.OnSDLPersistenceComplete")
           end

            Test["Precondition_IGN_OFF_TC1.4"] = function(self)
              IGNITION_OFF(self, 0)
            end

           -- 6. Start SDL
           Test["Precondition_StartSDLTC1.4"] = function(self)
              StartSDL(config.pathToSDL, config.ExitOnCrash)
              DelayedExp(1000)
            end

            Test["Precondition_InitHMI_TC1.4"] = function(self)
              self:initHMI()
            end

            Test["Precondition_InitHMI_onReady_TC1.4"] = function(self)
              self:initHMI_onReady()
            end

            Test["Precondition_ConnectMobile_TC1.4"] = function(self)
              self:connectMobile()
            end

            Test["Precondition_StartSession_TC1.4"] = function(self)
              self.mobileSession = mobile_session.MobileSession(self, self.mobileConnection)
            end
            -- Register App
            Precondition_RegisterAppWithoutUnregister(self, "TC1.4")
            -- Activate registered App
            ActivationApp(self, "TC1.4")

           --End Precondition to PositiveResponseCheck.1.4

        -- Test case PositiveResponseCheck.1.4
        function Test:TC1_4_NoSGPvrHelphelpPrompt_from_intList()
          userPrint(34, "=================== Test Case 1.4 ===================")
            -- start main part of TC
            local time = timestamp()
            -- start 10 sec timer
            if (time - TimeRAISuccess) > 10000 then
                   
                      -- hmi side: expect UI.SetGlobalProperties request
                      local cid = self.hmiConnection:SendRequest("SetGlobalProperties",
                        {
                          vrHelp = 
                          {
                              {
                                text = "VRCommand1",
                                position = 1
                              }
                          },
                          
                          helpPrompt = 
                          {
                              {
                                text = "VRCommand1",
                                type = "TEXT"
                              },
                              {
                                text = "300",
                                type = "SILENCE"
                              }
                          },
                          vrHelpTitle = config.application1.registerAppInterfaceParams.appName,

                        })

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
                                      text = "300",
                                      type = "SILENCE"
                                    }    
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

--Begin Test case PositiveResponseCheck.2
      --Description: Case when App does NOT send SetGlobalProperties request to SDL during 10 sec timer + default_values
      --Requirement id in JIRA: APPLINK-19475, APPLINK-23652->reg_2
      --Verification criteria:
        --In case mobile app has NO registered AddCommands and/or DeleteCommands requests:
          -- SDL must use current appName as default value for "vrHelp" parameter
          -- SDL must retrieve value of "helpPrompt" from .ini file ([GLOBAL PROPERTIES] section -> "HelpPrompt" param)
        -- SDL sends UI.SetGlobalProperties(<default_vrHelp>, params) and TTS.SetGlobalProperties(<default_helpPrompt>, params) to HMI 

      --Precondition to PositiveResponseCheck.2
      function Test:PrintPrecondition()
        userPrint(35, "================= Precondition TC2 ==================")
      end
            Precondition_RegisterApp(self, "TC2")
            -- Activate registered App
            ActivationApp(self, "TC2")

      --End Precondition to PositiveResponseCheck.2

      -- Begin Test Case PositiveResponseCheck.2

      function Test:TC2_NoSGP_from_App_during_10secTimer()
        userPrint(34, "================= Test Case 2 ==================")
        local time = timestamp()

          if (time - TimeRAISuccess) > 10000 then

          -- hmi side: expect SetGlobalProperties request
          local cid = self.hmiConnection:SendRequest("SetGlobalProperties",
                            {
                  vrHelp = 
                  {
                      {
                        text = "VRCommand1",
                        position = 1
                      }
                  },
                  
                  helpPrompt = 
                  {
                      {
                        text = "VRCommand1",
                        type = "TEXT"
                      },
                  },
                  vrHelpTitle = config.application1.registerAppInterfaceParams.appName,

                })
          
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
    --End Test case PositiveResponseCheck.2

----------------------------------------------------------------------------------------------
----------------------------------------III TEST BLOCK----------------------------------------
----------------------------------------Negative cases----------------------------------------
----Check of negative value of request/response parameters (HMI protocol)---------------------
----------------------------------------------------------------------------------------------

  --Begin Test suit NegativeResponse
    --Begin Test case NegativeResponse.1
      --Description: Case when App does NOT send SetGlobalProperties to SDL during 10 sec timer and SDL receives at least to one TTS/UI.SetGlobalProperties <errorCode> from HMI
      --Requirement id in JIRA: APPLINK 23652->reg_4
      --Verification criteria:
        --In case mobile app has registered AddCommand requests (previously added)
        --SDL receives GENERIC_ERROR <errorCode> on UI.SetGlobalProperties from HMI
        --SDL should log corresponding error internally

        --Precondition for NegativeResponse.1
        function Test:PrintPrecondition()
          userPrint(35, "================= Precondition TC3.1 ==================")
        end
            -- Register App
            Precondition_RegisterApp(self, "TC3.1")
            -- Activate registered App
            ActivationApp(self, "TC3.1")
        --End Precondition for NegativeResponse.1

        -- Test case NegativeResponse.1

        function Test:TC3_1_NoSGPGENERICERRORonUISGPfromHMI()
          userPrint(34, "================= Test Case 3.1 ==================")
            local time = timestamp()
            -- start 10 sec timer
            if (time - TimeRAISuccess) > 10000 then

              -- hmi side: expect UI.SetGlobalProperties request
              local cid = self.hmiConnection:SendRequest("SetGlobalProperties",
                {
                  vrHelp = 
                  {
                      {
                        text = "VRCommand1",
                        position = 1
                      }
                  },
                  
                  helpPrompt = 
                  {
                      {
                        text = "VRCommand1",
                        type = "TEXT"
                      },
                      {
                        text = "300",
                        type = "SILENCE"
                      }
                  },
                  vrHelpTitle = config.application1.registerAppInterfaceParams.appName,

                })
          

      --hmi side: expect UI.SetGlobalProperties request
      EXPECT_HMICALL("UI.SetGlobalProperties",
        {
          vrHelpTitle = config.application1.registerAppInterfaceParams.appName,
          
          vrHelp = { 
                {
                  text = "Command" .. tostring(cmdCount),
                  position = 1
                      } 
                  },
                    appID = self.applications[config.application1.registerAppInterfaceParams.appName]
        })

      :Do(function(_,data)
        --hmi side: sending UI.SetGlobalProperties response
        self.hmiConnection:SendResponse(data.id, data.method, "GENERIC_ERROR", {})
      end)

      --hmi side: expect TTS.SetGlobalProperties request
      EXPECT_HMICALL("TTS.SetGlobalProperties",
        {
          helpPrompt = 
                      {
                        {
                          text = "Command" .. tostring(cmdCount),
                          type = "TEXT"
                              },
                        {
                          text = "300",
                          type = "SILENCE"
                        }     
                      },                                    
          appID = self.applications[config.application1.registerAppInterfaceParams.appName]
        })

      :Do(function(_,data)
        --hmi side: sending TTS.SetGlobalProperties response
        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
        end)    
      end
    end 
    -- End Test case NegativeResponse.1

    --Begin Test case NegativeResponse.2
      --Description: Case when App does NOT send SetGlobalProperties to SDL during 10 sec timer and SDL receives at least to one TTS/UI.SetGlobalProperties <errorCode> from HMI
      --Requirement id in JIRA: APPLINK 23652->reg_4
      --Verification criteria:
        --In case mobile app has registered AddCommand requests (previously added)
        --SDL receives GENERIC_ERROR <errorCode> on TTS.SetGlobalProperties from HMI
        --SDL should log corresponding error internally

        --Precondition for NegativeResponse.2
        function Test:PrintPrecondition()
          userPrint(35, "================= Precondition TC3.2 ==================")
        end
            -- Register App
            Precondition_RegisterApp(self, "TC3.2")
            -- Activate registered App
            ActivationApp(self, "TC3.2")
        --End Precondition for NegativeResponse.2

        -- Test case NegativeResponse.2

        function Test:TC3_2_NoSGPGENERICERRORonTTSSGPfromHMI()
          userPrint(34, "================= Test Case 3.2 ==================")
            local time = timestamp()
            -- start 10 sec timer
            if (time - TimeRAISuccess) > 10000 then

              -- hmi side: expect UI.SetGlobalProperties request
              local cid = self.hmiConnection:SendRequest("SetGlobalProperties",
                {
                  vrHelp = 
                  {
                      {
                        text = "VRCommand1",
                        position = 1
                      }
                  },
                  
                  helpPrompt = 
                  {
                      {
                        text = "VRCommand1",
                        type = "TEXT"
                      },
                      {
                        text = "300",
                        type = "SILENCE"
                      }
                  },
                  vrHelpTitle = config.application1.registerAppInterfaceParams.appName,

                })
          

      --hmi side: expect UI.SetGlobalProperties request
      EXPECT_HMICALL("UI.SetGlobalProperties",
        {
          vrHelpTitle = config.application1.registerAppInterfaceParams.appName,
          
          vrHelp = { 
                {
                  text = "Command" .. tostring(cmdCount),
                  position = 1
                      } 
                  },
                    appID = self.applications[config.application1.registerAppInterfaceParams.appName]
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
                          text = "Command" .. tostring(cmdCount),
                          type = "TEXT"
                              },
                        {
                          text = "300",
                          type = "SILENCE"
                        }     
                      },                                    
          appID = self.applications[config.application1.registerAppInterfaceParams.appName]
        })

      :Do(function(_,data)
        --hmi side: sending TTS.SetGlobalProperties response
        self.hmiConnection:SendResponse(data.id, data.method, "GENERIC_ERROR", {})
        end)    
      end
    end    
    --End Test case NegativeResponse.2

    --Begin Test case NegativeResponse.3
      --Description: Case when App does NOT send SetGlobalProperties to SDL during 10 sec timer and SDL receives at least to one TTS/UI.SetGlobalProperties <errorCode> from HMI
      --Requirement id in JIRA: APPLINK 23652->reg_4
      --Verification criteria:
        --In case mobile app has registered AddCommand requests (previously added)
        --SDL receives UNSUPPORTED_RESOURCE <errorCode> on TTS.SetGlobalProperties from HMI
        --SDL should log corresponding error internally

        --Precondition for NegativeResponse.3
        function Test:PrintPrecondition()
          userPrint(35, "================= Precondition TC3.3 ==================")
        end
            -- Register App
            Precondition_RegisterApp(self, "TC3.3")
            -- Activate registered App
            ActivationApp(self, "TC3.3")
        --End Precondition for NegativeResponse.3

        -- Test case NegativeResponse.3
        function Test:TC3_3_NoSGPUNSUPPORTEDRESOURCEonUISSGPfromHMI()
          userPrint(34, "================= Test Case 3.3 ==================")
            local time = timestamp()
            -- start 10 sec timer
            if (time - TimeRAISuccess) > 10000 then

              -- hmi side: expect UI.SetGlobalProperties request
              local cid = self.hmiConnection:SendRequest("SetGlobalProperties",
                {
                  vrHelp = 
                  {
                      {
                        text = "VRCommand1",
                        position = 1
                      }
                  },
                  
                  helpPrompt = 
                  {
                      {
                        text = "VRCommand1",
                        type = "TEXT"
                      },
                      {
                        text = "300",
                        type = "SILENCE"
                      }
                  },
                  vrHelpTitle = config.application1.registerAppInterfaceParams.appName,

                })
          

      --hmi side: expect UI.SetGlobalProperties request
      EXPECT_HMICALL("UI.SetGlobalProperties",
        {
          vrHelpTitle = config.application1.registerAppInterfaceParams.appName,
          
          vrHelp = { 
                {
                  text = "Command" .. tostring(cmdCount),
                  position = 1
                      } 
                  },
                    appID = self.applications[config.application1.registerAppInterfaceParams.appName]
        })

      :Do(function(_,data)
        --hmi side: sending UI.SetGlobalProperties response
        self.hmiConnection:SendResponse(data.id, data.method, "UNSUPPORTED_RESOURCE", {})
      end)

      --hmi side: expect TTS.SetGlobalProperties request
      EXPECT_HMICALL("TTS.SetGlobalProperties",
        {
          helpPrompt = 
                      {
                        {
                          text = "Command" .. tostring(cmdCount),
                          type = "TEXT"
                              },
                        {
                          text = "300",
                          type = "SILENCE"
                        }     
                      },                                    
          appID = self.applications[config.application1.registerAppInterfaceParams.appName]
        })

      :Do(function(_,data)
        --hmi side: sending TTS.SetGlobalProperties response
        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
        end)    
      end
    end    
    --End Test case NegativeResponse.3

    --Begin Test case NegativeResponse.4
      --Description: Case when App does NOT send SetGlobalProperties to SDL during 10 sec timer and SDL receives at least to one TTS/UI.SetGlobalProperties <errorCode> from HMI
      --Requirement id in JIRA: APPLINK 23652->reg_4
      --Verification criteria:
        --In case mobile app has registered AddCommand requests (previously added)
        --SDL receives UNSUPPORTED_RESOURCE <errorCode> on UI.SetGlobalProperties from HMI
        --SDL should log corresponding error internally

        --Precondition for NegativeResponse.4
        function Test:PrintPrecondition()
          userPrint(35, "================= Precondition TC3.4 ==================")
        end
            -- Register App
            Precondition_RegisterApp(self, "TC3.4")
            -- Activate registered App
            ActivationApp(self, "TC3.4")
        --End Precondition for NegativeResponse.4

        -- Test case NegativeResponse.4

        function Test:TC3_4_NoSGPUNSUPPORTEDRESOURCEonTTSSSGPfromHMI()
          userPrint(34, "================= Test Case 3.4 ==================")
            local time = timestamp()
            -- start 10 sec timer
            if (time - TimeRAISuccess) > 10000 then

              -- hmi side: expect UI.SetGlobalProperties request
              local cid = self.hmiConnection:SendRequest("SetGlobalProperties",
                {
                  vrHelp = 
                  {
                      {
                        text = "VRCommand1",
                        position = 1
                      }
                  },
                  
                  helpPrompt = 
                  {
                      {
                        text = "VRCommand1",
                        type = "TEXT"
                      },
                      {
                        text = "300",
                        type = "SILENCE"
                      }
                  },
                  vrHelpTitle = config.application1.registerAppInterfaceParams.appName,

                })
          

      --hmi side: expect UI.SetGlobalProperties request
      EXPECT_HMICALL("UI.SetGlobalProperties",
        {
          vrHelpTitle = config.application1.registerAppInterfaceParams.appName,
          
          vrHelp = { 
                {
                  text = "Command" .. tostring(cmdCount),
                  position = 1
                      } 
                  },
                    appID = self.applications[config.application1.registerAppInterfaceParams.appName]
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
                          text = "Command" .. tostring(cmdCount),
                          type = "TEXT"
                              },
                        {
                          text = "300",
                          type = "SILENCE"
                        }     
                      },                                    
          appID = self.applications[config.application1.registerAppInterfaceParams.appName]
        })

      :Do(function(_,data)
        --hmi side: sending TTS.SetGlobalProperties response
        self.hmiConnection:SendResponse(data.id, data.method, "UNSUPPORTED_RESOURCE", {})
        end)    
      end
    end    
    --End Test case NegativeResponse.4

    --Begin Test case NegativeResponse.5
      --Description: Case when App does NOT send SetGlobalProperties to SDL during 10 sec timer and SDL receives at least to one TTS/UI.SetGlobalProperties <errorCode> from HMI
      --Requirement id in JIRA: APPLINK 23652->reg_4
      --Verification criteria:
        --In case mobile app has registered AddCommand requests
        --SDL receives REJECTED <errorCode> on UI.SetGlobalProperties from HMI
        --SDL should log corresponding error internally

        --Precondition for Test case NegativeResponse.5
        function Test:PrintPrecondition()
          userPrint(35, "================= Precondition TC3.5 ==================")
        end
            -- Register App
            Precondition_RegisterApp(self, "TC3.5")
            -- Activate registered App
            ActivationApp(self, "TC3.5")
        --End Precondition for NegativeResponse.5

        -- Test case NegativeResponse.5

        function Test:TC3_5_NoSGPREJECTEDonUISSGPfromHMI()
          userPrint(34, "================= Test Case 3.5 ==================")
            local time = timestamp()
            -- start 10 sec timer
            if (time - TimeRAISuccess) > 10000 then

              -- hmi side: expect UI.SetGlobalProperties request
              local cid = self.hmiConnection:SendRequest("SetGlobalProperties",
                {
                  vrHelp = 
                  {
                      {
                        text = "VRCommand1",
                        position = 1
                      }
                  },
                  
                  helpPrompt = 
                  {
                      {
                        text = "VRCommand1",
                        type = "TEXT"
                      },
                      {
                        text = "300",
                        type = "SILENCE"
                      }
                  },
                  vrHelpTitle = config.application1.registerAppInterfaceParams.appName,

                })
          

      --hmi side: expect UI.SetGlobalProperties request
      EXPECT_HMICALL("UI.SetGlobalProperties",
        {
          vrHelpTitle = config.application1.registerAppInterfaceParams.appName,
          
          vrHelp = { 
                {
                  text = "Command" .. tostring(cmdCount),
                  position = 1
                      } 
                  },
                    appID = self.applications[config.application1.registerAppInterfaceParams.appName]
        })

      :Do(function(_,data)
        --hmi side: sending UI.SetGlobalProperties response
        self.hmiConnection:SendResponse(data.id, data.method, "REJECTED", {})
      end)

      --hmi side: expect TTS.SetGlobalProperties request
      EXPECT_HMICALL("TTS.SetGlobalProperties",
        {
          helpPrompt = 
                      {
                        {
                          text = "Command" .. tostring(cmdCount),
                          type = "TEXT"
                              },
                        {
                          text = "300",
                          type = "SILENCE"
                        }     
                      },                                    
          appID = self.applications[config.application1.registerAppInterfaceParams.appName]
        })

      :Do(function(_,data)
        --hmi side: sending TTS.SetGlobalProperties response
        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
        end)    
      end
    end    
    --End Test case NegativeResponse.5

    --Begin Test case NegativeResponse.6
      --Description: Case when App does NOT send SetGlobalProperties to SDL during 10 sec timer and SDL receives at least to one TTS/UI.SetGlobalProperties <errorCode> from HMI
      --Requirement id in JIRA: APPLINK 23652->reg_4
      --Verification criteria:
        --In case mobile app has registered AddCommand requests
        --SDL receives REJECTED <errorCode> on TTS.SetGlobalProperties from HMI
        --SDL should log corresponding error internally

        --Precondition for Test case NegativeResponse.6
        function Test:PrintPrecondition()
          userPrint(35, "================= Precondition TC3.6 ==================")
        end
            -- Register App
            Precondition_RegisterApp(self, "TC3.6")
            -- Activate registered App
            ActivationApp(self, "TC3.6")
        --End Precondition for NegativeResponse.1

        -- Test case NegativeResponse.6

        function Test:TC3_6_NoSGPREJECTEDonTTSSSGPfromHMI()
          userPrint(34, "================= Test Case 3.6 ==================")
            local time = timestamp()
            -- start 10 sec timer
            if (time - TimeRAISuccess) > 10000 then

              -- hmi side: expect UI.SetGlobalProperties request
              local cid = self.hmiConnection:SendRequest("SetGlobalProperties",
                {
                  vrHelp = 
                  {
                      {
                        text = "VRCommand1",
                        position = 1
                      }
                  },
                  
                  helpPrompt = 
                  {
                      {
                        text = "VRCommand1",
                        type = "TEXT"
                      },
                      {
                        text = "300",
                        type = "SILENCE"
                      }
                  },
                  vrHelpTitle = config.application1.registerAppInterfaceParams.appName,

                })
          
      --hmi side: expect UI.SetGlobalProperties request
      EXPECT_HMICALL("UI.SetGlobalProperties",
        {
          vrHelpTitle = config.application1.registerAppInterfaceParams.appName,
          
          vrHelp = { 
                {
                  text = "Command" .. tostring(cmdCount),
                  position = 1
                      } 
                  },
                    appID = self.applications[config.application1.registerAppInterfaceParams.appName]
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
                          text = "Command" .. tostring(cmdCount),
                          type = "TEXT"
                              },
                        {
                          text = "300",
                          type = "SILENCE"
                        }     
                      },                                    
          appID = self.applications[config.application1.registerAppInterfaceParams.appName]
        })

      :Do(function(_,data)
        --hmi side: sending TTS.SetGlobalProperties response
        self.hmiConnection:SendResponse(data.id, data.method, "REJECTED", {})
        end)    
      end
    end    
    --End Test case NegativeResponse.6


      -- Begin Test case NegativeResponse.7
      -- Description: Case when App does NOT send SetGlobalProperties to SDL during 10 sec timer and SDL doesn't receive response from HMI at least to one TTS/UI.SetGlobalProperties 
      -- Requirement id in JIRA: APPLINK 23652->reg_5
      -- Verification criteria:
      --   In case mobile app has registered AddCommand requests
      --   SDL doesn't receive response on UI.SetGlobalProperties from HMI
      --   SDL should log corresponding error internally

      --   Precondition for Test case NegativeResponse.7

        function Test:PrintPrecondition()
          userPrint(35, "================= Precondition TC3.7 ==================")
        end
            -- Register App
            Precondition_RegisterApp(self, "TC3.7")
            -- Activate registered App
            ActivationApp(self, "TC3.7")
        --End Precondition for NegativeResponse.7
 
        -- Begin Test Case NegativeResponse.7
        function Test:TC3_8_NoSGP_from_App_during_10secTimer()
           userPrint(34, "================= Test Case 3.7 ==================")
              
            local time = timestamp()

              if (time - TimeRAISuccess) > 10000 then

                -- hmi side: expect UI.SetGlobalProperties request
                local cid = self.hmiConnection:SendRequest("SetGlobalProperties",
                  {
                    vrHelp = 
                    {
                        {
                          text = "VRCommand1",
                          position = 1
                        }
                    },
                    
                    helpPrompt = 
                    {
                        {
                          text = "VRCommand1",
                          type = "TEXT"
                        },
                        {
                          text = "300",
                          type = "SILENCE"
                        }
                    },
                    vrHelpTitle = config.application1.registerAppInterfaceParams.appName

                  })

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

          --mobile side: expect SetGlobalProperties response
          EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
          :Times(0)

          end
        end

        for cmdCount = 1, 1 do
          Test["NoSGP+NoResponse_on_UI.SGP_from_HMI" .. cmdCount] = function(self)
          AddCommand(self, cmdCount)
          end
        end 

        local time = timestamp()

        if( (time - TimeRAISuccess) < 10000 and (time - TimeRAISuccess) > 0 ) then

        --hmi side: expect UI.SetGlobalProperties request
        EXPECT_HMICALL("UI.SetGlobalProperties",
        {
          vrHelpTitle = config.application1.registerAppInterfaceParams.appName,
          
          vrHelp = { 
                {
                  text = "Command" .. tostring(cmdCount),
                  position = 1
                      } 
                                                                             },
          appID = self.applications[config.application1.registerAppInterfaceParams.appName]
        })

        --hmi side: sending UI.SetGlobalProperties response
        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
        :Times(0) 
   


        --hmi side: expect TTS.SetGlobalProperties request
        EXPECT_HMICALL("TTS.SetGlobalProperties",
        {
          helpPrompt = 
                {
                  {
                    text = "Command" .. tostring(cmdCount),
                    type = "TEXT"
                        },
                  {
                    text = "300",
                    type = "SILENCE"
                  }     
                },                                    
          appID = self.applications[config.application1.registerAppInterfaceParams.appName]
        })


        :Do(function(_,data)          
          --hmi side: sending UI.SetGlobalProperties response
          self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
        end) 

        end
      -- End Test case NegativeResponse.7

      -- Begin Test case NegativeResponse.8
      -- Description: Case when App does NOT send SetGlobalProperties to SDL during 10 sec timer and SDL doesn't receive response from HMI at least to one TTS/UI.SetGlobalProperties 
      -- Requirement id in JIRA: APPLINK 23652->reg_5
      -- Verification criteria:
      --   In case mobile app has registered AddCommand requests
      --   SDL doesn't receive response on TTS.SetGlobalProperties from HMI
      --   SDL should log corresponding error internally
         
      -- Precondition for Test case NegativeResponse.8
        function Test:PrintPrecondition()
          userPrint(35, "================= Precondition TC3.8 ==================")
        end
            -- Register App
            Precondition_RegisterApp(self, "TC3.8")
            -- Activate registered App
            ActivationApp(self, "TC3.8")
        --End Precondition for NegativeResponse.8
 
        -- Begin Test Case NegativeResponse.8
        function Test:TC3_8_NoSGP_from_App_during_10secTimer()
           userPrint(34, "================= Test Case 3.8 ==================")
              
            local time = timestamp()

              if (time - TimeRAISuccess) > 10000 then

                -- hmi side: expect UI.SetGlobalProperties request
                local cid = self.hmiConnection:SendRequest("SetGlobalProperties",
                  {
                    vrHelp = 
                    {
                        {
                          text = "VRCommand1",
                          position = 1
                        }
                    },
                    
                    helpPrompt = 
                    {
                        {
                          text = "VRCommand1",
                          type = "TEXT"
                        },
                        {
                          text = "300",
                          type = "SILENCE"
                        }
                    },
                    vrHelpTitle = config.application1.registerAppInterfaceParams.appName

                  })

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

          --mobile side: expect SetGlobalProperties response
          EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
          :Times(0)

          end
        end

        for cmdCount = 1, 1 do
          Test["NoSGP+NoResponse_on_UI.SGP_from_HMI" .. cmdCount] = function(self)
          AddCommand(self, cmdCount)
          end
        end 

        local time = timestamp()

        if( (time - TimeRAISuccess) < 10000 and (time - TimeRAISuccess) > 0 ) then

        --hmi side: expect UI.SetGlobalProperties request
        EXPECT_HMICALL("UI.SetGlobalProperties",
        {
          vrHelpTitle = config.application1.registerAppInterfaceParams.appName,
          
          vrHelp = { 
                {
                  text = "Command" .. tostring(cmdCount),
                  position = 1
                      } 
                                                                             },
          appID = self.applications[config.application1.registerAppInterfaceParams.appName]
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
                    text = "Command" .. tostring(cmdCount),
                    type = "TEXT"
                        },
                  {
                    text = "300",
                    type = "SILENCE"
                  }     
                },                                    
          appID = self.applications[config.application1.registerAppInterfaceParams.appName]
        })


        --hmi side: sending TTS.SetGlobalProperties response
        self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
        :Times(0) 

        end
    --End Test case NegativeResponse.8

 --End Test suit NegativeResponse
----------------------------------------------------------------------------------------------
----------------------------------------IV TEST BLOCK-----------------------------------------
---------------------------------------Result codes check-------------------------------------
------------------Check of each resultCode + success (true, false)----------------------------

   --These test shall be performed in tests for testing API SetGlobalProperties. 
   --See ATF_SetGlobalProperties.lua

----------------------------------------------------------------------------------------------
----------------------------------------V TEST BLOCK------------------------------------------
------------------------------------ HMI negative cases---------------------------------------
----------------------------------incorrect data from HMI-------------------------------------

  --These test shall be performed in tests for testing API SetGlobalProperties.
  --See ATF_SetGlobalProperties.lua

----------------------------------------------------------------------------------------------
----------------------------------------VI TEST BLOCK-----------------------------------------
--------------------------Sequence with emulating of user's action(s)-------------------------
----------------------------------------------------------------------------------------------
  --Begin Test suit EmulatingUserAction
    --Begin Test case EmulatingUserAction.1
      --Description: Case when App does NOT send SetGlobalProperties to SDL during 10 sec timer + AddCommand request
      --Requirement id in JIRA: APPLINK 23652->reg_3
                        --Verification criteria:
        --In case mobile app has no registered AddCommand requests
        --SDL should update internal list with new values of "vrHelp" and "helpPrompt" params ONLY after successfull AddCommand response from HMI
        --SDL should send updated "vrHelp" and "helpPrompt" via TTS/UI.SetGlobalProperties to HMI till App sends SetGlobalProperties request with valid <vrHelp> and <helpPrompt> params to SDL
 
            -- Precondition for Test case EmulatingUserAction.1
            function Test:PrintPrecondition()
              userPrint(35, "================= Precondition TC4.1 ==================")
            end
            -- Register App
            Precondition_RegisterApp(self, "TC4.1")
            -- Activate registered App
            ActivationApp(self, "TC4.1")
            --End Precondition for Test case EmulatingUserAction.1
 
        -- Test case EmulatingUserAction.2

        function Test:TC4_1_NoSGP_from_App_during_10secTimer()
          userPrint(34, "================= Test Case 4.1 ==================")
            -- start main part of TC
            local time = timestamp()
            -- start 10 sec timer
            if (time - TimeRAISuccess) > 10000 then

          -- hmi side: expect UI.SetGlobalProperties request
              local cid = self.hmiConnection:SendRequest("SetGlobalProperties",
                {
                  vrHelp = 
                  {
                      {
                        text = "VRCommand1",
                        position = 1
                      }
                  },
                  
                  helpPrompt = 
                  {
                      {
                        text = "VRCommand1",
                        type = "TEXT"
                      },
                      {
                        text = "300",
                        type = "SILENCE"
                      }
                  },
                  vrHelpTitle = config.application1.registerAppInterfaceParams.appName,

                })
          
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


        -- App has registered AddCommand
        for cmdCount = 1, 1 do
          Test["TC4.1_AddCommand_" .. cmdCount] = function(self)
            AddCommand(self, cmdCount)
          end
        end 

       Test["TC4.1_CheckInternalList_AddCommand"] = function(self)
              local SGP_helpPrompt = {}
              local SGP_vrHelp = {}
              
              if(AddCmdSuccess[cmdCount] == true) then
                SGP_helpPrompt[1] ={
                                    text = "Command" .. tostring(cmdCount),
                                    type = "TEXT" }
                SGP_helpPrompt[2] ={
                                    text = "300",
                                    type = "SILENCE" }
                
                SGP_vrHelp[1] = { 
                                  text = "Command" .. tostring(cmdCount), 
                                  position = 1
                                }
              else
                SGP_helpPrompt[1] ={
                                      text = default_HelpPromt,
                                      type = "TEXT" }               
                SGP_vrHelp[1] = { 
                                  text = config.application1.registerAppInterfaceParams.appName,
                                  position = 1
                                }
              end
              
              CheckUpdateFile(self, SGP_helpPrompt, SGP_vrHelp)
            end
          
         function Test:TC4_1_NoSGP_from_App_during_10secTimer()
              local time = timestamp()

              if( (time - TimeRAISuccess) < 10000 and (time - TimeRAISuccess) > 0 ) then
          
          --hmi side: expect UI.SetGlobalProperties request
          EXPECT_HMICALL("UI.SetGlobalProperties",
                          {
                            vrHelpTitle = config.application1.registerAppInterfaceParams.appName,
                            
                            vrHelp = { 
                                  {
                                    text = "Command" .. tostring(cmdCount),
                                    position = 1
                                        } 
                                       },
                            appID = self.applications[config.application1.registerAppInterfaceParams.appName]
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
                                            text = "Command" .. tostring(cmdCount),
                                            type = "TEXT"
                                                },
                                          {
                                            text = "300",
                                            type = "SILENCE"
                                          }     
                                        },                                    
                            appID = self.applications[config.application1.registerAppInterfaceParams.appName]
                          })

          :Do(function(_,data)
          --hmi side: sending TTS.SetGlobalProperties response
          self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
          end)

      end
    end
    --End Test case EmulatingUserAction.1


    --Begin Test case EmulatingUserAction.2
      --Description: Case when App does NOT send SetGlobalProperties to SDL during 10 sec timer + default values + AddCommand FAIL
      --Requirement id in JIRA: APPLINK 23652->reg_3
      --Verification criteria:
        --In case mobile app has registered AddCommand/DeleteCommand requests
        --SDL should update internal list with new values of "vrHelp" and "helpPrompt" params ONLY after successfull AddCommand response from HMI
        --SDL should send updated "vrHelp" and "helpPrompt" via TTS/UI.SetGlobalProperties to HMI till App sends SetGlobalProperties request with valid <vrHelp> and <helpPrompt> params to SDL
        -- <vrHelp> and <helpPrompt> in internal list after AddCommand FAIL shouldnt be updated
            --Precondition for Test case EmulatingUserAction.2
            function Test:PrintPrecondition()
              userPrint(35, "================= Precondition TC4.2 ==================")
            end
            -- Register App
            Precondition_RegisterApp(self, "TC4.2")
            -- Activate registered App
            ActivationApp(self, "TC4.2")
            --End Precondition for Test case EmulatingUserAction.2

        -- Test case EmulatingUserAction.2

        function Test:TC4_2_NoSGP_from_App_during_10secTimer()
          userPrint(34, "================= Test Case 4.2 ==================")
        -- start main part of TC
            local time = timestamp()
            -- start 10 sec timer
            if (time - TimeRAISuccess) > 10000 then

             -- hmi side: expect UI.SetGlobalProperties request
              local cid = self.hmiConnection:SendRequest("SetGlobalProperties",
                {
                  vrHelp = 
                  {
                      {
                        text = "VRCommand1",
                        position = 1
                      }
                  },
                  
                  helpPrompt = 
                  {
                      {
                        text = "VRCommand1",
                        type = "TEXT"
                      },
                      {
                        text = "300",
                        type = "SILENCE"
                      }
                  },
                  vrHelpTitle = config.application1.registerAppInterfaceParams.appName,

                })
          
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

    -- AddCommand unsuccessfully 
    function Test:TC4_2_AddCmdFAILED()

            AddCommandFAIL(self)
       end

    -- Check internal list wasn't updated if AddCommand FAILED    
    function Test:TC4_2_NoUpdateFileAddCommandFailed()
      local cid = self.mobileSession:SendRPC("SetGlobalProperties",{menuTitle = "Menu Title"})

      --hmi side: expect UI.SetGlobalProperties request
      EXPECT_HMICALL("UI.SetGlobalProperties",
          {
            vrHelpTitle = config.application1.registerAppInterfaceParams.appName,
            
            vrHelp ={
                 {
                  text = config.application1.registerAppInterfaceParams.appName,
                  position = 1
                  } 
                },  
            appID = self.applications[config.application1.registerAppInterfaceParams.appName]
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
                  },                                    
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

    --End Test case EmulatingUserAction.2


    --Begin Test case EmulatingUserAction.3
      --Description: Case when App does NOT send SetGlobalProperties to SDL during 10 sec timer + values from intrnal list + AddCommand(success)
      --Requirement id in JIRA: APPLINK 23652->reg_3
      --Verification criteria:
        --In case mobile app has registered AddCommand/DeleteCommand requests
        --SDL should update internal list with new values of "vrHelp" and "helpPrompt" params after successfull AddCommand response from HMI
        --SDL should send updated "vrHelp" and "helpPrompt" via TTS/UI.SetGlobalProperties to HMI till App sends SetGlobalProperties request with valid <vrHelp> and <helpPrompt> params to SDL
        -- <vrHelp> and <helpPrompt> in internal list after AddCommand should be updated
            --Precondition for Test case EmulatingUserAction.4
            function Test:PrintPrecondition()
              userPrint(35, "================= Precondition TC4.3 ==================")
            end
            -- Register App
            Precondition_RegisterApp(self, "TC4.3")
            -- Activate registered App
            ActivationApp(self, "TC4.3")
            --End Precondition for Test case EmulatingUserAction.4

        -- Test case EmulatingUserAction.3

        function Test:TC4_3_NoSGP_from_App_during_10secTimer()
          userPrint(34, "================= Test Case 4.3 ==================")
        -- start main part of TC
            local time = timestamp()
            -- start 10 sec timer
            if (time - TimeRAISuccess) > 10000 then

             -- hmi side: expect UI.SetGlobalProperties request
              local cid = self.hmiConnection:SendRequest("SetGlobalProperties",
                {
                  vrHelp = 
                  {
                      {
                        text = "VRCommand1",
                        position = 1
                      }
                  },
                  
                  helpPrompt = 
                  {
                      {
                        text = "VRCommand1",
                        type = "TEXT"
                      },
                      {
                        text = "300",
                        type = "SILENCE"
                      }
                  },
                  vrHelpTitle = config.application1.registerAppInterfaceParams.appName,

                })
          
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
     
      -- AddCommand (success)
      for cmdCount = 1, 1 do
        Test["TC4.3_AddCommand_" .. cmdCount] = function(self)
          AddCommand(self, cmdCount)
        end
      end 
      
      -- internal list should be updated with values if vrHelp and helpPrpmpt after successfull AddCommand
      function Test:TC4_3_CheckInternalList_AddCommandSuccess()
          local SGP_helpPrompt = {}
          local SGP_vrHelp = {}
          
          if(AddCmdSuccess[cmdCount] == true) then
            SGP_helpPrompt[1] ={
                                text = "Command" .. tostring(cmdCount),
                                type = "TEXT" }
            SGP_helpPrompt[2] ={
                                text = "300",
                                type = "SILENCE" }
            
            SGP_vrHelp[1] = { 
                              text = "Command" .. tostring(cmdCount), 
                              position = 1
                            }
          else
            SGP_helpPrompt[1] ={
                                  text = default_HelpPromt,
                                  type = "TEXT" }               
            SGP_vrHelp[1] = { 
                              text = config.application1.registerAppInterfaceParams.appName,
                              position = 1
                            }
          end
          
          CheckUpdateFile(self, SGP_helpPrompt, SGP_vrHelp)
        end


    function Test:TC4_3_NoSGP_from_App_during_10secTimer()
              local time = timestamp()

              if( (time - TimeRAISuccess) < 10000 and (time - TimeRAISuccess) > 0 ) then
          
          --hmi side: expect UI.SetGlobalProperties request
          EXPECT_HMICALL("UI.SetGlobalProperties",
                          {
                            vrHelpTitle = config.application1.registerAppInterfaceParams.appName,
                            
                            vrHelp = { 
                                  {
                                    text = "Command" .. tostring(cmdCount),
                                    position = 1
                                        } 
                                       },
                            appID = self.applications[config.application1.registerAppInterfaceParams.appName]
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
                                            text = "Command" .. tostring(cmdCount),
                                            type = "TEXT"
                                                },
                                          {
                                            text = "300",
                                            type = "SILENCE"
                                          }     
                                        },                                    
                            appID = self.applications[config.application1.registerAppInterfaceParams.appName]
                          })

          :Do(function(_,data)
          --hmi side: sending TTS.SetGlobalProperties response
          self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
          end)

      end
    end

    --End Test case EmulatingUserAction.3


  --Begin Test case EmulatingUserAction.4
      --Description: Case when App does NOT send SetGlobalProperties to SDL during 10 sec timer + values from intrnal list + AddCommand(fail)
      --Requirement id in JIRA: APPLINK 23652->reg_3
      --Verification criteria:
        --In case mobile app has registered AddCommand/DeleteCommand requests
        --SDL should update internal list with new values of "vrHelp" and "helpPrompt" params after successfull AddCommand response from HMI
        --SDL should send updated "vrHelp" and "helpPrompt" via TTS/UI.SetGlobalProperties to HMI till App sends SetGlobalProperties request with valid <vrHelp> and <helpPrompt> params to SDL
        -- <vrHelp> and <helpPrompt> in internal list after AddCommand should be updated
            --Precondition for Test case EmulatingUserAction.4
            function Test:PrintPrecondition()
              userPrint(35, "================= Precondition TC4.4 ==================")
            end
            -- Register App
            Precondition_RegisterApp(self, "TC4.4")
            -- Activate registered App
            ActivationApp(self, "TC4.4")
            --End Precondition for Test case EmulatingUserAction.4

        -- Test case EmulatingUserAction.4

        function Test:TC4_4_NoSGP_from_App_during_10secTimer()
          userPrint(34, "================= Test Case 4.4 ==================")
        -- start main part of TC
            local time = timestamp()
            -- start 10 sec timer
            if (time - TimeRAISuccess) > 10000 then

             -- hmi side: expect UI.SetGlobalProperties request
              local cid = self.hmiConnection:SendRequest("SetGlobalProperties",
                {
                  vrHelp = 
                  {
                      {
                        text = "VRCommand1",
                        position = 1
                      }
                  },
                  
                  helpPrompt = 
                  {
                      {
                        text = "VRCommand1",
                        type = "TEXT"
                      },
                      {
                        text = "300",
                        type = "SILENCE"
                      }
                  },
                  vrHelpTitle = config.application1.registerAppInterfaceParams.appName,

                })
          
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
     
    -- AddCommand unsuccessfully 
    function Test:TC4_4_AddCmdFAILED()

            AddCommandFAIL(self)
       end

    -- Check internal list wasn't updated if AddCommand FAILED 
    function Test:TC4_4_CheckInternalListAddCommandFAILED()
              local SGP_helpPrompt = {}
              local SGP_vrHelp = {}
              SGP_helpPrompt[1] ={
                                text = "Command" .. tostring(cmdCount),
                                type = "TEXT" }
              SGP_helpPrompt[2] ={
                                text = "300",
                                type = "SILENCE" }
                
              SGP_vrHelp[1] = { text = "Command" .. tostring(cmdCount) }
              
              CheckUpdateFile(self, SGP_helpPrompt, SGP_vrHelp)


          end   
    -- Check internal list wasn't updated if AddCommand FAILED 
    function Test:TC4_4_NoUpdateFileAddCommandFailed()
      local cid = self.mobileSession:SendRPC("SetGlobalProperties",{menuTitle = "Menu Title"})

      --hmi side: expect UI.SetGlobalProperties request
      EXPECT_HMICALL("UI.SetGlobalProperties",
          {
            vrHelpTitle = config.application1.registerAppInterfaceParams.appName,
            
            vrHelp ={
                 {
                  text = config.application1.registerAppInterfaceParams.appName,
                  position = 1
                  } 
                },  
            appID = self.applications[config.application1.registerAppInterfaceParams.appName]
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
                  },                                    
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

    --End Test case EmulatingUserAction.4

----------------------------------------------------------------------------------------------
----------------------------------------VII TEST BLOCK----------------------------------------
-------------------------------------Different HMIStatus--------------------------------------

 --These test shall be performed in tests for testing API SetGlobalProperties.
  --See ATF_SetGlobalProperties.lua

---------------------------------------------------------------------------------------------
-------------------------------------------Postconditions------------------------------------
---------------------------------------------------------------------------------------------

  function Test:Postcondition_remove_user_connecttest_restore_preloaded_file()
    userPrint(34, "================= Postcondition ==================")
        os.execute(" cp " .. config.pathToSDL .. "sdl_preloaded_pt_origin.json " .. config.pathToSDL .. "sdl_preloaded_pt.json" )
        os.execute(" rm -f " .. config.pathToSDL .. "/sdl_preloaded_pt_origin.json" ) 
  end

