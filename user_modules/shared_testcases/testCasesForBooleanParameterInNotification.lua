--This script contains all test cases to verify Boolean parameter
--How to use:
	--1. local booleanParameterInNotification = require('user_modules/shared_testcases/testCasesForBooleanParameterInNotification')
	--2. booleanParameterInNotification:verify_Boolean_Parameter(Notification, Parameter, IsMandatory)
---------------------------------------------------------------------------------------------

local testCasesForBooleanParameterInNotification = {}
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')

---------------------------------------------------------------------------------------------
--Test cases to verify Boolean parameter
---------------------------------------------------------------------------------------------
--List of test cases:
	--1. IsMissed
	--2. IsWrongDataType
	--3. IsExistentValues

function testCasesForBooleanParameterInNotification:verify_Boolean_Parameter(Notification, Parameter, IsMandatory)

	--Print new line to separate new test cases group
	commonFunctions:newTestCasesGroup(Parameter)	
	
	--1. IsMissed
	if IsMandatory == nil then
		--no check mandatory: in case this parameter is element in array. We does not verify an element is missed. It is checked in test case checks bound of array.
	else			
		if IsMandatory == true then
			--HMI sends notification and check that SDL ignores the notification 
			commonFunctions:TestCaseForNotification(self, Notification, Parameter, "IsMissed", nil, false)	
		else
			--HMI sends notification and check that SDL ignores the notification
			commonFunctions:TestCaseForNotification(self, Notification, Parameter, "IsMissed", nil, true)	
		end		
	end
	
	--2. IsWrongDataType
	commonFunctions:TestCaseForNotification(self, Notification, Parameter, "IsWrongDataType", 123, false)
	
	--3. IsExistentValues
	commonFunctions:TestCaseForNotification(self, Notification, Parameter, "true", true, true)
	commonFunctions:TestCaseForNotification(self, Notification, Parameter, "false", false, true)
	
end	



return testCasesForBooleanParameterInNotification
