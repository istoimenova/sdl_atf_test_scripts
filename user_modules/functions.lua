local mobile_session = require('mobile_session')

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

function BringAppToLimitedLevel(self)
	if 
	    self.hmiLevel ~= "FULL" and
	    self.hmiLevel ~= "LIMITED" then
      		ActivationApp(self)

	      	EXPECT_NOTIFICATION("OnHMIStatus",
	        		{ systemContext = "MAIN", hmiLevel = "FULL", audioStreamingState = "AUDIBLE"},
	        		{ systemContext = "MAIN", hmiLevel = "LIMITED", audioStreamingState = "AUDIBLE"})
	          	:Do(function(_,data)
	            	self.hmiLevel = data.payload.hmiLevel
	          	end)
	          	:Times(2)
    else 
        EXPECT_NOTIFICATION("OnHMIStatus",
        { systemContext = "MAIN", hmiLevel = "LIMITED", audioStreamingState = "AUDIBLE"})
          :Do(function(_,data)
            self.hmiLevel = data.payload.hmiLevel
          end)
    end

 	self.hmiConnection:SendNotification("BasicCommunication.OnAppDeactivated", {appID = self.applications["Test Application"], reason = "GENERAL"})
end

function BringAppToBackgroundLevel(self)
	if  
	  config.application1.registerAppInterfaceParams.isMediaApplication == true or
	  Test.appHMITypes["NAVIGATION"] == true or
	  Test.appHMITypes["COMMUNICATION"] == true then 

		  	if 
			    self.hmiLevel == "NONE" then
		      		ActivationApp(self)
		      		EXPECT_NOTIFICATION("OnHMIStatus", 
		      			AppValuesOnHMIStatusFULL,
		      			{hmiLevel = "BACKGROUND", systemContext = "MAIN", audioStreamingState = "NOT_AUDIBLE"})
			      		:Do(function()
			    			local cidUnregister = self.mobileSessionForBackground:SendRPC("UnregisterAppInterface",{})

							self.mobileSessionForBackground:ExpectResponse(cidUnregister, { success = true, resultCode = "SUCCESS"})
								:Timeout(2000)
			    		end)
		    else 
		    	EXPECT_NOTIFICATION("OnHMIStatus", {hmiLevel = "BACKGROUND", systemContext = "MAIN", audioStreamingState = "NOT_AUDIBLE"})
		    		:Do(function()
		    			local cidUnregister = self.mobileSessionForBackground:SendRPC("UnregisterAppInterface",{})

						self.mobileSessionForBackground:ExpectResponse(cidUnregister, { success = true, resultCode = "SUCCESS"})
							:Timeout(2000)
		    		end)
		    end

		    self.mobileSessionForBackground = mobile_session.MobileSession(
	        self,
	        self.mobileConnection,
	        mobileSessionForBackground)


	        self.mobileSessionForBackground:Start()
	        	:Do(function()
	        		EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered")
		     			:Do(function(_,data)
		     				HMIAppID = data.params.application.appID
		     				self.applications[mobileSessionForBackground.appName] = data.params.application.appID
		     			end)

		     		self.mobileSessionForBackground:ExpectNotification("OnHMIStatus", {hmiLevel = "NONE", systemContext = "MAIN", audioStreamingState = "NOT_AUDIBLE"},
		     			{hmiLevel = "FULL", systemContext = "MAIN", audioStreamingState = "AUDIBLE"})
		     			:Do(function()
		     				-- hmi side: sending SDL.ActivateApp request
						    local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications[mobileSessionForBackground.appName]})
						 
						 	-- hmi side: expect SDL.ActivateApp response
						    EXPECT_HMIRESPONSE(RequestId)

		     			end)
		     			:Times(2)
	        	end)
	elseif
		config.application1.registerAppInterfaceParams.isMediaApplication == false then

			  	if 
				    self.hmiLevel == "NONE" then
			      		ActivationApp(self)
			      		EXPECT_NOTIFICATION("OnHMIStatus", 
			      			AppValuesOnHMIStatusFULL,
			      			{hmiLevel = "BACKGROUND", systemContext = "MAIN", audioStreamingState = "NOT_AUDIBLE"})
			    else 
			    	EXPECT_NOTIFICATION("OnHMIStatus", {hmiLevel = "BACKGROUND", systemContext = "MAIN", audioStreamingState = "NOT_AUDIBLE"})
			    end

			    -- hmi side: sending BasicCommunication.OnAppDeactivated request
				local cid = self.hmiConnection:SendNotification("BasicCommunication.OnAppDeactivated",
					{
						appID = self.applications[config.application1.registerAppInterfaceParams.appName],
						reason = "GENERAL"
					})
	end
