Test = require('user_modules/connecttestRAIvrUnavailable')
require('cardinalities')
local events = require('events')
local mobile_session = require('mobile_session')



local hmi_connection = require('hmi_connection')
local websocket      = require('websocket_connection')
local module         = require('testbase')
local mobile  = require('mobile_connection')
local tcp = require('tcp_connection')
local file_connection  = require('file_connection')

	--Requirement id in JAMA/or Jira ID: SDLAQ-CRS-1328

	--Verification criteria: When vrSynonyms are sent and VR isn't avaliable at the moment on current HMI, UNSUPPORTED_RESOURCE is returned as a result of request. Info parameter provides additional information about the case. General request result success=true in case of no errors from other components.  

	--Begin Test case ResultCodeCheck
	--Description: Check UNSUPPORTED_RESOURCE resultCode in case VR isn't avaliable at the moment on current HMI

		function module:ConnectMobileStartSession()
			local tcpConnection = tcp.Connection(config.mobileHost, config.mobilePort)
			local fileConnection = file_connection.FileConnection("mobile.out", tcpConnection)
			self.mobileConnection = mobile.MobileConnection(fileConnection)
			self.mobileSession= mobile_session.MobileSession(
			self,
			self.mobileConnection)
			event_dispatcher:AddConnection(self.mobileConnection)
			self.mobileSession:ExpectEvent(events.connectedEvent, "Connection started")
			self.mobileConnection:Connect()
			self.mobileSession:StartService(7)
		end

		function Test:RegisterAppInterface_vrUnavailableUnsupportedResource() 

			--mobile side: RegisterAppInterface request 
			local CorIdRAI = self.mobileSession:SendRPC("RegisterAppInterface",
														{
														  	 
															syncMsgVersion = 
															{ 
																majorVersion = 2,
																minorVersion = 2,
															}, 
															appName ="SyncProxyTester",
															ttsName = 
															{ 
																 
																{ 
																	text ="SyncProxyTester",
																	type ="TEXT",
																}, 
															}, 
															ngnMediaScreenAppName ="SPT",
															vrSynonyms = 
															{ 
																"VRSyncProxyTester",
															}, 
															isMediaApplication = true,
															languageDesired ="EN-US",
															hmiDisplayLanguageDesired ="EN-US",
															appHMIType = 
															{ 
																"DEFAULT",
															}, 
															appID ="123456",
															deviceInfo = 
															{
																hardware = "hardware",
																firmwareRev = "firmwareRev",
																os = "os",
																osVersion = "osVersion",
																carrier = "carrier",
																maxNumberRFCOMMPorts = 5
															}
														
														})
			

		 	--hmi side: expected  BasicCommunication.OnAppRegistered
				EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered")

			--mobile side: RegisterAppInterface response 
			EXPECT_RESPONSE(CorIdRAI, { success = true, resultCode = "UNSUPPORTED_RESOURCE"})
				:Timeout(2000)

		end

	--End Test case ResultCodeCheck