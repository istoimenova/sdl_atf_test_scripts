--This script contains all test cases to verify String parameter
--How to use:
	--1. local stringParameterInNotification = require('user_modules/shared_testcases/testCasesForStringParameterInNotification')
	--2. stringParameterInNotification:verify_String_Parameter(Notification, Parameter, Boundary, IsMandatory, IsAcceptedInvalidCharacters)
---------------------------------------------------------------------------------------------


local testCasesForStringParameterInNotification = {}
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')




---------------------------------------------------------------------------------------------
--Test cases to verify String parameter
---------------------------------------------------------------------------------------------
--List of test cases for String type parameter:
	--1. IsMissed
	--2. IsWrongType
	--3. IsLowerBound/IsEmpty
	--4. IsOutLowerBound/IsEmpty
	--5. IsUpperBound
	--6. IsOutUpperBound
	--7. IsInvalidCharacters

---------------------------------------------------------------------------------------------
--Test cases to verify String parameter
---------------------------------------------------------------------------------------------
--List of test cases for String type parameter:
	--1. IsMissed
	--2. IsWrongType
	--3. IsLowerBound/IsEmpty
	--4. IsOutLowerBound/IsEmpty
	--5. IsUpperBound
	--6. IsOutUpperBound
	--7. IsInvalidCharacters
---------------------------------------------------------------------------------------------
	
--1. verify_String_Parameter_Basic: verify basic cases
	--2. IsWrongType
	--3. IsLowerBound/IsEmpty
	--4. IsOutLowerBound/IsEmpty
	--5. IsUpperBound
	--6. IsOutUpperBound
	
-- function testCasesForStringParameterInNotification:verify_String_Parameter_Basic(Notification, Parameter, Boundary)
		
		-- --Print new line to separate new test cases group
		-- commonFunctions:newTestCasesGroup(Parameter)	
		
		-- --2. IsWrongDataType
		-- commonFunctions:TestCaseForNotification(self, Notification, Parameter, "IsWrongDataType", 123, false)
		
		-- --3. IsLowerBound
		-- local verification = "IsLowerBound"
		-- if Boundary[1] == 0 then
			-- verification = "IsLowerBound_IsEmpty"
		-- end
		
		-- local value = commonFunctions:createString(Boundary[1])
		-- commonFunctions:TestCaseForNotification(self, Notification, Parameter, "IsLowerBound", value, true)
		
		-- --4. IsUpperBound
		-- local value = commonFunctions:createString(Boundary[2])
		-- commonFunctions:TestCaseForNotification(self, Notification, Parameter, "IsUpperBound", value, true)
		
		
		-- --5. IsOutLowerBound
		-- local value = commonFunctions:createString(Boundary[1] - 1)
		-- if Boundary[1] >= 2 then
			-- commonFunctions:TestCaseForNotification(self, Notification, Parameter, "IsOutLowerBound", value, false)
		-- elseif Boundary[1] == 1 then		
			-- commonFunctions:TestCaseForNotification(self, Notification, Parameter, "IsOutLowerBound_IsEmpty", value, false)
		-- else
			-- --minlength = 0, no check out lower bound
		-- end

		
		-- --6. IsOutUpperBound
		-- local value = commonFunctions:createString(Boundary[2] + 1)
		-- commonFunctions:TestCaseForNotification(self, Notification, Parameter, "IsOutUpperBound", Boundary[2] + 1, false)
		

-- end

	
-- --2. verify_String_Parameter_Mandatory: verify mandatory and basic cases
	-- --1. IsMissed
	-- --2-6:
-- function testCasesForStringParameterInNotification:verify_String_Parameter_Mandatory(Notification, Parameter, Boundary, Mandatory)
		
	-- --Print new line to separate new test cases group
	-- commonFunctions:newTestCasesGroup(Parameter)	
	
	-- --1. IsMissed
	-- local IsValidValue = false
	-- if Mandatory == nil then
		-- --no check mandatory: in case this parameter is element in array. We does not verify an element is missed. It is checked in test case checks bound of array.
	-- else			
		-- local resultCode
		-- if Mandatory == true then
			-- IsValidValue = false
		-- else
			-- IsValidValue = true
		-- end		
		-- commonFunctions:TestCaseForNotification(self, Notification, Parameter, "IsMissed", nil, IsValidValue)	
	-- end
	
	-- testCasesForStringParameterInNotification:verify_String_Parameter_Basic(Notification, Parameter, Boundary)
	
-- end


