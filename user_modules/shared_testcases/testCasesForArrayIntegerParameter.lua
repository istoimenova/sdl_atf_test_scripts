--This script contains all test cases to array String Parameter
--How to use:
	--1. local arrayIntegerParameter = require('user_modules/shared_testcases/testCasesForArrayIntegerParameter')
	--2. arrayIntegerParameter:verify_Array_Integer_Parameter(Request, Parameter, Boundary, ElementBoundary, Mandatory)
---------------------------------------------------------------------------------------------

local testCasesForArrayIntegerParameter = {}
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')


---------------------------------------------------------------------------------------------
--Test cases to verify Array Integer Parameter
---------------------------------------------------------------------------------------------
--List of test cases for Integer type Parameter:
	--1. IsMissed
	--2. IsLowerBound
	--3. IsUpperBound
	--4. OutLowerBound/IsEmpty
	--5. OutUpperBound
	--6. IsWrongType
	------------------------
	--7. Check an element of array Integer
	
	

--Verify array only:
	--1. IsMissed
	--2. IsLowerBound
	--3. IsUpperBound
	--4. OutLowerBound/IsEmpty
	--5. OutUpperBound
	--6. IsWrongType
function testCasesForArrayIntegerParameter:verify_Array_Integer_Parameter_Only(Request, Parameter, Boundary,  ElementBoundary, Mandatory)


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
		
		--2. IsLowerBound
		local verification = "IsLowerBound"
		if Boundary[1] > 0 then
			verification = "IsLowerBound_IsEmpty"
			local value = commonFunctions:createArrayInteger(Boundary[1], ElementBoundary[1])
			commonFunctions:TestCase(self, Request, Parameter, verification, value, "SUCCESS")
		else
			-- Boundary = 0 ==> Is covered by _element_IsMissed_
		end
		
		
		
		--3. IsUpperBound
		local value = commonFunctions:createArrayInteger(Boundary[2], ElementBoundary[2])
		commonFunctions:TestCase(self, Request, Parameter, "IsUpperBound", value, "SUCCESS")
		
		--4. IsOutLowerBound/IsEmpty
		if Boundary[1] ==1 then
			local value = commonFunctions:createArrayInteger(Boundary[1]-1)
			commonFunctions:TestCase(self, Request, Parameter, "IsOutLowerBound_IsEmpty", value, "INVALID_DATA")
		
		elseif Boundary[1] >1 then
			local value = commonFunctions:createArrayInteger(Boundary[1]-1)
			commonFunctions:TestCase(self, Request, Parameter, "IsOutLowerBound", value, "INVALID_DATA")
			
			commonFunctions:TestCase(self, Request, Parameter, "IsEmpty", {}, "INVALID_DATA")			
		else
			--minsize = 0, no check out lower bound		
		end
		
		--5. IsOutUpperBound
		local value = commonFunctions:createArrayInteger(Boundary[2]+1)
		commonFunctions:TestCase(self, Request, Parameter, "IsOutUpperBound", value, "INVALID_DATA")
		
		--6. IsWrongType
		commonFunctions:TestCase(self, Request, Parameter, "IsWrongDataType", 123, "INVALID_DATA")
				
		
end
---------------------------------------------------------------------------------------------

--Contains all test cases
function testCasesForArrayIntegerParameter:verify_Array_Integer_Parameter(Request, Parameter, Boundary,  ElementBoundary, Mandatory)

		--Verify array only
		testCasesForArrayIntegerParameter:verify_Array_Integer_Parameter_Only(Request, Parameter, Boundary,  ElementBoundary, Mandatory)
		
		
		--Verify an element in array		
		local TestingRequest = commonFunctions:cloneTable(Request)
		commonFunctions:setValueForParameter(TestingRequest, Parameter, {})	

		local parameter_arrayElement = commonFunctions:BuildChildParameter(Parameter, 1) -- element #1

		--Verify an element in a Integer array. It includes test case 2-6 of Integer parameter
		--2. IsWrongType
		--3. IsLowerBound/IsEmpty
		--4. IsOutLowerBound/IsEmpty
		--5. IsUpperBound
		--6. IsOutUpperBound
		IntegerParameter:verify_Integer_Parameter_Basic(TestingRequest, parameter_arrayElement, ElementBoundary, false)
		
		
end
---------------------------------------------------------------------------------------------