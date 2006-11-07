_global.settings = new Object();

_global.systemInformation = "Copyright © " + new Date().getFullYear() + " Building Intelligence Pty Ltd";

_global.flashMajorVersion = Number(System.capabilities.version.split(" ")[1].split(",")[0]);

_global.settings.serverPort = 10000;
_global.settings.serverRetryTime = 10;
_global.settings.serverConnectTimeout = 3;
_global.settings.libLocation = "lib/";
_global.settings.debugMode = false;
_global.settings.hideMouseCursor = true;
_global.settings.fullScreen = true;
_global.settings.scale = false;
_global.settings.width = 1024;
_global.settings.height = 768;

_global.settings.webRefreshRate = 1; // seconds

_global.sounds = new Object();
_global.sounds["default"] = new Sound();
_global.sounds["default"].attachSound("sfx_default");
_global.sounds["alarm"] = new Sound();
_global.sounds["alarm"].attachSound("sfx_alarm");

_global.settings.screenLockTimeout = 300;
_global.settings.screenLockPin = "";
			
_global.settings.screenLockDisplay = "logo";
_global.settings.screenLockPhotoPath = "";
_global.settings.screenLockPhotoScale = "noscale";
_global.settings.screenLockPhotoRotate = 5;

_global.settings.adminPin = "4321";
_global.settings.cachePinTime = 360;

_global.settings.defaultFont = "helvetica";

_global.settings.applicationBg = 0x52688D;

_global.settings.globalBtnClickTimer = 500;
			
_global.settings.windowAutoCloseTime = 360;

_global.settings.windowWidth = 400;
_global.settings.windowHeight = 420;
_global.settings.windowFont = "helvetica";
_global.settings.windowBgOpacity = 100;
_global.settings.windowBgColour1 = 0x476390;
_global.settings.windowBgColour2 = 0x445C85;
_global.settings.windowShadowOffset = 2;
_global.settings.windowCornerRadius = 10;
_global.settings.windowBorderColour = 0xFFFFFF;
_global.settings.windowBorderWidth = 0;

_global.settings.tabBgOpacity = 100;
_global.settings.tabOnColour = 0x597096;
_global.settings.tabOffColour = 0x3B5887;
_global.settings.tabOffAlpha = 70;
_global.settings.tabPosition = "left";
_global.settings.tabWidth = 50; // 100
_global.settings.tabHeight = 50; // 30
_global.settings.tabSpacing = 5;
_global.settings.tabCornerRadius = 10;
_global.settings.tabContentPadding = 10;
_global.settings.tabGreyWhenOff = true;
_global.settings.tabDisplayAs = "icons"; // labels
_global.settings.tabFont = "helvetica";
_global.settings.tabFontColour = 0xFFFFFF;
_global.settings.tabFontSize = 14;

_global.settings.buttonBgColour = 0x7C90B0;
_global.settings.buttonBorderColour = 0x95A7C4;
_global.settings.buttonFont = "helvetica";
_global.settings.buttonAlign = "center";
_global.settings.buttonFontColour = 0xFFFFFF;
_global.settings.buttonFontSize = 16;

_global.settings.labelFont = "helvetica";
_global.settings.labelFontColour = 0xFFFFFF;
_global.settings.labelFontSize = 16;

_global.settings.listBgOpacity = 100;
_global.settings.listBgColour = 0x6E82A6;
_global.settings.listCornerRadius = 10;
_global.settings.listPadding = 2;
_global.settings.listItemFont = "helvetica";
_global.settings.listItemFontColour = 0xFFFFFF;
_global.settings.listItemFontSize = 14;
_global.settings.listItemBgOpacity = 100;
_global.settings.listItemBgColour1 = 0x98A6BE;
_global.settings.listItemBgColour2 = 0x45608D;
_global.settings.listItemHeight = 30;
_global.settings.listItemSpacing = 0;
_global.settings.listItemCornerRadius = 0;

_global.settings.titleX = 6;
_global.settings.titleY = 10;
_global.settings.titleFont = "helvetica";
_global.settings.titleFontSize = 19;
_global.settings.titleFontColour = 0xFFFFFF;
			
_global.settings.dateX = 6;
_global.settings.dateY = 10;
_global.settings.dateFontSize = 19;
_global.settings.dateFontColour = 0xFFFFFF;
			
_global.settings.statusBarX = 5;
_global.settings.statusBarY = 52;
_global.settings.statusBarBtnWidth = 48;
_global.settings.statusBarBtnHeight = 48;
_global.settings.statusBarBtnSpacing = 5;
_global.settings.statusBarBtnFadeRate = 45;
			
_global.settings.appsBarX = 2;
_global.settings.appsBarY = 52;
_global.settings.appsBarBtnWidth = 48;
_global.settings.appsBarBtnHeight = 48;
_global.settings.appsBarBtnSpacing = 5;
			
_global.settings.miniAlertBtnPadding = 2;
_global.settings.miniAlertBtnBg = 0x829ECB;
_global.settings.miniAlertBtnFadeInTime = 100;
_global.settings.miniAlertBtnFadeOutTime = 200;
			
_global.settings.macroBtnWidth = 110;
_global.settings.macroBtnHeight = 35;
_global.settings.macroBtnSpacing = 5;
_global.settings.macroBtnFontSize = 14;
_global.settings.macroListY = 12;
			
_global.settings.zonesX = 0;
_global.settings.zonesY = 105;
			
_global.settings.zoneLabelsX = 12;
_global.settings.zoneLabelsY = 12;
_global.settings.zoneBtnFontSize = 16;
_global.settings.zoneBtnWidth = 130;
_global.settings.zoneBtnHeight = 26;
_global.settings.zoneBtnSpacing = 8;
			
_global.settings.zoneDoorColour = 0xCC3333;
			
_global.settings.zoneBg = 0xFFCC00;
			
_global.settings.zoneChangeTimeout = 10;
_global.settings.zoneChangeTime = 15;
_global.settings.zoneFadeRate = 50;

_global.settings.roomHighlightTime = .5; // seconds
_global.settings.roomFadeRate = 0; // seconds
			
_global.settings.controlButtonSpacing = 2;
_global.settings.controlButtonHeight = 45;
_global.settings.controlButtonLabelColour = 0x042D70;
_global.settings.controlButtonLabelFontSize = 18;

_global.settings.showDropShadows = false;
_global.settings.dropShadowFilterBig = new DropShadowFilter(0, 0, 0x000000, 5, 8, 8, 1, 1);
_global.settings.dropShadowFilterMedium = new DropShadowFilter(0, 0, 0x000000, 5, 3, 3, 1, 2);
_global.settings.dropShadowFilterSmall = new DropShadowFilter(0, 0, 0x000000, 20, 2, 2, 1, 2);

_global.settings.modalBlur = false;

_global.settings.calendarCanEdit = "superuser";
			
_global.settings.shortTimeFormat = "HH:nn";
_global.settings.longTimeFormat = "HH:nn:ss";
_global.settings.longDateFormat = "d-mmm-yyyy";
_global.settings.clockFormat = "H:nn dddd, d mmmm yyyy";

_global.settings.defaultBrowserURL = "http://www.google.com/";

_global.settings.enableTVButton = true;