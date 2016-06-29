local config = { }

config.color = true
config.hmiUrl = "ws://localhost"
config.hmiPort = 8087
config.mobileHost = "localhost"
config.mobilePort = 12345
config.heartbeatTimeout = 7000
config.defaultProtocolVersion = 2

config. SDLStoragePath = "SDL_build_path/bin/storage/"
config.deviceMAC = "12ca17b49af2289436f303e0166030a21e525d266e209267433801a8fd4071a0"

config.pathToSDL = "/home/igetmanets/SDL/resump_job_2/bin/"
config.pathToSDL = "SDL_build_path/bin/"
config.SDL = "smartDeviceLinkCore"
config.sdl_logs_host = "localhost"
config.sdl_logs_port = 6676

config.ExitOnCrash = true
config.autorunSDL = true

config.excludeReport = false
config.storeFullATFLogs = true
config.storeFullSDLLogs = false
config.reportPath = "./TestingReports"
--for store sdl log -"x" before start script and +"x" after end script execution. In milliseconds(ms).
config.x_sdllog = 100
config.application1 =
{
  registerAppInterfaceParams =
  {
    syncMsgVersion =
    {
      majorVersion = 3,
      minorVersion = 3
    },
    appName = "Test Application",
    isMediaApplication = true,
    languageDesired = 'EN-US',
    hmiDisplayLanguageDesired = 'EN-US',

    appHMIType = { "DEFAULT" },
    appID = "0000001",
    deviceInfo =
    {
      os = "Android",
      carrier = "Megafon",
      firmwareRev = "Name: Linux, Version: 3.4.0-perf",
      osVersion = "4.4.2",
      maxNumberRFCOMMPorts = 1
    }
  }
}

config.application2 =
{
  registerAppInterfaceParams =
  {
    syncMsgVersion =
    {
      majorVersion = 3,
      minorVersion = 0
    },
    appName = "Test Application2",
    isMediaApplication = true,
    languageDesired = 'EN-US',
    hmiDisplayLanguageDesired = 'EN-US',
    appHMIType = { "NAVIGATION" },
    appID = "0000002",
    deviceInfo =
    {
      os = "Android",
      carrier = "Megafon",
      firmwareRev = "Name: Linux, Version: 3.4.0-perf",
      osVersion = "4.4.2",
      maxNumberRFCOMMPorts = 1
    }
  }
}
config.application3 =
{
  registerAppInterfaceParams =
  {
    syncMsgVersion =
    {
      majorVersion = 3,
      minorVersion = 0
    },
    appName = "Test Application3",
    isMediaApplication = true,
    languageDesired = 'EN-US',
    hmiDisplayLanguageDesired = 'EN-US',
    appHMIType = { "NAVIGATION" },
    appID = "0000003",
    deviceInfo =
    {
      os = "Android",
      carrier = "Megafon",
      firmwareRev = "Name: Linux, Version: 3.4.0-perf",
      osVersion = "4.4.2",
      maxNumberRFCOMMPorts = 1
    }
  }
}
config.application4 =
{
  registerAppInterfaceParams =
  {
    syncMsgVersion =
    {
      majorVersion = 3,
      minorVersion = 0
    },
    appName = "Test Application4",
    isMediaApplication = true,
    languageDesired = 'EN-US',
    hmiDisplayLanguageDesired = 'EN-US',
    appHMIType = { "NAVIGATION" },
    appID = "0000004",
    deviceInfo =
    {
      os = "Android",
      carrier = "Megafon",
      firmwareRev = "Name: Linux, Version: 3.4.0-perf",
      osVersion = "4.4.2",
      maxNumberRFCOMMPorts = 1
    }
  }
}
config.application5 =
{
  registerAppInterfaceParams =
  {
    syncMsgVersion =
    {
      majorVersion = 3,
      minorVersion = 0
    },
    appName = "Test Application5",
    isMediaApplication = true,
    languageDesired = 'EN-US',
    hmiDisplayLanguageDesired = 'EN-US',
    appHMIType = { "NAVIGATION" },
    appID = "0000005",
    deviceInfo =
    {
      os = "Android",
      carrier = "Megafon",
      firmwareRev = "Name: Linux, Version: 3.4.0-perf",
      osVersion = "4.4.2",
      maxNumberRFCOMMPorts = 1
    }
  }
}
config.application6 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application6",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675314",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application7 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application7",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675315",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application8 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application8",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675316",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application9 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application9",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675317",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application10 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application10",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675318",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application11 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application11",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675319",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application12 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application12",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675320",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application13 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application13",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675321",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application14 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application14",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675322",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application15 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application15",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675323",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application16 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application16",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675324",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application17 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application17",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675325",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application18 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application18",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675326",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application19 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application19",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675327",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application20 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application20",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675328",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}