end

function CreateSession( self)
	self.mobileSession = mobile_session.MobileSession(
        self,
        self.mobileConnection)
end

function IGNITION_OFF(self, appNumber)
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

function ActivationApp(self)

  if 
    notificationState.VRSession == true then
      self.hmiConnection:SendNotification("VR.Stopped", {})
  elseif 
    notificationState.EmergencyEvent == true then
      self.hmiConnection:SendNotification("BasicCommunication.OnEmergencyEvent", {enabled = false})
  elseif
    notificationState.PhoneCall == true then
      self.hmiConnection:SendNotification("BasicCommunication.OnPhoneCall", {isActive = false})
  end

    -- hmi side: sending SDL.ActivateApp request
      local RequestId = self.hmiConnection:SendRequest("SDL.ActivateApp", { appID = self.applications["Test Application"]})

    -- hmi side: expect SDL.ActivateApp response
    EXPECT_HMIRESPONSE(RequestId)
      	:Do(function(_,data)
        -- In case when app is not allowed, it is needed to allow app
          	if
              data.result.isSDLAllowed ~= true then

                -- hmi side: sending SDL.GetUserFriendlyMessage request
                  local RequestId = self.hmiConnection:SendRequest("SDL.GetUserFriendlyMessage", 
                          {language = "EN-US", messageCodes = {"DataConsent"}})

                -- hmi side: expect SDL.GetUserFriendlyMessage response
                -- TODO: comment until resolving APPLINK-16094
                -- EXPECT_HMIRESPONSE(RequestId,{result = {code = 0, method = "SDL.GetUserFriendlyMessage"}})
                EXPECT_HMIRESPONSE(RequestId)
                    :Do(function(_,data)

	                    -- hmi side: send request SDL.OnAllowSDLFunctionality
	                    self.hmiConnection:SendNotification("SDL.OnAllowSDLFunctionality", 
                      		{allowed = true, source = "GUI", device = {id = config.deviceMAC, name = "127.0.0.1"}})

	                    -- hmi side: expect BasicCommunication.ActivateApp request
	                      EXPECT_HMICALL("BasicCommunication.ActivateApp")
	                        :Do(function(_,data)

	                          -- hmi side: sending BasicCommunication.ActivateApp response
	                          self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})

	                      end)
	                      :Times(2)
                      end)

        	end
        end)

end

