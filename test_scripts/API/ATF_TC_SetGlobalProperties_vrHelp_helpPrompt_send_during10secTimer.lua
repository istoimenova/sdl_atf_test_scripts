---------------------------------------------------------------------------------------------
-- Author: I.Stoimenova
-- Creation date: 19.07.2016
-- Last update date: 22.07.2016
-- ATF version: 2.2

---------------------------------------------------------------------------------------------
----------------------------- General Preparation -------------------------------------------
---------------------------------------------------------------------------------------------
	local commonSteps   = require('user_modules/shared_testcases/commonSteps')
	local commonPreconditions = require('user_modules/shared_testcases/commonPreconditions')

	commonSteps:DeleteLogsFileAndPolicyTable()

	if ( commonSteps:file_exists(config.pathToSDL .. "policy.sqlite") == true ) then
		print("policy.sqlite is found in bin folder")
  	os.remove(config.pathToSDL .. "policy.sqlite")
	end
---------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------
---------------------- require system ATF files for script like -----------------------------
---------------------------------------------------------------------------------------------
	Test = require('connecttest')
	require('cardinalities')
	local events 				   = require('events')
	local mobile_session   = require('mobile_session')
	local mobile  			   = require('mobile_connection')
	local tcp 						 = require('tcp_connection')
	local file_connection  = require('file_connection')
---------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------
-----------------------------Required Shared Libraries---------------------------------------
---------------------------------------------------------------------------------------------
	require('user_modules/AppTypes')
	local commonTestCases = require('user_modules/shared_testcases/commonTestCases')
	local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
---------------------------------------------------------------------------------------------

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
	
	-- Requirement id in JIRA: APPLINK-19475
	-- Read default value of HelpPromt in .ini file
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
			

			--Requirement id in JAMA/or Jira ID: APPLINK-15682
			--[Data Resumption]: OnHashChange
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
		
			--Requirement id in JAMA/or Jira ID: APPLINK-15682
			--[Data Resumption]: OnHashChange
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

---------------------------------------------------------------------------------------------
-------------------------------------------Preconditions-------------------------------------
---------------------------------------------------------------------------------------------
	--Begin Precondition.1
			TextPrint("General Precondition")
			commonSteps:ActivationApp("ActivationApp_GeneralPrecondition")
	--End Precondition.1

	--Begin Precondition.2
		--Description: Update Policy with SetGlobalProperties API in FULL, LIMITED, BACKGROUND is allowed
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
																															"files/ptu_general.json"
																														)
				
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
	--End Precondition.2
---------------------------------------------------------------------------------------------	

