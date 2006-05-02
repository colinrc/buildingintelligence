﻿openRoomControl = function (room, roomPoly) {
	var windowObject = new Object();
	windowObject.title = room.name;
	windowObject.iconName = statusObj.icon;
	
	for (var attr in room.window) {
		if (attr.substr(0, 6) == "window") {
			//trace(attr + ":" + room.window[attr]);
			if (room.window[attr] == Number(room.window[attr])) {
				windowObject[attr.substr(6, 1).toLowerCase() + attr.substr(7)] = Number(room.window[attr]);
			} else if (room.window[attr] == "true" || room.window[attr] == "false") {
				windowObject[attr.substr(6, 1).toLowerCase() + attr.substr(7)] = (room.windowg[attr] == "true");
			} else {
				windowObject[attr.substr(6, 1).toLowerCase() + attr.substr(7)] = room.window[attr];
			}
		}
	}
	
	var window_mc = showWindow(windowObject);
	
	var tabs = room.window.tabs;
	window_mc.content_mc.groups = room.window.tabs;

	var tabObject = new Object();
	tabObject.width = window_mc.contentClip.width;
	tabObject.height = window_mc.contentClip.height;

	for (var attr in room.window) {
		if (attr.substr(0, 3) == "tab") {
			//trace(attr + ":" + room.window[attr]);
			if (room.window[attr] == Number(room.window[attr])) {
				tabObject[attr] = Number(room.window[attr]);
			} else if (room.window[attr] == "true" || room.window[attr] == "false") {
				tabObject[attr] = (room.window[attr] == "true");
			} else {
				tabObject[attr] = room.window[attr];
			}
		}
	}	
	
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
			//debug("onShow: " + control_mc);
		}
		// fire onHide event to hidden clip
		var controls = this.tabs[eventObj.oldId].controls;
		for (var control=0; control<controls.length; control++) {
			var control_mc = this.contentClips[eventObj.oldId]["control" + control + "_mc"];
			control_mc.onHide();
			//debug("onHide: " + control_mc);
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