-- Script is developed by Dong Thanh Ta
-- for ATF version 2.2

--------------------------------------------------------------------------------
-- Preconditions
--------------------------------------------------------------------------------
local commonPreconditions = require('user_modules/shared_testcases/commonPreconditions')

-- Cretion dummy connections fo script
os.execute("ifconfig lo:1 1.0.0.1 ; ifconfig lo:2 2.0.0.1 ; ifconfig lo:3 3.0.0.1 ; ifconfig lo:4 4.0.0.1 ; ifconfig lo:5 5.0.0.1 ; ifconfig lo:6 6.0.0.1 ; ifconfig lo:7 7.0.0.1 ; ifconfig lo:8 8.0.0.1 ; ifconfig lo:9 9.0.0.1 ; ifconfig lo:10 10.0.0.1 ; ifconfig lo:11 11.0.0.1 ; ifconfig lo:12 12.0.0.1 ; ifconfig lo:13 13.0.0.1 ; ifconfig lo:14 14.0.0.1 ; ifconfig lo:15 15.0.0.1 ; ifconfig lo:16 16.0.0.1 ; ifconfig lo:17 17.0.0.1 ; ifconfig lo:18 18.0.0.1 ; ifconfig lo:19 19.0.0.1 ; ifconfig lo:20 20.0.0.1 ; ifconfig lo:21 21.0.0.1 ; ifconfig lo:22 22.0.0.1 ; ifconfig lo:23 23.0.0.1 ; ifconfig lo:24 24.0.0.1 ; ifconfig lo:25 25.0.0.1 ; ifconfig lo:26 26.0.0.1 ; ifconfig lo:27 27.0.0.1 ; ifconfig lo:28 28.0.0.1 ; ifconfig lo:29 29.0.0.1 ; ifconfig lo:30 30.0.0.1 ; ifconfig lo:31 31.0.0.1 ; ifconfig lo:32 32.0.0.1 ; ifconfig lo:33 33.0.0.1 ; ifconfig lo:34 34.0.0.1 ; ifconfig lo:35 35.0.0.1 ; ifconfig lo:36 36.0.0.1 ; ifconfig lo:37 37.0.0.1 ; ifconfig lo:38 38.0.0.1 ; ifconfig lo:39 39.0.0.1 ; ifconfig lo:40 40.0.0.1 ; ifconfig lo:41 41.0.0.1 ; ifconfig lo:42 42.0.0.1 ; ifconfig lo:43 43.0.0.1 ; ifconfig lo:44 44.0.0.1 ; ifconfig lo:45 45.0.0.1 ; ifconfig lo:46 46.0.0.1 ; ifconfig lo:47 47.0.0.1 ; ifconfig lo:48 48.0.0.1 ; ifconfig lo:49 49.0.0.1 ; ifconfig lo:50 50.0.0.1 ; ifconfig lo:51 51.0.0.1 ; ifconfig lo:52 52.0.0.1 ; ifconfig lo:53 53.0.0.1 ; ifconfig lo:54 54.0.0.1 ; ifconfig lo:55 55.0.0.1 ; ifconfig lo:56 56.0.0.1 ; ifconfig lo:57 57.0.0.1 ; ifconfig lo:58 58.0.0.1 ; ifconfig lo:59 59.0.0.1 ; ifconfig lo:60 60.0.0.1 ; ifconfig lo:61 61.0.0.1 ; ifconfig lo:62 62.0.0.1 ; ifconfig lo:63 63.0.0.1 ; ifconfig lo:64 64.0.0.1 ; ifconfig lo:65 65.0.0.1 ; ifconfig lo:66 66.0.0.1 ; ifconfig lo:67 67.0.0.1 ; ifconfig lo:68 68.0.0.1 ; ifconfig lo:69 69.0.0.1 ; ifconfig lo:70 70.0.0.1 ; ifconfig lo:71 71.0.0.1 ; ifconfig lo:72 72.0.0.1 ; ifconfig lo:73 73.0.0.1 ; ifconfig lo:74 74.0.0.1 ; ifconfig lo:75 75.0.0.1 ; ifconfig lo:76 76.0.0.1 ; ifconfig lo:77 77.0.0.1 ; ifconfig lo:78 78.0.0.1 ; ifconfig lo:79 79.0.0.1 ; ifconfig lo:80 80.0.0.1 ; ifconfig lo:81 81.0.0.1 ; ifconfig lo:82 82.0.0.1 ; ifconfig lo:83 83.0.0.1 ; ifconfig lo:84 84.0.0.1 ; ifconfig lo:85 85.0.0.1 ; ifconfig lo:86 86.0.0.1 ; ifconfig lo:87 87.0.0.1 ; ifconfig lo:88 88.0.0.1 ; ifconfig lo:89 89.0.0.1 ; ifconfig lo:90 90.0.0.1 ; ifconfig lo:91 91.0.0.1 ; ifconfig lo:92 92.0.0.1 ; ifconfig lo:93 93.0.0.1 ; ifconfig lo:94 94.0.0.1 ; ifconfig lo:95 95.0.0.1 ; ifconfig lo:96 96.0.0.1 ; ifconfig lo:97 97.0.0.1 ; ifconfig lo:98 98.0.0.1 ; ifconfig lo:99 99.0.0.1 ; ifconfig lo:100 100.0.0.1 ; ifconfig lo:101 101.0.0.1")