---------------------------------------------------------------------------------------------
-----------------------------------------I TEST BLOCK----------------------------------------
--CommonRequestCheck: Check of mandatory/conditional request's parameters (mobile protocol)--
---------------------------------------------------------------------------------------------
	--Begin Test suit PositiveRequestCheck

		--Description: TC's checks processing 
			-- request with all parameters
      -- request with only vrHelp and helpPrompts
      -- request with only vrHelp and helpPrompts and fake parameters (fake - not from protocol)
      -- request without any parameters
      -- request with only VrHelp
      -- request with only helpPrompts

		--Begin Test case CommonRequestCheck.1
			--Description:Positive case and request with all parameters in boundary conditions; 5 elements of helpPrompt[]
			--Requirement id in JIRA: APPLINK-19476
			--Verification criteria:
				-- SDL must transfer TTS.SetGlobalProperties (<helpPrompts>, params) to HMI with adding period of silence between each command "helpPrompt" to HMI 
				-- SDL must transfer UI.SetGlobalProperties (<vrHelp, params>) to HMI
				-- SDL must respond with <resultCode_received_from_HMI> to mobile app
				Test["SetGlobalProperties_AllValidParametes_TC" ..TC_Number] = function(self)

					xmlReporter.AddMessage("Test Case "..TC_Number)
					userPrint(35,"======================================= Test Case " .. TC_Number .." =============================================")
					--mobile side: sending SetGlobalProperties request
					local cid = self.mobileSession:SendRPC("SetGlobalProperties",
																									{
																										helpPrompt = 
																																{
																																	{
																																		text = "Help prompt 1",
																																		type = "TEXT"
																																	},
																																	{
																																		text = "Help prompt 2",
																																		type = "TEXT"
																																	},
																																	{
																																		text = "Help prompt 3",
																																		type = "TEXT"
																																	},
																																	{
																																		text = "Help prompt 4",
																																		type = "TEXT"
																																	},
																																	{
																																		text = "Help prompt 5",
																																		type = "TEXT"
																																	}

																																},
																										timeoutPrompt = 
																																{
																																	{
																																		text = "Timeout prompt",
																																		type = "TEXT"
																																	}
																																},
																										vrHelpTitle = "VR help title",
																										vrHelp = 
																																{
																																	{
																																		text = "VR help item",
																																		image = {
																																							value = "action.png",
																																							imageType = "DYNAMIC"
																																						},
																																		position = 1
																																	}
																																},
																										menuTitle = "Menu Title",
																										menuIcon = 
																																{
																																	value = "action.png",
																																	imageType = "DYNAMIC"
																																},
																										keyboardProperties = 
																																{
																																	keyboardLayout = "QWERTY",
																																	keypressMode = "SINGLE_KEYPRESS",
																																	limitedCharacterList = { "a" },
																																	language = "EN-US",
																																	autoCompleteText = "Daemon, Freedom"
																																}
																									})
					
					--hmi side: expect UI.SetGlobalProperties request
					EXPECT_HMICALL("UI.SetGlobalProperties",
													{
														vrHelpTitle = "VR help title",
														vrHelp = 
																		{
																			{
																				text = "VR help item",
																				--[[ TODO: update after resolving APPLINK-16052]]
																				image = 
																								{
																									imageType = "DYNAMIC",
																									value = strAppFolder .. "action.png"
																								},--]]
																				position = 1
																		}	},
														menuTitle = "Menu Title",
														--[[ TODO: update after resolving APPLINK-16052]]
														menuIcon = 
																			{
																				imageType = "DYNAMIC",
																				value = strAppFolder .. "action.png"
																			},
														keyboardProperties = 
																			{
																				keyboardLayout = "QWERTY",
																				keypressMode = "SINGLE_KEYPRESS",
																				--[=[ TODO: update after resolving APPLINK-16047
																				limitedCharacterList = { "a" },]=]
																				language = "EN-US",
																				autoCompleteText = "Daemon, Freedom"
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
																						text = "Help prompt 1",
																						type = "TEXT"
																					},
																					{
																						text = "300",
																						type = "SILENCE"
																					},
																					{
																						text = "Help prompt 2",
																						type = "TEXT"
																					},
																					{
																						text = "300",
																						type = "SILENCE"
																					},
																					{
																						text = "Help prompt 3",
																						type = "TEXT"
																					},
																					{
																						text = "300",
																						type = "SILENCE"
																					},
																					{
																						text = "Help prompt 4",
																						type = "TEXT"
																					},
																					{
																						text = "300",
																						type = "SILENCE"
																					},
																					{
																						text = "Help prompt 5",
																						type = "TEXT"
																					},
																					{
																						text = "300",
																						type = "SILENCE"
																					}
																				},
														timeoutPrompt = 
																				{
																					{
																						text = "Timeout prompt",
																						type = "TEXT"
																				}	},
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
					TC_Number = TC_Number + 1
				end
		--End Test case CommonRequestCheck.1

		--Begin Test case CommonRequestCheck.2
			--Preconditions Test case CommonRequestCheck.2
				Precondition_RegisterApp("TC"..TC_Number, self)
		
			--Description:Positive case and request with only helpPrompt and vrHelp; 5 elements of helpPrompt[]
			--Requirement id in JIRA: APPLINK-19476
			--Verification criteria:
				-- SDL must transfer TTS.SetGlobalProperties (<helpPrompts>, params) to HMI with adding period of silence between each command "helpPrompt" to HMI 
				-- SDL must transfer UI.SetGlobalProperties (<vrHelp, params>) to HMI
				-- SDL must respond with <resultCode_received_from_HMI> to mobile app
				Test["SetGlobalProperties_onlyparams_helpPrompt_vrHelp_TC"..TC_Number] = function(self)
					xmlReporter.AddMessage("Test Case "..TC_Number)
					userPrint(35,"======================================= Test Case ".. TC_Number .." =============================================")
					--mobile side: sending SetGlobalProperties request
					local cid = self.mobileSession:SendRPC("SetGlobalProperties",
																									{
																										helpPrompt = 
																																{
																																	{
																																		text = "Help prompt 1",
																																		type = "TEXT"
																																	},
																																	{
																																		text = "Help prompt 2",
																																		type = "TEXT"
																																	},
																																	{
																																		text = "Help prompt 3",
																																		type = "TEXT"
																																	},
																																	{
																																		text = "Help prompt 4",
																																		type = "TEXT"
																																	},
																																	{
																																		text = "Help prompt 5",
																																		type = "TEXT"
																																	}

																																},
																										vrHelpTitle = "VR Help Title",
																										vrHelp = 
																																{
																																	{
																																		text = "VR help item",
																																		image = {
																																							value = "action.png",
																																							imageType = "DYNAMIC"
																																						},
																																		position = 1
																																	}
																																}
																									})
					
					--hmi side: expect UI.SetGlobalProperties request
					EXPECT_HMICALL("UI.SetGlobalProperties",
													{
														vrHelpTitle = "VR help title",
														vrHelp = 
																		{
																			{
																				text = "VR help item",
																				--[[ TODO: update after resolving APPLINK-16052]]
																				image = 
																								{
																									imageType = "DYNAMIC",
																									value = strAppFolder .. "action.png"
																								},--]]
																				position = 1
																		}	},
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
																						text = "Help prompt 1",
																						type = "TEXT"
																					},
																					{
																						text = "300",
																						type = "SILENCE"
																					},
																					{
																						text = "Help prompt 2",
																						type = "TEXT"
																					},
																					{
																						text = "300",
																						type = "SILENCE"
																					},
																					{
																						text = "Help prompt 3",
																						type = "TEXT"
																					},
																					{
																						text = "300",
																						type = "SILENCE"
																					},
																					{
																						text = "Help prompt 4",
																						type = "TEXT"
																					},
																					{
																						text = "300",
																						type = "SILENCE"
																					},
																					{
																						text = "Help prompt 5",
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

					--mobile side: expect SetGlobalProperties response
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
			
					--mobile side: expect OnHashChange notification
					EXPECT_NOTIFICATION("OnHashChange")

					TC_Number = TC_Number + 1
				end
		--End Test case CommonRequestCheck.2

		--Begin Test case CommonRequestCheck.3
			--Preconditions Test case CommonRequestCheck.3
				Precondition_RegisterApp("TC"..TC_Number, self)
		
			--Description:Positive case and request with all params and 1 fake param; 5 elements of helpPrompt[]
			--Requirement id in JIRA: APPLINK-19476
			--Verification criteria:
				-- SDL must transfer TTS.SetGlobalProperties (<helpPrompts>, params) to HMI with adding period of silence between each command "helpPrompt" to HMI 
				-- SDL must transfer UI.SetGlobalProperties (<vrHelp, params>) to HMI
				-- SDL must respond with <resultCode_received_from_HMI> to mobile app
				Test["SetGlobalProperties_AllParams_AdditionalFake_TC" ..TC_Number] = function(self)					
					xmlReporter.AddMessage("Test Case "..TC_Number)
					userPrint(35,"======================================= Test Case "..TC_Number.." =============================================")
					--mobile side: sending SetGlobalProperties request
					local cid = self.mobileSession:SendRPC("SetGlobalProperties",
																									{
																										fakeParam = "fakeParam",
																										helpPrompt = 
																																{
																																	{
																																		text = "Help prompt 1",
																																		type = "TEXT"
																																	},
																																	{
																																		text = "Help prompt 2",
																																		type = "TEXT"
																																	},
																																	{
																																		text = "Help prompt 3",
																																		type = "TEXT"
																																	},
																																	{
																																		text = "Help prompt 4",
																																		type = "TEXT"
																																	},
																																	{
																																		text = "Help prompt 5",
																																		type = "TEXT"
																																	}

																																},
																										timeoutPrompt = 
																																{
																																	{
																																		text = "Timeout prompt",
																																		type = "TEXT"
																																	}
																																},
																										vrHelpTitle = "VR help title",
																										vrHelp = 
																																{
																																	{
																																		text = "VR help item",
																																		image = {
																																							value = "action.png",
																																							imageType = "DYNAMIC"
																																						},
																																		position = 1
																																	}
																																},
																										menuTitle = "Menu Title",
																										menuIcon = 
																																{
																																	value = "action.png",
																																	imageType = "DYNAMIC"
																																},
																										keyboardProperties = 
																																{
																																	keyboardLayout = "QWERTY",
																																	keypressMode = "SINGLE_KEYPRESS",
																																	limitedCharacterList = { "a" },
																																	language = "EN-US",
																																	autoCompleteText = "Daemon, Freedom"
																																}
																									})
					
					--hmi side: expect UI.SetGlobalProperties request
					EXPECT_HMICALL("UI.SetGlobalProperties",
													{
														vrHelpTitle = "VR help title",
														vrHelp = 
																		{
																			{
																				text = "VR help item",
																				--[[ TODO: update after resolving APPLINK-16052]]
																				image = 
																								{
																									imageType = "DYNAMIC",
																									value = strAppFolder .. "action.png"
																								},--]]
																				position = 1
																		}	},
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
																						text = "Help prompt 1",
																						type = "TEXT"
																					},
																					{
																						text = "300",
																						type = "SILENCE"
																					},
																					{
																						text = "Help prompt 2",
																						type = "TEXT"
																					},
																					{
																						text = "300",
																						type = "SILENCE"
																					},
																					{
																						text = "Help prompt 3",
																						type = "TEXT"
																					},
																					{
																						text = "300",
																						type = "SILENCE"
																					},
																					{
																						text = "Help prompt 4",
																						type = "TEXT"
																					},
																					{
																						text = "300",
																						type = "SILENCE"
																					},
																					{
																						text = "Help prompt 5",
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

					--mobile side: expect SetGlobalProperties response
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
			
					--mobile side: expect OnHashChange notification
					EXPECT_NOTIFICATION("OnHashChange")

					TC_Number = TC_Number + 1
				end
		--End Test case CommonRequestCheck.3

		--Begin Test case CommonRequestCheck.4
			--Preconditions Test case CommonRequestCheck.4
			Precondition_RegisterApp("TC"..TC_Number, self)

			--Description:Positive case and request without any params, as result default values of VrHelp and helpPrompt shall be used.
			--Requirement id in JIRA: APPLINK-19475; APPLINK-23962; APPLINK-23728
			--Verification criteria:
				--In case mobile app has NO registered AddCommands and/or DeleteCommands requests (previously added or resumed within data resumption process)
				-- SDL must use current appName as default value for "vrHelp" parameter
				-- SDL must retrieve value of "helpPrompt" from .ini file ([GLOBAL PROPERTIES] section -> "HelpPrompt" param)
				Test["SetGlobalProperties_NoParams_TC" ..TC_Number] = function (self)					
					xmlReporter.AddMessage("Test Case "..TC_Number)
					userPrint(35,"======================================= Test Case "..TC_Number.." =============================================")
					--mobile side: sending SetGlobalProperties request
					local cid = self.mobileSession:SendRPC("SetGlobalProperties",{ menuTitle = "Menu Title"})
					
					--hmi side: expect UI.SetGlobalProperties request
					EXPECT_HMICALL("UI.SetGlobalProperties",
													{
														vrHelpTitle = config.application1.registerAppInterfaceParams.appName,
													  -- Clarification is done: APPLINK-26638
														vrHelp = { 
																	{
																		text = config.application1.registerAppInterfaceParams.appName,
																		position = 1
																}	},
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

					TC_Number = TC_Number + 1
				end
		--End Test case CommonRequestCheck.4

		--Begin Test case CommonRequestCheck.5
			--Preconditions Test case CommonRequestCheck.5
			Precondition_RegisterApp("TC"..TC_Number, self)

			--Description:Positive case and request with only VrHelp, as result default values of helpPrompt shall be used.
			--Requirement id in JIRA: APPLINK-19475; APPLINK-23962; APPLINK-23728
			--Verification criteria:
				--In case mobile app has NO registered AddCommands and/or DeleteCommands requests (previously added or resumed within data resumption process)
				-- SDL must use current appName as default value for "vrHelp" parameter
				-- SDL must retrieve value of "helpPrompt" from .ini file ([GLOBAL PROPERTIES] section -> "HelpPrompt" param)
				Test["SetGlobalProperties_onlyparam_VrHelp_TC" ..TC_Number] = function(self)
					xmlReporter.AddMessage("Test Case "..TC_Number)
					userPrint(35,"======================================= Test Case "..TC_Number.." =============================================")
					--mobile side: sending SetGlobalProperties request
					local cid = self.mobileSession:SendRPC("SetGlobalProperties",{ vrHelpTitle = "VR help title" } )
					
					--hmi side: expect UI.SetGlobalProperties request
					EXPECT_HMICALL("UI.SetGlobalProperties",
													{
													 	-- Clarification is done: APPLINK-26638
														vrHelpTitle = "VR help title",
														vrHelp ={ 
																	{
																		text = config.application1.registerAppInterfaceParams.appName,
																		position = 1
																}	},
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
																					}},																			
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

					TC_Number = TC_Number + 1
				end
		--End Test case CommonRequestCheck.5

		--Begin Test case CommonRequestCheck.6
			--Preconditions Test case CommonRequestCheck.6
			Precondition_RegisterApp("TC"..TC_Number, self)

			--Description:Positive case and request with only helpPrompt, as result default values of helpPrompt shall be used.
			--Requirement id in JIRA: APPLINK-19475; APPLINK-23962; APPLINK-23728
			--Verification criteria:
				--In case mobile app has NO registered AddCommands and/or DeleteCommands requests (previously added or resumed within data resumption process)
				-- SDL must use current appName as default value for "vrHelp" parameter
				-- SDL must retrieve value of "helpPrompt" from .ini file ([GLOBAL PROPERTIES] section -> "HelpPrompt" param)
				Test["SetGlobalProperties_onlyparam_helpPrompt_TC" ..TC_Number] = function(self)
					xmlReporter.AddMessage("Test Case "..TC_Number)
					userPrint(35,"======================================= Test Case ".. TC_Number.." =============================================")
					--mobile side: sending SetGlobalProperties request
					local cid = self.mobileSession:SendRPC("SetGlobalProperties", {
																									helpPrompt = 
																													{
																														{
																															text = "Help prompt 1",
																															type = "TEXT"
																														},
																														{
																															text = "Help prompt 2",
																															type = "TEXT"
																														},
																														{
																															text = "Help prompt 3",
																															type = "TEXT"
																														},
																														{
																															text = "Help prompt 4",
																															type = "TEXT"
																														},
																														{
																															text = "Help prompt 5",
																															type = "TEXT"
																														}
																													}
																					}		)
					
					--hmi side: expect UI.SetGlobalProperties request
					EXPECT_HMICALL("UI.SetGlobalProperties",
													{
														vrHelpTitle = config.application1.registerAppInterfaceParams.appName,
														-- Clarification is done in APPLINK-26638
														vrHelp ={
																			{
																				text = config.application1.registerAppInterfaceParams.appName,
																				position = 1
																		}	},
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
																						text = "Help prompt 1",
																						type = "TEXT"
																					},
																					{
																						text = "300",
																						type = "SILENCE"
																					},
																					{
																						text = "Help prompt 2",
																						type = "TEXT"
																					},
																					{
																						text = "300",
																						type = "SILENCE"
																					},
																					{
																						text = "Help prompt 3",
																						type = "TEXT"
																					},
																					{
																						text = "300",
																						type = "SILENCE"
																					},
																					{
																						text = "Help prompt 4",
																						type = "TEXT"
																					},
																					{
																						text = "300",
																						type = "SILENCE"
																					},
																					{
																						text = "Help prompt 5",
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

					--mobile side: expect SetGlobalProperties response
					EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
			
					--mobile side: expect OnHashChange notification
					EXPECT_NOTIFICATION("OnHashChange")

					TC_Number = TC_Number + 1
				end
		--End Test case CommonRequestCheck.6
	--End Test suit PositiveRequestCheck
---------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------
----------------------------------------II TEST BLOCK----------------------------------------
----------------------------------------Positive cases---------------------------------------
--Positive cases: Check of positive value of request/response parameters (mobile protocol, HMI protocol)
---------------------------------------------------------------------------------------------
	--Begin Test suit PositiveResponseCheck

		
		--Description: Positive case without request but with update of internal list with helpPrompts, vrHelp
			--Requirement id in JIRA: APPLINK-19477
			--Verification criteria:
				-- In case SDL already transfers UI/TTS.SetGlobalProperties with <vrHelp> and <helpPrompt> received from mobile app to HMI
				-- and and 10 sec timer is NOT expired yet
				-- and mobile app sends AddCommand and/or DeleteCommand requests to SDL 
				-- SDL must update internal list with new values of "vrHelp" and "helpPrompt" params ONLY after successfull response from HMI
				-- SDL must NOT: send updated values of "vrHelp" and "helpPrompt" via TTS/UI.SetGlobalProperties requests to HMI
				-- PositivaResponseCheck.1 and PositivaResponseCheck.2 are added -> deleted commands one by one.

				--Preconditions Test case PositiveResponseCheck.1
					Precondition_RegisterApp("TC" ..TC_Number, self)
		
				--Begin PositivaResponseCheck.1 and PositivaResponseCheck.2
					for cmdCount = 1, 10 do
						--Begin Test case PositiveResponseCheck.1
						Test["SetGlobalProperties_NoRequestToHMI_AddCommand" .. cmdCount .. "_TC" ..TC_Number] = function(self)
							xmlReporter.AddMessage("Test Case " ..TC_Number )
							userPrint(35,"======================================= Test Case ".. TC_Number .." =============================================")

							AddCommand(self, cmdCount)

							

							EXPECT_HMICALL("UI.SetGlobalProperties",{})
							:Times(0)

							EXPECT_HMICALL("TTS.SetGlobalProperties",{})
							:Times(0)

							TC_Number = TC_Number + 1
						end						
						
						Test["CheckInternalList_AddCommand" .. cmdCount .. "_TC" ..TC_Number] = function(self)
							
							--TODO: Shall be updated after APPLINK-26644 is answered.
							SGP_helpPrompt[1] ={
																text = "Command" .. tostring(cmdCount), --menuName}
																type = "TEXT" }
							SGP_helpPrompt[2] ={
																text = "300",
																type = "SILENCE" }
								
							SGP_vrHelp[1] = { 
																text = "Command" .. tostring(cmdCount), 
																position = 1
															}
							
							CheckUpdateFile(self, SGP_helpPrompt, SGP_vrHelp)
						end

						--End Test case PositiveResponseCheck.1			

						--Begin Test case PositiveResponseCheck.2
						Test["SetGlobalProperties_NoRequestToHMI_DeleteCommand" .. cmdCount .."_TC" ..TC_Number] = function(self)
							xmlReporter.AddMessage("Test Case " ..TC_Number )
							userPrint(35,"===============================																																																																																																																																																																																																																																																																																																						======== Test Case "..TC_Number .." =============================================")
							DeleteCommand(self, cmdCount)
							

							EXPECT_HMICALL("UI.SetGlobalProperties",{})
							:Times(0)

							EXPECT_HMICALL("TTS.SetGlobalProperties",{})
							:Times(0)
							TC_Number = TC_Number + 1
						end

						Test["CheckInternalList_DeleteCommand" .. cmdCount .. "_TC" ..TC_Number] = function(self)
							local SGP_helpPrompt{}
							local SGP_vrHelp{}

							--TODO: Shall be updated after APPLINK-26640 and APPLINK-26644 is answered.
							SGP_helpPrompt[1] ={
																 		text = default_HelpPromt,
																		type = "TEXT"
																	}
							
							SGP_vrHelp[1] = {
																text = config.application1.registerAppInterfaceParams.appName,
																position = 1
															}
							
							CheckUpdateFile(self, SGP_helpPrompt, SGP_vrHelp)
						end

						--End Test case PositiveResponseCheck.2			
					end
				--End PositivaResponseCheck.1 and PositivaResponseCheck.2

				-- Added 10 commands and after that delete 10 commands one by one
				-- Precondition Test case PositiveResponseCheck.3
					for cmdCount = 1, 10 do
						Test["Precondition_NoRequestToHMI_AddManyCommands" .. cmdCount.."_TC"..TC_Number] = function(self)
							AddCommand(self, cmdCount)

							EXPECT_HMICALL("UI.SetGlobalProperties",{})
							:Times(0)

							EXPECT_HMICALL("TTS.SetGlobalProperties",{})
							:Times(0)
						end
					end				

					Test["CheckInternalList10commands_TC" .. TC_Number] = function(self)
						local cnt_cmd = 1

						for i = 1, cmdCount*2, i = i+2 do
								SGP_helpPrompt[i] ={
																		text = "Command" .. tostring(cnt_cmd), --menuName}
																		type = "TEXT" }
								SGP_helpPrompt[i + 1] ={
																		text = "300",
																		type = "SILENCE" }

								cnt_cmd = cnt_cmd + 1
						end

						for i = 1, cmdCount do
							SGP_vrHelp[i] = {	text = "Command" .. tostring(i) }
						end

						CheckUpdateFile(self, SGP_helpPrompt, SGP_vrHelp)
					end
				
				--Begin Test case PositiveResponseCheck.3
					for cmdCount = 1, 10 do
						Test["SetGlobalProperties_NoRequestToHMI_DelCommand_After10Added" .. (cmdCount).."_TC"..TC_Number] = function(self)
							xmlReporter.AddMessage("Test Case " ..TC_Number )
							userPrint(35,"======================================= Test Case "..TC_Number .." =============================================")
							DeleteCommand(self, cmdCount)
							

							EXPECT_HMICALL("UI.SetGlobalProperties",{})
							:Times(0)

							EXPECT_HMICALL("TTS.SetGlobalProperties",{})
							:Times(0)
							TC_Number = TC_Number + 1
						end

						Test["CheckInternalListDelete10commands_TC" .. TC_Number] = function(self)
							local cnt_cmd = 10

							for i = (10 - cmdCount*2), cmdCount, (i = i-2) do
								SGP_helpPrompt[i] ={
																		text = "Command" .. tostring(cnt_cmd), --menuName}
																		type = "TEXT" }
								SGP_helpPrompt[i + 1] ={
																		text = "300",
																		type = "SILENCE" }

								cnt_cmd = cnt_cmd - 1
							end

							for i = (10 - cmdCount), cmdCount  do
								SGP_vrHelp[i] = {	text = "Command" .. tostring(i) }
							end

						CheckUpdateFile(self, SGP_helpPrompt, SGP_vrHelp)
						end
					end
				--End Test case PositiveResponseCheck.3
				
		--Description: Positive case with request and update of internal list with helpPrompts, vrHelp
			--Requirement id in JIRA: APPLINK-23727; APPLINK-19474
			--Verification criteria:
				-- Precondition PositiveResponseCheck.4
					Precondition_RegisterApp("TC"..TC_Number, self)
					for cmdCount = 1, 5 do
						Test["Precondition_NoRequestToHMI_AddCommandInitial_" .. cmdCount.."_TC"..TC_Number] = function(self)
							AddCommand(self, cmdCount)
						end
					end 

				--Begin Test case PositiveResponseCheck.4
					Test["SetGlobalProperties_Without_vrHelp_helpPrompt_TC" ..TC_Number] = function(self)
						local time = timestamp()

						if( (time - TimeRAISuccess) < 10000 and (time - TimeRAISuccess) > 0 ) then
							
							xmlReporter.AddMessage("Test Case " ..TC_Number )
							userPrint(35,"======================================= Test Case ".. TC_Number .." =============================================")

							local cid = self.mobileSession:SendRPC("SetGlobalProperties",{ menuTitle = "Menu Title"})

							--hmi side: expect UI.SetGlobalProperties request
							--TODO: Shall be updated when APPLINK-26640 / APPLINK-26644 are clarified.
							EXPECT_HMICALL("UI.SetGlobalProperties",
															{
																vrHelpTitle = config.application1.registerAppInterfaceParams.appName,
																-- Clarification is done in APPLINK-26638
																vrHelp ={
																					{
																						text = config.application1.registerAppInterfaceParams.appName,
																						position = 1
																				}	},
																appID = self.applications[config.application1.registerAppInterfaceParams.appName]
															})
							:Do(function(_,data)
								--hmi side: sending UI.SetGlobalProperties response
								self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
							end)

							--TODO: Shall be updated when APPLINK-26640 / APPLINK-26644 are clarified.
							--hmi side: expect TTS.SetGlobalProperties request
							EXPECT_HMICALL("TTS.SetGlobalProperties",
															{
																helpPrompt = 
																						{
																							
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
							:Times(0)
						end

						TC_Number = TC_Number + 1
					end	
				--End Test case PositiveResponseCheck.4

				--Precondition PositiveResponseCheck.5
					Test["Suspend_TC"..TC_Number] = function(self)
						self.hmiConnection:SendNotification("BasicCommunication.OnExitAllApplications",
																									{ reason = "SUSPEND" })
						--Requirement id in JAMA/or Jira ID: APPLINK-15702
						--Send BC.OnPersistanceComplete to HMI on data persistance complete			
						-- hmi side: expect OnSDLPersistenceComplete notification
						EXPECT_HMINOTIFICATION("BasicCommunication.OnSDLPersistenceComplete")
					end

					Test["Ignion_OFF_TC" ..TC_Number] = function(self)
						-- hmi side: sends OnExitAllApplications (IGNITION_OFF)
						self.hmiConnection:SendNotification("BasicCommunication.OnExitAllApplications",
																								{ reason = "IGNITION_OFF"	})

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
						for m=1,5 do
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
						:Times(5)
					end
		
				--Begin Test case PositiveResponseCheck.5
					Test["SetGlobalPropertiesAfterResumption_TC" .. TC_Number] = function(self)
						xmlReporter.AddMessage("Test Case " ..TC_Number )
						userPrint(35,"======================================= Test Case ".. TC_Number .." =============================================")

						local cid = self.mobileSession:SendRPC("SetGlobalProperties",{menuTitle = "Menu Title"})

						--hmi side: expect UI.SetGlobalProperties request
						--TODO: Shall be updated when APPLINK-26640 / APPLINK-26644 are clarified.
						EXPECT_HMICALL("UI.SetGlobalProperties",
															{
																vrHelpTitle = config.application1.registerAppInterfaceParams.appName,
																-- Clarification is done in APPLINK-26638
																vrHelp ={
																					{
																						text = config.application1.registerAppInterfaceParams.appName,
																						position = 1
																				}	},
																appID = self.applications[config.application1.registerAppInterfaceParams.appName]
															})
						:Do(function(_,data)
							--hmi side: sending UI.SetGlobalProperties response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
						end)

						--TODO: Shall be updated when APPLINK-26640 / APPLINK-26644 are clarified.
						--hmi side: expect TTS.SetGlobalProperties request
						EXPECT_HMICALL("TTS.SetGlobalProperties",
															{
																helpPrompt = 
																						{
																							
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
						:Times(0)

						TC_Number = TC_Number + 1
					end
				--End Test case PositiveResponseCheck.5

		--Description: Positive case with request and update of internal list with helpPrompts, vrHelp
			--Requirement id in JIRA: APPLINK-23730
			--Verification criteria: In case ResetGlobalProperties_request SDL must continue update internal list with "vrHelp" and "helpPrompt" parameters
			--SDL must update internal list with "vrHelp" and "helpPrompt" parameters with new requested AddCommands till mobile app sends SetGlobalProperties 
			--                                                                                      request with valid <vrHelp> and <helpPrompt> params to SDL
				--Preconditions Test case PositiveResponseCheck.5
					Precondition_RegisterApp("TC" ..TC_Number, self)

					for cmdCount = 1, 5 do
						Test["Precondition_NoRequestToHMI_AddManyCommands" .. cmdCount.."_TC"..TC_Number] = function(self)
							AddCommand(self, cmdCount)
						

							EXPECT_HMICALL("UI.SetGlobalProperties",{})
							:Times(0)

							EXPECT_HMICALL("TTS.SetGlobalProperties",{})
							:Times(0)
						end
					end		
					
				
				--Begin Test case PositiveResponseCheck.5
					Test["ResetGlobalProperties_TC" ..TC_Number] = function(self)
						for i = 1, cmdCount*2, i = i+2 do
								SGP_helpPrompt[i] ={
																		text = "Command" .. tostring(cnt_cmd), --menuName}
																		type = "TEXT" }
								SGP_helpPrompt[i + 1] ={
																		text = "300",
																		type = "SILENCE" }

								cnt_cmd = cnt_cmd + 1
						end

						for i = 1, cmdCount do
							SGP_vrHelp[i] = {	
																text = "Command" .. tostring(i),
																position = i
															}
						end

						local cid = self.mobileSession:SendRPC("ResetGlobalProperties",{})
			  			
						--hmi side: expect UI.SetGlobalProperties request
						--TODO: Shall be updated when APPLINK-26640 / APPLINK-26644 are clarified.
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

						--TODO: Shall be updated when APPLINK-26640 / APPLINK-26644 are clarified.
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

						--mobile side: expect ResetGlobalProperties response
						EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
					
						--mobile side: expect OnHashChange notification
						EXPECT_NOTIFICATION("OnHashChange")
						:Times(0)
						
						TC_Number = TC_Number + 1
					end
				--End Test case PositiveResponseCheck.5

				--Precondition Test case PositiveResponseCheck.6
				  -- Add another 5 commands
					for cmdCount = 6, 10 do
						Test["Precondition_NoRequestToHMI_AddManyCommands" .. cmdCount .. "_TC" ..TC_Number] = function(self)
							AddCommand(self, cmdCount)

							EXPECT_HMICALL("UI.SetGlobalProperties",{})
							:Times(0)

							EXPECT_HMICALL("TTS.SetGlobalProperties",{})
							:Times(0)
						end
					end		

				--Begin Test case PositiveResponseCheck.6
					Test["ResetGlobalProperties_AdditionalCommand_TC" ..TC_Number] = function(self)

						for i = 1, cmdCount*2, i = i+2 do
								SGP_helpPrompt[i] ={
																		text = "Command" .. tostring(cnt_cmd), --menuName}
																		type = "TEXT" }
								SGP_helpPrompt[i + 1] ={
																		text = "300",
																		type = "SILENCE" }

								cnt_cmd = cnt_cmd + 1
						end

						for i = 1, cmdCount do
							SGP_vrHelp[i] = {	
																text = "Command" .. tostring(i),
																position = i
															 }
						end
						
						local cid = self.mobileSession:SendRPC("ResetGlobalProperties",{})
			  			
						--hmi side: expect UI.SetGlobalProperties request
						--TODO: Shall be updated when APPLINK-26640 / APPLINK-26644 are clarified.
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

						--TODO: Shall be updated when APPLINK-26640 / APPLINK-26644 are clarified.
						--hmi side: expect TTS.SetGlobalProperties request
						EXPECT_HMICALL("TTS.SetGlobalProperties",
															{
																helpPrompt = { SGP_helpPrompt},
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

						TC_Number = TC_Number + 1
					end
				--End Test case PositiveResponseCheck.6

				--Begin Test case PositiveResponseCheck.7
					Test["SetGlobalProperties_Reset_vrHelp_helpPrompt_TC" ..TC_Number] = function (self)
						xmlReporter.AddMessage("Test Case "..TC_Number)
						userPrint(35,"======================================= Test Case "..TC_Number .." =============================================")
						--mobile side: sending SetGlobalProperties request
						local cid = self.mobileSession:SendRPC("SetGlobalProperties",
																										{
																											helpPrompt = 
																																	{
																																		{
																																			text = "Help prompt 1",
																																			type = "TEXT"
																																		},
																																		{
																																			text = "Help prompt 2",
																																			type = "TEXT"
																																		},
																																		{
																																			text = "Help prompt 3",
																																			type = "TEXT"
																																		},
																																		{
																																			text = "Help prompt 4",
																																			type = "TEXT"
																																		},
																																		{
																																			text = "Help prompt 5",
																																			type = "TEXT"
																																		}

																																	},
																											timeoutPrompt = 
																																	{
																																		{
																																			text = "Timeout prompt",
																																			type = "TEXT"
																																		}
																																	},
																											vrHelpTitle = "VR help title",
																											vrHelp = 
																																	{
																																		{
																																			text = "VR help item",
																																			image = {
																																								value = "action.png",
																																								imageType = "DYNAMIC"
																																							},
																																			position = 1
																																		}
																																	},
																											menuTitle = "Menu Title",
																											menuIcon = 
																																	{
																																		value = "action.png",
																																		imageType = "DYNAMIC"
																																	},
																											keyboardProperties = 
																																	{
																																		keyboardLayout = "QWERTY",
																																		keypressMode = "SINGLE_KEYPRESS",
																																		limitedCharacterList = { "a" },
																																		language = "EN-US",
																																		autoCompleteText = "Daemon, Freedom"
																																	}
																										})
						
						--hmi side: expect UI.SetGlobalProperties request
						EXPECT_HMICALL("UI.SetGlobalProperties",
														{
															vrHelpTitle = "VR help title",
															vrHelp = 
																			{
																				{
																					text = "VR help item",
																					--[[ TODO: update after resolving APPLINK-16052]]
																					image = 
																									{
																										imageType = "DYNAMIC",
																										value = strAppFolder .. "action.png"
																									},--]]
																					position = 1
																			}	},
															menuTitle = "Menu Title",
															--[[ TODO: update after resolving APPLINK-16052]]
															menuIcon = 
																				{
																					imageType = "DYNAMIC",
																					value = strAppFolder .. "action.png"
																				},
															keyboardProperties = 
																				{
																					keyboardLayout = "QWERTY",
																					keypressMode = "SINGLE_KEYPRESS",
																					--[=[ TODO: update after resolving APPLINK-16047
																					limitedCharacterList = { "a" },]=]
																					language = "EN-US",
																					autoCompleteText = "Daemon, Freedom"
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
																							text = "Help prompt 1",
																							type = "TEXT"
																						},
																						{
																							text = "300",
																							type = "SILENCE"
																						},
																						{
																							text = "Help prompt 2",
																							type = "TEXT"
																						},
																						{
																							text = "300",
																							type = "SILENCE"
																						},
																						{
																							text = "Help prompt 3",
																							type = "TEXT"
																						},
																						{
																							text = "300",
																							type = "SILENCE"
																						},
																						{
																							text = "Help prompt 4",
																							type = "TEXT"
																						},
																						{
																							text = "300",
																							type = "SILENCE"
																						},
																						{
																							text = "Help prompt 5",
																							type = "TEXT"
																						},
																						{
																							text = "300",
																							type = "SILENCE"
																						}
																					},
															timeoutPrompt = 
																					{
																						{
																							text = "Timeout prompt",
																							type = "TEXT"
																					}	},
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

						TC_Number = TC_Number + 1
					end
				--End Test case PositiveResponseCheck.7

				
			--Verification criteria: In case ResetGlobalProperties_request SDL must continue update internal list with "vrHelp" and "helpPrompt" parameters
			--SDL must update internal list with "vrHelp" and "helpPrompt" parameters with new requested DeleteCommands till mobile app sends SetGlobalProperties 
			--                                                                                      request with valid <vrHelp> and <helpPrompt> params to SDL
				--Begin Test case PositiveResponseCheck.8
					Test["ResetGlobalPropertiesAfterSetGlobalProp_TC" ..TC_Number] = function(self)
						local cid = self.mobileSession:SendRPC("ResetGlobalProperties",{})
			  			
						--hmi side: expect UI.SetGlobalProperties request
						--TODO: Shall be updated when APPLINK-26640 / APPLINK-26644 are clarified.
						EXPECT_HMICALL("UI.SetGlobalProperties",
															{
																vrHelpTitle = "VR help title",
																vrHelp = 
																			{
																				{
																					text = "VR help item",
																					--[[ TODO: update after resolving APPLINK-16052]]
																					image = 
																									{
																										imageType = "DYNAMIC",
																										value = strAppFolder .. "action.png"
																									},--]]
																					position = 1
																}	},
																appID = self.applications[config.application1.registerAppInterfaceParams.appName]
															})
						:Do(function(_,data)
							--hmi side: sending UI.SetGlobalProperties response
							self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
						end)

						--TODO: Shall be updated when APPLINK-26640 / APPLINK-26644 are clarified.
						--hmi side: expect TTS.SetGlobalProperties request
						EXPECT_HMICALL("TTS.SetGlobalProperties",
															{
																helpPrompt = 
																					{
																						{
																							text = "Help prompt 1",
																							type = "TEXT"
																						},
																						{
																							text = "300",
																							type = "SILENCE"
																						},
																						{
																							text = "Help prompt 2",
																							type = "TEXT"
																						},
																						{
																							text = "300",
																							type = "SILENCE"
																						},
																						{
																							text = "Help prompt 3",
																							type = "TEXT"
																						},
																						{
																							text = "300",
																							type = "SILENCE"
																						},
																						{
																							text = "Help prompt 4",
																							type = "TEXT"
																						},
																						{
																							text = "300",
																							type = "SILENCE"
																						},
																						{
																							text = "Help prompt 5",
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

						--mobile side: expect SetGlobalProperties response
						EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
					
						--mobile side: expect OnHashChange notification
						EXPECT_NOTIFICATION("OnHashChange")
						:Times(0)

						TC_Number = TC_Number + 1
					end
				--End Test case PositiveResponseCheck.8

				--Precondition Test case PositiveResponseCheck.9
					for cmdCount = 1, 7 do
						Test["Precondition_NoRequestToHMI_AddManyCommands" .. cmdCount .. "_TC" ..TC_Number] = function(self)
							AddCommand(self, cmdCount)

							EXPECT_HMICALL("UI.SetGlobalProperties",{})
							:Times(0)

							EXPECT_HMICALL("TTS.SetGlobalProperties",{})
							:Times(0)
						end
					end		

				--Begin Test case PositiveResponseCheck.9
					Test["ResetGlobalProperties_ContinueAddCommands_TC" ..TC_Number] = function(self)

						local cnt_cmd = 1

						for i = 1, cmdCount*2, i = i+2 do
								SGP_helpPrompt[i] ={
																		text = "Command" .. tostring(cnt_cmd), --menuName}
																		type = "TEXT" }
								SGP_helpPrompt[i + 1] ={
																		text = "300",
																		type = "SILENCE" }

								cnt_cmd = cnt_cmd + 1
						end

						for i = 1, cmdCount do
							SGP_vrHelp[i] = {	
																text = "Command" .. tostring(i),
																position = i
															}
						end
						local cid = self.mobileSession:SendRPC("ResetGlobalProperties",{})
			  			
						--hmi side: expect UI.SetGlobalProperties request
						--TODO: Shall be updated when APPLINK-26640 / APPLINK-26644 are clarified.
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

						--TODO: Shall be updated when APPLINK-26640 / APPLINK-26644 are clarified.
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

						TC_Number = TC_Number + 1
					end
				--End Test case PositiveResponseCheck.9

				--Begin Test case PositiveResponseCheck.10
					Test["SetGlobalProperties_AgainReset_vrHelp_helpPrompt_TC" .. TC_Number] = function(self)
						xmlReporter.AddMessage("Test Case "..TC_Number)
						userPrint(35,"======================================= Test Case ".. TC_Number.. " =============================================")
						--mobile side: sending SetGlobalProperties request
						local cid = self.mobileSession:SendRPC("SetGlobalProperties",
																										{
																											helpPrompt = 
																																	{
																																		{
																																			text = "Help prompt 1",
																																			type = "TEXT"
																																		},
																																		{
																																			text = "Help prompt 2",
																																			type = "TEXT"
																																		},
																																		{
																																			text = "Help prompt 3",
																																			type = "TEXT"
																																		},
																																		{
																																			text = "Help prompt 4",
																																			type = "TEXT"
																																		},
																																		{
																																			text = "Help prompt 5",
																																			type = "TEXT"
																																		}

																																	},
																											timeoutPrompt = 
																																	{
																																		{
																																			text = "Timeout prompt",
																																			type = "TEXT"
																																		}
																																	},
																											vrHelpTitle = "VR help title",
																											vrHelp = 
																																	{
																																		{
																																			text = "VR help item",
																																			image = {
																																								value = "action.png",
																																								imageType = "DYNAMIC"
																																							},
																																			position = 1
																																		}
																																	},
																											menuTitle = "Menu Title",
																											menuIcon = 
																																	{
																																		value = "action.png",
																																		imageType = "DYNAMIC"
																																	},
																											keyboardProperties = 
																																	{
																																		keyboardLayout = "QWERTY",
																																		keypressMode = "SINGLE_KEYPRESS",
																																		limitedCharacterList = { "a" },
																																		language = "EN-US",
																																		autoCompleteText = "Daemon, Freedom"
																																	}
																										})
						
						--hmi side: expect UI.SetGlobalProperties request
						EXPECT_HMICALL("UI.SetGlobalProperties",
														{
															vrHelpTitle = "VR help title",
															vrHelp = 
																			{
																				{
																					text = "VR help item",
																					--[[ TODO: update after resolving APPLINK-16052]]
																					image = 
																									{
																										imageType = "DYNAMIC",
																										value = strAppFolder .. "action.png"
																									},--]]
																					position = 1
																			}	},
															menuTitle = "Menu Title",
															--[[ TODO: update after resolving APPLINK-16052]]
															menuIcon = 
																				{
																					imageType = "DYNAMIC",
																					value = strAppFolder .. "action.png"
																				},
															keyboardProperties = 
																				{
																					keyboardLayout = "QWERTY",
																					keypressMode = "SINGLE_KEYPRESS",
																					--[=[ TODO: update after resolving APPLINK-16047
																					limitedCharacterList = { "a" },]=]
																					language = "EN-US",
																					autoCompleteText = "Daemon, Freedom"
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
																							text = "Help prompt 1",
																							type = "TEXT"
																						},
																						{
																							text = "300",
																							type = "SILENCE"
																						},
																						{
																							text = "Help prompt 2",
																							type = "TEXT"
																						},
																						{
																							text = "300",
																							type = "SILENCE"
																						},
																						{
																							text = "Help prompt 3",
																							type = "TEXT"
																						},
																						{
																							text = "300",
																							type = "SILENCE"
																						},
																						{
																							text = "Help prompt 4",
																							type = "TEXT"
																						},
																						{
																							text = "300",
																							type = "SILENCE"
																						},
																						{
																							text = "Help prompt 5",
																							type = "TEXT"
																						},
																						{
																							text = "300",
																							type = "SILENCE"
																						}
																					},
															timeoutPrompt = 
																					{
																						{
																							text = "Timeout prompt",
																							type = "TEXT"
																					}	},
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

						TC_Number = TC_Number + 1
					end
				--End Test case PositiveResponseCheck.10

	--End Test suit PositiveResponseCheck
---------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------
----------------------------------------III TEST BLOCK----------------------------------------
------------------------------------Negative request cases------------------------------------
--Check of negative value of request/response parameters (mobile protocol, HMI protocol)------
----------------------------------------------------------------------------------------------
  --Begin Test suit NegativeRequestCheck
  	--Preconditions Test case NegativeRequestCheck.1

			Precondition_RegisterApp("TC" ..TC_Number, self)

		--Begin Test case NegativeRequestCheck.1
			--Description: SDL receives REJECTED at response from HMI and shall not update internal list
				--Requirement id in JIRA: APPLINK-23729
				--Verification criteria:
					-- SDL must: transfer received REJECTED from HMI to mobile app
					-- SDL must NOT: update internal list with "vrHelp" and "helpPrompt" params
					Test["AddCommand_HMI_REJECTED_TC" ..TC_Number] = function(self)
						local cid = self.mobileSession:SendRPC("AddCommand",
						{
							cmdID = 1,
							menuParams = 	
														{
															position = 0,
															menuName ="Command1"
														}, 
														vrCommands = {"VRCommand1"}
						})
			
						--hmi side: expect UI.AddCommand request 
						EXPECT_HMICALL("UI.AddCommand", {})
						:Do(function(_,data)
							--hmi side: sending UI.AddCommand response 
							self.hmiConnection:SendResponse(data.id, data.method, "REJECTED", {})
						end)

						--mobile side: expect SetGlobalProperties response
						EXPECT_RESPONSE(cid, { success = false, resultCode = "REJECTED"})
						:Timeout(iTimeout)				
						
						--mobile side: expect OnHashChange notification
						EXPECT_NOTIFICATION("OnHashChange")
						:Times(0)

						TC_Number = TC_Number + 1
					end

					Test["NoUpdateFile_HMI_REJECTEDAddCommand_TC" .. TC_Number] = function(self)
						local cid = self.mobileSession:SendRPC("SetGlobalProperties",{menuTitle = "Menu Title"})
					
						--hmi side: expect UI.SetGlobalProperties request
						EXPECT_HMICALL("UI.SetGlobalProperties",
													{
														vrHelpTitle = config.application1.registerAppInterfaceParams.appName,
														-- Clarification is done in APPLINK-26638
														vrHelp ={
																			{
																				text = config.application1.registerAppInterfaceParams.appName,
																				position = 1
																		} },	
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
		--End Test case NegativeRequestCheck.1

		--Begin Test case NegativeRequestCheck.2
			--Description: SDL receives any UNSUPPORTED_RESOURCE at response from HMI and shall not update internal list
				--Requirement id in JIRA: APPLINK-23729
				--Verification criteria:
					-- SDL must: transfer received UNSUPPORTED_RESOURCE from HMI to mobile app
					-- SDL must NOT: update internal list with "vrHelp" and "helpPrompt" params
					Test["AddCommand_HMI_UNSUPPORTED_RESOURCE_TC" ..TC_Number] = function(self)
						local cid = self.mobileSession:SendRPC("AddCommand",
						{
							cmdID = 1,
							menuParams = 	
														{
															position = 0,
															menuName ="Command1"
														}, 
														vrCommands = {"VRCommand1"}
						})
			
						--hmi side: expect UI.AddCommand request 
						EXPECT_HMICALL("UI.AddCommand", {})
						:Do(function(_,data)
							--hmi side: sending UI.AddCommand response 
							self.hmiConnection:SendResponse(data.id, data.method, "UNSUPPORTED_RESOURCE", {})
						end)

						--mobile side: expect SetGlobalProperties response
						EXPECT_RESPONSE(cid, { success = false, resultCode = "UNSUPPORTED_RESOURCE"})
						:Timeout(iTimeout)				
						
						--mobile side: expect OnHashChange notification
						EXPECT_NOTIFICATION("OnHashChange")
						:Times(0)

						CheckNOUpdateFile()

						TC_Number = TC_Number + 1
					end

					Test["NoUpdateFile_HMI_UnsupportedAddCommand_TC" .. TC_Number] = function(self)
						local cid = self.mobileSession:SendRPC("SetGlobalProperties",{menuTitle = "Menu Title"})
					
						--hmi side: expect UI.SetGlobalProperties request
						EXPECT_HMICALL("UI.SetGlobalProperties",
													{
														vrHelpTitle = config.application1.registerAppInterfaceParams.appName,
														-- Clarification is done in APPLINK-26638
														vrHelp ={
																			{
																				text = config.application1.registerAppInterfaceParams.appName,
																				position = 1
																		}	},	
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
		--End Test case NegativeRequestCheck.2

		--Begin Test case NegativeRequestCheck.3
			--Description: SDL receives REJECTED at response from HMI and shall not update internal list
				--Requirement id in JIRA: APPLINK-23729
				--Verification criteria:
					-- SDL must: transfer received REJECTED from HMI to mobile app
					-- SDL must NOT: update internal list with "vrHelp" and "helpPrompt" params
					--Precondition
					Test["Precondition_DeleteCommand_HMI_NegativeResp_TC" ..TC_Number ]
						AddCommand(self, 202)

						EXPECT_HMICALL("UI.SetGlobalProperties",{})
						:Times(0)

						EXPECT_HMICALL("TTS.SetGlobalProperties",{})
						:Times(0)

						EXPECT_NOTIFICATION("OnHashChange")
					end

					Test["CheckInternalList_OneCommand_TC" ..TC_Number] = function(self)
							
							--TODO: Shall be updated after APPLINK-26644 is answered.
							SGP_helpPrompt[1] ={
																text = "Command" .. tostring(202), --menuName}
																type = "TEXT" }
							SGP_helpPrompt[2] ={
																text = "300",
																type = "SILENCE" }
								
							SGP_vrHelp[1] = { text = "Command" .. tostring(202) }
							
							CheckUpdateFile(self, SGP_helpPrompt, SGP_vrHelp)
					end
					
					Test["DeleteCommand_HMI_REJECTED_TC" ..TC_Number] = function(self)
						local cid = self.mobileSession:SendRPC("DeleteCommand",
																										{
																											cmdID = 202
																										})
			
						--hmi side: expect UI.AddCommand request 
						EXPECT_HMICALL("UI.DeleteCommand", {})
						:Do(function(_,data)
							--hmi side: sending UI.AddCommand response 
							self.hmiConnection:SendResponse(data.id, data.method, "REJECTED", {})
						end)

						--mobile side: expect SetGlobalProperties response
						EXPECT_RESPONSE(cid, { success = false, resultCode = "REJECTED"})
						:Timeout(iTimeout)				
						
						--mobile side: expect OnHashChange notification
						EXPECT_NOTIFICATION("OnHashChange")
						:Times(0)

						

						TC_Number = TC_Number + 1
					end

					Test["NoUpdateFile_HMI_REJECTEDDeletCommand_TC" ..TC_Number] = function(self)
							
							--TODO: Shall be updated after APPLINK-26644 is answered.
							SGP_helpPrompt[1] ={
																text = "Command" .. tostring(202), --menuName}
																type = "TEXT" }
							SGP_helpPrompt[2] ={
																text = "300",
																type = "SILENCE" }
								
							SGP_vrHelp[1] = { text = "Command" .. tostring(202) }
							
							CheckUpdateFile(self, SGP_helpPrompt, SGP_vrHelp)
					end
		--End Test case NegativeRequestCheck.3

		--Begin Test case NegativeRequestCheck.4
			--Description: SDL receives any UNSUPPORTED_RESOURCE at response from HMI and shall not update internal list
				--Requirement id in JIRA: APPLINK-23729
				--Verification criteria:
					-- SDL must: transfer received UNSUPPORTED_RESOURCE from HMI to mobile app
					-- SDL must NOT: update internal list with "vrHelp" and "helpPrompt" params
					Test["AddCommand_HMI_UNSUPPORTED_RESOURCE_TC" ..TC_Number] = function(self)
						local cid = self.mobileSession:SendRPC("DeleteCommand",
																										{
																											cmdID = 202
																										})
			
						--hmi side: expect UI.AddCommand request 
						EXPECT_HMICALL("UI.DeleteCommand", {})
						:Do(function(_,data)
							--hmi side: sending UI.AddCommand response 
							self.hmiConnection:SendResponse(data.id, data.method, "UNSUPPORTED_RESOURCE", {})
						end)

						--mobile side: expect SetGlobalProperties response
						EXPECT_RESPONSE(cid, { success = false, resultCode = "UNSUPPORTED_RESOURCE"})
						:Timeout(iTimeout)				
						
						--mobile side: expect OnHashChange notification
						EXPECT_NOTIFICATION("OnHashChange")
						:Times(0)

					

						TC_Number = TC_Number + 1
					end

					Test["NoUpdateFile_HMI_UnsupportedDeletCommand_TC" ..TC_Number] = function(self)
							
							--TODO: Shall be updated after APPLINK-26644 is answered.
							SGP_helpPrompt[1] ={
																text = "Command" .. tostring(202), --menuName}
																type = "TEXT" }
							SGP_helpPrompt[2] ={
																text = "300",
																type = "SILENCE" }
								
							SGP_vrHelp[1] = { text = "Command" .. tostring(202) }
							
							CheckUpdateFile(self, SGP_helpPrompt, SGP_vrHelp)
					end
		--End Test case NegativeRequestCheck.4

  --End Test suit NegativeRequestCheck
----------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------
----------------------------------------IV TEST BLOCK-----------------------------------------
---------------------------------------Result codes check-------------------------------------
------------------Check of each resultCode + success (true, false)----------------------------
	--These test shall be performed in tests for testing API SetGlobalProperties. 
	--Begin Test suit ResultCodesCheck
	--End Test suit ResultCodesCheck

----------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------
----------------------------------------V TEST BLOCK------------------------------------------
------------------------------------ HMI negative cases---------------------------------------
----------------------------------incorrect data from HMI-------------------------------------
  --These test shall be performed in tests for testing API SetGlobalProperties.
  --See ATF_SetGlobalProperties.lua
  --Begin Test suit HMINegativeCases
  --End Test suit HMINegativeCases

----------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------
----------------------------------------VI TEST BLOCK-----------------------------------------
--------------------------Sequence with emulating of user's action(s)-------------------------
----------------------------------------------------------------------------------------------
  --Begin Test suit EmulatingUserAction
  	--Begin Test case EmulatingUserAction.1
			--Preconditions Test case EmulatingUserAction.1
			Precondition_RegisterApp("TC"..TC_Number, self)

			Test["Precondition_DefaultParams_AddDeleteCmd_TC" ..TC_Number] = function (self)					
				
					--mobile side: sending SetGlobalProperties request
					local cid = self.mobileSession:SendRPC("SetGlobalProperties",{ menuTitle = "Menu Title"})
					
					--hmi side: expect UI.SetGlobalProperties request
					EXPECT_HMICALL("UI.SetGlobalProperties",
													{
														vrHelpTitle = config.application1.registerAppInterfaceParams.appName,
														-- Clarification is done in APPLINK-26638
														vrHelp ={
																			{
																				text = config.application1.registerAppInterfaceParams.appName,
																				position = 1
																		}	},
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

			for cmdCount = 1, 10 do
				Test["Precondition_NoRequestToHMI_AddCommand" .. cmdCount .. "_TC" ..TC_Number] = function(self)
				
					AddCommand(self, cmdCount)

					EXPECT_HMICALL("UI.SetGlobalProperties",{})
					:Times(0)

					EXPECT_HMICALL("TTS.SetGlobalProperties",{})
					:Times(0)
				end						
						
				Test["Precondition_CheckInternalList_AddCommand" .. cmdCount .. "_TC" ..TC_Number] = function(self)
						
					--TODO: Shall be updated after APPLINK-26644 is answered.
					SGP_helpPrompt[1] ={
																text = "Command" .. tostring(cmdCount), --menuName}
																type = "TEXT" }
					SGP_helpPrompt[2] ={
																text = "300",
																type = "SILENCE" }
								
					SGP_vrHelp[1] = { text = "Command" .. tostring(cmdCount) }
							
					CheckUpdateFile(self, SGP_helpPrompt, SGP_vrHelp)
				end

						
				Test["Precondition_NoRequestToHMI_DeleteCommand" .. cmdCount .."_TC" ..TC_Number] = function(self)
					DeleteCommand(self, cmdCount)
							
					EXPECT_HMICALL("UI.SetGlobalProperties",{})
					:Times(0)

					EXPECT_HMICALL("TTS.SetGlobalProperties",{})
					:Times(0)
				end
			end

			--Description:Sequence that verifies that SGP starts with default values of vrHelp and helpPrompt;
			--            Successfully updates internal list with AddCommand and DeleteCommand
			--            And when nothing in internal list returns again default values
			--Requirement id in JIRA: APPLINK-19475; APPLINK-23962; APPLINK-23728
			--Verification criteria:
				--In case mobile app has NO registered AddCommands and/or DeleteCommands requests (previously added or resumed within data resumption process)
				-- SDL must use current appName as default value for "vrHelp" parameter
				-- SDL must retrieve value of "helpPrompt" from .ini file ([GLOBAL PROPERTIES] section -> "HelpPrompt" param)					

				Test["SetGlobalProperties_DefaultParams_AddDeleteCmd_TC" ..TC_Number] = function (self)					
					xmlReporter.AddMessage("Test Case "..TC_Number)
					userPrint(35,"======================================= Test Case "..TC_Number.." =============================================")
					--mobile side: sending SetGlobalProperties request
					local cid = self.mobileSession:SendRPC("SetGlobalProperties",{ menuTitle = "Menu Title"})
					
					--hmi side: expect UI.SetGlobalProperties request
					EXPECT_HMICALL("UI.SetGlobalProperties",
													{
														vrHelpTitle = config.application1.registerAppInterfaceParams.appName,
														-- Clarification is done in APPLINK-26638
														vrHelp ={
																			{
																				text = config.application1.registerAppInterfaceParams.appName,
																				position = 1
																		}	},	
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

					TC_Number = TC_Number + 1
				end
		--End Test case EmulatingUserAction.1

		--Begin Test case EmulatingUserAction.2
			--Precondition
			Precondition_RegisterApp("TC"..TC_Number, self)

			Test["Precondition_NoRespUpdateList_TC" ..TC_Number] = function(self)
			
				--mobile side: sending SetGlobalProperties request
				local cid = self.mobileSession:SendRPC("SetGlobalProperties",
																											{
																												helpPrompt = 
																																		{
																																			{
																																				text = "Help prompt 1",
																																				type = "TEXT"
																																			},
																																			{
																																				text = "Help prompt 2",
																																				type = "TEXT"
																																			},
																																			{
																																				text = "Help prompt 3",
																																				type = "TEXT"
																																			},
																																			{
																																				text = "Help prompt 4",
																																				type = "TEXT"
																																			},
																																			{
																																				text = "Help prompt 5",
																																				type = "TEXT"
																																			}

																																		},
																												timeoutPrompt = 
																																		{
																																			{
																																				text = "Timeout prompt",
																																				type = "TEXT"
																																			}
																																		},
																												vrHelpTitle = "VR help title",
																												vrHelp = 
																																		{
																																			{
																																				text = "VR help item",
																																				image = {
																																									value = "action.png",
																																									imageType = "DYNAMIC"
																																								},
																																				position = 1
																																			}
																																		},
																												menuTitle = "Menu Title",
																												menuIcon = 
																																		{
																																			value = "action.png",
																																			imageType = "DYNAMIC"
																																		},
																												keyboardProperties = 
																																		{
																																			keyboardLayout = "QWERTY",
																																			keypressMode = "SINGLE_KEYPRESS",
																																			limitedCharacterList = { "a" },
																																			language = "EN-US",
																																			autoCompleteText = "Daemon, Freedom"
																																		}
																											})
							
				--hmi side: expect UI.SetGlobalProperties request
				EXPECT_HMICALL("UI.SetGlobalProperties",
															{
																vrHelpTitle = "VR help title",
																vrHelp = 
																				{
																					{
																						text = "VR help item",
																						--[[ TODO: update after resolving APPLINK-16052]]
																						image = 
																										{
																											imageType = "DYNAMIC",
																											value = strAppFolder .. "action.png"
																										},--]]
																						position = 1
																				}	},
																menuTitle = "Menu Title",
																--[[ TODO: update after resolving APPLINK-16052]]
																menuIcon = 
																					{
																						imageType = "DYNAMIC",
																						value = strAppFolder .. "action.png"
																					},
																keyboardProperties = 
																					{
																						keyboardLayout = "QWERTY",
																						keypressMode = "SINGLE_KEYPRESS",
																						--[=[ TODO: update after resolving APPLINK-16047
																						limitedCharacterList = { "a" },]=]
																						language = "EN-US",
																						autoCompleteText = "Daemon, Freedom"
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
																								text = "Help prompt 1",
																								type = "TEXT"
																							},
																							{
																								text = "300",
																								type = "SILENCE"
																							},
																							{
																								text = "Help prompt 2",
																								type = "TEXT"
																							},
																							{
																								text = "300",
																								type = "SILENCE"
																							},
																							{
																								text = "Help prompt 3",
																								type = "TEXT"
																							},
																							{
																								text = "300",
																								type = "SILENCE"
																							},
																							{
																								text = "Help prompt 4",
																								type = "TEXT"
																							},
																							{
																								text = "300",
																								type = "SILENCE"
																							},
																							{
																								text = "Help prompt 5",
																								type = "TEXT"
																							},
																							{
																								text = "300",
																								type = "SILENCE"
																							}
																						},
																timeoutPrompt = 
																						{
																							{
																								text = "Timeout prompt",
																								type = "TEXT"
																						}	},
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
			for cmdCount = 1, 10 do
				Test["Precondition_NoRequestToHMI_AddCommand" .. cmdCount .. "_TC" ..TC_Number] = function(self)
				
					AddCommand(self, cmdCount)

					EXPECT_HMICALL("UI.SetGlobalProperties",{})
					:Times(0)

					EXPECT_HMICALL("TTS.SetGlobalProperties",{})
					:Times(0)
				end						
						
				Test["Precondition_CheckInternalList_AddCommand" .. cmdCount .. "_TC" ..TC_Number] = function(self)
					local i = 1
					for helpPrompt_count = 1, 5
						SGP_helpPrompt[i]={
																text = "Help prompt " .. helpPrompt_count,
																type = "TEXT"
															}
						SGP_helpPrompt[i+1]={
															{
																text = "300",
																type = "SILENCE"
															}
						i = i + 2
					end
					
					--TODO: Shall be updated after APPLINK-26644 is answered.
					SGP_helpPrompt[helpPrompt_count*2 + 1] ={
																text = "Command" .. tostring(cmdCount), --menuName}
																type = "TEXT" }
					SGP_helpPrompt[helpPrompt_count*2 + 2] ={
																text = "300",
																type = "SILENCE" }
					
					SGP_vrHelp[1]={ text = "VR help item"}
					SGP_vrHelp[2] = { text = "Command" .. tostring(cmdCount) }
							
					CheckUpdateFile(self, SGP_helpPrompt, SGP_vrHelp)
				end

						
				Test["Precondition_NoRequestToHMI_DeleteCommand" .. cmdCount .."_TC" ..TC_Number] = function(self)
					DeleteCommand(self, cmdCount)
							
					EXPECT_HMICALL("UI.SetGlobalProperties",{})
					:Times(0)

					EXPECT_HMICALL("TTS.SetGlobalProperties",{})
					:Times(0)
				end
			end
			--Description:Sequence that verifies that SGP starts with 5 helpPrompt params;
			--            Successfully updates internal list with AddCommand and DeleteCommand
			--            And when all commands are added / deleted only 5 helpPrompt params are left.
				Test["SetGlobalProperties_5helpPrompt_vrHelpTitle_Assigned" ..TC_Number] = function(self)
					
					--mobile side: sending SetGlobalProperties request
					local cid = self.mobileSession:SendRPC("SetGlobalProperties", { menuTitle = "Menu Title" })
							
					--hmi side: expect UI.SetGlobalProperties request
					EXPECT_HMICALL("UI.SetGlobalProperties",
															{
																vrHelpTitle = "VR help title",
																vrHelp = 
																				{
																					{
																						text = "VR help item",
																						--[[ TODO: update after resolving APPLINK-16052]]
																						image = 
																										{
																											imageType = "DYNAMIC",
																											value = strAppFolder .. "action.png"
																										},--]]
																						position = 1
																				}	},
																menuTitle = "Menu Title",
																--[[ TODO: update after resolving APPLINK-16052]]
																menuIcon = 
																					{
																						imageType = "DYNAMIC",
																						value = strAppFolder .. "action.png"
																					},
																keyboardProperties = 
																					{
																						keyboardLayout = "QWERTY",
																						keypressMode = "SINGLE_KEYPRESS",
																						--[=[ TODO: update after resolving APPLINK-16047
																						limitedCharacterList = { "a" },]=]
																						language = "EN-US",
																						autoCompleteText = "Daemon, Freedom"
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
																								text = "Help prompt 1",
																								type = "TEXT"
																							},
																							{
																								text = "300",
																								type = "SILENCE"
																							},
																							{
																								text = "Help prompt 2",
																								type = "TEXT"
																							},
																							{
																								text = "300",
																								type = "SILENCE"
																							},
																							{
																								text = "Help prompt 3",
																								type = "TEXT"
																							},
																							{
																								text = "300",
																								type = "SILENCE"
																							},
																							{
																								text = "Help prompt 4",
																								type = "TEXT"
																							},
																							{
																								text = "300",
																								type = "SILENCE"
																							},
																							{
																								text = "Help prompt 5",
																								type = "TEXT"
																							},
																							{
																								text = "300",
																								type = "SILENCE"
																							}
																						},
																timeoutPrompt = 
																						{
																							{
																								text = "Timeout prompt",
																								type = "TEXT"
																						}	},
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

					TC_Number = TC_Number + 1
				end
		--End Test case EmulatingUserAction.2
  --End Test suit EmulatingUserAction
----------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------
----------------------------------------VII TEST BLOCK----------------------------------------
-------------------------------------Different HMIStatus--------------------------------------
--processing of request/response in different HMIlevels, SystemContext, AudioStreamingState---
  --Begin Test suit Different HMIStatus
  	--Begin Test case FULLHMIStatus.1
			--Preconditions Test case FULLHMIStatus.1
			Precondition_RegisterApp("TC"..TC_Number, self)

			commonSteps:ActivationApp("TC"..TC_Number)
			
			Test["Precondition_FULL_DefaultParams_AddDeleteCmd_TC" ..TC_Number] = function (self)					
				
					--mobile side: sending SetGlobalProperties request
					local cid = self.mobileSession:SendRPC("SetGlobalProperties",{ menuTitle = "Menu Title"})
					
					--hmi side: expect UI.SetGlobalProperties request
					EXPECT_HMICALL("UI.SetGlobalProperties",
													{
														vrHelpTitle = config.application1.registerAppInterfaceParams.appName,
														-- Clarification is done in APPLINK-26638
														vrHelp ={
																			{
																				text = config.application1.registerAppInterfaceParams.appName,
																				position = 1
																		}	},	
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

			for cmdCount = 1, 10 do
				Test["Precondition_FULL_NoRequestToHMI_AddCommand" .. cmdCount .. "_TC" ..TC_Number] = function(self)
				
					AddCommand(self, cmdCount)

					EXPECT_HMICALL("UI.SetGlobalProperties",{})
					:Times(0)

					EXPECT_HMICALL("TTS.SetGlobalProperties",{})
					:Times(0)
				end						
						
				Test["Precondition_FULL_CheckInternalList_AddCommand" .. cmdCount .. "_TC" ..TC_Number] = function(self)
						
					--TODO: Shall be updated after APPLINK-26644 is answered.
					SGP_helpPrompt[1] ={
																text = "Command" .. tostring(cmdCount), --menuName}
																type = "TEXT" }
					SGP_helpPrompt[2] ={
																text = "300",
																type = "SILENCE" }
								
					SGP_vrHelp[1] = { text = "Command" .. tostring(cmdCount) }
							
					CheckUpdateFile(self, SGP_helpPrompt, SGP_vrHelp)
				end

						
				Test["Precondition_FULL_NoRequestToHMI_DeleteCommand" .. cmdCount .."_TC" ..TC_Number] = function(self)
					DeleteCommand(self, cmdCount)
							
					EXPECT_HMICALL("UI.SetGlobalProperties",{})
					:Times(0)

					EXPECT_HMICALL("TTS.SetGlobalProperties",{})
					:Times(0)
				end
			end

			--Description:Sequence that verifies that SGP starts with default values of vrHelp and helpPrompt;
			--            Successfully updates internal list with AddCommand and DeleteCommand
			--            And when nothing in internal list returns again default values
			--Requirement id in JIRA: APPLINK-19475; APPLINK-23962; APPLINK-23728
			--Verification criteria:
				--In case mobile app has NO registered AddCommands and/or DeleteCommands requests (previously added or resumed within data resumption process)
				-- SDL must use current appName as default value for "vrHelp" parameter
				-- SDL must retrieve value of "helpPrompt" from .ini file ([GLOBAL PROPERTIES] section -> "HelpPrompt" param)					

				Test["SetGlobalProperties_FULL_DefaultParams_AddDeleteCmd_TC" ..TC_Number] = function (self)					
					xmlReporter.AddMessage("Test Case "..TC_Number)
					userPrint(35,"======================================= Test Case "..TC_Number.." =============================================")
					--mobile side: sending SetGlobalProperties request
					local cid = self.mobileSession:SendRPC("SetGlobalProperties",{ menuTitle = "Menu Title"})
					
					--hmi side: expect UI.SetGlobalProperties request
					EXPECT_HMICALL("UI.SetGlobalProperties",
													{
														vrHelpTitle = config.application1.registerAppInterfaceParams.appName,
														-- Clarification is done in APPLINK-26638
														vrHelp ={
																			{
																				text = config.application1.registerAppInterfaceParams.appName,
																				position = 1
																		}	},	
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

					TC_Number = TC_Number + 1
				end
		--End Test case FULLHMIStatus.1

		--Begin Test case FULLHMIStatus.2
			--Precondition
			Precondition_RegisterApp("TC"..TC_Number, self)
			
			commonSteps:ActivationApp("TC"..TC_Number)

			Test["Precondition_FULL_NoRespUpdateList_TC" ..TC_Number] = function(self)
			
				--mobile side: sending SetGlobalProperties request
				local cid = self.mobileSession:SendRPC("SetGlobalProperties",
																											{
																												helpPrompt = 
																																		{
																																			{
																																				text = "Help prompt 1",
																																				type = "TEXT"
																																			},
																																			{
																																				text = "Help prompt 2",
																																				type = "TEXT"
																																			},
																																			{
																																				text = "Help prompt 3",
																																				type = "TEXT"
																																			},
																																			{
																																				text = "Help prompt 4",
																																				type = "TEXT"
																																			},
																																			{
																																				text = "Help prompt 5",
																																				type = "TEXT"
																																			}

																																		},
																												timeoutPrompt = 
																																		{
																																			{
																																				text = "Timeout prompt",
																																				type = "TEXT"
																																			}
																																		},
																												vrHelpTitle = "VR help title",
																												vrHelp = 
																																		{
																																			{
																																				text = "VR help item",
																																				image = {
																																									value = "action.png",
																																									imageType = "DYNAMIC"
																																								},
																																				position = 1
																																			}
																																		},
																												menuTitle = "Menu Title",
																												menuIcon = 
																																		{
																																			value = "action.png",
																																			imageType = "DYNAMIC"
																																		},
																												keyboardProperties = 
																																		{
																																			keyboardLayout = "QWERTY",
																																			keypressMode = "SINGLE_KEYPRESS",
																																			limitedCharacterList = { "a" },
																																			language = "EN-US",
																																			autoCompleteText = "Daemon, Freedom"
																																		}
																											})
							
				--hmi side: expect UI.SetGlobalProperties request
				EXPECT_HMICALL("UI.SetGlobalProperties",
															{
																vrHelpTitle = "VR help title",
																vrHelp = 
																				{
																					{
																						text = "VR help item",
																						--[[ TODO: update after resolving APPLINK-16052]]
																						image = 
																										{
																											imageType = "DYNAMIC",
																											value = strAppFolder .. "action.png"
																										},--]]
																						position = 1
																				}	},
																menuTitle = "Menu Title",
																--[[ TODO: update after resolving APPLINK-16052]]
																menuIcon = 
																					{
																						imageType = "DYNAMIC",
																						value = strAppFolder .. "action.png"
																					},
																keyboardProperties = 
																					{
																						keyboardLayout = "QWERTY",
																						keypressMode = "SINGLE_KEYPRESS",
																						--[=[ TODO: update after resolving APPLINK-16047
																						limitedCharacterList = { "a" },]=]
																						language = "EN-US",
																						autoCompleteText = "Daemon, Freedom"
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
																								text = "Help prompt 1",
																								type = "TEXT"
																							},
																							{
																								text = "300",
																								type = "SILENCE"
																							},
																							{
																								text = "Help prompt 2",
																								type = "TEXT"
																							},
																							{
																								text = "300",
																								type = "SILENCE"
																							},
																							{
																								text = "Help prompt 3",
																								type = "TEXT"
																							},
																							{
																								text = "300",
																								type = "SILENCE"
																							},
																							{
																								text = "Help prompt 4",
																								type = "TEXT"
																							},
																							{
																								text = "300",
																								type = "SILENCE"
																							},
																							{
																								text = "Help prompt 5",
																								type = "TEXT"
																							},
																							{
																								text = "300",
																								type = "SILENCE"
																							}
																						},
																timeoutPrompt = 
																						{
																							{
																								text = "Timeout prompt",
																								type = "TEXT"
																						}	},
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
			for cmdCount = 1, 10 do
				Test["Precondition_FULL_NoRequestToHMI_AddCommand" .. cmdCount .. "_TC" ..TC_Number] = function(self)
				
					AddCommand(self, cmdCount)

					EXPECT_HMICALL("UI.SetGlobalProperties",{})
					:Times(0)

					EXPECT_HMICALL("TTS.SetGlobalProperties",{})
					:Times(0)
				end						
						
				Test["Precondition_FULL_CheckInternalList_AddCommand" .. cmdCount .. "_TC" ..TC_Number] = function(self)
					local i = 1
					for helpPrompt_count = 1, 5
						SGP_helpPrompt[i]={
																text = "Help prompt " .. helpPrompt_count,
																type = "TEXT"
															}
						SGP_helpPrompt[i+1]={
															{
																text = "300",
																type = "SILENCE"
															}
						i = i + 2
					end
					
					--TODO: Shall be updated after APPLINK-26644 is answered.
					SGP_helpPrompt[helpPrompt_count*2 + 1] ={
																text = "Command" .. tostring(cmdCount), --menuName}
																type = "TEXT" }
					SGP_helpPrompt[helpPrompt_count*2 + 2] ={
																text = "300",
																type = "SILENCE" }
					
					SGP_vrHelp[1]={ text = "VR help item"}
					SGP_vrHelp[2] = { text = "Command" .. tostring(cmdCount) }
							
					CheckUpdateFile(self, SGP_helpPrompt, SGP_vrHelp)
				end

						
				Test["Precondition_FULL_NoRequestToHMI_DeleteCommand" .. cmdCount .."_TC" ..TC_Number] = function(self)
					DeleteCommand(self, cmdCount)
							
					EXPECT_HMICALL("UI.SetGlobalProperties",{})
					:Times(0)

					EXPECT_HMICALL("TTS.SetGlobalProperties",{})
					:Times(0)
				end
			end
			--Description:Sequence that verifies that SGP starts with 5 helpPrompt params;
			--            Successfully updates internal list with AddCommand and DeleteCommand
			--            And when all commands are added / deleted only 5 helpPrompt params are left.
				Test["SetGlobalProperties_FULL_5helpPrompt_vrHelpTitle_Assigned" ..TC_Number] = function(self)
					
					--mobile side: sending SetGlobalProperties request
					local cid = self.mobileSession:SendRPC("SetGlobalProperties", { menuTitle = "Menu Title" })
							
					--hmi side: expect UI.SetGlobalProperties request
					EXPECT_HMICALL("UI.SetGlobalProperties",
															{
																vrHelpTitle = "VR help title",
																vrHelp = 
																				{
																					{
																						text = "VR help item",
																						--[[ TODO: update after resolving APPLINK-16052]]
																						image = 
																										{
																											imageType = "DYNAMIC",
																											value = strAppFolder .. "action.png"
																										},--]]
																						position = 1
																				}	},
																menuTitle = "Menu Title",
																--[[ TODO: update after resolving APPLINK-16052]]
																menuIcon = 
																					{
																						imageType = "DYNAMIC",
																						value = strAppFolder .. "action.png"
																					},
																keyboardProperties = 
																					{
																						keyboardLayout = "QWERTY",
																						keypressMode = "SINGLE_KEYPRESS",
																						--[=[ TODO: update after resolving APPLINK-16047
																						limitedCharacterList = { "a" },]=]
																						language = "EN-US",
																						autoCompleteText = "Daemon, Freedom"
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
																								text = "Help prompt 1",
																								type = "TEXT"
																							},
																							{
																								text = "300",
																								type = "SILENCE"
																							},
																							{
																								text = "Help prompt 2",
																								type = "TEXT"
																							},
																							{
																								text = "300",
																								type = "SILENCE"
																							},
																							{
																								text = "Help prompt 3",
																								type = "TEXT"
																							},
																							{
																								text = "300",
																								type = "SILENCE"
																							},
																							{
																								text = "Help prompt 4",
																								type = "TEXT"
																							},
																							{
																								text = "300",
																								type = "SILENCE"
																							},
																							{
																								text = "Help prompt 5",
																								type = "TEXT"
																							},
																							{
																								text = "300",
																								type = "SILENCE"
																							}
																						},
																timeoutPrompt = 
																						{
																							{
																								text = "Timeout prompt",
																								type = "TEXT"
																						}	},
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

					TC_Number = TC_Number + 1
				end
		--End Test case FULLHMIStatus.2
  --End Test suit Different HMIStatus
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------
-------------------------------------------Postconditions------------------------------------
---------------------------------------------------------------------------------------------
	function Test:Postcondition_remove_user_connecttest_restore_preloaded_file()
  	os.execute(" cp " .. config.pathToSDL .. "sdl_preloaded_pt_origin.json " .. config.pathToSDL .. "sdl_preloaded_pt.json" )
  	os.execute(" rm -f " .. config.pathToSDL .. "/sdl_preloaded_pt_origin.json" ) 
	end
---------------------------------------------------------------------------------------------

return Test