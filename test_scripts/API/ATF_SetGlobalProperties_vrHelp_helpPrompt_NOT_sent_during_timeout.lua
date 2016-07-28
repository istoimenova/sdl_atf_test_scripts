-- Author: Anna Rotar
-- Creation date: 28.07.2016
-- ATF version: 2.2

---------------------------------------------------------------------------------------------
---------------------- Required system ATF files and Shared Libraries -----------------------
---------------------------------------------------------------------------------------------
	Test = require('connecttest')
	require('cardinalities')
	local events = require('events')
	local mobile_session   = require('mobile_session')
	local mobile = require('mobile_connection')
	local tcp = require('tcp_connection')
	local file_connection  = require('file_connection')

	local commonSteps   = require('user_modules/shared_testcases/commonSteps')
	local commonPreconditions = require('user_modules/shared_testcases/commonPreconditions')

	commonSteps:DeleteLogsFileAndPolicyTable()

	if ( commonSteps:file_exists(config.pathToSDL .. "policy.sqlite") == true ) then
		print("policy.sqlite is found in bin folder")
  	os.remove(config.pathToSDL .. "policy.sqlite")
	end

	require('user_modules/AppTypes')
	local commonTestCases = require('user_modules/shared_testcases/commonTestCases')

---------------------------------------------------------------------------------------------
------------------------------------ Common Variables ---------------------------------------
---------------------------------------------------------------------------------------------
	local TC_Number = 1
	config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

	--ToDo: shall be removed when APPLINK-16610 is fixed
	config.defaultProtocolVersion = 2

	local strAppFolder = config.pathToSDL .. "storage/" ..config.application1.registerAppInterfaceParams.appID.. "_" .. config.deviceMAC.. "/"
	strMaxLengthFileName255 = string.rep("a", 251)  .. ".png" -- set max length file name

	local default_HelpPromt = "Default Help Prompt"
	
	-- Requirement id in JIRA: APPLINK-19475: Read default value of HelpPromt in .ini file
	f = assert(io.open(config.pathToSDL.. "/smartDeviceLink.ini", "r"))
 
 	fileContent = f:read("*all")
 	DefaultContant = fileContent:match('HelpPromt.?=.?([^\n]*)')
 	
	if not DefaultContant then
		print ( " \27[31m HelpPromt is not found in smartDeviceLink.ini \27[0m " )
	else
		default_HelpPromt = DefaultContant
		print(default_HelpPromt)
	end
	f:close()

---------------------------------------------------------------------------------------------
-----------------------------------Backup, updated preloaded file ---------------------------
---------------------------------------------------------------------------------------------
 	commonSteps:DeleteLogsFileAndPolicyTable()

 	os.execute(" cp " .. config.pathToSDL .. "/sdl_preloaded_pt.json " .. config.pathToSDL .. "/sdl_preloaded_pt_origin.json" )

 	f = assert(io.open(config.pathToSDL.. "/sdl_preloaded_pt.json", "r"))

 	fileContent = f:read("*all")
 	DefaultContant = fileContent:match('"rpcs".?:.?.?%{')

 	if not DefaultContant then
  	print ( " \27[31m  rpcs is not found in sdl_preloaded_pt.json \27[0m " )
 	else
   	DefaultContant =  string.gsub(DefaultContant, '"rpcs".?:.?.?%{', '"rpcs": { \n"SystemRequest": {\n "hmi_levels": [\n  "BACKGROUND",\n   "FULL",\n   "LIMITED" ,\n   "NONE" \n]\n},')
   	fileContent  =  string.gsub(fileContent, '"rpcs".?:.?.?%{', DefaultContant)
 	end
	
	--[--[TODO: Shall be removed when APPLINK-26629: PASA_Ubuntu: Policy table can't be loaded when RPCs added in functional_group is greater than 50. is fixed
		Content_OnEncodedSyncPData = fileContent:match('"OnEncodedSyncPData".?:.?.?%{.-%},')
		if not Content_OnEncodedSyncPData then
			print ( " \27[31m  rpc OnEncodedSyncPData is not found in sdl_preloaded_pt.json \27[0m " )
		else
			Content_OnEncodedSyncPData = string.gsub(Content_OnEncodedSyncPData,'"OnEncodedSyncPData".?:.?.?%{.-%},','')
			fileContent = string.gsub(fileContent,'"OnEncodedSyncPData".?:.?.?%{.-%},',Content_OnEncodedSyncPData)
		end
	--]]
 	f = assert(io.open(config.pathToSDL.. "/sdl_preloaded_pt.json", "w+"))
 
 	f:write(fileContent)
 	f:close()
  os.execute(" cp " .. config.pathToSDL .. "sdl_preloaded_pt.json " .. config.pathToSDL .. "sdl_preloaded_pt_corrected.json" )