--------------------------------------------------------------------------------
--Precondition: preparation connecttest_resumption.lua
commonPreconditions:Connecttest_without_ExitBySDLDisconnect_WithoutOpenConnectionRegisterApp("connecttest_resumption.lua")

commonPreconditions:Connecttest_OnButtonSubscription("connecttest_resumption.lua")

Test = require('user_modules/connecttest_resumption')
require('cardinalities')
local mobile_session = require('mobile_session')
local tcp = require('tcp_connection')
local file_connection  = require('file_connection')
local mobile  = require('mobile_connection')

----------------------------------------------------------------------------
-- User required files
require('user_modules/AppTypes')
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
local commonTestCases = require('user_modules/shared_testcases/commonTestCases')
local commonSteps = require('user_modules/shared_testcases/commonSteps')
local policyTable = require('user_modules/shared_testcases/testCasesForPolicyTable')
----------------------------------------------------------------------------

-- User required variables
local appIDAndDeviceMac = config.application1.registerAppInterfaceParams.appID.. "_" .. config.deviceMAC.. "/"
config.SDLStoragePath = config.pathToSDL .. "storage/"
local storagePath = config.SDLStoragePath..appIDAndDeviceMac

local deviceMAC_Of_TheSecondDevice  = "54286cb92365be544aa7008b92854b9648072cf8d8b17b372fd0786bef69d7a2"


local Connections = { 
	{connection = Test.mobileConnection1, session = Test.mobileSession1}, 
	{connection = Test.mobileConnection2, session = Test.mobileSession2}
}