-- --3. verify_String_Parameter_AcceptSpecialCharacters: Contain basic cases and verify SUCCESS resultCode when containing spacial characters
-- function testCasesForStringParameterInNotification:verify_String_Parameter_AcceptSpecialCharacters(Notification, Parameter, Boundary, Mandatory)

	-- --Print new line to separate new test cases group
	-- commonFunctions:newTestCasesGroup(Parameter)	
	
	-- testCasesForStringParameterInNotification:verify_String_Parameter_Mandatory(Notification, Parameter, Boundary, Mandatory)
	
	-- --7. IsSpecialCharacters
	-- commonFunctions:TestCaseForNotification(self, Notification, Parameter, "ContainsNewLineCharacter", "a\nb", true)
	-- commonFunctions:TestCaseForNotification(self, Notification, Parameter, "ContainsTabCharacter", "a\tb", true)
	-- commonFunctions:TestCaseForNotification(self, Notification, Parameter, "WhiteSpacesOnly", "   ", true)		
-- end	

	
-- --4. verify_String_Parameter: Contain basic cases and verify INVALID_DATA resultCode when containing spacial characters
-- function testCasesForStringParameterInNotification:verify_String_Parameter1(Notification, Parameter, Boundary, Mandatory)

		-- local Notification = commonFunctions:cloneTable(Notification)	

		-- --Print new line to separate new test cases group
		-- commonFunctions:newTestCasesGroup(Parameter)	
		
		-- testCasesForStringParameterInNotification:verify_String_Parameter_Mandatory(Notification, Parameter, Boundary, Mandatory)
		
		-- --7. IsInvalidCharacters: Special characters validation: INVALID_DATA response should come according to APPLINK-7687
		-- commonFunctions:TestCaseForNotification(self, Notification, Parameter, "ContainsNewLineCharacter", "a\nb", false)
		-- commonFunctions:TestCaseForNotification(self, Notification, Parameter, "ContainsTabCharacter", "a\tb", false)
		-- commonFunctions:TestCaseForNotification(self, Notification, Parameter, "WhiteSpacesOnly", "   ", false)

-- end	


	
--4. verify_String_Parameter
function testCasesForStringParameterInNotification:verify_String_Parameter(Notification, Parameter, Boundary, IsMandatory, IsAcceptedInvalidCharacters)

	
	local TestingNotification = commonFunctions:cloneTable(Notification)	

	--Print new line to separate new test cases group
	commonFunctions:newTestCasesGroup(Parameter)	
	
	--1. IsMissed
	local IsValidValue = false
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
	
	--3. IsLowerBound
	local verification = "IsLowerBound"
	if Boundary[1] == 0 then
		verification = "IsLowerBound_IsEmpty"
	end
	
	local value = commonFunctions:createString(Boundary[1])
	commonFunctions:TestCaseForNotification(self, Notification, Parameter, "IsLowerBound", value, true)
	
	--4. IsUpperBound
	local value = commonFunctions:createString(Boundary[2])
	commonFunctions:TestCaseForNotification(self, Notification, Parameter, "IsUpperBound", value, true)
	
	
	--5. IsOutLowerBound
	local value = commonFunctions:createString(Boundary[1] - 1)
	if Boundary[1] >= 2 then
		commonFunctions:TestCaseForNotification(self, Notification, Parameter, "IsOutLowerBound", value, false)
	elseif Boundary[1] == 1 then		
		commonFunctions:TestCaseForNotification(self, Notification, Parameter, "IsOutLowerBound_IsEmpty", value, false)
	else
		--minlength = 0, no check out lower bound
	end

	
	--6. IsOutUpperBound
	local value = commonFunctions:createString(Boundary[2] + 1)
	commonFunctions:TestCaseForNotification(self, Notification, Parameter, "IsOutUpperBound", value, false)
	
	
	--7. IsInvalidCharacters
	if IsAcceptedInvalidCharacters == nil then
		--no check Characters
	else			
		if IsAcceptedInvalidCharacters == true then
			commonFunctions:TestCaseForNotification(self, Notification, Parameter, "ContainsNewLineCharacter", "a\nb", true)
			commonFunctions:TestCaseForNotification(self, Notification, Parameter, "ContainsTabCharacter", "a\tb", true)
			commonFunctions:TestCaseForNotification(self, Notification, Parameter, "WhiteSpacesOnly", "   ", true)
		else
			commonFunctions:TestCaseForNotification(self, Notification, Parameter, "ContainsNewLineCharacter", "a\nb", false)
			commonFunctions:TestCaseForNotification(self, Notification, Parameter, "ContainsTabCharacter", "a\tb", false)
			commonFunctions:TestCaseForNotification(self, Notification, Parameter, "WhiteSpacesOnly", "   ", false)
		end		
	end
	
end	



return testCasesForStringParameterInNotification
