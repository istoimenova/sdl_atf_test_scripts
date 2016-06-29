--This script contains all test cases to array Integer Parameter
--How to use:
	--1. local arrayIntegerParameterInResponse = require('user_modules/shared_testcases/testCasesForArrayIntegerParameterInResponse')
	--2. arrayIntegerParameterInResponse:verify_Array_Integer_Parameter(Response, Parameter, Boundary,  ElementBoundary, Mandatory)
---------------------------------------------------------------------------------------------

local testCasesForArrayIntegerParameterInResponse = {}
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
local integerParameterInResponse = require('user_modules/shared_testcases/testCasesForIntegerParameterInResponse')


---------------------------------------------------------------------------------------------
--Test cases to verify Array Integer Parameter
---------------------------------------------------------------------------------------------
--List of test cases for Array Integer type Parameter:
	--1. IsMissed
	--2. IsLowerBound
	--3. IsUpperBound
	--4. OutLowerBound/IsEmpty
	--5. OutUpperBound
	--6. IsWrongType
	--7. IsInvalidCharacters
---------------------------------------------------------------------------------------------



--Contains all test cases
function testCasesForArrayIntegerParameterInResponse:verify_Array_Integer_Parameter_Only(Response, Parameter, Boundary,  ElementBoundary, Mandatory)


		--Print new line to separate new test cases group
		commonFunctions:newTestCasesGroup(Parameter)	
		
		--1. IsMissed
		local resultCode
		if Mandatory == true then
			resultCode = "GENERIC_ERROR"
		else
			resultCode = "SUCCESS"
		end
		
		
		commonFunctions:TestCaseForResponse(self, Response, Parameter, "IsMissed", nil, resultCode)		
		
		--2. IsLowerBound
		local verification = "IsLowerBound"
		if Boundary[1] > 0 then
			verification = "IsLowerBound_IsEmpty"
			local value = commonFunctions:createArrayInteger(Boundary[1], ElementBoundary[1])
			commonFunctions:TestCaseForResponse(self, Response, Parameter, verification, value, "SUCCESS")
		else
			-- Boundary = 0 ==> Is covered by _element_IsMissed_
		end
		
		
		
		--3. IsUpperBound
		local value = commonFunctions:createArrayInteger(Boundary[2], ElementBoundary[2])
		commonFunctions:TestCaseForResponse(self, Response, Parameter, "IsUpperBound", value, "SUCCESS")
		
		--4. IsOutLowerBound/IsEmpty
		if Boundary[1] ==1 then
			local value = commonFunctions:createArrayInteger(Boundary[1]-1, ElementBoundary[1])
			commonFunctions:TestCaseForResponse(self, Response, Parameter, "IsOutLowerBound_IsEmpty", value, "GENERIC_ERROR")
		
		elseif Boundary[1] >1 then
			local value = commonFunctions:createArrayInteger(Boundary[1]-1, ElementBoundary[1])
			commonFunctions:TestCaseForResponse(self, Response, Parameter, "IsOutLowerBound", value, "GENERIC_ERROR")
			
			commonFunctions:TestCaseForResponse(self, Response, Parameter, "IsEmpty", {}, "GENERIC_ERROR")			
		else
			--minsize = 0, no check out lower bound		
		end
		
		--5. IsOutUpperBound
		local value = commonFunctions:createArrayInteger(Boundary[2]+1, ElementBoundary[2])
		commonFunctions:TestCaseForResponse(self, Response, Parameter, "IsOutUpperBound", value, "GENERIC_ERROR")
		
		--6. IsWrongType
		commonFunctions:TestCaseForResponse(self, Response, Parameter, "IsWrongDataType", 123, "GENERIC_ERROR")
		
end

--Contains all test cases
function testCasesForArrayIntegerParameterInResponse:verify_Array_Integer_Parameter(Response, Parameter, Boundary,  ElementBoundary, Mandatory)


		--Print new line to separate new test cases group
		commonFunctions:newTestCasesGroup(Parameter)	
		TestingResponse = commonFunctions:cloneTable(Response)
		
		testCasesForArrayIntegerParameterInResponse:verify_Array_Integer_Parameter_Only(Response, Parameter, Boundary,  ElementBoundary, Mandatory)
		
		
		--Verify an element in array		
		
		commonFunctions:setValueForParameter(TestingResponse, Parameter, {})	

		local parameter_arrayElement = commonFunctions:BuildChildParameter(Parameter, 1) -- element #1

		integerParameterInResponse:verify_Integer_Parameter(TestingResponse, parameter_arrayElement, ElementBoundary, nil) --nil: not check missed element
		
end
---------------------------------------------------------------------------------------------

return testCasesForArrayIntegerParameterInResponse
