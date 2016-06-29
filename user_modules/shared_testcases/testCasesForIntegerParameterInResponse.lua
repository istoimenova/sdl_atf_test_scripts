--This script contains all test cases to verify Integer parameter
--How to use:
	--1. local integerParameterInResponse = require('user_modules/shared_testcases/testCasesForIntegerParameterInResponse')
	--2. integerParameterInResponse:verify_Integer_Parameter(Response, Parameter, Boundary, Mandatory)
---------------------------------------------------------------------------------------------


local testCasesForIntegerParameterInResponse = {}
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
function testCasesForIntegerParameterInResponse:verify_Integer_Parameter(Response, Parameter, Boundary, Mandatory)
		
		--Print new line to separate new test cases group
		commonFunctions:newTestCasesGroup(Parameter)	
		
		--1. IsMissed
		if Mandatory == nil then
			--no check mandatory: in case this parameter is element in array. We does not verify an element is missed. It is checked in test case checks bound of array.
		else
			
			local resultCode
			if Mandatory == true then
				resultCode = "GENERIC_ERROR"
			else
				resultCode = "SUCCESS"
			end		
			commonFunctions:TestCaseForResponse(self, Response, Parameter, "IsMissed", nil, resultCode)	
		end
		
		
		--2. IsWrongDataType
		commonFunctions:TestCaseForResponse(self, Response, Parameter, "IsWrongDataType", "123", "GENERIC_ERROR")
		
		--3. IsLowerBound
		commonFunctions:TestCaseForResponse(self, Response, Parameter, "IsLowerBound", Boundary[1], "SUCCESS")
		
		--4. IsUpperBound
		commonFunctions:TestCaseForResponse(self, Response, Parameter, "IsUpperBound", Boundary[2], "SUCCESS")
		
		
		--5. IsOutLowerBound
		commonFunctions:TestCaseForResponse(self, Response, Parameter, "IsOutLowerBound", Boundary[1] -1, "GENERIC_ERROR")
		
		--6. IsOutUpperBound
		commonFunctions:TestCaseForResponse(self, Response, Parameter, "IsOutUpperBound", Boundary[2] + 1, "GENERIC_ERROR")
		
end


return testCasesForIntegerParameterInResponse
