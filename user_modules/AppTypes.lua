local config = require('config')

local CurrentAppType = config.application1.registerAppInterfaceParams.appHMIType
Test.appHMITypes = {DEFAULT = false, COMMUNICATION = false, MEDIA = false, MESSAGING = false, NAVIGATION = false, INFORMATION = false, SOCIAL = false, BACKGROUND_PROCESS = false, TESTING = false, SYSTEM = false}

for i=1,#CurrentAppType do
	Test.appHMITypes[CurrentAppType[i]] = true
end

Test.isMediaApplication = config.application1.registerAppInterfaceParams.isMediaApplication
NewTestSuiteNumber = 0 -- use as subfix of test case "NewTestSuite" to make different test case name.

--Verify config.pathToSDL
findresult = string.find (config.pathToSDL, '.$')
if string.sub(config.pathToSDL,findresult) ~= "/" then
	config.pathToSDL = config.pathToSDL..tostring("/")
end 