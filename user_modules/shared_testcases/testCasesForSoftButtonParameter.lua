--This script contains all test cases to verify SoftButton parameter
--How to use:
	--1. local softButtonParameter = require('user_modules/shared_testcases/testCasesForSoftButtonParameter')
	--2. softButtonParameter:verify_softButton_Parameter(Request, Parameter, ImageValueBoundary, Mandatory)

---------------------------------------------------------------------------------------------

local testCasesForSoftButtonParameter = {}
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')
local booleanParameter = require('user_modules/shared_testcases/testCasesForBooleanParameter')
local stringParameter = require('user_modules/shared_testcases/testCasesForStringParameter')
local enumerationParameter = require('user_modules/shared_testcases/testCasesForEnumerationParameter')
local imageParameter = require('user_modules/shared_testcases/testCasesForImageParameter')
local integerParameter = require('user_modules/shared_testcases/testCasesForIntegerParameter')





---------------------------------------------------------------------------------------------
--Test cases to verify a SoftButton parameter
---------------------------------------------------------------------------------------------
--List of parameters in side a button
	--1. type: type="SoftButtonType"
	--2. text: minlength="0" maxlength="500" type="String" mandatory="false"
	--3. image: type="Image" mandatory="false"
	--4. isHighlighted: type="Boolean" defvalue="false" mandatory="false"
	--5. softButtonID: type="Integer" minvalue="0" maxvalue="65535"
	--6. systemAction: type="SystemAction" defvalue="DEFAULT_ACTION" mandatory="false"
-----------------------------------------------------------------------------------------------	

