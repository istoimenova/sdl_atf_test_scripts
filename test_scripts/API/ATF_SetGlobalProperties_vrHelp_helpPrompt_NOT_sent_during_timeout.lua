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

	
function TextPrint(message)
    if(message == "Postconditions") then
	function Test:PrintPostcond()
		userPrint(34,"========================================= Postconditions ==========================================")
	end
    else
	function Test:PrintMes()
		userPrint(33,"------------------------------------------- ".. message .." -------------------------------------------")
	end
    end
end

function TCBody(self, numberOfTC)
	TextPrint("TC"..numberOfTC)
end


function Check_menuIconParams(data, type_icon, value)

    if( (value == nil) or (#value == 0) ) then value = "action.png" end
    if(type_icon == nil) then type_icon = "DYNAMIC" end

     local result = true
     local path  = "bin/storage/"..config.application1.registerAppInterfaceParams.appID.. "_" .. config.deviceMAC.. "/"
     local value_Icon = value--"action.png"
	
     if (type_icon == "DYNAMIC") then
	value_Icon = path .. value--"action.png"
end
	
        
    --if (data.params.menuIcon.imageType ~= "DYNAMIC") then
    if (data.params.menuIcon.imageType ~= type_icon) then
    	print("\27[31m imageType of menuIcon is WRONG. Expected: ".. type_icon.."; Real: " .. data.params.menuIcon.imageType .. "\27[0m")
    	result = false
    end

    if(string.find(data.params.menuIcon.value, value_Icon) ) then

    else
    	print("\27[31m value of menuIcon is WRONG. Expected: ~/".. value_Icon .. "; Real: " .. data.params.menuIcon.value .. "\27[0m")
    	result = false
    end

    return result
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


function copy_table(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end


--Registering application

function Precondition_RegisterApp(self, nameTC)

	TextPrint("Precondition_"..nameTC)

	commonSteps:UnregisterApplication(nameTC .."_UnregisterApplication")	

	commonSteps:StartSession(nameTC .."_StartSession")

	Test[nameTC .."_RegisterApp"] = function(self)

		self.mobileSession:StartService(7)
		:Do(function()	
			local CorIdRegister = self.mobileSession:SendRPC("RegisterAppInterface", config.application1.registerAppInterfaceParams)
			EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", 
														{ application = {	appName = config.application1.registerAppInterfaceParams.appName }})
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
		cmdID = 11,
		menuParams = 	
		{ 
					
			menuName ="SGP test"
		}, 
		vrCommands = 
		{ 
			"SGP test",
			"SGP"
		}
	})
			
	--UI
	EXPECT_HMICALL("UI.AddCommand", 
	{ 
		cmdID = 11,
		menuParams = 
		{ 
			menuName ="SGP test"
		}
	})
	:Do(function(_,data)
	self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
	end)
			
	--VR
	EXPECT_HMICALL("VR.AddCommand", 
	{ 
		cmdID = 11,
		vrCommands = 
		{
			"SGP test",
			"SGP"
		}
	})
	:Do(function(_,data)
	self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
	end)		
			
	EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
	EXPECT_NOTIFICATION("OnHashChange")
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

		--Begin Test case PositiveResponseCheck.1
			--Description: Case when App does NOT send SetGlobalProperties request to SDL during 10 sec timer + default_values
			--Requirement id in JIRA: APPLINK-19475, APPLINK-23652->reg_2
			--Verification criteria:
				--In case mobile app has NO registered AddCommands and/or DeleteCommands requests:
					-- SDL must use current appName as default value for "vrHelp" parameter
					-- SDL must retrieve value of "helpPrompt" from .ini file ([GLOBAL PROPERTIES] section -> "HelpPrompt" param)
				-- SDL sends UI.SetGlobalProperties(<default_vrHelp>, params) and TTS.SetGlobalProperties(<default_helpPrompt>, params) to HMI 

			--Precondition to PositiveResponseCheck.2

			  Precondition_RegisterApp(self, "TC1")
			--End Precondition to PositiveResponseCheck.2

                                TCBody(self, "1")

				Test["TC1_NoSGP_from_App_during_10secTimer"] = function(self)

	                        local time = timestamp()

				if (time - TimeRAISuccess) > 10000 then

					--mobile side: sending SetGlobalProperties request
				        local cid = self.mobileSession:SendRPC("SetGlobalProperties", {})
                                        :Times(0)
					
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


		--End Test case PositiveResponseCheck.1


		--Begin Test case PositiveResponseCheck.2
			--Description: Case when App does NOT send SetGlobalProperties request to SDL during 10 sec timer + values from internal list
			--Requirement id in JIRA: APPLINK-19474, APPLINK-26644, APPLINK-23652->reg_1
			--Verification criteria:
				--In case mobile app has registered AddCommands requests (previously added)
				-- SDL must provide the value of "helpPrompt" and "vrHelp" based on registered AddCommands and DeleteCommands requests to HMI: 
					-- SDL sends UI.SetGlobalProperties(<vrHelp_from_list>, params) and TTS.SetGlobalProperties(<helpPrompt_from_list>, params) to HMI 

				-- Precondition to PositiveResponseCheck.2

				  Precondition_RegisterApp(self, "TC2")

				  ActivationApp(self, "TC2")

					for cmdCount = 1, 1 do
						Test["TC2_Precondition_AddCommandInitial_" .. cmdCount] = function(self)
							AddCommand(self, cmdCount)
						end
					end 

				--End Precondition to PositiveResponseCheck.2

					TCBody(self, "2")

					Test["TC2_NoSGP+vrHelp&helpPrompt_from_intList"] = function(self)

						local time = timestamp()

						if (time - TimeRAISuccess) > 10000 then

							--mobile side: sending SetGlobalProperties request
							local cid = self.mobileSession:SendRPC("SetGlobalProperties", {})
				                        :Times(0)

							--hmi side: expect UI.SetGlobalProperties request
							EXPECT_HMICALL("UI.SetGlobalProperties",
															{
																vrHelpTitle = config.application1.registerAppInterfaceParams.appName,
														
																vrHelp ={
																					{
																						text = "VRCommand1",
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
					 			--hmi side: sending TTS.SetGlobalProperties response
					 			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
							end)		

							--mobile side: expect SetGlobalProperties response
							EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
							:Times(0)
					
							--mobile side: expect OnHashChange notification
							EXPECT_NOTIFICATION("OnHashChange")
							:Times(0)
						end

					end
				--End Test case PositiveResponseCheck.2

			   --[[	--[TODO:uncomment after APPLINK-16610, APPLINK-16094, APPLINK-26394 are fixed]
			
				--Begin Test case PositiveResponseCheck.3
					--Description: Case when App does NOT send SetGlobalProperties request to SDL during 10 sec timer + values from internal list
					--Requirement id in JIRA: APPLINK-19474, APPLINK-26644, APPLINK-23652->reg_1
					--Verification criteria:
						--In case mobile app has registered AddCommands and/or DeleteCommands requests (resumed within data resumption process)
						-- SDL must provide the value of "helpPrompt" and "vrHelp" based on registered AddCommands and DeleteCommands requests to HMI: 
							-- SDL sends UI.SetGlobalProperties(<vrHelp_from_list>, params) and TTS.SetGlobalProperties(<helpPrompt_from_list>, params) to HMI 

				  	 --Precondition to PositiveResponseCheck.3
						Precondition_RegisterApp(self, "TC2.1")
						Test["TC2.1_Suspend"] = function(self)
							self.hmiConnection:SendNotification("BasicCommunication.OnExitAllApplications", { reason = "SUSPEND" })
							--Requirement Jira ID: APPLINK-15702
							--Send BC.OnPersistanceComplete to HMI on data persistance complete			
							-- hmi side: expect OnSDLPersistenceComplete notification
							EXPECT_HMINOTIFICATION("BasicCommunication.OnSDLPersistenceComplete")
						end

						Test["TC2.1_Ignion_OFF"] = function(self)
							-- hmi side: sends OnExitAllApplications (IGNITION_OFF)
							self.hmiConnection:SendNotification("BasicCommunication.OnExitAllApplications", { reason = "IGNITION_OFF"})

							-- hmi side: expect OnSDLClose notification
							EXPECT_HMINOTIFICATION("BasicCommunication.OnSDLClose")

							-- hmi side: expect OnAppUnregistered notification
							EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered")
							:Times(1)
							StopSDL()
						end
					
						Test["TC2.1_StartSDL"] = function(self)
					
							StartSDL(config.pathToSDL, config.ExitOnCrash)
						end

						Test["TC2.1_InitHMI"] = function(self)
					
							self:initHMI()
						end

						Test["TC2.1_InitHMIOnReady"] = function(self)

							self:initHMI_onReady()
						end

						Test["TC2.1_ConnectMobile"] = function (self)

							self:connectMobile()
						end

						Test["TC2.1_StartSession"] = function(self)
						
							CreateSession(self)
						end

						Test["TC2.1_RegisterAppResumption"] = function (self)
							self.mobileSession:StartService(7)
							:Do(function()	
								local CorIdRegister = self.mobileSession:SendRPC("RegisterAppInterface", config.application1.registerAppInterfaceParams)
								EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", 
																		{
						  												application = {	appName = config.application1.registerAppInterfaceParams.appName }
																		})
								:Do(function(_,data)
									TimeRAISuccess = timestamp()
					  			self.applications[data.params.application.appName] = data.params.application.appID
								end)

								self.mobileSession:ExpectResponse(CorIdRegister, { success = true, resultCode = "SUCCESS" })
								:Timeout(2000)

								self.mobileSession:ExpectNotification("OnHMIStatus", {hmiLevel = "BACKGROUND", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
							end)

							local UIAddCommandValues = {}
							for m=1,1 do
								UIAddCommandValues[m] = {cmdID = m, menuParams = { menuName ="Command" .. tostring(m)}}
							end

							EXPECT_HMICALL("UI.AddCommand")
							:ValidIf(function(_,data)
								for i=1, #UIAddCommandValues do
									if (data.params.cmdID == UIAddCommandValues[i].cmdID ) and
										 (data.params.menuParams.position == 0 ) and 
										 (data.params.menuParams.menuName == UIAddCommandValues[i].menuParams.menuName ) then
										
											return true
									elseif (i == #UIAddCommandValues) then
										userPrint(31, "Any matches")
										userPrint(31, "Actual values cmdID ='" .. tostring(data.params.cmdID) .. "', position = '" .. tostring(data.params.menuParams.position) .. "', menuName = '" .. tostring(data.params.menuParams.menuName ) .. "'"  )
										return false
									end
								end
							end)
							:Do(function(_,data)
								--hmi side: sending UI.AddCommand response 
								self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
							end)
							:Times(1)
						end

		                        TCBody(self, "2.1")
		
					Test["TC2.1_No_SGP_After_Resumption"] = function(self)

					local time = timestamp()

						if (time - TimeRAISuccess) > 10000 then

						--mobile side: sending SetGlobalProperties request
						local cid = self.mobileSession:SendRPC("SetGlobalProperties", {})
				                :Times(0)


						       --hmi side: expect UI.SetGlobalProperties request
							EXPECT_HMICALL("UI.SetGlobalProperties",
															{
																vrHelpTitle = config.application1.registerAppInterfaceParams.appName,
														
																vrHelp ={
																					{
																						text = "VRCommand1",
																						position = 1
																				        }
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
																						text = "VRCommand1",
																						type = "TEXT"
																					},
																					{
																						text = "300",
																						type = "SILENCE"
																					}
																appID = self.applications[config.application1.registerAppInterfaceParams.appName]
															})

						:Do(function(_,data)
					 		--hmi side: sending TTS.SetGlobalProperties response
					 		self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
						end)		

						--mobile side: expect SetGlobalProperties response
						EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
					        :Times(0)

						--mobile side: expect OnHashChange notification
						EXPECT_NOTIFICATION("OnHashChange")
						:Times(0)
						end

					end

			--End Test case PositiveResponseCheck.3
			--]]
				
	--End Test suit PositiveResponseCheck

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

			                Precondition_RegisterApp(self, "TC3")

					ActivationApp(self, "TC3")

			         --End precondition for NegativeResponse.1

					TCBody(self, "3")

					Test["TC3_NoSGP_from_App_during_10secTimer"] = function(self)

			                local time = timestamp()

					if (time - TimeRAISuccess) > 10000 then

					--mobile side: sending SetGlobalProperties request
				        local cid = self.mobileSession:SendRPC("SetGlobalProperties", {})
                                        :Times(0)
					
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
						Test["NoSGP+GENERIC_ERROR_on_UI.SGP_from_HMI" .. cmdCount] = function(self)
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


					--mobile side: expect SetGlobalProperties response
					EXPECT_RESPONSE(cid, { success = true, resultCode = "GENERIC_ERROR"})
                                        :Times(0)

					end
							
		
		--End Test case NegativeResponse.1
                
		--Begin Test case NegativeResponse.2
			--Description: Case when App does NOT send SetGlobalProperties to SDL during 10 sec timer and SDL receives at least to one TTS/UI.SetGlobalProperties <errorCode> from HMI
			--Requirement id in JIRA: APPLINK 23652->reg_4
			--Verification criteria:
				--In case mobile app has registered AddCommand requests (previously added)
				--SDL receives GENERIC_ERROR <errorCode> on TTS.SetGlobalProperties from HMI
				--SDL should log corresponding error internally

				--Precondition for NegativeResponse.2

			          Precondition_RegisterApp(self, "TC4")

				  ActivationApp(self, "TC4")

				--End precondition for NegativeResponse.2

					TCBody(self, "4")

					Test["TC4_NoSGP_from_App_during_10secTimer"] = function(self)

			                local time = timestamp()

					if (time - TimeRAISuccess) > 10000 then

					--mobile side: sending SetGlobalProperties request
				        local cid = self.mobileSession:SendRPC("SetGlobalProperties", {})
                                        :Times(0)
					
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
						Test["NoSGP+GENERIC_ERROR_on_TTS.SGP_from_HMI" .. cmdCount] = function(self)
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

					:Do(function(_,data)
			 			--hmi side: sending TTS.SetGlobalProperties response
			 			self.hmiConnection:SendResponse(data.id, data.method, "GENERIC_ERROR", {})
					end)		


					--mobile side: expect SetGlobalProperties response
					EXPECT_RESPONSE(cid, { success = true, resultCode = "GENERIC_ERROR"})
                                        :Times(0)

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

			          Precondition_RegisterApp(self, "TC5")

				  ActivationApp(self, "TC5")

				--End precondition for NegativeResponse.3

					TCBody(self, "5")

					Test["TC5_NoSGP_from_App_during_10secTimer"] = function(self)

			                local time = timestamp()

					if (time - TimeRAISuccess) > 10000 then

					--mobile side: sending SetGlobalProperties request
				        local cid = self.mobileSession:SendRPC("SetGlobalProperties", {})
                                        :Times(0)
					
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
														--appID = self.applications[config.application1.registerAppInterfaceParams.appName]
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
														--appID = self.applications[config.application1.registerAppInterfaceParams.appName]
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
						Test["NoSGP+UNSUP_RES_on_UI.SGP_from_HMI" .. cmdCount] = function(self)
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


					--mobile side: expect SetGlobalProperties response
					EXPECT_RESPONSE(cid, { success = true, resultCode = "UNSUPPORTED_RESOURCE"})
                                        :Times(0)

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

			          Precondition_RegisterApp(self, "TC6")

			          ActivationApp(self, "TC6")

			        --End precondition for NegativeResponse.4

					TCBody(self, "6")

					Test["TC6_NoSGP_from_App_during_10secTimer"] = function(self)

			                local time = timestamp()

					if (time - TimeRAISuccess) > 10000 then

					--mobile side: sending SetGlobalProperties request
				        local cid = self.mobileSession:SendRPC("SetGlobalProperties", {})
                                        :Times(0)
					
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
						Test["NoSGP+UNSUP_RES_on_TTS.SGP_from_HMI" .. cmdCount] = function(self)
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

					:Do(function(_,data)
			 			--hmi side: sending TTS.SetGlobalProperties response
			 			self.hmiConnection:SendResponse(data.id, data.method, "UNSUPPORTED_RESOURCE", {})
					end)		


					--mobile side: expect SetGlobalProperties response
					EXPECT_RESPONSE(cid, { success = true, resultCode = "UNSUPPORTED_RESOURCE"})
                                        :Times(0)

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

			          Precondition_RegisterApp(self, "TC7")

			          ActivationApp(self, "TC7")

				--End precondition for NegativeResponse.5

					TCBody(self, "7")

					Test["TC7_NoSGP_from_App_during_10secTimer"] = function(self)

			                local time = timestamp()

					if (time - TimeRAISuccess) > 10000 then

					--mobile side: sending SetGlobalProperties request
				        local cid = self.mobileSession:SendRPC("SetGlobalProperties", {})
                                        :Times(0)
					
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
														--appID = self.applications[config.application1.registerAppInterfaceParams.appName]
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
														--appID = self.applications[config.application1.registerAppInterfaceParams.appName]
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
						Test["NoSGP+REJECTED_on_UI.SGP_from_HMI" .. cmdCount] = function(self)
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


					--mobile side: expect SetGlobalProperties response
					EXPECT_RESPONSE(cid, { success = true, resultCode = "REJECTED"})
                                        :Times(0)

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
				 
			          Precondition_RegisterApp(self, "TC8")

				  ActivationApp(self, "TC8")

				--End precondition for NegativeResponse.6

					TCBody(self, "8")

					Test["TC8_NoSGP_from_App_during_10secTimer"] = function(self)

			                local time = timestamp()

					if (time - TimeRAISuccess) > 10000 then

					--mobile side: sending SetGlobalProperties request
				        local cid = self.mobileSession:SendRPC("SetGlobalProperties", {})
                                        :Times(0)
					
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
						Test["NoSGP+REJECTED_on_TTS.SGP_from_HMI" .. cmdCount] = function(self)
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

					:Do(function(_,data)
			 			--hmi side: sending TTS.SetGlobalProperties response
			 			self.hmiConnection:SendResponse(data.id, data.method, "REJECTED", {})
					end)		


					--mobile side: expect SetGlobalProperties response
					EXPECT_RESPONSE(cid, { success = true, resultCode = "REJECTED"})
                                        :Times(0)

					end


		--End Test case NegativeResponse.6


	        --Begin Test case NegativeResponse.7
			--Description: Case when App does NOT send SetGlobalProperties to SDL during 10 sec timer and SDL doesn't receive response from HMI at least to one TTS/UI.SetGlobalProperties 
			--Requirement id in JIRA: APPLINK 23652->reg_5
			--Verification criteria:
				--In case mobile app has registered AddCommand requests
				--SDL doesn't receive response on UI.SetGlobalProperties from HMI
				--SDL should log corresponding error internally

				--Precondition for NegativeResponse.7
				 
				  Precondition_RegisterApp(self, "TC9")

				  ActivationApp(self, "TC9")

				--End precondition for NegativeResponse.7

					TCBody(self, "9")

					Test["TC9_NoSGP_from_App_during_10secTimer"] = function(self)
	
			                local time = timestamp()

					if (time - TimeRAISuccess) > 10000 then

					--mobile side: sending SetGlobalProperties request
				        local cid = self.mobileSession:SendRPC("SetGlobalProperties", {})
                                        :Times(0)
					
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
			 			--hmi side: sending TTS.SetGlobalProperties response
			 			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)		


					--mobile side: expect SetGlobalProperties response
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
                                        :Times(0)

					end

			--End Test case NegativeResponse.7

			--Begin Test case NegativeResponse.8
			--Description: Case when App does NOT send SetGlobalProperties to SDL during 10 sec timer and SDL doesn't receive response from HMI at least to one TTS/UI.SetGlobalProperties 
			--Requirement id in JIRA: APPLINK 23652->reg_5
			--Verification criteria:
				--In case mobile app has registered AddCommand requests
				--SDL doesn't receive response on TTS.SetGlobalProperties from HMI
				--SDL should log corresponding error internally

				--Precondition for NegativeResponse.8
				 
				  Precondition_RegisterApp(self, "TC10")

				  ActivationApp(self, "TC10")

				--End precondition for NegativeResponse.7

					TCBody(self, "10")

					Test["TC10_NoSGP_from_App_during_10secTimer"] = function(self)
	
			                local time = timestamp()

					if (time - TimeRAISuccess) > 10000 then

					--mobile side: sending SetGlobalProperties request
				        local cid = self.mobileSession:SendRPC("SetGlobalProperties", {})
                                        :Times(0)
					
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

					--mobile side: expect SetGlobalProperties response
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
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

			        --Precondition for Test case EmulatingUserAction.1

				  Precondition_RegisterApp(self, "TC12")

			          ActivationApp(self, "TC12")

				--End precondition for EmulatingUserAction.1

					TCBody(self, "12")

					Test["TC12_NoSGP_from_App_during_10secTimer"] = function(self)
	
			                local time = timestamp()

					if (time - TimeRAISuccess) > 10000 then

					--mobile side: sending SetGlobalProperties request
				        local cid = self.mobileSession:SendRPC("SetGlobalProperties", {})
                                        :Times(0)
					
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
						Test["NoSGP+SUCCESS_on_UI.SGP_from_HMI" .. cmdCount] = function(self)
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

					:Do(function(_,data)
			 		--hmi side: sending TTS.SetGlobalProperties response
			 		self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
                                   	end)

					--mobile side: expect SetGlobalProperties response
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
                                        :Times(0)

					end


		--End Test case EmulatingUserAction.1
			

                --Begin Test case EmulatingUserAction.2
			--Description: Case when App does NOT send SetGlobalProperties to SDL during 10 sec timer + default values + DeleteCommand request
			--Requirement id in JIRA: APPLINK 23652->reg_3
			--Verification criteria:
				--In case mobile app has registered AddCommand/DeleteCommand requests
				--SDL should update internal list with new values of "vrHelp" and "helpPrompt" params ONLY after successfull AddCommand response from HMI
				--SDL should send updated "vrHelp" and "helpPrompt" via TTS/UI.SetGlobalProperties to HMI till App sends SetGlobalProperties request with valid <vrHelp> and <helpPrompt> params to SDL

                                --Precondition for Test case EmulatingUserAction.2

				  Precondition_RegisterApp(self, "TC13")

			          ActivationApp(self, "TC13")

				--End precondition for EmulatingUserAction.2

					TCBody(self, "13")

					Test["TC13_NoSGP_from_App_during_10secTimer"] = function(self)
	
			                local time = timestamp()

					if (time - TimeRAISuccess) > 10000 then

					--mobile side: sending SetGlobalProperties request
				        local cid = self.mobileSession:SendRPC("SetGlobalProperties", {})
                                        :Times(0)
					
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
						Test["NoSGP_but_DeleteCommand_from_App" .. cmdCount] = function(self)
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

					:Do(function(_,data)
			 		--hmi side: sending TTS.SetGlobalProperties response
			 		self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
                                   	end)

					--mobile side: expect SetGlobalProperties response
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
                                        :Times(0)

                                        DeleteCommand(self, cmdCount)

                                        EXPECT_HMICALL("UI.SetGlobalProperties",{})
				        :Times(0)

					EXPECT_HMICALL("TTS.SetGlobalProperties",{})
					:Times(0)
					
			  end 
		--End Test case EmulatingUserAction.2

  --End Test suit EmulatingUserAction
----------------------------------------------------------------------------------------------
----------------------------------------VII TEST BLOCK----------------------------------------
-------------------------------------Different HMIStatus--------------------------------------

 --These test shall be performed in tests for testing API SetGlobalProperties.
  --See ATF_SetGlobalProperties.lua

---------------------------------------------------------------------------------------------
-------------------------------------------Postconditions------------------------------------
---------------------------------------------------------------------------------------------
 	TextPrint("Postconditions")

	function Test:Postcondition_remove_user_connecttest_restore_preloaded_file()
        os.execute(" cp " .. config.pathToSDL .. "sdl_preloaded_pt_origin.json " .. config.pathToSDL .. "sdl_preloaded_pt.json" )
	os.execute(" rm -f " .. config.pathToSDL .. "/sdl_preloaded_pt_origin.json" ) 
	end

return Test



