--This script contains all test cases to verify Enumeration parameter
--How to use:
	--1. local enumParameterInNotification = require('user_modules/shared_testcases/testCasesForEnumerationParameterInNotification')
	--2. enumParameterInNotification:verify_Enumeration_Parameter(Notification, Parameter, ExistentValues, IsMandatory, arrInValidValues)
---------------------------------------------------------------------------------------------

local testCasesForEnumerationParameterInNotification = {}
local commonFunctions = require('user_modules/shared_testcases/commonFunctions')

---------------------------------------------------------------------------------------------
--Test cases to verify Enumeration parameter
---------------------------------------------------------------------------------------------
--List of test cases for Enumeration type parameter:
	--1. IsMissed
	--2. IsWrongDataType
	--3. IsExistentValues
	--4. IsNonExistentValue
	--5. IsEmpty	

--Example: arrInValidValues = {{"", "IsEmpty"}, {123, "IsWrongType"}}
function testCasesForEnumerationParameterInNotification:verify_Enumeration_Parameter(Notification, Parameter, ExistentValues, IsMandatory, arrInValidValues)

	--Print new line to separate new test cases group
	commonFunctions:newTestCasesGroup(Parameter)	
	
	--1. IsMissed
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
	
	--2. IsExistentValues
	for i = 1, #ExistentValues do
		commonFunctions:TestCaseForNotification(self, Notification, Parameter, "IsExistentValues_"..ExistentValues[i], ExistentValues[i], true)
	end
	
	if arrInValidValues == nil then
	
		--3. IsWrongDataType
		commonFunctions:TestCaseForNotification(self, Notification, Parameter, "IsWrongDataType", 123, false)
		
		--4. IsNonexistentValue
		commonFunctions:TestCaseForNotification(self, Notification, Parameter, "IsNonexistentValue", "ANY", false)
		
		--5. IsEmpty
		commonFunctions:TestCaseForNotification(self, Notification, Parameter, "IsEmpty", "", false)
	else
		for i = 1, #arrInValidValues do
			commonFunctions:TestCaseForNotification(self, Notification, Parameter, arrInValidValues[i][2], arrInValidValues[i][1], false)
		end	
	end
	
end	



return testCasesForEnumerationParameterInNotification
