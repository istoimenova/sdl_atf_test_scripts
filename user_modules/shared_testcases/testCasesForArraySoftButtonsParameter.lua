--This script contains all test cases to verify SoftButtons Array parameter
--How to use:
	--1. local arraySoftButtonsParameter = require('user_modules/shared_testcases/testCasesForArraySoftButtonsParameter')
	--2. arraySoftButtonsParameter:verify_softButtons_Parameter(Request, Parameter, Boundary, ImageValueBoundary, Mandatory)
---------------------------------------------------------------------------------------------


local testCasesForArraySoftButtonsParameter = {}
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
local softButtonParameter = require('user_modules/shared_testcases/testCasesForSoftButtonParameter')


---------------------------------------------------------------------------------------------
--Test cases to verify SoftButton array parameter
---------------------------------------------------------------------------------------------
--List of test cases for softButtons type parameter:
	--1. IsMissed
	--2. IsEmpty
	--3. IsWrongType
	--4. IsLowerBound
	--5. IsUpperBound
	--6. IsOutLowerBound
	--7. IsOutUpperBound
	--8. Check parameters in side a button:
		--"type" type="SoftButtonType">
		--"text" minlength="0" maxlength="500" type="String" mandatory="false"
		--"image" type="Image" mandatory="false"
		--"isHighlighted" type="Boolean" defvalue="false" mandatory="false"
		--"softButtonID" type="Integer" minvalue="0" maxvalue="65535"
		--"systemAction" type="SystemAction" defvalue="DEFAULT_ACTION" mandatory="false"
-----------------------------------------------------------------------------------------------	


--Contains all test cases
function testCasesForArraySoftButtonsParameter:verify_softButtons_Parameter(Request, Parameter, Boundary, ImageValueBoundary, Mandatory)

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
		
		--2. IsWrongType
		commonFunctions:TestCase(self, Request, Parameter, "IsWrongDataType", 123, "INVALID_DATA")
		
		
		--3. IsEmpty/IsOutLowerBound
		local verification = "IsLowerBound"
		if Boundary[1] == 0 then
			verification = "IsLowerBound_IsEmpty"
		end
		
		local value = commonFunctions:createSoftButtons(1, "Button", "KEEP_CONTEXT", "BOTH", true, "DYNAMIC", "action.png", Boundary[1])
		commonFunctions:TestCase(self, Request, Parameter, verification, value, "SUCCESS")
		
		--4. IsUpperBound		
		local value = commonFunctions:createSoftButtons(1, "Button", "KEEP_CONTEXT", "BOTH", true, "DYNAMIC", "action.png", Boundary[2])
		commonFunctions:TestCase(self, Request, Parameter, "IsUpperBound", value, "SUCCESS")
		
		--5. IsOutLowerBound/IsEmpty
		local value = commonFunctions:createSoftButtons(1, "Button", "KEEP_CONTEXT", "BOTH", true, "DYNAMIC", "action.png", Boundary[1] -1)
		if Boundary[1] >= 2 then
			commonFunctions:TestCase(self, Request, Parameter, "IsOutLowerBound", value, "INVALID_DATA")
		elseif Boundary[1] == 1 then		
			--commonFunctions:TestCase(self, Request, Parameter, "IsOutLowerBound_IsEmpty", value, "INVALID_DATA")
			--Covered by _softButtons_element_IsMissed_INVALID_DATA
		else
			--minlength = 0, no check out lower bound
		end
		
		--6. IsOutUpperBound
		local value = commonFunctions:createSoftButtons(1, "Button", "KEEP_CONTEXT", "BOTH", true, "DYNAMIC", "action.png", Boundary[2] + 1)
		commonFunctions:TestCase(self, Request, Parameter, "IsOutUpperBound", value, "INVALID_DATA")
		
		
		-------------------------------------------------------------------------------------------
		--7. Check a button
		--Set default parameters for request
		local TestingRequest = commonFunctions:cloneTable(Request)
		local softButtons_value = 
		{
			{
				text = "Close",
				systemAction = "KEEP_CONTEXT",
				type = "BOTH",
				isHighlighted = true,																
				image =
				{
				   imageType = "DYNAMIC",
				   value = "action.png"
				},																
				softButtonID = 1
			}
		}

		commonFunctions:setValueForParameter(TestingRequest, Parameter, softButtons_value)		
		local parameter_button = commonFunctions:BuildChildParameter(Parameter, 1) -- button #1
		
		softButtonParameter:verify_softButton_Parameter(TestingRequest, parameter_button, ImageValueBoundary, true)

		
end
-----------------------------------------------------------------------------------------------

return testCasesForArraySoftButtonsParameter