---------------------------------------------------------------------------------------------
-------------------------------------------Preconditions-------------------------------------
---------------------------------------------------------------------------------------------

    -- Postcondition: removing user_modules/connecttest_resumption.lua
	function Test:Remove_user_connecttest()
	 	os.execute( "rm -f ./user_modules/connecttest_resumption.lua" )
	end

	commonSteps:DeleteLogsFileAndPolicyTable()

	--Print new line to separate new test cases group
	commonFunctions:newTestCasesGroup("Preconditions")
			
	--1. Update policy to allow request
	--TODO: Will be updated after policy flow implementation
	policyTable:Precondition_updatePolicy_By_overwriting_preloaded_pt("files/ptu_general.json")
	
	
	function Test:Precondition_CloseConnection()

		self.mobileConnection:Close()

		commonTestCases:DelayedExp(3000)
		
	end

	
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------

	
	-- Test case: APPLINK-16333: TC_Resumption_MultiDevices_01
	-- Related CRQs: APPLINK-14256: [RTC 630168] OnAppRegistered: SDL must provide the value of deviceID depending on TransportType
	-- Description: Check that SDL checks deviceID during resumption. 
	local function APPLINK_16333()

		--Print new line to separate new test cases group
		commonFunctions:newTestCasesGroup("Test case APPLINK-16333: TC_Resumption_MultiDevices_01")

		--Connect device1, register app1 and create some persistant data for checking resumption
		local function step1_Precondition()	

			function Test:Step1_ConnectDevice()
				
				commonTestCases:DelayedExp(2000)
				
				self:connectMobile()

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
					}
				)
				:Do(function(_,data)
					self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
				end)
				:Times(AtLeast(1)) --ToDo: Investigate why there is more than one request 
				
			end

			function Test:Step1_RegisterApplication()
				
				commonTestCases:DelayedExp(3000)
				
				self.mobileSession = mobile_session.MobileSession(self, self.mobileConnection)

				self.mobileSession:StartService(7)
				:Do(function()
				
					local correlationId = self.mobileSession:SendRPC("RegisterAppInterface", config.application1.registerAppInterfaceParams)

					EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered")
					:Do(function(_,data)
						self.HMIAppID = data.params.application.appID
					end)

					self.mobileSession:ExpectResponse(correlationId, { success = true, resultCode = "SUCCESS" })
					self.mobileSession:ExpectNotification("OnHMIStatus", {hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
				end)
				
			end

			commonSteps:ActivationApp(nil, "Step1_Activate_App")
				
			function Test:Step1_AddCommand()
				--mobile side: sending AddCommand request
				local cid = self.mobileSession:SendRPC("AddCommand",
														{
															cmdID = 11,
															menuParams = 	
															{ 
																--parentID = 1,
																position = 0,
																menuName ="Commandpositive"
															}, 
															vrCommands = 
															{ 
																"VRCommandonepositive",
																"VRCommandonepositivedouble"
															}
														})
				--hmi side: expect UI.AddCommand request
				EXPECT_HMICALL("UI.AddCommand", 
								{ 
									cmdID = 11,
									menuParams = 
									{ 
										position = 0,
										menuName ="Commandpositive"
									}
								})
				:Do(function(_,data)
					--hmi side: sending UI.AddCommand response
					self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
				end)
					
				--hmi side: expect VR.AddCommand request
				EXPECT_HMICALL("VR.AddCommand", 
								{ 
									cmdID = 11,
									type = "Command",
									vrCommands = 
									{
										"VRCommandonepositive", 
										"VRCommandonepositivedouble"
									}
								})
				:Do(function(_,data)
					--hmi side: sending VR.AddCommand response
					self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
				end)
				

				--mobile side: expect AddCommand response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				:Do(function()
					--mobile side: expect OnHashChange notification
					EXPECT_NOTIFICATION("OnHashChange")
					:Do(function(_, data)
						self.currentHashID = data.payload.hashID
					end)
				end)
					
			end			


			function Test:Step1_AddSubMenu()
				--mobile side: sending AddSubMenu request
				local cid = self.mobileSession:SendRPC("AddSubMenu",
														{
															menuID = 1,
															position = 500,
															menuName = "SubMenupositive"
														})

				--hmi side: expect UI.AddSubMenu request
				EXPECT_HMICALL("UI.AddSubMenu", 
								{ 
									menuID = 1,
									menuParams = {
										position = 500,
										menuName = "SubMenupositive"
									}
								}
				)
				:Do(function(_,data)
					--hmi side: sending UI.AddSubMenu response
					self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
				end)
					
				--mobile side: expect AddSubMenu response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })
				:Do(function()
					--mobile side: expect OnHashChange notification
					EXPECT_NOTIFICATION("OnHashChange")
					:Do(function(_, data)
						self.currentHashID = data.payload.hashID
					end)
				end)
			end

			function Test:Step1_CreateInteractionChoiceSet()
				--mobile side: sending CreateInteractionChoiceSet request
				local cid = self.mobileSession:SendRPC("CreateInteractionChoiceSet",
														{
															interactionChoiceSetID = 1,
															choiceSet = 
															{ 
																{ 
																	choiceID = 1,
																	menuName = "Choice 1",
																	vrCommands = { "VrChoice 1"}
																}
															}
														})
				
					
				--hmi side: expect VR.AddCommand request
				EXPECT_HMICALL("VR.AddCommand", 
								{ 
									cmdID = 1,
									appID = self.applications[config.application1.registerAppInterfaceParams.appName],
									type = "Choice",
									vrCommands = {"VrChoice 1"}
								})
				:Do(function(_,data)
					--hmi side: sending VR.AddCommand response
					grammarIDValue = data.params.grammarID
					self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
				end)
				
				--mobile side: expect CreateInteractionChoiceSet response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS" })

				--mobile side: expect OnHashChange notification
				EXPECT_NOTIFICATION("OnHashChange")
				:Do(function(_, data)
					self.currentHashID = data.payload.hashID
				end)
			end
			
			
			function Test:Step1_SubscribleButton()
				--mobile side: sending SubscribeButton request
				local cid = self.mobileSession:SendRPC("SubscribeButton", {buttonName = "PRESET_0"})

				--expect Buttons.OnButtonSubscription
				EXPECT_HMINOTIFICATION("Buttons.OnButtonSubscription", 
					{
						appID = self.applications[config.application1.registerAppInterfaceParams.appName], 
						isSubscribed = true, 
						name = "PRESET_0"
					}
				)

				--mobile side: expect SubscribeButton response
				EXPECT_RESPONSE(cid, {success = true, resultCode = "SUCCESS"})
				
				EXPECT_NOTIFICATION("OnHashChange")
				:Do(function(_, data)
					self.currentHashID = data.payload.hashID
				end)
			end

			
			function Test:Step1_SubscribleVehicleData()

				--mobile side: sending SubscribeVehicleData request
				local cid = self.mobileSession:SendRPC("SubscribeVehicleData", {gps = true})
				
				--hmi side: expect SubscribeVehicleData request
				EXPECT_HMICALL("VehicleInfo.SubscribeVehicleData", {gps = true})
				:Do(function(_,data)
					--hmi side: sending VehicleInfo.SubscribeVehicleData response
					self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", 
						{gps = {resultCode = "SUCCESS", dataType = "VEHICLEDATA_GPS"}}
					)	
				end)

				
				--mobile side: expect SubscribeVehicleData response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				
				--mobile side: expect OnHashChange notification
				EXPECT_NOTIFICATION("OnHashChange")
				:Do(function(_, data)
					self.currentHashID = data.payload.hashID
				end)
			end
			
			
			function Test:Step1_SetGlobalProperites()
				--mobile side: sending SetGlobalProperties request
				local cid = self.mobileSession:SendRPC("SetGlobalProperties",
														{
															menuTitle = "Menu Title 1",
															timeoutPrompt = 
															{
																{
																	text = "Timeout prompt 1",
																	type = "TEXT"
																}
															},
															vrHelp = 
															{
																{
																	position = 1,
																	text = "VR help item 1"
																}
															},
															helpPrompt = 
															{
																{
																	text = "Help prompt 1",
																	type = "TEXT"
																}
															},
															vrHelpTitle = "VR help title 1",
														})


				--hmi side: expect TTS.SetGlobalProperties request
				EXPECT_HMICALL("TTS.SetGlobalProperties",
								{
									timeoutPrompt = 
									{
										{
											text = "Timeout prompt 1",
											type = "TEXT"
										}
									},
									helpPrompt = 
									{
										{
											text = "Help prompt 1",
											type = "TEXT"
										}
									}
								})
					:Do(function(_,data)
						--hmi side: sending UI.SetGlobalProperties response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)



				--hmi side: expect UI.SetGlobalProperties request
				EXPECT_HMICALL("UI.SetGlobalProperties",
								{
									menuTitle = "Menu Title 1",
									vrHelp = 
									{
										{
											position = 1,
											text = "VR help item 1"
										}
									},
									vrHelpTitle = "VR help title 1"
								})
					:Do(function(_,data)
						--hmi side: sending UI.SetGlobalProperties response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)


				--mobile side: expect SetGlobalProperties response
				EXPECT_RESPONSE(cid, { success = true, resultCode = "SUCCESS"})
				
				EXPECT_NOTIFICATION("OnHashChange")
					:Do(function(_, data)
						self.currentHashID = data.payload.hashID
					end)
			end


		end
						
		local function step2_Turn_off_transport_on_device_1()				
							
			function Test:Step2_TurnOffTransport()
				print("")
				self.mobileConnection:Close()

				commonTestCases:DelayedExp(3000)
			end

			function Test:Step2_Check_UpdateDeviceList_EmptyDeviceList_AfterConnectionIsClosed()

				self.hmiConnection:SendNotification("BasicCommunication.OnStartDeviceDiscovery")

				--Defect: APPLINK-25762: [Genivi][API]SDL sends UpdateDeviceList with disconnected device in the deviceList
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

		end

		local function step3_Start_the_same_App_on_device_2()

			--Connect the second device
			function Test:Step3_Connect_The_Second_Device()
				print("")
				local mobileHost = "1.0.0.1"
				local tcpConnection = tcp.Connection(mobileHost, config.mobilePort)
				local fileConnection = file_connection.FileConnection("mobile.out", tcpConnection)
				Connections[1].connection = mobile.MobileConnection(fileConnection)
				Connections[1].session = mobile_session.MobileSession(self, Connections[1].connection)
				event_dispatcher:AddConnection(Connections[1].connection)
				Connections[1].session:ExpectEvent(events.connectedEvent, "Connection started")
				Connections[1].connection:Connect()


				EXPECT_HMICALL("BasicCommunication.UpdateDeviceList",
					{
						deviceList = {					
							{
								id = deviceMAC_Of_TheSecondDevice,
								isSDLAllowed = true,
								name = mobileHost,
								transportType = "WIFI"
							}
						}
					}
				)
				:Do(function(_,data)
					self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
				end)

			end



			function Test:Step3_RegisterApplication_RESUME_FAILED_Due_To_Wrong_deviceID()
				
				commonTestCases:DelayedExp(5000)
				
				config.application1.registerAppInterfaceParams.hashID = self.currentHashID
				
				--self.mobileSession = mobile_session.MobileSession(self, self.mobileConnection)
				--self.mobileSession:StartService(7)
				Connections[1].session:StartService(7)
				:Do(function()

					local correlationId = Connections[1].session:SendRPC("RegisterAppInterface", config.application1.registerAppInterfaceParams)

					EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered")
					:Do(function(_,data)
						self.HMIAppID = data.params.application.appID
					end)

					Connections[1].session:ExpectResponse(correlationId, { success = true, resultCode = "RESUME_FAILED", info = "Hash from RAI does not match to saved resume data."})

					Connections[1].session:ExpectNotification("OnHMIStatus", {hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"})
				end)				
			end
		end

		local function step4_Exit_from_App_on_device_2()
		
			function Test:Step4_Exit_from_App_on_device_2()
				print("")
				--self.mobileConnection:Close()
				Connections[1].connection:Close()

				commonTestCases:DelayedExp(2000)
			end

		end

		local function step5_Turn_on_transport_on_device_1()

			function Test:Step5_ConnectDevice1_Again()
				print("")
				self:connectMobile()
				commonTestCases:DelayedExp(2000)
			end

			function Test:Step5_RegisterApplication_Again()
				
				
				local function VerifyResumptionPersistantData()
				
					---------------------------------------------
					--Verify resumption of command
					---------------------------------------------
					--hmi side: expect UI.AddCommand request
					EXPECT_HMICALL("UI.AddCommand", 
									{ 
										cmdID = 11,
										menuParams = 
										{ 
											
											position = 0,
											menuName ="Commandpositive",
											parentID = 0
										}
									})
					:Do(function(_,data)
						--hmi side: sending UI.AddCommand response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)
								

					--hmi side: expect VR.AddCommand request
					EXPECT_HMICALL("VR.AddCommand", 
									{ 
										cmdID = 11,
										type = "Command",
										vrCommands = 
										{
											"VRCommandonepositive", 
											"VRCommandonepositivedouble"
										}
									},
									{ 
										cmdID = 1,							
										type = "Choice",
										vrCommands = 
										{
											"VrChoice 1"
										}
									}
					)
					:Times(2)
					:Do(function(_,data)
						--hmi side: sending VR.AddCommand response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)
					
					
					
					---------------------------------------------
					--Verify resumption of SubMenu 
					---------------------------------------------
					--hmi side: expect UI.AddSubMenu request
					EXPECT_HMICALL("UI.AddSubMenu", 
									{ 
										menuID = 1,
										menuParams = {
											position = 500,
											menuName = "SubMenupositive"
										}
									}
					)
					:Do(function(_,data)
						--hmi side: sending UI.AddSubMenu response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)
					
					
					---------------------------------------------
					--Verify resumption of Buttons.OnButtonSubscription 
					---------------------------------------------			
					--APPLINK-17706: [Resumption] SDL sends redundant notification Buttons.OnButtonSubscription with subscribed "CUSTOM_BUTTON" during resumption
					EXPECT_HMINOTIFICATION("Buttons.OnButtonSubscription", 
						{
							appID = self.applications[config.application1.registerAppInterfaceParams.appName], 
							isSubscribed = true, 
							name = "PRESET_0"
						},
						{
							appID = self.applications[config.application1.registerAppInterfaceParams.appName], 
							isSubscribed = true, 
							name = "CUSTOM_BUTTON"
						}						
					)
					:Times(2)

					---------------------------------------------
					--Verify resumption of SubscribeVehicleData
					---------------------------------------------			
					EXPECT_HMICALL("VehicleInfo.SubscribeVehicleData",{gps = true})
					:Do(function(_,data)
						--hmi side: sending VehicleInfo.SubscribeVehicleData response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})	
					end)

					
					---------------------------------------------
					--Verify resumption of TTS.SetGlobalProperties 
					---------------------------------------------						
					--hmi side: expect TTS.SetGlobalProperties request
					EXPECT_HMICALL("TTS.SetGlobalProperties",
						{},
						{
							timeoutPrompt = 
							{
								{
									text = "Timeout prompt 1",
									type = "TEXT"
								}
							},
							helpPrompt = 
							{
								{
									text = "Help prompt 1",
									type = "TEXT"
								}
							}
						}
					)
					:Do(function(exp,data)
						--hmi side: sending UI.SetGlobalProperties response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)
					:Times(2)


					---------------------------------------------
					--Verify resumption of UI.SetGlobalProperties 
					---------------------------------------------	
					--hmi side: expect UI.SetGlobalProperties request
					EXPECT_HMICALL("UI.SetGlobalProperties",
						{
							menuTitle = "Menu Title 1",
							vrHelp = 
							{
								{
									position = 1,
									text = "VR help item 1"
								}
							},
							vrHelpTitle = "VR help title 1"
						}
					)
					:Do(function(_,data)
						--hmi side: sending UI.SetGlobalProperties response
						self.hmiConnection:SendResponse(data.id, data.method, "SUCCESS", {})
					end)

				end
				
				
				commonTestCases:DelayedExp(5000)
							
				config.application1.registerAppInterfaceParams.hashID = self.currentHashID 

				--Create session
				self.mobileSession = mobile_session.MobileSession(self, self.mobileConnection)

				--Start RPC service
				self.mobileSession:StartService(7)
				:Do(function()
					local correlationId = self.mobileSession:SendRPC("RegisterAppInterface", config.application1.registerAppInterfaceParams)

					--HMI: Wait for OnAppRegistered notification
					EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered", 
						{
							application = 
							{
								appName = config.application1.registerAppInterfaceParams.appName,
								policyAppID = config.application1.registerAppInterfaceParams.appID
							},
							resumeVrGrammars = true
						}
					)
					:Do(function(_,data)
						self.HMIAppID = data.params.application.appID
					end)
					
					--Mobile: Expect RegisterAppInterface respond
					self.mobileSession:ExpectResponse(correlationId, { success = true, resultCode = "SUCCESS", info = "Resume succeeded."})

					--HMI: Expect ActivateApp request
					EXPECT_HMICALL("BasicCommunication.ActivateApp")
					:Do(function(_,data)
						self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})
					end)


					self.mobileSession:ExpectNotification("OnHMIStatus", 
						{hmiLevel = "NONE", audioStreamingState = "NOT_AUDIBLE", systemContext = "MAIN"},
						{hmiLevel = "FULL", audioStreamingState = "AUDIBLE", systemContext = "MAIN"}
					)
					:Times(2)
					
					VerifyResumptionPersistantData()

				end)
				
				
			end
		end

		step1_Precondition()
		step2_Turn_off_transport_on_device_1()
		step3_Start_the_same_App_on_device_2()
		step4_Exit_from_App_on_device_2()
		step5_Turn_on_transport_on_device_1()

	end

	APPLINK_16333()

	
	