config.application21 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application21",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675329",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application22 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application22",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675330",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application23 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application23",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675331",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application24 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application24",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675332",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application25 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application25",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675333",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application26 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application26",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675334",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application27 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application27",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675335",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application28 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application28",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675336",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application29 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application29",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675337",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application30 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application30",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675338",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application31 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application31",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675339",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application32 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application32",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675340",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application33 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application33",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675341",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application34 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application34",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675342",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application35 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application35",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675343",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application36 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application36",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675344",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application37 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application37",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675345",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application38 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application38",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675346",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application39 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application39",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675347",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application40 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application40",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675348",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application41 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application41",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675349",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application42 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application42",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675350",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application43 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application43",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675351",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application44 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application44",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675352",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application45 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application45",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675353",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application46 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application46",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675354",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application47 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application47",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675355",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application48 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application48",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675356",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application49 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application49",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675357",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application50 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application50",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675358",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application51 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application51",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675359",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application52 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application52",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675360",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application53 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application53",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675361",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application54 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application54",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675362",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application55 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application55",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675363",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application56 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application56",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675364",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application57 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application57",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675365",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application58 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application58",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675366",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application59 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application59",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675367",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application60 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application60",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675368",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application61 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application61",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675369",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application62 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application62",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675370",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application63 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application63",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675371",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application64 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application64",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675372",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application65 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application65",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675373",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application66 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application66",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675374",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application67 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application67",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675375",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application68 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application68",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675376",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application69 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application69",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675377",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application70 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application70",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675378",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application71 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application71",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675379",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application72 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application72",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675380",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application73 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application73",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675381",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application74 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application74",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675382",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application75 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application75",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675383",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application76 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application76",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675384",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application77 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application77",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675385",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application78 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application78",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675386",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application79 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application79",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675387",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application80 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application80",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675388",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application81 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application81",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675389",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application82 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application82",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675390",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application83 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application83",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675391",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application84 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application84",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675392",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application85 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application85",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675393",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application86 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application86",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675394",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application87 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application87",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675395",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application88 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application88",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675396",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application89 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application89",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675397",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application90 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application90",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675398",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application91 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application91",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675399",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application92 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application92",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675400",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application93 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application93",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675401",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application94 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application94",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675402",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application95 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application95",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675403",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application96 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application96",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675404",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application97 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application97",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675405",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application98 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application98",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675406",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application99 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application99",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675407",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application100 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application100",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675408",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application101 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application101",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675409",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application102 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application102",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675410",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application103 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application103",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675411",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application104 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application104",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675412",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application105 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application105",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675413",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application106 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application106",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675414",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application107 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application107",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675415",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application108 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application108",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675416",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application109 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application109",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675417",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application110 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application110",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675418",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application111 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application111",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675419",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application112 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application112",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675420",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application113 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application113",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675421",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application114 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application114",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675422",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application115 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application115",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675423",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application116 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application116",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675424",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application117 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application117",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675425",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application118 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application118",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675426",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application119 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application119",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675427",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application120 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application120",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675428",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application121 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application121",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675429",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application122 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application122",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675430",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application123 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application123",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675431",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application124 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application124",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675432",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application125 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application125",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675433",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application126 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application126",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675434",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application127 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application127",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675435",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application128 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application128",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675436",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application129 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application129",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675437",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application130 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application130",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675438",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application131 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application131",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675439",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application132 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application132",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675440",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application133 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application133",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675441",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application134 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application134",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675442",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application135 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application135",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675443",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application136 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application136",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675444",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application137 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application137",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675445",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application138 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application138",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675446",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application139 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application139",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675447",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application140 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application140",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675448",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application141 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application141",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675449",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application142 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application142",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675450",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application143 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application143",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675451",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application144 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application144",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675452",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application145 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application145",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675453",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application146 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application146",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675454",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application147 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application147",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675455",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application148 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application148",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675456",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application149 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application149",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675457",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application150 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application150",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675458",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application151 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application151",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675459",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application152 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application152",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675460",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application153 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application153",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675461",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application154 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application154",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675462",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application155 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application155",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675463",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application156 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application156",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675464",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application157 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application157",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675465",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application158 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application158",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675466",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application159 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application159",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675467",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application160 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application160",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675468",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application161 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application161",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675469",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application162 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application162",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675470",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application163 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application163",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675471",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application164 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application164",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675472",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application165 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application165",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675473",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application166 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application166",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675474",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application167 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application167",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675475",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application168 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application168",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675476",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application169 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application169",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675477",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application170 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application170",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675478",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application171 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application171",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675479",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application172 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application172",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675480",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application173 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application173",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675481",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application174 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application174",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675482",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application175 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application175",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675483",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application176 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application176",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675484",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application177 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application177",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675485",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application178 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application178",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675486",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application179 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application179",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675487",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application180 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application180",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675488",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application181 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application181",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675489",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application182 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application182",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675490",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application183 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application183",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675491",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application184 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application184",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675492",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application185 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application185",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675493",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application186 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application186",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675494",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application187 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application187",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675495",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application188 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application188",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675496",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application189 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application189",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675497",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application190 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application190",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675498",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application191 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application191",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675499",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application192 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application192",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675500",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application193 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application193",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675501",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application194 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application194",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675502",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application195 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application195",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675503",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application196 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application196",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675504",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application197 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application197",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675505",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application198 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application198",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675506",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application199 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application199",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675507",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application200 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application200",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675508",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application201 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application201",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675509",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application202 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application202",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675510",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application203 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application203",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675511",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application204 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application204",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675512",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application205 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application205",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675513",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application206 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application206",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675514",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application207 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application207",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675515",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application208 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application208",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675516",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application209 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application209",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675517",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application210 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application210",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675518",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application211 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application211",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675519",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application212 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application212",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675520",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application213 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application213",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675521",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application214 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application214",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675522",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application215 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application215",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675523",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application216 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application216",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675524",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application217 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application217",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675525",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application218 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application218",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675526",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application219 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application219",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675527",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application220 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application220",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675528",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application221 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application221",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675529",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application222 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application222",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675530",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application223 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application223",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675531",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application224 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application224",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675532",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application225 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application225",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675533",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application226 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application226",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675534",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application227 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application227",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675535",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application228 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application228",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675536",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application229 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application229",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675537",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application230 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application230",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675538",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application231 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application231",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675539",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application232 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application232",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675540",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application233 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application233",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675541",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application234 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application234",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675542",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application235 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application235",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675543",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application236 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application236",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675544",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application237 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application237",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675545",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application238 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application238",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675546",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application239 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application239",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675547",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application240 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application240",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675548",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application241 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application241",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675549",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application242 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application242",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675550",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application243 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application243",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675551",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application244 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application244",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675552",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application245 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application245",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675553",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application246 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application246",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675554",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application247 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application247",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675555",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application248 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application248",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675556",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application249 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application249",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675557",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application250 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application250",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675558",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application251 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application251",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675559",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application252 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application252",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675560",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application253 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application253",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675561",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application254 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application254",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675562",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
config.application255 =
{
  registerAppInterfaceParams =
  {
  syncMsgVersion =
  {
    majorVersion = 3,
    minorVersion = 0
  },
  appName = "Test Application255",
  isMediaApplication = true,
  languageDesired = 'EN-US',
  hmiDisplayLanguageDesired = 'EN-US',
  appHMIType = { "NAVIGATION" },
  appID = "8675563",
  deviceInfo =
  {
    os = "Android",
    carrier = "Megafon",
    firmwareRev = "Name: Linux, Version: 3.4.0-perf",
    osVersion = "4.4.2",
    maxNumberRFCOMMPorts = 1
  }
  }
}
return config