---------------------------------------------------------------------------------------------
-----------------------------------Local functions ------------------------------------------
---------------------------------------------------------------------------------------------
	local function userPrint( color, message)

		print ("\27[" .. tostring(color) .. "m " .. tostring(message) .. " \27[0m")
	end

	local function TextPrint(message)
		if(message == "Precondition") then
			function Test:PrintPrecondition()
				userPrint(35,"======================================= Precondition =============================================")
			end
		elseif (message == "Test Case") then
			function Test:PrintTestCase()
				userPrint(35,"========================================= Test Case ==============================================")
			end
		else
			function Test:PrintMessage()
				userPrint(35,"==============================".. message .."==========================================")
			end
		end
	end

	local function Precondition_RegisterApp(nameTC, self)
		local TimeRAISuccess = 0
		TextPrint("Precondition " ..nameTC)
		commonSteps:UnregisterApplication("UnregisterApplication_" .. nameTC)	

		commonSteps:StartSession("StartSession_" ..nameTC)
		
		Test["RegisterApp" ..nameTC] = function(self)
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
		end		
	end

	local function AddCommand(self, icmdID)
	
		--mobile side: sending AddCommand request
		local cid = self.mobileSession:SendRPC("AddCommand",
		{
			cmdID = icmdID,
			menuParams = 	
			{
				position = 0,
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
				position = 0,
				menuName ="Command" .. tostring(icmdID)
			}
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
			vrCommands = 
			{
				"VRCommand" .. tostring(icmdID)
			}
		})
		:Do(function(_,data)
			--hmi side: sending VR.AddCommand response 
			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
		end)	
	
		
		--mobile side: expect AddCommand response 
		EXPECT_RESPONSE(cid, {  success = true, resultCode = "SUCCESS"  })
		:Do(function(_,data)
			--mobile side: expect OnHashChange notification
			

			--Requirement Jira ID: APPLINK-15682
			EXPECT_NOTIFICATION("OnHashChange")
			:Do(function(_, data)
				self.currentHashID = data.payload.hashID
			end)
			
		end)
	end

	local function DeleteCommand(self, icmdID)
		--mobile side: sending DeleteCommand request
		local cid = self.mobileSession:SendRPC("DeleteCommand",
		{
			cmdID = icmdID
		})
	
		--hmi side: expect UI.DeleteCommand request
		EXPECT_HMICALL("UI.DeleteCommand", 
		{ 
			cmdID = icmdID,
			appID = self.applications[config.application1.registerAppInterfaceParams.appName]
		})
		:Do(function(_,data)
			--hmi side: sending UI.DeleteCommand response
			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
		end)
	
		--hmi side: expect VR.DeleteCommand request
		EXPECT_HMICALL("VR.DeleteCommand", 
		{ 
			cmdID = icmdID,
			type = "Command"
		})
		:Do(function(_,data)
			--hmi side: sending VR.DeleteCommand response
			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
		end)
				
		--mobile side: expect DeleteCommand response 
		EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
		:Do(function(_,data)
		
			--Requirement Jira ID: APPLINK-15682
			EXPECT_NOTIFICATION("OnHashChange")
			:Do(function(_, data)
				self.currentHashID = data.payload.hashID
			end)
		end)
	end

	local function CheckUpdateFile(self, SGP_helpPrompt, SGP_vrHelp)
		--userPrint(31, "NEED CLARIFICATION of APPLINK-26640 / APPLINK-26644")
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
		:Times(0)
	end

	local function CheckNOUpdateFile()
		userPrint(31, "NEED CLARIFICATION of APPLINK-26640 / APPLINK-26644")
	end

