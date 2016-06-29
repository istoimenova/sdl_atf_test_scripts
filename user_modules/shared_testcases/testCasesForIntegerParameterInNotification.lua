--This script contains all test cases to verify Integer parameter
--How to use:
	--1. local integerParameterInNotification = require('user_modules/shared_testcases/testCasesForIntegerParameterInNotification')
	--2. integerParameterInNotification:verify_Integer_Parameter(Notification, Parameter, Boundary, Mandatory)
---------------------------------------------------------------------------------------------


local testCasesForIntegerParameterInNotification = {}
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')




---------------------------------------------------------------------------------------------
--Test cases to verify Integer parameter
---------------------------------------------------------------------------------------------
--List of test cases for Integer type parameter:
	--1. IsMissed
	--2. IsWrongType
	--3. IsLowerBound
	--4. IsUpperBound
	--5. IsOutLowerBound
	--6. IsOutUpperBound

	

--Contains all test cases
function testCasesForIntegerParameterInNotification:verify_Integer_Parameter(Notification, Parameter, Boundary, Mandatory, FloatValue)
		
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
		commonFunctions:TestCaseForNotification(self, Notification, Parameter, "IsOutLowerBound", Boundary[1] -1, false)
		
		--6. IsOutUpperBound
		commonFunctions:TestCaseForNotification(self, Notification, Parameter, "IsOutUpperBound", Boundary[2] + 1, false)
		

end


return testCasesForIntegerParameterInNotification
