local SGP_with_vr_help_start = {
	vrHelp = 
	{
		{
			position = 1,
			-- image = 
			-- {
			-- 	value = "action.png",
			-- 	imageType = "DYNAMIC"
			-- },
			text = "Custom VR Help"
		}
	},
	vrHelpTitle = "Custom VR help title",
}

local SGP_without_vr_help_start = {
	menuTitle = "Menu Title",
	-- menuIcon = 
	-- {
	-- 	value = "action.png",
	-- 	imageType = "DYNAMIC"
	-- },
}

local SGP_with_vr_help_next = {
	vrHelp = 
	{
		{
			position = 1,
			-- image = 
			-- {
			-- 	value = "action.png",
			-- 	imageType = "DYNAMIC"
			-- },
			text = "New Vr Help"
		}
	},
	vrHelpTitle = "New VR help title",
}

local SGP_without_vr_help_next = {
	menuTitle = "New menu title",
	-- menuIcon = 
	-- {
	-- 	value = "action.png",
	-- 	imageType = "DYNAMIC"
	-- },
}

local function userPrint( color, message)
	print ("\27[" .. tostring(color) .. "m " .. tostring(message) .. " \27[0m")
end

local function info(message)
	-- body
	userPrint(33, message)
end

local function preconditionHead()
	-- body
	userPrint(35, "================= Precondition ==================")
end

local function preconditionMessage(message)
	-- body
	userPrint(35, message)
end

local function testHead()
	-- body
	userPrint(34, "=================== Test Case ===================")
end

local function testMessage(message)
	-- body
	userPrint(34, message)
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

return {
	userPrint = userPrint,
	info = info,
	preconditionHead = preconditionHead,
	preconditionMessage = preconditionMessage,
	testHead = testHead,
	testMessage = testMessage,
	DelayedExp = DelayedExp,
	SGP_with_vr_help_start = SGP_with_vr_help_start,
	SGP_without_vr_help_start = SGP_without_vr_help_start,
	SGP_with_vr_help_next = SGP_with_vr_help_next,
	SGP_without_vr_help_next = SGP_without_vr_help_next
}