---------------------------------------------------------------------------------------------
-------------------------------------------Preconditions-------------------------------------
---------------------------------------------------------------------------------------------

	--1. Precondition
			TextPrint("General Precondition")
			commonSteps:ActivationApp("ActivationApp_GeneralPrecondition")


	--2. Precondition: update Policy with SetGlobalProperties API in FULL, LIMITED, BACKGROUND is allowed
		function Test:Precondition_PolicyUpdate_GeneralPrecondition()
			--hmi side: sending SDL.GetURLS request
			local RequestIdGetURLS = self.hmiConnection:SendRequest("SDL.GetURLS", { service = 7 })
		
			--hmi side: expect SDL.GetURLS response from HMI
			EXPECT_HMIRESPONSE(RequestIdGetURLS,{result = {code = 0, method = "SDL.GetURLS", urls = {{url = "http://policies.telematics.ford.com/api/policies"}}}})
			:Do(function(_,data)
				--print("SDL.GetURLS response is received")
				--hmi side: sending BasicCommunication.OnSystemRequest request to SDL
				self.hmiConnection:SendNotification("BasicCommunication.OnSystemRequest",
																				{
																					requestType = "PROPRIETARY",
																					fileName = "filename"
																				} )
			
				--mobile side: expect OnSystemRequest notification 
				EXPECT_NOTIFICATION("OnSystemRequest", { requestType = "PROPRIETARY" })
				:Do(function(_,data)
					--print("OnSystemRequest notification is received")
					--mobile side: sending SystemRequest request 
					local CorIdSystemRequest = self.mobileSession:SendRPC("SystemRequest",
																																{
																																	fileName = "PolicyTableUpdate",
																																	requestType = "PROPRIETARY"
																																},
																																"files/ptu_general.json")

				
					local systemRequestId
					--hmi side: expect SystemRequest request
					EXPECT_HMICALL("BasicCommunication.SystemRequest")
					:Do(function(_,data)
						systemRequestId = data.id
						--print("BasicCommunication.SystemRequest is received")
						
						--hmi side: sending BasicCommunication.OnSystemRequest request to SDL
						self.hmiConnection:SendNotification("SDL.OnReceivedPolicyUpdate",
																								{
																									policyfile = "/tmp/fs/mp/images/ivsu_cache/PolicyTableUpdate"
																								}	)
						function to_run()
							--hmi side: sending SystemRequest response
							self.hmiConnection:SendResponse(systemRequestId,"BasicCommunication.SystemRequest", "SUCCESS", {})
						end
					
						RUN_AFTER(to_run, 500)
					end)
				
					--hmi side: expect SDL.OnStatusUpdate
					EXPECT_HMINOTIFICATION("SDL.OnStatusUpdate")
					:ValidIf(function(exp,data)
						if ( exp.occurences == 1 and data.params.status == "UP_TO_DATE" ) then
							return true
						elseif ( exp.occurences == 1 and data.params.status == "UPDATING" ) then
							return true
						elseif ( exp.occurences == 2 and data.params.status == "UP_TO_DATE" ) then
							return true
						else 
							if (exp.occurences == 1) then
								print ("\27[31m SDL.OnStatusUpdate came with wrong values. Expected in first occurrences status 'UP_TO_DATE' or 'UPDATING', got '" .. tostring(data.params.status) .. "' \27[0m")
							elseif (exp.occurences == 2) then
								print ("\27[31m SDL.OnStatusUpdate came with wrong values. Expected in second occurrences status 'UP_TO_DATE', got '" .. tostring(data.params.status) .. "' \27[0m")
							end
							return false
						end
					end)
					:Times(Between(1,2))
				
					--mobile side: expect SystemRequest response
					EXPECT_RESPONSE(CorIdSystemRequest, { success = true, resultCode = "SUCCESS"})
					:Do(function(_,data)
						--print("SystemRequest is received")
						--hmi side: sending SDL.GetUserFriendlyMessage request to SDL
						local RequestIdGetUserFriendlyMessage = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", {language = "EN-US", messageCodes = {"StatusUpToDate"}})
				
						--hmi side: expect SDL.GetUserFriendlyMessage response
						-- TODO: update after resolving APPLINK-16094 EXPECT_HMIRESPONSE(RequestIdGetUserFriendlyMessage,{result = {code = 0, method = "SDL.GetUserFriendlyMessage", messages = {{line1 = "Up-To-Date", messageCode = "StatusUpToDate", textBody = "Up-To-Date"}}}})
						EXPECT_HMIRESPONSE(RequestIdGetUserFriendlyMessage)
						:Do(function(_,data)
							--print("SDL.GetUserFriendlyMessage is received")			
						end)
					end)
				end)
			end)
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

				Test["NO_SGP_from_App_during_Timer_TC" ..TC_Number] = function(self)

	                        local time = timestamp()

				if( (time - TimeRAISuccess) > 10000 then

					xmlReporter.AddMessage("Test Case "..TC_Number)
					userPrint(35,"======================================= Test Case " .. TC_Number .." =============================================")

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
			 			--hmi side: sending TTS.SetGlobalProperties response
			 			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)		

					--mobile side: expect SetGlobalProperties response
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
                                        :Times(0)
					
					TC_Number = TC_Number + 1
			
				end

		--End Test case PositiveResponseCheck.1


		--Begin Test case PositiveResponseCheck.2
			--Description: Case when App does NOT send SetGlobalProperties request to SDL during 10 sec timer + values from internal list
			--Requirement id in JIRA: APPLINK-19474, APPLINK-26644, APPLINK-23652->reg_1
			--Verification criteria:
				--In case mobile app has registered AddCommands and/or DeleteCommands requests (previously added)
				-- SDL must provide the value of "helpPrompt" and "vrHelp" based on registered AddCommands and DeleteCommands requests to HMI: 
					-- SDL sends UI.SetGlobalProperties(<vrHelp_from_list>, params) and TTS.SetGlobalProperties(<helpPrompt_from_list>, params) to HMI 


				-- Precondition to PositiveResponseCheck.2
					Precondition_RegisterApp("TC"..TC_Number, self)
					for cmdCount = 1, 2 do
						Test["Precondition_AddCommandInitial_" .. cmdCount.."_TC"..TC_Number] = function(self)
							AddCommand(self, cmdCount)
						end
					end 
				--End Precondition to PositiveResponseCheck.2

					Test["No_SGP_and_VrHelp&HelpPrompt_from_List_TC" ..TC_Number] = function(self)

						local time = timestamp()

						if( (time - TimeRAISuccess) > 10000 then
							
							xmlReporter.AddMessage("Test Case " ..TC_Number )
							userPrint(35,"======================================= Test Case ".. TC_Number .." =============================================")

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
																				        },
	                                                                                                                                                                {
																						text = "VRCommand2",
																						position = 2
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
																					},
																					{
																						text = "VRCommand2",
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

						TC_Number = TC_Number + 1
					end	
				--End Test case PositiveResponseCheck.2

				----Begin Test case PositiveResponseCheck.3
					--Description: Case when App does NOT send SetGlobalProperties request to SDL during 10 sec timer + values from internal list
					--Requirement id in JIRA: APPLINK-19474, APPLINK-26644, APPLINK-23652->reg_1
					--Verification criteria:
						--In case mobile app has registered AddCommands and/or DeleteCommands requests (resumed within data resumption process)
						-- SDL must provide the value of "helpPrompt" and "vrHelp" based on registered AddCommands and DeleteCommands requests to HMI: 
							-- SDL sends UI.SetGlobalProperties(<vrHelp_from_list>, params) and TTS.SetGlobalProperties(<helpPrompt_from_list>, params) to HMI 

				  	 --Precondition to PositiveResponseCheck.3
						Test["Suspend_TC"..TC_Number] = function(self)
							self.hmiConnection:SendNotification("BasicCommunication.OnExitAllApplications", { reason = "SUSPEND" })
							--Requirement Jira ID: APPLINK-15702
							--Send BC.OnPersistanceComplete to HMI on data persistance complete			
							-- hmi side: expect OnSDLPersistenceComplete notification
							EXPECT_HMINOTIFICATION("BasicCommunication.OnSDLPersistenceComplete")
						end

						Test["Ignion_OFF_TC" ..TC_Number] = function(self)
							-- hmi side: sends OnExitAllApplications (IGNITION_OFF)
							self.hmiConnection:SendNotification("BasicCommunication.OnExitAllApplications", { reason = "IGNITION_OFF"})

							-- hmi side: expect OnSDLClose notification
							EXPECT_HMINOTIFICATION("BasicCommunication.OnSDLClose")

							-- hmi side: expect OnAppUnregistered notification
							EXPECT_HMINOTIFICATION("BasicCommunication.OnAppUnregistered")
							:Times(appNumber)
							StopSDL()
						end
					
						Test["StartSDL_TC" ..TC_Number] = function(self)
					
							StartSDL(config.pathToSDL, config.ExitOnCrash)
						end

						Test["InitHMI_TC" ..TC_Number] = function(self)
					
							self:initHMI()
						end

						Test["InitHMIOnReady_TC" ..TC_Number] = function(self)

							self:initHMI_onReady()
						end

						Test["ConnectMobile_TC" ..TC_Number] = function (self)

							self:connectMobile()
						end

						Test["StartSession_TC" ..TC_Number] = function(self)
						
							CreateSession(self)
						end

						Test["RegisterAppResumption_TC" .. TC_Number] = function (self)
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
							for m=1,2 do
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
							:Times(2)
						end

				--End Precondition to PositiveResponseCheck.3
		
					Test["No_SGP_After_Resumption_TC" .. TC_Number] = function(self)

					local time = timestamp()

						if( (time - TimeRAISuccess) > 10000 then

						xmlReporter.AddMessage("Test Case " ..TC_Number )
						userPrint(35,"======================================= Test Case ".. TC_Number .." =============================================")

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
																				        },
	                                                                                                                                                                {
																						text = "VRCommand2",
																						position = 2
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
																					},
																					{
																						text = "VRCommand2",
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

						TC_Number = TC_Number + 1
					end
			--End Test case PositiveResponseCheck.3
		
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
				 Precondition_RegisterApp("TC"..TC_Number, self)

						Test["Precondition_AddCommand_" .. cmdCount.."_TC"..TC_Number] = function(self)
							AddCommand(self, cmdCount)
						end	
				
				--End precondition for NegativeResponse.1	

					Test["No_SGP_GENERIC_ERROR_on_UISGP_from_HMI_TC" ..TC_Number] = function(self)

						local time = timestamp()

						if( (time - TimeRAISuccess) > 10000 then
							
							xmlReporter.AddMessage("Test Case " ..TC_Number )
							userPrint(35,"======================================= Test Case ".. TC_Number .." =============================================")

							--mobile side: sending SetGlobalProperties request
							local cid = self.mobileSession:SendRPC("SetGlobalProperties", {})
				                        :Times(0)

							--hmi side: expect UI.SetGlobalProperties request
							EXPECT_HMICALL("UI.SetGlobalProperties",
															{
																vrHelpTitle = config.application1.registerAppInterfaceParams.appName,
														
																vrHelp ={
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
					
							--mobile side: expect OnHashChange notification
							EXPECT_NOTIFICATION("OnHashChange")
							:Times(0)
						end
						
						AddCommand(self, cmdCount)

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

					--mobile side: expect SetGlobalProperties response
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
                                        :Times(0)

						TC_Number = TC_Number + 1
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
				 Precondition_RegisterApp("TC"..TC_Number, self)

						Test["Precondition_AddCommand_" .. cmdCount.."_TC"..TC_Number] = function(self)
							AddCommand(self, cmdCount)
						end	
				
				--End precondition for NegativeResponse.2	

					Test["No_SGP_GENERIC_ERROR_on_TTSSGP_from_HMI_TC" ..TC_Number] = function(self)

						local time = timestamp()

						if( (time - TimeRAISuccess) > 10000 then
							
							xmlReporter.AddMessage("Test Case " ..TC_Number )
							userPrint(35,"======================================= Test Case ".. TC_Number .." =============================================")

							--mobile side: sending SetGlobalProperties request
							local cid = self.mobileSession:SendRPC("SetGlobalProperties", {})
				                        :Times(0)

							--hmi side: expect UI.SetGlobalProperties request
							EXPECT_HMICALL("UI.SetGlobalProperties",
															{
																vrHelpTitle = config.application1.registerAppInterfaceParams.appName,
														
																vrHelp ={
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
					
							--mobile side: expect OnHashChange notification
							EXPECT_NOTIFICATION("OnHashChange")
							:Times(0)
						end
						
						AddCommand(self, cmdCount)

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

					--mobile side: expect SetGlobalProperties response
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
					:Times(0)

						TC_Number = TC_Number + 1
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
				 Precondition_RegisterApp("TC"..TC_Number, self)

						Test["Precondition_AddCommand_" .. cmdCount.."_TC"..TC_Number] = function(self)
							AddCommand(self, cmdCount)
						end	
				
				--End precondition for NegativeResponse.3	

					Test["No_SGP_UNSUP_RES_on_TTSSGP_from_HMI_TC" ..TC_Number] = function(self)

						local time = timestamp()

						if( (time - TimeRAISuccess) > 10000 then
							
							xmlReporter.AddMessage("Test Case " ..TC_Number )
							userPrint(35,"======================================= Test Case ".. TC_Number .." =============================================")

							--mobile side: sending SetGlobalProperties request
							local cid = self.mobileSession:SendRPC("SetGlobalProperties", {})
				                        :Times(0)

							--hmi side: expect UI.SetGlobalProperties request
							EXPECT_HMICALL("UI.SetGlobalProperties",
															{
																vrHelpTitle = config.application1.registerAppInterfaceParams.appName,
														
																vrHelp ={
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
					
							--mobile side: expect OnHashChange notification
							EXPECT_NOTIFICATION("OnHashChange")
							:Times(0)
						end
						
						AddCommand(self, cmdCount)

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
		
					--mobile side: expect SetGlobalProperties response
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
                                        :Times(0)

						TC_Number = TC_Number + 1
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
				 Precondition_RegisterApp("TC"..TC_Number, self)

						Test["Precondition_AddCommand_" .. cmdCount.."_TC"..TC_Number] = function(self)
							AddCommand(self, cmdCount)
						end	
				
				--End precondition for NegativeResponse.4	

					Test["No_SGP_UNSUP_RES_on_UISGP_from_HMI_TC" ..TC_Number] = function(self)

						local time = timestamp()

						if( (time - TimeRAISuccess) > 10000 then
							
							xmlReporter.AddMessage("Test Case " ..TC_Number )
							userPrint(35,"======================================= Test Case ".. TC_Number .." =============================================")

							--mobile side: sending SetGlobalProperties request
							local cid = self.mobileSession:SendRPC("SetGlobalProperties", {})
				                        :Times(0)

							--hmi side: expect UI.SetGlobalProperties request
							EXPECT_HMICALL("UI.SetGlobalProperties",
															{
																vrHelpTitle = config.application1.registerAppInterfaceParams.appName,
														
																vrHelp ={
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
					
							--mobile side: expect OnHashChange notification
							EXPECT_NOTIFICATION("OnHashChange")
							:Times(0)
						end
						
						AddCommand(self, cmdCount)

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
		
					--mobile side: expect SetGlobalProperties response
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
                                        :Times(0)

						TC_Number = TC_Number + 1
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
				 
				Precondition_RegisterApp("TC"..TC_Number, self)

				--End precondition for Test case NegativeResponse.5


				Test["No_SGP_REJECTED_on_UISGP_from_HMI_TC" ..TC_Number] = function(self)

	                        local time = timestamp()

				if( (time - TimeRAISuccess) > 10000 then

					xmlReporter.AddMessage("Test Case "..TC_Number)
					userPrint(35,"======================================= Test Case " .. TC_Number .." =============================================")

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
			 			--hmi side: sending TTS.SetGlobalProperties response
			 			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)		

					--mobile side: expect SetGlobalProperties response
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
                                        :Times(0)
					
					AddCommand(self, cmdCount)

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

					--mobile side: expect SetGlobalProperties response
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
                                        :Times(0)
					
					TC_Number = TC_Number + 1
			
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
				 
				Precondition_RegisterApp("TC"..TC_Number, self)

				--End precondition for Test case NegativeResponse.6


				Test["No_SGP_REJECTED_on_TTSSGP_from_HMI_TC" ..TC_Number] = function(self)

	                        local time = timestamp()

				if( (time - TimeRAISuccess) > 10000 then

					xmlReporter.AddMessage("Test Case "..TC_Number)
					userPrint(35,"======================================= Test Case " .. TC_Number .." =============================================")

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
			 			--hmi side: sending TTS.SetGlobalProperties response
			 			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)		

					--mobile side: expect SetGlobalProperties response
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
                                        :Times(0)
					
					AddCommand(self, cmdCount)

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

					--mobile side: expect SetGlobalProperties response
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
                                        :Times(0)
					
					TC_Number = TC_Number + 1
			
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
				 
				Precondition_RegisterApp("TC"..TC_Number, self)

				--End precondition for NegativeResponse.7


				Test["NO_SGP_and_NO_UISGPResponse_TC" ..TC_Number] = function(self)

	                        local time = timestamp()

				if( (time - TimeRAISuccess) > 10000 then

					xmlReporter.AddMessage("Test Case "..TC_Number)
					userPrint(35,"======================================= Test Case " .. TC_Number .." =============================================")

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
			 			--hmi side: sending TTS.SetGlobalProperties response
			 			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)		

					--mobile side: expect SetGlobalProperties response
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
                                        :Times(0)
					
					AddCommand(self, cmdCount)

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
					
					TC_Number = TC_Number + 1
			
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
				 
				Precondition_RegisterApp("TC"..TC_Number, self)

				--End precondition for NegativeResponse.8


				Test["NO_SGP_and_NO_TTSSGPResponse_TC" ..TC_Number] = function(self)

	                        local time = timestamp()

				if( (time - TimeRAISuccess) > 10000 then

					xmlReporter.AddMessage("Test Case "..TC_Number)
					userPrint(35,"======================================= Test Case " .. TC_Number .." =============================================")

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
			 			--hmi side: sending TTS.SetGlobalProperties response
			 			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)		

					--mobile side: expect SetGlobalProperties response
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
                                        :Times(0)
					
					AddCommand(self, cmdCount)

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
					
					TC_Number = TC_Number + 1
			
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
			--Description: Case when App does NOT send SetGlobalProperties to SDL during 10 sec timer + values from internal list + AddCommand request
			--Requirement id in JIRA: APPLINK 23652->reg_3
			--Verification criteria:
				--In case mobile app has registered AddCommand requests (previously added)
				--SDL should update internal list with new values of "vrHelp" and "helpPrompt" params ONLY after successfull AddCommand response from HMI
				--SDL should send updated "vrHelp" and "helpPrompt" via TTS/UI.SetGlobalProperties to HMI till App sends SetGlobalProperties request with valid <vrHelp> and <helpPrompt> params to SDL

				--Precondition for Test case EmulatingUserAction.1
				 Precondition_RegisterApp("TC"..TC_Number, self)

						Test["Precondition_AddCommand_" .. cmdCount.."_TC"..TC_Number] = function(self)
							AddCommand(self, cmdCount)
						end	
				
				--End precondition for Test case EmulatingUserAction.1	

					Test["No_SGP_ListValues_AddCommand_from_App_TC" ..TC_Number] = function(self)

						local time = timestamp()

						if( (time - TimeRAISuccess) > 10000 then
							
							xmlReporter.AddMessage("Test Case " ..TC_Number )
							userPrint(35,"======================================= Test Case ".. TC_Number .." =============================================")

							--mobile side: sending SetGlobalProperties request
							local cid = self.mobileSession:SendRPC("SetGlobalProperties", {})
				                        :Times(0)

							--hmi side: expect UI.SetGlobalProperties request
							EXPECT_HMICALL("UI.SetGlobalProperties",
															{
																vrHelpTitle = config.application1.registerAppInterfaceParams.appName,
														
																vrHelp ={
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
					
							--mobile side: expect OnHashChange notification
							EXPECT_NOTIFICATION("OnHashChange")
							:Times(0)
						end
						
						AddCommand(self, cmdCount)

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

						TC_Number = TC_Number + 1
					end				
		
		--End Test case EmulatingUserAction.1

		--Begin Test case EmulatingUserAction.2
			--Description: Case when App does NOT send SetGlobalProperties to SDL during 10 sec timer + default values + AddCommand request
			--Requirement id in JIRA: APPLINK 23652->reg_3
                        --Verification criteria:
				--In case mobile app has no registered AddCommand requests
				--SDL should update internal list with new values of "vrHelp" and "helpPrompt" params ONLY after successfull AddCommand response from HMI
				--SDL should send updated "vrHelp" and "helpPrompt" via TTS/UI.SetGlobalProperties to HMI till App sends SetGlobalProperties request with valid <vrHelp> and <helpPrompt> params to SDL

	                	--Precondition for Test case EmulatingUserAction.2
				 
					Precondition_RegisterApp("TC"..TC_Number, self)

				--End precondition for Test case EmulatingUserAction.2


				Test["NO_SGP_DefValues_AddCommand_from_App_TC" ..TC_Number] = function(self)

	                        local time = timestamp()

				if( (time - TimeRAISuccess) > 10000 then

					xmlReporter.AddMessage("Test Case "..TC_Number)
					userPrint(35,"======================================= Test Case " .. TC_Number .." =============================================")

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
			 			--hmi side: sending TTS.SetGlobalProperties response
			 			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)		

					--mobile side: expect SetGlobalProperties response
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
                                        :Times(0)
					
					AddCommand(self, cmdCount)

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
					
					TC_Number = TC_Number + 1
			
				end

		--End Test case EmulatingUserAction.2
			

                --Begin Test case EmulatingUserAction.3
			--Description: Case when App does NOT send SetGlobalProperties to SDL during 10 sec timer + values from internal list + DeleteCommand request
			--Requirement id in JIRA: APPLINK 23652->reg_3
			--Verification criteria:
				--In case mobile app has registered DeleteCommand requests (previously added)
				--SDL should update internal list with new values of "vrHelp" and "helpPrompt" params ONLY after successfull DeleteCommand response from HMI
				--SDL should send updated "vrHelp" and "helpPrompt" via TTS/UI.SetGlobalProperties to HMI till App sends SetGlobalProperties request with valid <vrHelp> and <helpPrompt> params to SDL

				--Precondition for Test case EmulatingUserAction.3
		
				Precondition_RegisterApp("TC"..TC_Number, self)

				--End precondition for Test case EmulatingUserAction.3


				Test["NO_SGP_ListValues_DeleteCommand_from_App_TC" ..TC_Number] = function(self)

	                        local time = timestamp()

				if( (time - TimeRAISuccess) > 10000 then

					xmlReporter.AddMessage("Test Case "..TC_Number)
					userPrint(35,"======================================= Test Case " .. TC_Number .." =============================================")

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
			 			--hmi side: sending TTS.SetGlobalProperties response
			 			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)		

					--mobile side: expect SetGlobalProperties response
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
                                        :Times(0)
					
					AddCommand(self, cmdCount)

					
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

                                            local time = timestamp()

                                         if( (time - TimeRAISuccess) < 10000 and (time - TimeRAISuccess) > 0 ) then

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
			 			--hmi side: sending TTS.SetGlobalProperties response
			 			self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)		

					--mobile side: expect SetGlobalProperties response
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
                                        :Times(0)
					
					TC_Number = TC_Number + 1
			
				end
			
		--End Test case EmulatingUserAction.3

  --End Test suit EmulatingUserAction

----------------------------------------------------------------------------------------------
----------------------------------------VII TEST BLOCK----------------------------------------
-------------------------------------Different HMIStatus--------------------------------------

 --These test shall be performed in tests for testing API SetGlobalProperties.
  --See ATF_SetGlobalProperties.lua

---------------------------------------------------------------------------------------------
-------------------------------------------Postconditions------------------------------------
---------------------------------------------------------------------------------------------

	function Test:Postcondition_remove_user_connecttest_restore_preloaded_file()
	  	os.execute(" cp " .. config.pathToSDL .. "sdl_preloaded_pt_origin.json " .. config.pathToSDL .. "sdl_preloaded_pt.json" )
	  	os.execute(" rm -f " .. config.pathToSDL .. "/sdl_preloaded_pt_origin.json" ) 
	end

return Test