---------------------------------------------------------------------------------------------
-------------------------------------------Postcondition-------------------------------------
---------------------------------------------------------------------------------------------

	--Print new line to separate new test cases group
	commonFunctions:newTestCasesGroup("Postconditions")
	
	--Postcondition: restore sdl_preloaded_pt.json
	policyTable:Restore_preloaded_pt()			
	

	function Test:RemoveCreatedDummyConnections()
		os.execute("ifconfig lo:1 down ; ifconfig lo:2 down ; ifconfig lo:3 down ; ifconfig lo:4 down ; ifconfig lo:5 down ; ifconfig lo:6 down ; ifconfig lo:7 down ; ifconfig lo:8 down ; ifconfig lo:9 down ; ifconfig lo:10 down ; ifconfig lo:11 down ; ifconfig lo:12 down ; ifconfig lo:13 down ; ifconfig lo:14 down ; ifconfig lo:15 down ; ifconfig lo:16 down ; ifconfig lo:17 down ; ifconfig lo:18 down ; ifconfig lo:19 down ; ifconfig lo:20 down ; ifconfig lo:21 down ; ifconfig lo:22 down ; ifconfig lo:23 down ; ifconfig lo:24 down ; ifconfig lo:25 down ; ifconfig lo:26 down ; ifconfig lo:27 down ; ifconfig lo:28 down ; ifconfig lo:29 down ; ifconfig lo:30 down ; ifconfig lo:31 down ; ifconfig lo:32 down ; ifconfig lo:33 down ; ifconfig lo:34 down ; ifconfig lo:35 down ; ifconfig lo:36 down ; ifconfig lo:37 down ; ifconfig lo:38 down ; ifconfig lo:39 down ; ifconfig lo:40 down ; ifconfig lo:41 down ; ifconfig lo:42 down ; ifconfig lo:43 down ; ifconfig lo:44 down ; ifconfig lo:45 down ; ifconfig lo:46 down ; ifconfig lo:47 down ; ifconfig lo:48 down ; ifconfig lo:49 down ; ifconfig lo:50 down ; ifconfig lo:51 down ; ifconfig lo:52 down ; ifconfig lo:53 down ; ifconfig lo:54 down ; ifconfig lo:55 down ; ifconfig lo:56 down ; ifconfig lo:57 down ; ifconfig lo:58 down ; ifconfig lo:59 down ; ifconfig lo:60 down ; ifconfig lo:61 down ; ifconfig lo:62 down ; ifconfig lo:63 down ; ifconfig lo:64 down ; ifconfig lo:65 down ; ifconfig lo:66 down ; ifconfig lo:67 down ; ifconfig lo:68 down ; ifconfig lo:69 down ; ifconfig lo:70 down ; ifconfig lo:71 down ; ifconfig lo:72 down ; ifconfig lo:73 down ; ifconfig lo:74 down ; ifconfig lo:75 down ; ifconfig lo:76 down ; ifconfig lo:77 down ; ifconfig lo:78 down ; ifconfig lo:79 down ; ifconfig lo:80 down ; ifconfig lo:81 down ; ifconfig lo:82 down ; ifconfig lo:83 down ; ifconfig lo:84 down ; ifconfig lo:85 down ; ifconfig lo:86 down ; ifconfig lo:87 down ; ifconfig lo:88 down ; ifconfig lo:89 down ; ifconfig lo:90 down ; ifconfig lo:91 down ; ifconfig lo:92 down ; ifconfig lo:93 down ; ifconfig lo:94 down ; ifconfig lo:95 down ; ifconfig lo:96 down ; ifconfig lo:97 down ; ifconfig lo:98 down ; ifconfig lo:99 down ; ifconfig lo:100 down ; ifconfig lo:101 down")

	end
		
return Test
