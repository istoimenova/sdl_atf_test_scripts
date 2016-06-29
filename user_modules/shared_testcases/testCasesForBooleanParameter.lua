--This script contains all test cases to verify boolean parameter
--How to use:
	--1. local booleanParameter = require('user_modules/shared_testcases/testCasesForBooleanParameter')
	--2. booleanParameter:verify_bolean_Parameter(Request, Parameter, ExistentValues, Mandatory)
---------------------------------------------------------------------------------------------

local testCasesForBooleanParameter = {}
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')



---------------------------------------------------------------------------------------------
--Test cases to verify boolean parameter
---------------------------------------------------------------------------------------------
--List of test cases:
	--1. IsMissed
	--2. IsExistentValues
	--3. IsWrongType
	

--Contains all test cases
function testCasesForBooleanParameter:verify_boolean_Parameter(Request, Parameter, ExistentValues, Mandatory)
		
		local Request = commonFunctions:cloneTable(Request)	
		
		--Print new line to separate new test cases group
		commonFunctions:newTestCasesGroup(Parameter)	
		
		--1. IsMissed
		local resultCode
		if Mandatory == true then
			resultCode = "INVALID_DATA"
		else
			resultCode = "SUCCESS"
		end
		
		
		commonFunctions:TestCase(self, Request, Parameter, "IsMissed", nil, resultCode)	
		
		--2. IsExistentValues

		for i = 1, #ExistentValues do
			commonFunctions:TestCase(self, Request, Parameter, "IsExistentValues_"..tostring(ExistentValues[i]), ExistentValues[i], "SUCCESS")
		end
		
		--3. IsWrongDataType
		commonFunctions:TestCase(self, Request, Parameter, "IsWrongDataType", "true", "INVALID_DATA")
		
end
---------------------------------------------------------------------------------------------

return testCasesForBooleanParameter