--Contains all test cases. It is used by function to verify array of buttons parameter.
function testCasesForSoftButtonParameter:verify_softButton_Parameter(Request, Parameter, ImageValueBoundary, Mandatory)

	--Print new line to separate new test cases group
	commonFunctions:newTestCasesGroup(Parameter)	
	
	--0. IsMissed
	local resultCode
	if Mandatory == true then
		resultCode = "INVALID_DATA"
	else
		resultCode = "SUCCESS"
	end
	
	commonFunctions:TestCase(self, Request, Parameter, "IsMissed", nil, resultCode)	
	
	
	--1. type: type="SoftButtonType": "TEXT", "IMAGE", "BOTH"
	local ExistentValues = {"TEXT", "IMAGE", "BOTH"}
	
	local parameter_type = commonFunctions:BuildChildParameter(Parameter, "type") -- type parameter in button #1
	enumerationParameter:verify_Enum_String_Parameter(Request, parameter_type, ExistentValues, true)
	
	
	
	--softbutton.type = "BOTH"
	TestingRequest = commonFunctions:cloneTable(Request)
	commonFunctions:setValueForParameter(TestingRequest, parameter_type, "BOTH")
	
	--Add suffix to test case name to explain for spacial cases that test case names are not clear
	TestCaseNameSuffix = "ButtonTypeIsBOTH"
	
		--2. text: minlength="0" maxlength="500" type="String" mandatory="true"
		local Boundary = {0, 500}
		local parameter_text = commonFunctions:BuildChildParameter(Parameter, "text") -- text parameter in button #1
	
		stringParameter:verify_String_Parameter(TestingRequest, parameter_text, Boundary, true)
		
		--3. image: type="Image" mandatory="true"
		local parameter_image = commonFunctions:BuildChildParameter(Parameter, "image") -- image parameter in button #1
		
		imageParameter:verify_Image_Parameter(TestingRequest, parameter_image, ImageValueBoundary, true)
		
		--4. isHighlighted: type="Boolean" defvalue="false" mandatory="false"
		local parameter_isHighlighted = commonFunctions:BuildChildParameter(Parameter, "isHighlighted") -- isHighlighted parameter in button #1
		
		booleanParameter:verify_boolean_Parameter(TestingRequest, parameter_isHighlighted, {true, false}, false)
		
		
		--5. softButtonID: type="Integer" minvalue="0" maxvalue="65535"			
		local parameter_softButtonID = commonFunctions:BuildChildParameter(Parameter, "softButtonID") -- softButtonID parameter in button #1
		
		integerParameter:verify_Integer_Parameter(TestingRequest, parameter_softButtonID, {0, 65535}, true)
		
		--6. systemAction: type="SystemAction" default="DEFAULT_ACTION" mandatory="false"
		local parameter_systemAction = commonFunctions:BuildChildParameter(Parameter, "systemAction") -- systemAction parameter in button #1
		
		local ExistentValues = {"DEFAULT_ACTION", "STEAL_FOCUS", "KEEP_CONTEXT"}
		enumerationParameter:verify_Enum_String_Parameter(TestingRequest, parameter_systemAction, ExistentValues, false)

		
	--softbutton.type = "TEXT"			
	TestingRequest = commonFunctions:cloneTable(Request)
	commonFunctions:setValueForParameter(TestingRequest, parameter_type, "TEXT")
	--Add suffix to test case name to explain for spacial cases that test case names are not clear
	TestCaseNameSuffix = "ButtonTypeIsTEXT"
	
		--2. text: minlength="0" maxlength="500" type="String" mandatory="true"
		local Boundary = {1, 500} -- type = TEXT, text should not be empty
		
		local parameter_text = commonFunctions:BuildChildParameter(Parameter, "text") -- text parameter in button #1
	
		stringParameter:verify_String_Parameter(TestingRequest, parameter_text, Boundary, true)
						
		
		--3. image: type="Image" mandatory="false"
		local parameter_image = commonFunctions:BuildChildParameter(Parameter, "image")  -- image parameter in button #1
		
		imageParameter:verify_Image_Parameter(TestingRequest, parameter_image, ImageValueBoundary, false)
		
		
		--4. isHighlighted: type="Boolean" default="false" mandatory="false"
		local parameter_isHighlighted = commonFunctions:BuildChildParameter(Parameter, "isHighlighted") -- isHighlighted parameter in button #1
		
		booleanParameter:verify_boolean_Parameter(TestingRequest, parameter_isHighlighted, {true, false}, false)
		
		
		--5. softButtonID: type="Integer" minvalue="0" maxvalue="65535"
		local parameter_softButtonID = commonFunctions:BuildChildParameter(Parameter, "softButtonID") -- softButtonID parameter in button #1
		
		integerParameter:verify_Integer_Parameter(TestingRequest, parameter_softButtonID, {0, 65535}, true)
		
						
		--6. systemAction: type="SystemAction" default="DEFAULT_ACTION" mandatory="false"
		local parameter_systemAction = commonFunctions:BuildChildParameter(Parameter, "systemAction")  -- systemAction parameter in button #1
		
		local ExistentValues = {"DEFAULT_ACTION", "STEAL_FOCUS", "KEEP_CONTEXT"}
		enumerationParameter:verify_Enum_String_Parameter(TestingRequest, parameter_systemAction, ExistentValues,  false)
		
						
		
	--softbutton.type = "IMAGE"			
	TestingRequest = commonFunctions:cloneTable(Request)
	commonFunctions:setValueForParameter(TestingRequest, parameter_type, "IMAGE")
	--Add suffix to test case name to explain for spacial cases that test case names are not clear
	TestCaseNameSuffix = "ButtonTypeIsIMAGE"
	
		--2. text: minlength="0" maxlength="500" type="String" mandatory="false"
		local parameter_text = commonFunctions:BuildChildParameter(Parameter, "text") -- text parameter in button #1
	
		stringParameter:verify_String_Parameter(TestingRequest, parameter_text, {0, 500}, false)
		
		
		--3. image: type="Image" mandatory="true"
		local parameter_image = commonFunctions:BuildChildParameter(Parameter, "image") -- image parameter in button #1
		
		imageParameter:verify_Image_Parameter(TestingRequest, parameter_image, ImageValueBoundary, true)
					
					
		--4. isHighlighted: type="Boolean" default="false" mandatory="false"
		local parameter_isHighlighted = commonFunctions:BuildChildParameter(Parameter, "isHighlighted")-- isHighlighted parameter in button #1
		
		local ExistentValues = {true, false}
		booleanParameter:verify_boolean_Parameter(TestingRequest, parameter_isHighlighted, ExistentValues, false)
		
		
		--5. softButtonID: type="Integer" minvalue="0" maxvalue="65535"
		local parameter_softButtonID = commonFunctions:BuildChildParameter(Parameter, "softButtonID") -- softButtonID parameter in button #1
		
		integerParameter:verify_Integer_Parameter(TestingRequest, parameter_softButtonID, {0, 65535}, true)
		
		
		--6. systemAction: type="SystemAction" default="DEFAULT_ACTION" mandatory="false"
		local parameter_systemAction = commonFunctions:BuildChildParameter(Parameter, "systemAction") -- systemAction parameter in button #1
		
		local ExistentValues = {"DEFAULT_ACTION", "STEAL_FOCUS", "KEEP_CONTEXT"}
		enumerationParameter:verify_Enum_String_Parameter(TestingRequest, parameter_systemAction, ExistentValues,  false)

	--Clear TestCaseNameSuffix
	TestCaseNameSuffix = nil
end
	

return testCasesForSoftButtonParameter
