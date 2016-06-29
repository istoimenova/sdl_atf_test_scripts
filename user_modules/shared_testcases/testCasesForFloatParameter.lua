--This script contains all test cases to verify Float parameter
--How to use:
	--1. local integerParameter = require('user_modules/shared_testcases/testCasesForFloatParameter')
	--2. integerParameter:verify_Float_Parameter(Request, Parameter, Boundary, Mandatory)
---------------------------------------------------------------------------------------------


local testCasesForFloatParameter = {}
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
	

--Contains all test cases
function testCasesForFloatParameter:verify_Float_Parameter(Request, Parameter, Boundary, Mandatory)
		
		--Print new line to separate new test cases group
		commonFunctions:newTestCasesGroup()	
		
		
		--1. IsMissed
		local resultCode
		if Mandatory == true then
			resultCode = "INVALID_DATA"
		else
			resultCode = "SUCCESS"
		end
		
		
		commonFunctions:TestCase(self, Request, Parameter, "IsMissed", nil, resultCode)	
		
		
		--2. IsWrongDataType
		commonFunctions:TestCase(self, Request, Parameter, "IsWrongDataType", "123", "INVALID_DATA")
		
		--3. IsLowerBound
		commonFunctions:TestCase(self, Request, Parameter, "IsLowerBound", Boundary[1] + 0.1, "SUCCESS")
		
		--4. IsUpperBound
		commonFunctions:TestCase(self, Request, Parameter, "IsUpperBound", Boundary[2] - 0.1, "SUCCESS")
		
		
		--5. IsOutLowerBound
		commonFunctions:TestCase(self, Request, Parameter, "IsOutLowerBound", Boundary[1] - 0.1, "INVALID_DATA")
		
		--6. IsOutUpperBound
		commonFunctions:TestCase(self, Request, Parameter, "IsOutUpperBound", Boundary[2] + 0.1, "INVALID_DATA")
		
end


return testCasesForFloatParameter