function SUSPEND(self, targetLevel)

   if 
      targetLevel == "FULL" and
      self.hmiLevel ~= "FULL" then
            ActivationApp(self)
            EXPECT_NOTIFICATION("OnHMIStatus", {hmiLevel = "FULL", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
              :Do(function(_,data)
                self.hmiConnection:SendNotification("BasicCommunication.OnExitAllApplications",
                  {
                    reason = "SUSPEND"
                  })

                -- hmi side: expect OnSDLPersistenceComplete notification
                EXPECT_HMINOTIFICATION("BasicCommunication.OnSDLPersistenceComplete")

              end)
    elseif 
      targetLevel == "LIMITED" and
      self.hmiLevel ~= "LIMITED" then
        if self.hmiLevel ~= "FULL" then
          ActivationApp(self)
          EXPECT_NOTIFICATION("OnHMIStatus",
            {hmiLevel = "FULL", audioStreamingState = "AUDIBLE", systemContext = "MAIN"},
            {hmiLevel = "LIMITED", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
            :Do(function(exp,data)
              if exp.occurences == 2 then
                self.hmiConnection:SendNotification("BasicCommunication.OnExitAllApplications",
                  {
                    reason = "SUSPEND"
                  })

                -- hmi side: expect OnSDLPersistenceComplete notification
                EXPECT_HMINOTIFICATION("BasicCommunication.OnSDLPersistenceComplete")
              end
            end)

            -- hmi side: sending BasicCommunication.OnAppDeactivated notification
            self.hmiConnection:SendNotification("BasicCommunication.OnAppDeactivated", {appID = self.applications["Test Application"], reason = "GENERAL"})
        else 
            -- hmi side: sending BasicCommunication.OnAppDeactivated notification
            self.hmiConnection:SendNotification("BasicCommunication.OnAppDeactivated", {appID = self.applications["Test Application"], reason = "GENERAL"})

            EXPECT_NOTIFICATION("OnHMIStatus",
            {hmiLevel = "LIMITED", audioStreamingState = "AUDIBLE", systemContext = "MAIN"})
            :Do(function(exp,data)
                self.hmiConnection:SendNotification("BasicCommunication.OnExitAllApplications",
                  {
                    reason = "SUSPEND"
                  })

                -- hmi side: expect OnSDLPersistenceComplete notification
                EXPECT_HMINOTIFICATION("BasicCommunication.OnSDLPersistenceComplete")
            end)
        end
    elseif 
      (targetLevel == "LIMITED" and
      self.hmiLevel == "LIMITED") or
      (targetLevel == "FULL" and
      self.hmiLevel == "FULL") or
      targetLevel == nil then
        self.hmiConnection:SendNotification("BasicCommunication.OnExitAllApplications",
          {
            reason = "SUSPEND"
          })

        -- hmi side: expect OnSDLPersistenceComplete notification
        EXPECT_HMINOTIFICATION("BasicCommunication.OnSDLPersistenceComplete")
    end

end

function RegisterApp_HMILevelResumption(self, HMILevel, reason)

	if HMILevel == "FULL" then
		local AppValuesOnHMIStatus = AppValuesOnHMIStatusFULL
	elseif HMILevel == "LIMITED" then
		local AppValuesOnHMIStatus = AppValuesOnHMIStatusLIMITED
	end

	local correlationId = self.mobileSession:SendRPC("RegisterAppInterface", config.application1.registerAppInterfaceParams)
	-- got time after RAI request
	local time =  timestamp()

	if reason == "IGN_OFF" then
		local RAIAfterOnReady = time - self.timeOnReady
		userPrint( 33, "Time of sending RAI request after OnReady notification " ..tostring(RAIAfterOnReady))
	end

	EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered")
		:Do(function(_,data)
			HMIAppID = data.params.application.appID
			self.applications[config.application1.registerAppInterfaceParams.appName] = data.params.application.appID
		end)

	self.mobileSession:ExpectResponse(correlationId, { success = true })

	if HMILevel == "FULL" then
		EXPECT_HMICALL("BasicCommunication.ActivateApp")
			:Do(function(_,data)
		      	self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})
			end)
	elseif HMILevel == "LIMITED" then
		EXPECT_HMINOTIFICATION("BasicCommunication.OnResumeAudioSource", {appID = self.applications[config.application1.registerAppInterfaceParams.appName]})
	end

	EXPECT_NOTIFICATION("OnHMIStatus", 
			AppValuesOnHMIStatusDEFAULT,
			AppValuesOnHMIStatus)
		:ValidIf(function(exp,data)
			if	exp.occurences == 2 then 
				local time2 =  timestamp()
				local timeToresumption = time2 - time
		  		if timeToresumption >= 3000 and
		  		 	timeToresumption < 3500 then 
		    		userPrint(33, "Time to HMI level resumption is " .. tostring(timeToresumption) ..", expected ~3000 " )
		  			return true
		  		else 
		  			userPrint(31, "Time to HMI level resumption is " .. tostring(timeToresumption) ..", expected ~3000 " )
		  			return false
		  		end

			elseif exp.occurences == 1 then
				return true
			end
		end)
		:Do(function(_,data)
			self.hmiLevel = data.payload.hmiLevel
		end)
		:Times(2)

end

function RegisterApp_WithoutHMILevelResumption(self, reason)

	local correlationId = self.mobileSession:SendRPC("RegisterAppInterface", config.application1.registerAppInterfaceParams)
	-- got time after RAI request
	local time =  timestamp()

	if reason == "IGN_OFF" then
		local RAIAfterOnReady = time - self.timeOnReady
		userPrint( 33, "Time of sending RAI request after OnReady notification " ..tostring(RAIAfterOnReady))
	end

	EXPECT_HMINOTIFICATION("BasicCommunication.OnAppRegistered")
		:Do(function(_,data)
			HMIAppID = data.params.application.appID
			self.applications[config.application1.registerAppInterfaceParams.appName] = data.params.application.appID
		end)

	self.mobileSession:ExpectResponse(correlationId, { success = true })


	EXPECT_HMICALL("BasicCommunication.ActivateApp")
		:Do(function(_,data)
		    self.hmiConnection:SendResponse(data.id,"BasicCommunication.ActivateApp", "SUCCESS", {})
		end)
		:Times(0)

	EXPECT_HMINOTIFICATION("BasicCommunication.OnResumeAudioSource", {appID = self.applications[config.application1.registerAppInterfaceParams.appName]})
		:Times(0)

	EXPECT_NOTIFICATION("OnHMIStatus", 
			AppValuesOnHMIStatusDEFAULT)
		:Do(function(_,data)
			self.hmiLevel = data.payload.hmiLevel
		end)

	DelayedExp(5000)

end