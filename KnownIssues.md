# Known FAILS in test scripts:

* ATF_Speak.lua:
  * Speak_ttsChunks_IsUpperBound_SUCCESS
  * Speak_ttsChunks_IsOutUpperBound_INVALID_DATA
  * Speak_CorrelationID_IsDuplicated
  * Speak_Response_resultCode_IsValidValue_UNSUPPORTED_RESOURCE_SendError
  * Speak_Response_resultCode_IsValidValue_WARNINGS_SendError
  * Activation_App // (sometimes)

* ATF_AddSubMenu.lua:
  * AddSubMenu_InvalidDataSuccessFalse
  * AddSubMenu_OutOfMemorySuccessFalse
  * AddSubMenu_GenericErrorSuccessFalse
  * AddSubMenu_RejectedSuccessFalse
  * AddSubMenu_REJECTED
  * Activation_App // (sometimes)

* ATF_OnDriverDistraction.lua:
  * Activate_Media_App2 // (sometimes)

* ATF_SetMediaClockTimer.lua:
  * UI_SetMediaClockTimer_Response*

* ATF_Slider.lua:
  * Slider_AllParametersUpperBound_SUCCESS
  * Slider_sliderFooter_IsOutLowerBound_IsEmpty_INVALID_DATA
  * Slider_sliderFooter_IsUpperBound_SUCCESS
  * Activation_App // (sometimes)

Checked on SDL commit SDL commit [85918cb](https://github.com/smartdevicelink/sdl_core/commit/85918cb)
