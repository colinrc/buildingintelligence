_global.lastPressed = getTimer();
MovieClip.prototype.addProperty("onPress2", 
	function () {
		return this.$onPress;
	}, 
	function (func) {
		this.$onPress = func;
		this.lastPressed = getTimer();
		this.onPress = function () {
			if (this.debounce == undefined) this.debounce = _global.settings.globalBtnClickTimer;
			if (!_global.systemBusy && getTimer() >= (_global.lastPressed + this.debounce)) {
				this.$onPress();
				if (this.sound != undefined) {
					_global.sounds[this.sound].start();
				} else {
					_global.sounds["default"].start();
				}
				_global.lastPressed = getTimer();
			}
		}
	}
)

createLabel = function (item_mc, settings) {
	var label_tf = new TextFormat();
	label_tf.color = 0xFFFFFF;
	label_tf.size = 14;
	label_tf.bold = true;
	label_tf.font = "globalFont";
	
	item_mc.createTextField("label_txt", 10, 0, 0, settings.w, 20);
	var label_txt = item_mc.label_txt;
	label_txt.embedFonts = true;
	label_txt.selectable = false;
	label_txt.setNewTextFormat(label_tf);
	label_txt.text = settings.label;
	
	var dropShadow = new DropShadowFilter(0, 0, 0x000000, 10, 4, 4, 1);
	label_txt.filters = [dropShadow];
}

updateKey = function (key, state, value, force) {
	var control = _global.controls[key];
	var changed = false;
	
	if (typeof(value) == "object") {
		var valueRest = value.slice(1);
		var value = value[0];
	}
	
	if (control.state != state) {
		control.state = state;
		if (state == "on" || state == "off") {
			control.storedStates["state"] = state;
		}
		changed = true; 
	}

	if (value != undefined && control.value != value) {
		control.value = value;
		control.storedStates[state] = value;
		changed = true;
	}

	if (changed || force) {
		broadcastChange(key);
	}
}

broadcastChange = function (key) {
	//debug("broadcasting for " + key + ":")
	var control = _global.controls[key];
	for (var subscriber=0; subscriber<control.subscribers.length; subscriber++) {
		eval(control.subscribers[subscriber]).update(key, control.state, control.value);
		//debug(" - " + control.subscribers[subscriber])
	}
}

subscribe = function (keys, movieClip, sendCurrentState) {
	if (typeof(keys) == "string") keys = keys.split(",");
	for (var q=0; q<keys.length; q++) {
		var key = keys[q];
		if (_global.controls[key] == undefined) {
			_global.controls[key] = new Object();
			_global.controls[key].key = key;
		}
		if (_global.controls[key].subscribers == undefined) _global.controls[key].subscribers = new Array();
		var subscribers = _global.controls[key].subscribers;
		var i = subscribers.length;
		while (i--) {
			if (subscribers[i] == movieClip) break;
		}
		subscribers.push(movieClip);
	}
	if (sendCurrentState) movieClip.update(key, _global.controls[key].state, _global.controls[key].value);
}

createSlider = function (item_mc, settings) {
	var bg_mc = item_mc.createEmptyMovieClip("bg_mc",0);
	bg_mc.beginFill(0x829ECB);
	bg_mc.drawRect(0, 0, settings.w, settings.h, 4);
	bg_mc.endFill();
	
	var slider_mc = item_mc.createEmptyMovieClip("slider_mc", 50);
	slider_mc.width = settings.w - 4;
	var padding = 2;
	slider_mc._x = slider_mc._y = padding;
		
	var handle_mc = slider_mc.createEmptyMovieClip("handle_mc",10);
	var iconOn_mc = handle_mc.attachMovie("bi.ui.Icon", "iconOn_mc", 10, {iconName:item_mc.icons[1], size:settings.h - (padding * 2)});
	var iconOff_mc = handle_mc.attachMovie("bi.ui.Icon", "iconOff_mc", 0, {iconName:item_mc.icons[0], size:settings.h - (padding * 2)});
	
	bg_mc.onPress2 = function () {
		var value = Math.round(this._xmouse / (this._width - (this._width * 0.2)) * 10) * 10;
		if (value >= 0 && value <= 100) updateKey(this._parent.key, "on", value);
	}
	
	item_mc.setPercent = function (value) {
		this.slider_mc.handle_mc._x = Math.round((this.slider_mc.width - this.slider_mc.handle_mc._width) * (value / 100));	
	}
	/*
	slider_mc.onPress2 = function () {
		this.onMouseMove = function () {
			var value = Math.round(this._xmouse / (this._parent.width - 4) * 10) * 10;
			if (value >= 0 && value <= 100) updateKey(this._parent.key, "on", value);
		}
		this.onMouseMove();
	}
	slider_mc.onRelease = slider_mc.onDragOut = function () {
		delete this.onMouseMove;
	}
	*/
}

