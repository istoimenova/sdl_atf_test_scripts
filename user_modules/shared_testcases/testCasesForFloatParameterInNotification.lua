--This script contains all test cases to verify Float parameter
--How to use:
	--1. local floatParameterInNotification = require('user_modules/shared_testcases/testCasesForFloatParameterInNotification')
	--2. floatParameterInNotification:verify_Float_Parameter(Notification, Parameter, Boundary, Mandatory)
---------------------------------------------------------------------------------------------


local testCasesForFloatParameterInNotification = {}
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')




---------------------------------------------------------------------------------------------
--Test cases to verify Float parameter
---------------------------------------------------------------------------------------------
--List of test cases for Float type parameter:
	--1. IsMissed
	--2. IsWrongType
	--3. IsLowerBound
	--4. IsUpperBound
	--5. IsOutLowerBound
	--6. IsOutUpperBound
	--7. IsInteger
	

--Contains all test cases
function testCasesForFloatParameterInNotification:verify_Float_Parameter(Notification, Parameter, Boundary, Mandatory, IntegerValue)
		
		--Print new line to separate new test cases group
		commonFunctions:newTestCasesGroup(Parameter)	
		
		--1. IsMissed
		local IsValidValue = false
		if Mandatory == nil then
			--no check mandatory: in case this parameter is element in array. We does not verify an element is missed. It is checked in test case checks bound of array.
		else
			
			local resultCode
			if Mandatory == true then
				--resultCode = "GENERIC_ERROR"
				IsValidValue = false
			else
				--resultCode = "SUCCESS"
				IsValidValue = true
			end		
			commonFunctions:TestCaseForNotification(self, Notification, Parameter, "IsMissed", nil, IsValidValue)	
		end
		
		
		--2. IsWrongDataType
		commonFunctions:TestCaseForNotification(self, Notification, Parameter, "IsWrongDataType", "123", false)
		
		--3. IsLowerBound
		commonFunctions:TestCaseForNotification(self, Notification, Parameter, "IsLowerBound", Boundary[1], true)
		
		--4. IsUpperBound
		commonFunctions:TestCaseForNotification(self, Notification, Parameter, "IsUpperBound", Boundary[2], true)
		
		
		--5. IsOutLowerBound
		commonFunctions:TestCaseForNotification(self, Notification, Parameter, "IsOutLowerBound", Boundary[1] -0.0000001, false)
		
		--6. IsOutUpperBound
		commonFunctions:TestCaseForNotification(self, Notification, Parameter, "IsOutUpperBound", Boundary[2] + 0.0000001, false)
		
		--7. IsInteger
		if IntegerValue == nil then IntegerValue= math.ceil(Boundary[1]) end
		commonFunctions:TestCaseForNotification(self, Notification, Parameter, "IsInteger", IntegerValue, true)
		
		
end


return testCasesForFloatParameterInNotification
