openRoomControl = function (room, roomPoly) {
	var windowObject = new Object();
	windowObject.title = room.name;
	windowObject.iconName = statusObj.icon;
	
	if (room.window.windowWidth != undefined) windowObject.width = Number(room.window.windowWidth);
	if (room.window.windowHeight != undefined) windowObject.height = Number(room.window.windowHeight);
	if (room.window.windowBgOpacity != undefined) windowObject.bgOpacity = Number(room.window.windowBgOpacity);
	if (room.window.windowBgColour1 != undefined) windowObject.bgColour1 = Number(room.window.windowBgColour1);
	if (room.window.windowBgColour2 != undefined) windowObject.bgColour2 = Number(room.window.windowBgColour2);
	if (room.window.windowBorderColour != undefined) windowObject.borderColour = Number(room.window.windowBorderColour);
	if (room.window.windowBorderWidth != undefined) windowObject.borderWidth = Number(room.window.windowBorderWidth);
	if (room.window.windowCornerRadius != undefined) windowObject.cornerRadius = Number(room.window.windowCornerRadius);
	if (room.window.windowShadowOffset != undefined) windowObject.shadowOffset = Number(room.window.windowShadowOffset);
	
	showWindow(windowObject);
	
	var tabs = room.window.tabs;
	window_mc.content_mc.groups = room.window.tabs;

	var tabObject = new Object();
	tabObject.width = window_mc.contentClip.width;
	tabObject.height = window_mc.contentClip.height;

	if (room.window.tabOpacity != undefined) tabObject.tabOpacity = room.window.tabBgOpacity;
	if (room.window.tabOnColour != undefined) tabObject.tabOnColour = room.window.tabOnColour;
	if (room.window.tabOffColour != undefined) tabObject.tabOffColour = room.window.tabOffColour;
	if (room.window.tabOffAlpha != undefined) tabObject.tabOffAlpha = room.window.tabOffAlpha;
	if (room.window.tabPosition != undefined) tabObject.tabPosition = room.window.tabPosition;
	if (room.window.tabWidth != undefined) tabObject.tabWidth = room.window.tabWidth;
	if (room.window.tabHeight != undefined) tabObject.tabHeight = room.window.tabHeight;
	if (room.window.tabSpacing != undefined) tabObject.tabSpacing = room.window.tabSpacing;
	if (room.window.cornerRadius != undefined) tabObject.cornerRadius = room.window.tabCornerRadius;
	if (room.window.contentPadding != undefined) tabObject.contentPadding = room.window.tabContentPadding;	
	
	var tabs_mc = window_mc.contentClip.attachMovie("bi.ui.Tabs", "tabs_mc", 0, {settings:tabObject});

	var tab_array = new Array();
	for (var tab=0; tab<tabs.length; tab++) {
		if (tabs[tab].canSee == undefined || isAuthenticated(tabs[tab].canSee)) {
			tab_array.push({name:tabs[tab].name, iconName:tabs[tab].icon});
		}
	}
	tabs_mc.tabData = tab_array;

	var tabCount = 0;
	for (var tab=0; tab<tabs.length; tab++) {
		if (tabs[tab].canSee == undefined || isAuthenticated(tabs[tab].canSee)) {
			var controls = tabs[tab].controls;
			var lastY = 0;
			var controlCount = 0;
			for (var control=0; control<controls.length; control++) {
				if (controls[control].canSee == undefined || isAuthenticated(controls[control].canSee)) {
					var control_mc = tabs_mc.contentClips[tabCount].createEmptyMovieClip("control" + controlCount + "_mc", controlCount);
					renderControl(controls[control], control_mc, window_mc.contentClip.tabs_mc.contentClips[0].width);
					subscribe(controls[control].key, control_mc);
					control_mc._y = lastY;
					lastY += control_mc._height + 8;
					controlCount++;
				}
			}
			tabCount++;
		}
	}
	
	tabs_mc.originalTitle = room.name;
	tabs_mc.tabs = tabs;
	tabs_mc.changeTab = function (eventObj) {
		// set window title
		this._parent._parent.title = this.originalTitle + ": " + eventObj.name;
		// fire onShow event to active clip
		var controls = this.tabs[eventObj.id].controls;
		for (var control=0; control<controls.length; control++) {
			var control_mc = this.contentClips[eventObj.id]["control" + control + "_mc"];
			control_mc.onShow();
			//trace("onShow: " + control_mc);
		}
		// fire onHide event to hidden clip
		var controls = this.tabs[eventObj.oldId].controls;
		for (var control=0; control<controls.length; control++) {
			var control_mc = this.contentClips[eventObj.oldId]["control" + control + "_mc"];
			control_mc.onHide();
			//trace("onHide: " + control_mc);
		}
	}
	tabs_mc.addEventListener("changeTab", tabs_mc);
	tabs_mc.activeTab = 0;
	
	window_mc.onClose = function () {
		var tabs = this.contentClip.tabs_mc.tabs;
		for (var tab=0; tab<tabs.length; tab++) {
			var controls = tabs[tab].controls;
			for (var control=0; control<controls.length; control++) {
				unsubscribe(controls[control].key, this.content_mc["tab" + tab + "_mc"].tabContent_mc["control" + control + "_mc"]);
				this.contentClip.tabs_mc.contentClips[tab]["control" + control + "_mc"].onClose();
			}
		}
	}
}