import flash.display.BitmapData;

#include "../../elife client/standalone/include/drawRect.as"
#include "../../elife client/standalone/include/parseXML.as"
#include "../../elife client/standalone/include/renderControl.as"
#include "../../elife client/standalone/include/openRoomControl.as"
#include "../../elife client/standalone/include/defaults.as"

_global.controls = new Object();
_global.controlTypes = new Object();
_global.icons = new Object();
_global.zones = [new Array()];
_global.zones[0].rooms = [new Array()];
_global.zones[0].rooms[0].name = "Preview";
_global.zones[0].rooms[0].window = new Object();

setWindowData = function (w, h, window) {
	//trace("set window data");
	var windowObj = new Object()
	windowObj.width = w;
	windowObj.height = h;
	windowObj.title = "";
	windowObj.bgOpacity = _global.settings.windowBgOpacity;
	windowObj.bgColour1 = _global.settings.windowBgColour1;
	windowObj.bgColour2 = _global.settings.windowBgColour2;
	windowObj.bgOpacity = _global.settings.windowBgOpacity;
	windowObj.shadowOffset = _global.settings.windowShadowOffset;
	windowObj.cornerRadius = _global.settings.windowCornerRadius;
	windowObj.borderColour = _global.settings.windowBorderColour;
	windowObj.borderWidth = _global.settings.windowBorderWidth;
	windowObj.hideClose = true;
		
	attachMovie("bi.ui.Window", "window_mc", 10, windowObj);
	
	defineWindow(window.firstChild, 0, 0);
}

setControlTypeData = function (controlTypes) {
	//trace("set control data");
	defineControlTypes(controlTypes.firstChild.childNodes);
}

loadIcons = function () {
	//trace("load icons");
	var st = getTimer();
	var iconLoader_mc = _root.createEmptyMovieClip("iconLoader_mc", -9999);
	loader = new MovieClipLoader();
	loader.addListener(loader);
	loader.onLoadInit = function (mc) {
		_global.icons[mc._name] = new BitmapData(mc._width, mc._height, true, 0x00FFFFFF);
		_global.icons[mc._name].draw(mc);
		mc.removeMovieClip();
		this.loadCounter--;
		if (this.loadCounter == 0) {
			//trace("time to load " + _global.iconNames.length + " icons: " + (getTimer() - st) + "ms");
			iconLoader_mc.removeMovieClip();
			openRoomControl(_global.zones[0].rooms[0]);
		}
	}
	loader.loadPointer = 0;
	loader.loadCounter = 0;
	loader.loadNext = function () {
		var name = _global.iconNames[this.loadPointer];
		var loadClip_mc = iconLoader_mc.createEmptyMovieClip(name.split(".")[0], this.loadPointer);
		this.loadClip(iconPath + name, loadClip_mc);
		this.loadPointer++;
		this.loadCounter++;
		if (this.loadPointer < _global.iconNames.length) {
			this.loadNext();
		}
	}
	
	// load the list of icons and store them into the icon objects
	var loadIconList = new LoadVars();
	loadIconList.load(iconPath + "_icons.txt");
	loadIconList.onData = function (src) {
		_global.iconNames = src.split(chr(13) + chr(10));
		loader.loadNext();
	}
}

setIconPath = function (path) {
	iconPath = path;	
	loadIcons();
}

setControlTypeData(controlTypeData);
setWindowData(width, height, windowData);
setIconPath(iconPath);