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
					_global.sounds[this.sound].start(0,1);
				} else {
					_global.sounds["default"].start(0,1);
				}
				_global.lastPressed = getTimer();
			}
		}
	}
)

_global.zones = new Array();
_global.alerts = new Array();
_global.statusBar = new Array();
_global.logging = new Array();
_global.appsBar = new Array();
_global.macros = new Array();
_global.macroStatus = new Array();
_global.scripts = new Array();
_global.controls = new Object();
_global.controlTypes = new Object();
_global.calendarData = new Array();
_global.windows = new Array();
_global.sounds = new Object();
_global.icons = new Array();
_global.controlPanelApps = new Array();
_global.tv = new Object();

_global.settings.applicationWidth = Stage.width;
_global.settings.applicationHeight = Stage.height;

createObjects = function () {
	// create modal blocker
	modal_mc.beginFill(0x000000, 30);
	modal_mc.drawRect(0, 0, _global.settings.applicationWidth, _global.settings.applicationHeight);
	modal_mc.endFill();
	modal_mc.onPress = function () {};
	modal_mc.useHandCursor = false;
	modal_mc._visible = false;

	// create mega modal blocker
	megaModal_mc.beginFill(0x000000, 45);
	megaModal_mc.drawRect(0, 0, _global.settings.applicationWidth, _global.settings.applicationHeight);
	megaModal_mc.endFill();
	megaModal_mc.onPress = function () {};
	megaModal_mc.useHandCursor = false;
	megaModal_mc._visible = false;
	
	// set up window
	window_mc.attachMovie("closeBtn","close_btn", 20);
	window_mc.close_btn.onPress2 = function () {
		this.gotoAndStop(2);
		this.onEnterFrame = function () {
			this._parent.close();
			delete this.onEnterFrame;
		}
	}
	window_mc.close = function () {
		delete window_mc.onMouseMove;
		this.gotoAndStop(1);
		this._visible = false;
		modal_mc._visible = false;
		megaModal_mc._visible = false;
		clearInterval(this.closeWindowID);
		this.onClose();
		this.content_mc.removeMovieClip();
	}
	window_mc.createTextField("title_txt", 30, 10, window_mc.close_btn._height / 2 - 4, 10, 22);
	var title_tf = new TextFormat();
	title_tf.color = 0xFFFFFF;
	title_tf.size = 18;
	title_tf.bold = true;
	title_tf.font = "globalFont";
	window_mc.title_txt.embedFonts = true;
	window_mc.title_txt.selectable = false;
	window_mc.title_txt.setNewTextFormat(title_tf);
	window_mc.setTitle = function (title) {
		this.title_txt.text = title;
	}
	
	var icon_mc = window_mc.attachMovie("Icon", "icon_mc", 35, {height:28});
	icon_mc._x = 10;
	icon_mc._y = window_mc.title_txt._y;
	icon_mc._visible = false;

	window_mc._visible = false;
}

confirm = function (msg, scope, onYes, onNo) {
	var window_mc = confirm_mc.createEmptyMovieClip("bg_mc", 10);
	megaModal_mc._visible = true;

	var bg_mc = window_mc.createEmptyMovieClip("bg_mc", 10);
	bg_mc.lineStyle(2, 0xFFFFFF);
	bg_mc.beginFill(0x043B96);
	bg_mc.drawRect(0, 0, 300, 150, 10);
	bg_mc.endFill();
	
	window_mc.createTextField("content_txt", 20, 10, 0, bg_mc._width - 10, 10);
	var content_txt = window_mc.content_txt;
	
	var content_tf = new TextFormat();
	content_tf.color = 0xFFFFFF;
	content_tf.size = 16;
	content_tf.bold = true;
	content_tf.font = "globalFont";
	content_tf.align = "center";
	
	content_txt.embedFonts = true;
	content_txt.selectable = false;
	content_txt.multiline = true;
	content_txt.wordWrap = true;
	content_txt.autoSize = true;
	content_txt.setNewTextFormat(content_tf);
	content_txt.text = msg;
	content_txt._x = Math.round((bg_mc._width / 2) - (content_txt._width / 2));
	content_txt._y = Math.round(((bg_mc._height - 40) / 2) - (content_txt.textHeight / 2));
	
	var buttons_mc = window_mc.createEmptyMovieClip("buttons_mc", 30);
	buttons_mc.scope = scope;
	var yes_mc = buttons_mc.attachMovie("Button", "yes_mc", 5, {width:60, height:35, label:"Yes", fontSize:14});
	yes_mc.func = onYes;
	yes_mc.buttonDown = function () {
		trace(this._parent.scope +":"+this.func);
		this._parent.scope[this.func]();
		this._parent._parent.removeMovieClip();
		megaModal_mc._visible = false;
	}
	var no_mc = buttons_mc.attachMovie("Button", "no_mc", 10, {width:60, height:35, label:"No", fontSize:14});
	no_mc._x = 80;
	no_mc.func = onNo;
	no_mc.buttonDown = function () {
		this._parent.scope[this.func]();
		this._parent._parent.removeMovieClip();
		megaModal_mc._visible = false;
	}
	buttons_mc._x = Math.round((bg_mc._width / 2) - (buttons_mc._width / 2));
	buttons_mc._y = 110;
	
	window_mc._x = Math.round(((_global.settings.applicationWidth - 121) / 2) - (bg_mc._width / 2));
	window_mc._y = Math.round(((_global.settings.applicationHeight - 104) / 2) - (bg_mc._height / 2)) + 104;
}
	
showMessageWindow = function (msgObj) {
	var width = (msgObj.width == undefined) ? 450 : msgObj.width;
	var height = (msgObj.height == undefined) ? 300 : msgObj.height;
	showWindow(width, height, msgObj.title, msgObj.icon, true, msgObj.hideClose, true);

	// set autoclose for this window if required
	if (msgObj.autoClose > 1) {
		window_mc.countDown = new Object();
		window_mc.countDown.counter = msgObj.autoClose;
		window_mc.countDown.content = msgObj.content;
		window_mc.countDown.update = function () {
			this.counter--;
			var timeSuffix = (this.counter <> 1) ? "seconds" : "second";
			window_mc.content_mc.content_txt.text = this.content.split("%t%").join(this.counter + " " + timeSuffix);
			if (this.counter == 0) {
				window_mc.close();
				delete window_mc.countDown;
			}
		}
		delete window_mc.onMouseMove;
		clearInterval(window_mc.closeWindowID);
		window_mc.closeWindowID = setInterval(window_mc.countDown, "update", 1000);
	}
	
	if (msgObj.content.length) {
		window_mc.content_mc.createTextField("content_txt", 10, 0, 0, width - 15, 1);
		var content_txt = window_mc.content_mc.content_txt;
		
		var content_tf = new TextFormat();
		content_tf.color = 0xFFFFFF;
		content_tf.size = 14;
		content_tf.bold = true;
		content_tf.font = "globalFont";
		content_tf.align = "center";
		
		content_txt.embedFonts = true;
		content_txt.selectable = false;
		content_txt.multiline = true;
		content_txt.wordWrap = true;
		content_txt.autoSize = true;
		content_txt.setNewTextFormat(content_tf);
		if (msgObj.autoClose == 0 || msgObj.autoClose == undefined) {
			content_txt.text = msgObj.content;
		} else {
			window_mc.countDown.update();
		}
	
		content_txt._y = Math.round((window_mc.content_mc.height / 2) - (content_txt._height / 2));
	} else if (msgObj.video != undefined) {
		renderControl({type:msgObj.video}, window_mc.content_mc, window_mc.content_mc.width);
	}
}

showKeyboard = function (limit, onClose, callerObj, initial, password, title, type) {
	createKeyboard(type);
	megaModal_mc._visible = true;
	keyboard_mc._visible = true;
	keyboard_mc.password = true;
	keyboard_mc.title = title;
	keyboard_mc.inputArea_mc.inputField_txt.maxChars = limit;
	keyboard_mc.inputArea_mc.inputField_txt.text = (initial != undefined) ? initial : "";
	keyboard_mc.inputArea_mc.inputField_txt.scrollRight();
	keyboard_mc.inputArea_mc.inputField_txt.password = password;
	keyboard_mc.onClose = onClose;
	keyboard_mc.callerObj = callerObj;
}

hideKeyboard = function () {
	megaModal_mc._visible = false;
	keyboard_mc._visible = false;
}

createKeyboard = function (type) {
	if (type == "pin") {
		var keyboard = "1,2,3;4,5,6;7,8,9;*,0,#;clear,ok";
	} else if (type == "web") {
		var keyboard = "1,2,3,4,5,6,7,8,9,0,/;q,w,e,r,t,y,u,i,o,p,';http://,a,s,d,f,g,h,j,k,l,:;www.,z,x,c,v,b,n,m,.,clear,del;.com,.au,shift,space,ok";
	} else {
		var keyboard = "1,2,3,4,5,6,7,8,9,0,!;q,w,e,r,t,y,u,i,o,p,';a,s,d,f,g,h,j,k,l,:;clear,z,x,c,v,b,n,m,.,del;shift,space,ok";
	}
	
	var keys_mc = keyboard_mc.createEmptyMovieClip("keys_mc", 100);

	var buttonWidth = buttonHeight = 50;
	var buttonSpacing = 2;

	keys_mc._x = keys_mc._y = buttonSpacing;
	keys_mc._x += 3;
	keys_mc._y += 50;
	
	var rows = keyboard.split(";");
	var counter = 0;
	for (var row=0; row<rows.length; row++) {
		var keys = rows[row].split(",");
		var row_mc = keys_mc.createEmptyMovieClip("row" + row + "_mc", row);
		var currentX = 0;
		for (var key=0; key<keys.length; key++) {
			var realWidth = buttonWidth;
			if (keys[key] == "space") {
				realWidth = (buttonWidth + buttonSpacing) * 5 - buttonSpacing;
				var key_mc = row_mc.attachMovie("Button", "key" + key + "_mc", key, {width:realWidth, height:buttonHeight, label:keys[key].toUpperCase(), fontSize:13});
				key_mc.buttonDown = function () {
					var inputField_txt = this.keyboard_mc.inputArea_mc.inputField_txt;
					if (inputField_txt.length < inputField_txt.maxChars) inputField_txt.text += " ";
					inputField_txt.scrollRight();
				}
			} else if (keys[key] == "del") {
				var key_mc = row_mc.attachMovie("Button", "key" + key + "_mc", key, {width:buttonWidth, height:buttonHeight, label:keys[key].toUpperCase(), fontSize:13});
				key_mc.buttonDown = function () {
					var inputField_txt = this.keyboard_mc.inputArea_mc.inputField_txt;
					inputField_txt.text = inputField_txt.text.substr(0, inputField_txt.length - 1);
					inputField_txt.scrollRight();
				}
			} else if (keys[key] == "clear") {
				var key_mc = row_mc.attachMovie("Button", "key" + key + "_mc", key, {width:buttonWidth, height:buttonHeight, label:keys[key].toUpperCase(), fontSize:13});
				key_mc.buttonDown = function () {
					var inputField_txt = this.keyboard_mc.inputArea_mc.inputField_txt;
					inputField_txt.text = "";
				}
			} else if (keys[key] == "ok") {
				realWidth = (buttonWidth + buttonSpacing) * 2 - buttonSpacing;
				var key_mc = row_mc.attachMovie("Button", "key" + key + "_mc", key, {width:realWidth, height:buttonHeight, label:keys[key].toUpperCase(), fontSize:13});
				key_mc.buttonDown = function () {
					var inputField_txt = this.keyboard_mc.inputArea_mc.inputField_txt;
					this.keyboard_mc.onClose(inputField_txt.text, this.keyboard_mc.callerObj);
					hideKeyboard();
				}
			} else if (keys[key] == "shift") {
				realWidth = (buttonWidth + buttonSpacing)* 2 - buttonSpacing;
				var key_mc = row_mc.attachMovie("Button", "key" + key + "_mc", key, {width:realWidth, height:buttonHeight, label:keys[key].toUpperCase(), fontSize:13});
				key_mc.buttonDown = function () {
					this.keyboard_mc.useShift = true;
				}
			} else {
				var key_mc = row_mc.attachMovie("Button", "key" + key + "_mc", key, {width:buttonWidth, height:buttonHeight, label:keys[key].toLowerCase(), fontSize:13});
				key_mc.buttonDown = function () {
					var inputField_txt = this.keyboard_mc.inputArea_mc.inputField_txt;
					if (inputField_txt.length < inputField_txt.maxChars) {
						if (this.keyboard_mc.useShift) {
							inputField_txt.text += this.label_txt.text.toUpperCase();
							this.keyboard_mc.useShift = false;
						} else {
							inputField_txt.text += this.label_txt.text.toLowerCase();
						}
						inputField_txt.scrollRight();
					}
				}
			}
			key_mc.keyboard_mc = keyboard_mc;
			key_mc._x = currentX;
			key_mc.debounce = 0;
			currentX += realWidth + buttonSpacing;
			key_mc._y = (buttonHeight + buttonSpacing) * row;
		}
		row_mc._x = Math.round((keys_mc._width / 2) - (row_mc._width / 2));
	}
	
	var w = keys_mc._width + buttonSpacing + 9;
	var h = keys_mc._height + buttonSpacing + 56;

	var bg_mc = keyboard_mc.createEmptyMovieClip("bg_mc", 10);
	bg_mc.lineStyle(2, 0xFFFFFF);
	bg_mc.beginFill(0x043B96);
	bg_mc.drawRect(0, 0, w, h, 10);
	bg_mc.endFill();
	
	var close_btn = keyboard_mc.attachMovie("closeBtn","close_btn", 80);
	close_btn._x = w - close_btn._width + 2;
	close_btn._y = 7;
	close_btn.onPress2 = function () {
		this.gotoAndStop(2);
		this._parent.onClose("", this._parent.callerObj);
		hideKeyboard();
	}

	
	var inputArea_mc = keyboard_mc.createEmptyMovieClip("inputArea_mc", 200);
	inputArea_mc.createEmptyMovieClip("bg_mc", 10);
	inputArea_mc.bg_mc.lineStyle(2, 0x91A7CD);
	inputArea_mc.bg_mc.beginFill(0x24519B);
	inputArea_mc.bg_mc.drawRect(0, 0, keyboard_mc._width - 62, 40, 10);
	inputArea_mc.bg_mc.endFill();
	inputArea_mc.createTextField("inputField_txt", 20, 5, 0, inputArea_mc._width - 15, inputArea_mc._height);
	inputArea_mc._x = inputArea_mc._y = 6;
	
	var label_tf = new TextFormat();
	label_tf.color = 0xFFFFFF;
	label_tf.size = 28;
	label_tf.bold = true;
	label_tf.align = "center";
	label_tf.font = "globalFont";
	
	inputArea_mc.inputField_txt.embedFonts = true;
	inputArea_mc.inputField_txt.selectable = false;
	
	inputArea_mc.inputField_txt.setNewTextFormat(label_tf);
	
	inputArea_mc.inputField_txt.scrollRight = function () {
		this.hscroll = this.maxhscroll;
		this.background = false;
	}
	
	keyboard_mc._x = Math.round((_global.settings.applicationWidth / 2) - (w / 2));
	keyboard_mc._y = Math.round(((_global.settings.applicationHeight - 100) / 2) - (h / 2)) + 100;
	
	keyboard_mc._visible = false;
}

showWindow = function (w, h, title, icon, megaModal, hideClose, noAutoClose) {
	if (window_mc._visible) window_mc.close();
	delete window_mc.onClose;
	
	if (w == "full") {
		w = _global.settings.applicationWidth;
		var x = 0;
	} else if (h == "map") {
		w = _global.settings.applicationWidth - 120;
		var x = 0;
	} else {
		var x = Math.round(((_global.settings.applicationWidth - 120) / 2) - (w / 2));
	}
	if (h == "full") {
		h = _global.settings.applicationHeight - 48;
		var y = 48;	
	} else if (h == "map") {
		h = _global.settings.applicationHeight - 104;
		var y = 104;	
	} else {
		var y = Math.round(((_global.settings.applicationHeight - 104) / 2) - (h / 2)) + 104;
	}
	
	window_mc._visible = true;
	modal_mc._visible = true;
	
	window_mc.close_btn.gotoAndStop(1);
	window_mc.title_txt._width = w - window_mc.close_btn._width - 20;
	window_mc.setTitle(title);

	window_mc.close_btn._visible = !hideClose;
	megaModal_mc._visible = megaModal;
	
	if (icon != undefined) {
		window_mc.icon_mc.showIcon(icon);
		window_mc.icon_mc._visible = true;
		window_mc.title_txt._x = 45;
	} else {
		window_mc.icon_mc._visible = false;
		window_mc.title_txt._x = 10;
	}
	
	var offset = 3;
	var shadow_mc = window_mc.createEmptyMovieClip("shadow_mc", 5);
	shadow_mc.beginFill(0x000000, 30);
	shadow_mc.drawRect(offset, offset, w + offset, h + offset, 10);
	shadow_mc.endFill();
	
	var bg_mc = window_mc.createEmptyMovieClip("bg_mc", 10);
	bg_mc.lineStyle(2, 0xFFFFFF, 100);
	bg_mc.beginFill(_global.settings.applicationBg);
	bg_mc.drawRect(0, 0, w, h, 10);
	bg_mc.endFill();

	var content_mc = window_mc.createEmptyMovieClip("content_mc", 100);
	content_mc._x = 10;
	if (title == "" && icon == "") {
		content_mc._y = 10;
		content_mc.height = h - 18;
	} else {
		content_mc._y = 60;
		content_mc.height = h - 68;
	}
	content_mc.width = w - 18;
	
	window_mc.close_btn._y = 8;
	window_mc.close_btn._x = w - window_mc.close_btn._width - window_mc.close_btn._y;

	window_mc._x = x;
	window_mc._y = y;

	if (!noAutoClose) {
		window_mc.onMouseMove = function () {
			clearInterval(this.closeWindowID);
			this.closeWindowID = setInterval(this, "close", _global.settings.windowAutoCloseTime * 1000);
		}
	}
}

renderStatusBar = function () {
	for (var group=0; group<_global.statusBar.length; group++) {
		var group_mc = statusBar_mc.createEmptyMovieClip("group" + group + "_mc", group);
 		var groupObj = group_mc.groupObj = _global.statusBar[group];
		createButton(group_mc, {w:_global.settings.statusBarBtnWidth, h:_global.settings.statusBarBtnHeight, icon:groupObj.icon});
		
		group_mc.hide = function () {
			this.active = false;
			this.onEnterFrame = function () {
				this._alpha = this._alpha - _global.settings.statusBarBtnFadeRate;
				if (this._alpha < 0) {
					this._visible = false;
					this._parent.layout();
					delete this.onEnterFrame;
				}
			}
		}
		group_mc.show = function () {
			this.active = this._visible = true;
			this._parent.layout()
			this.onEnterFrame = function () {
				this._alpha = this._alpha + _global.settings.statusBarBtnFadeRate;
				if (this._alpha > 100) {;
					delete this.onEnterFrame;
				}
			}
		}
		group_mc.update = function (key, state, extra) {
			if (state == this.groupObj.show && !this.active) {
				this.show();
			} else if (state == this.groupObj.hide && this.active) {
				for (var control=0; control<this.groupObj.controls.length; control++) {
					if (_global.controls[this.groupObj.controls[control].key].storedStates["state"] == this.groupObj.show) {
						return;
					}
				}
				this.hide();
			}
		}
		group_mc._alpha = 0;
		group_mc.active = false;
		group_mc._visible = false;
		var keys = new Array();
		for (var control=0; control<groupObj.controls.length; control++) {
			keys.push(groupObj.controls[control].key)
		}
		subscribe(keys, group_mc);
		
		group_mc.buttonDown = function () {
			if (this.groupObj.canOpen == undefined || isAuthenticated(this.groupObj.canOpen)) openStatusWindow(this.groupObj);
		}
	}
	statusBar_mc.layout = function () {
		var groupCount = 0;
		for (var group=0; group<_global.statusBar.length; group++) {
			var group_mc = this["group" + group + "_mc"];
			if (group_mc._visible) {
				group_mc._x = (_global.settings.statusBarBtnWidth + _global.settings.statusBarBtnSpacing) * groupCount;
				groupCount++;
			}
		}
	}
	statusBar_mc.layout();
}

renderAppsBar = function () {
	for (var icon=0; icon<_global.appsBar.length; icon++) {
		var iconObj = _global.appsBar[icon];
		var icon_mc = appsBar_mc.createEmptyMovieClip(iconObj.func + "_mc", icon);
		createButton(icon_mc, {w:_global.settings.appsBarBtnWidth, h:_global.settings.appsBarBtnHeight, icon:iconObj.icon});
		icon_mc.func = iconObj.func;
		icon_mc.program = iconObj.program;
		icon_mc.canOpen = iconObj.canOpen;
		icon_mc.showOn = true;
		
		icon_mc.buttonDown = function () {
			if (_global.windows[this.func] == undefined && this.canOpen == "superuser" && !isAuthenticated("superuser")) {
				//openPinPad(authenticateUser, this.func);
				this.hideHighlight();
				return;
			} else {
				if (this.func == "runexe") {
					mdm.exec(this.program);
					this.hideHighlight();
				} else {
					_root[this.func]();
				}
			}
		}
		icon_mc._x = (_global.settings.appsBarBtnWidth + _global.settings.appsBarBtnSpacing) * icon;
	}
}

setAuthenticated = function (authenticated) {
	clearInterval(autoExpireLogin);
	if (isLoggedIn != authenticated) {
		isLoggedIn = authenticated;
		if (authenticated) {
			appsBar_mc.openAuthentication_mc.setIcon("unlocked");
			autoExpireLogin = setInterval(this, "setAuthenticated", _global.settings.cachePinTime * 1000);
		} else {
			appsBar_mc.openAuthentication_mc.setIcon("locked");
		}
	}
}

isAuthenticated = function (user) {
	return (user == "" || _global.settings.adminPin == "" || isLoggedIn)
}

renderMacroList = function () {
	_root.createEmptyMovieClip("macros_mc", 700);
	macros_mc._x = _global.settings.applicationWidth - _global.settings.macroBtnWidth - _global.settings.macroBtnSpacing;
	macros_mc._y = _global.settings.applicationHeight - _global.settings.macroBtnHeight - _global.settings.macroListY;

	var counter = 0;
	var macro = _global.macros.length;
	while (macro--) {
		if (!_global.macros[macro].status.noToolbar) {
			macros_mc.attachMovie("Button", "macro" + counter + "_mc", macro, {width:_global.settings.macroBtnWidth, height:_global.settings.macroBtnHeight, label:_global.macros[macro].name, fontSize:_global.settings.macroBtnFontSize});
			var macro_mc = macros_mc["macro" + counter + "_mc"];
			macro_mc.macroID = macro;
			
			if (_global.macros[macro].type == "dual") {
				if (_global.macroStatus[macro] == 1) {
					macro_mc.setLabel(_global.macros[macro].controls[1].command);
					macro_mc.macroName = _global.macros[macro].controls[1].command;
					macro_mc.onChangeID = 0;
				} else {
					macro_mc.setLabel(_global.macros[macro].controls[0].command);
					macro_mc.macroName = _global.macros[macro].controls[0].command;
					macro_mc.onChangeID = 1;
				}
				macro_mc.buttonDown = function () {
					if (isAuthenticated("superuser") || !_global.macros[this.macroID].status.isSecure) {
						sendCmd("MACRO", "run", this.macroName);
						_global.macroStatus[this.macroID] = this.onChangeID;
						this.showHighlight();
					}
				}
			} else {
				if (_global.macros[macro].running) {
					macro_mc.showHighlight();
				}
				macro_mc.macroName = _global.macros[macro].name;
				
				macro_mc.buttonDown = function () {
					if (isAuthenticated("superuser") || !_global.macros[this.macroID].status.isSecure) {
						if (_global.macros[this.macroID].running) {
							sendCmd("MACRO", "abort", this.macroName);
							this.hideHighlight();
						} else {
							sendCmd("MACRO", "run", this.macroName);
							this.showHighlight();
						}
					}
				}
			}
			
			macro_mc._y = -(_global.settings.macroBtnHeight + _global.settings.macroBtnSpacing) * counter;
			counter++;
		}
		if (counter == 16) break;
	}
}

renderZones = function () {
	var maxZoneWidth = 0;
	var maxZoneHeight = 0;
	var cycleCount = 0;
	for (var zone=0; zone<_global.zones.length; zone++) {
		var zone_mc = zones_mc.createEmptyMovieClip("zone" + zone + "_mc", zone);
		renderZone(_global.zones[zone], zone_mc);
		
		if (_global.zones[zone].alignment == "center") {
			if (zone_mc._width > maxZoneWidth) maxZoneWidth = zone_mc._width;
			if (zone_mc._height > maxZoneHeight) maxZoneHeight = zone_mc._height;
		}
		
		if (_global.zones[zone].cycle) cycleCount++;

		zone_mc.zoneObj = _global.zones[zone];
		zone_mc._visible = false;
		zone_mc.fadeOut = function (fadeRate) {
			this.fadeRate = fadeRate;
			this.onEnterFrame = function () {
				if (this._alpha > 0) {
					this._alpha = this._alpha - fadeRate;
				} else {
					this._visible = false;
					delete this.onEnterFrame;
				}
			}
		}
		zone_mc.fadeIn = function (fadeRate) {
			this._visible = true;
			this._alpha = 0;
			this.fadeRate = fadeRate;
			this.onEnterFrame = function () {
				if (this._alpha < 100) {
					this._alpha = this._alpha + this.fadeRate;
				} else {
					delete this.onEnterFrame;
				}
			}
		}
		
		if (_global.zones.length > 1) {
			var zoneLabel_mc = zoneLabels_mc.createEmptyMovieClip("zoneLabel" + zone + "_mc", zone);
			createButton(zoneLabel_mc, {w:_global.settings.zoneBtnWidth, h:_global.settings.zoneBtnHeight, label:zones[zone].name, fontSize:_global.settings.zoneBtnFontSize});

			zoneLabel_mc._x = (_global.settings.zoneBtnWidth + _global.settings.zoneBtnSpacing) * zone;

			zoneLabel_mc.zoneId = zone;
			zoneLabel_mc.zoneId = zone;
			zoneLabel_mc.zones_mc = zones_mc;
			zoneLabel_mc.zoneObj = _global.zones[zone]

			zoneLabel_mc.buttonDown = function () {
				if (this.zoneObj.canOpen == undefined || isAuthenticated(this.zoneObj.canOpen)) {
					if (this.zones_mc.currentZone != this.zoneId) {
						this.zones_mc["zone" + this.zones_mc.currentZone + "_mc"]._alpha = 0;
						this.zones_mc["zone" + this.zones_mc.currentZone + "_mc"]._visible = false;
						this.zones_mc["zone" + this.zones_mc.currentZone + "_mc"].panels_mc.onHide();
						this.zones_mc.currentZone = this.zoneId;
						this.zones_mc["zone" + this.zones_mc.currentZone + "_mc"]._alpha = 100;
						this.zones_mc["zone" + this.zones_mc.currentZone + "_mc"]._visible = true;
						this.zones_mc["zone" + this.zones_mc.currentZone + "_mc"].panels_mc.onShow();
						overlay_mc.title_txt.text = _global.zones[this.zones_mc.currentZone].name;
					}
				}
			}
		}
	}
	
	zones_mc.zone0_mc._visible = true;
	overlay_mc.title_txt.text = _global.zones[0].name;
	zones_mc.numZones = _global.zones.length;
	zones_mc.currentZone = 0;

	zones_mc.switchZone = function () {
		var fadeRate = _global.settings.zoneFadeRate;
		this["zone" + this.currentZone + "_mc"].fadeOut(fadeRate);
		this["zone" + this.currentZone + "_mc"]._visible = false;
		this["zone" + this.currentZone + "_mc"]._alpha = 0;
		if (++this.currentZone == this.numZones) this.currentZone = 0;
		while (!_global.zones[this.currentZone].cycle) {
			if (++this.currentZone == this.numZones) this.currentZone = 0;
		}
		this["zone" + this.currentZone + "_mc"].fadeIn(fadeRate);
		this["zone" + this.currentZone + "_mc"]._visible = true;
		overlay_mc.title_txt.text = _global.zones[this.currentZone].name;
	}

	if (cycleCount > 1 && _global.settings.zoneChangeTimeout != "0" && _global.zones.length > 1) {
		zones_mc.zoneChangeID = 0;
		zones_mc.startAutoSwitch = function () {
			clearInterval(this.autoSwitchID);
			this.zoneChangeID = setInterval(this, "switchZone", _global.settings.zoneChangeTime * 1000);
		}
		// setup timer to start zone change on no mouse movement
		zones_mc.autoSwitchID = 0;
		zones_mc.onMouseMove = function () {
			clearInterval(this.zoneChangeID);
			clearInterval(this.autoSwitchID);
			this.autoSwitchID = setInterval(this, "startAutoSwitch", _global.settings.zoneChangeTimeout * 1000)
		}
	}
	for (var zone=0; zone<_global.zones.length; zone++) {
		var zone_mc = zones_mc["zone" + zone + "_mc"];
		if (_global.zones[zone].alignment == "center") {
			zone_mc._x = Math.round(((_global.settings.applicationWidth - 121) / 2) - (maxZoneWidth / 2));
			zone_mc._y = Math.round(((_global.settings.applicationHeight - zones_mc._y) / 2) - (maxZoneHeight / 2));
		}
	}
}

renderZone = function (zone, clip) {
	var rooms_mc = clip.createEmptyMovieClip("rooms_mc", 100);
	var alerts_mc = clip.createEmptyMovieClip("alerts_mc", 300);
	var doors_mc = clip.createEmptyMovieClip("doors_mc", 400);
	var arbitrary_mc = clip.createEmptyMovieClip("arbitrary_mc", 500);
	var panels_mc = clip.createEmptyMovieClip("panels_mc", 600);
	if (zone.map.length) {
		var shadow_mc = clip.createEmptyMovieClip("shadow_mc", 150);
		var map_mc = clip.createEmptyMovieClip("map_mc", 200);
		shadow_mc.loadMovie(_global.settings.mapsLocation + zone.map);
		shadow_mc._x = shadow_mc._y = 1;
		shadow_mc._alpha = 50;
		new Color(shadow_mc).setRGB(0x000000);
		map_mc.loadMovie(_global.settings.mapsLocation + zone.map);
	}
	var rooms = zone.rooms;
	for (var room=0; room<rooms.length; room++) {
		var room_mc = rooms_mc.createEmptyMovieClip("room" + room + "_mc", room);
		room_mc.roomObj = rooms[room];
		var poly = rooms[room].poly.split(",");
		room_mc._x = poly[0]
		room_mc._y = poly[1];
		room_mc.beginFill(_global.settings.zoneBg);
		var realX = 0;
		var realY = 0;
		for (var q=2; q<poly.length; q=q+2) {
			if (poly[q] - poly[0] < realX) realX = poly[q] - poly[0];
			if (poly[q+1] - poly[1] < realY) realY = poly[q+1] - poly[1];
			room_mc.lineTo(poly[q] - poly[0], poly[q+1] - poly[1]);
		}
		room_mc.alertCenterX = room_mc._x + realX + (room_mc._width / 2);
		room_mc.alertCenterY = room_mc._y + realY + (room_mc._height / 2);
		room_mc.moveTo(0, 0);
		room_mc.endFill();
		room_mc._alpha = 0;
		
		if (rooms[room].groups.length) {
			room_mc.onPress2 = function () {
				if (this.roomObj.canOpen == undefined || isAuthenticated(this.roomObj.canOpen)) {
					this._alpha = 100;
					this.onEnterFrame = function () {
						this._alpha = 0;
						openRoomControl(this.roomObj, this);
						delete this.onEnterFrame;
					}
				}
			}
		}

		var alerts = rooms[room].alerts;
		var roomAlerts_mc = alerts_mc.createEmptyMovieClip("roomAlerts" + room + "_mc", room);
		roomAlerts_mc.room_mc = room_mc;
		roomAlerts_mc.alertsObj = rooms[room].alerts;
		roomAlerts_mc.alertsPosObj = rooms[room].alertsPos;
		if (rooms[room].alertsPos.x != undefined) {
			room_mc.alertCenterX = rooms[room].alertsPos.x;
			room_mc.alertCenterY = rooms[room].alertsPos.y;
		}
		for (var alert=0; alert<alerts.length; alert++) {
			var alert_mc = roomAlerts_mc.attachMovie("Icon", "alert" + alert + "_mc", alert + 10, {icon:alerts[alert].icon, height:24});
			alert_mc._y = _global.settings.miniAlertBtnPadding;
			var keys = alerts[alert].keys.split(",");
			alert_mc.keys = keys;
			alert_mc.canSee = alerts[alert].canSee;
			alert_mc.fadeInTime = _global.settings.miniAlertBtnFadeInTime;
			if (alerts[alert].fadeOutTime != undefined) {
				alert_mc.fadeOutTime = alerts[alert].fadeOutTime;
			} else {
				alert_mc.fadeOutTime = _global.settings.miniAlertBtnFadeOutTime;
			}
			alert_mc.hide = function () {
				this.active = false;
				this.startTime = new Date().getTime();
				this.initialAlpha = this._alpha;
				this.onEnterFrame = function () {
					var currentTime = new Date().getTime() - this.startTime;
					if (currentTime < this.fadeOutTime) {
						this._alpha = easeIn(currentTime, this.initialAlpha, -this.initialAlpha, this.fadeOutTime);
					} else {
						this._alpha = 0;
					}
					if (this._alpha <= 0) {
						this._alpha = 0;
						this._visible = false;
						this._parent.layoutAlerts();
						delete this.onEnterFrame;
					}
				}
			}
			alert_mc.show = function () {
				this.active = this._visible = true;
				this._parent.layoutAlerts()
				this.startTime = new Date().getTime();
				this.initialAlpha = this._alpha;
				this.onEnterFrame = function () {
					var currentTime = new Date().getTime() - this.startTime;
					if (currentTime < this.fadeInTime) {
						this._alpha = easeOut(currentTime, this.initialAlpha, 100, this.fadeInTime);
					} else {
						this._alpha = 100;
					}
					if (this._alpha >= 100) {
						this._alpha = 100;
						delete this.onEnterFrame;
					}
				}
			}
			alert_mc.update = function (key, state) {
				if (this.canSee == undefined || isAuthenticated(this.canSee)) {
					if (state == "on" && !this.active) {
						this.show();
					} else if (state == "off" && this.active) {
						for (var key=0; key<this.keys.length; key++) {
							if (_global.controls[this.keys[key]].state == "on") return;
						}
						this.hide();
					} else {
						// think this isn't needed anymore as room control windows subscribe to events by themselves
						//if (this.windowOpen) window_mc.content_mc.refresh();
					}
				} else if (this.active) {
					this.hide();
				}
			}
			alert_mc._alpha = 0;
			alert_mc.active = false;
			alert_mc._visible = false;
			subscribe(keys, alert_mc);
		}
		roomAlerts_mc.layoutAlerts = function () {
			var alertCount = 0;
			for (var alert=0; alert<this.alertsObj.length; alert++) {
				var alert_mc = this["alert" + alert + "_mc"];
				if (alert_mc._visible) {
					if (this.alertsPosObj.layout == "vertical") {
						alert_mc._x = _global.settings.miniAlertBtnPadding;
						alert_mc._y = alert_mc._height * alertCount + _global.settings.miniAlertBtnPadding;
					} else {
						alert_mc._x = alert_mc._width * alertCount + _global.settings.miniAlertBtnPadding;
						alert_mc._y = _global.settings.miniAlertBtnPadding;
					}
					alertCount++;
				}
			}
			var bg_mc = this.createEmptyMovieClip("bg_mc", 0);
			if (alertCount) {
				var padding = _global.settings.miniAlertBtnPadding * 2;

				if (this.alertsPosObj.layout == "vertical") {
					var width = alert_mc._width + padding
					var height = alertCount * alert_mc._height + padding
				} else {
					var width = alertCount * alert_mc._width + padding;
					var height = alert_mc._height + padding;
				}

				bg_mc.beginFill(_global.settings.miniAlertBtnBg);
				bg_mc.drawRect(0, 0, width, height, 5);
				bg_mc.endFill();

				this._x = this.room_mc.alertCenterX - (width / 2);
				this._y = this.room_mc.alertCenterY - (height / 2);
			}
		}
		roomAlerts_mc.layoutAlerts();
		var doors = rooms[room].doors;
		var room_mc = doors_mc.createEmptyMovieClip("room" + room + "_mc", room);
		for (var door=0; door<doors.length; door++) {
			var door_mc = room_mc.createEmptyMovieClip("door" + door + "_mc", door);
			var pos = doors[door].pos;
			if (doors[door].colour != undefined) {
				door_mc.beginFill(_global.settings.zoneDoorColour);
			} else {
				door_mc.beginFill(_global.settings.zoneDoorColour);
			}
			door_mc.drawRect(pos[0], pos[1], pos[2], pos[3]);
			door_mc.endFill();
			door_mc.update = function (key, state, value) {
				this._visible = (state == "on");
			}
			subscribe(doors[door].key, door_mc);
			door_mc.update();
		}
	}
	var panels = zone.panels;
	if (panels.length) {
		panels_mc.panels = panels;
		panels_mc.onShow = function () {
			for (var panel=0; panel<this.panels.length; panel++) {
				this["panel" + panel + "_mc"].onShow();
			}
		}
		panels_mc.onHide = function () {
			for (var panel=0; panel<this.panels.length; panel++) {
				this["panel" + panel + "_mc"].onHide();
			}			
		}
	}
	for (var panel=0; panel<panels.length; panel++) {
		var panel_mc = panels_mc.createEmptyMovieClip("panel" + panel + "_mc", panel);
		panel_mc._x = panels[panel].x;
		panel_mc._y = panels[panel].y;
		var bg_mc = panel_mc.createEmptyMovieClip("bg_mc", 0);
		bg_mc.lineStyle(2, 0xFFFFFF);
		bg_mc.beginFill(0x4E75B5);
		bg_mc.drawRect(0, 0, Number(panels[panel].width), Number(panels[panel].height), 10);
		bg_mc.endFill();

		panel_mc.createTextField("label_txt", 10, 5, 5, 1, 1);
		var label_tf = new TextFormat();
		label_tf.color = 0xFFFFFF;
		label_tf.size = 14;
		label_tf.bold = true;
		label_tf.font = "globalFont";
		
		panel_mc.label_txt.embedFonts = true;
		panel_mc.label_txt.selectable = false;
		panel_mc.label_txt.autoSize = true;
		panel_mc.label_txt.setNewTextFormat(label_tf);
		panel_mc.label_txt.text = panels[panel].name;

		var controls_mc = panel_mc.createEmptyMovieClip("controls_mc", 30);
		controls_mc._x = 5;
		controls_mc._y = 30;
		var controls = panels[panel].controls;
		var lastY = 0;
		for (var control=0; control<controls.length; control++) {
			var control_mc = controls_mc.createEmptyMovieClip("control" + control + "_mc", control);
			renderControl(controls[control], control_mc, panels[panel].width - 10);
			subscribe(controls[control].key, control_mc);
			control_mc._y = lastY;
			lastY += control_mc._height + 8;
		}
		panel_mc.controls = controls;
		panel_mc.onShow = function () {
			for (var control=0; control<this.controls.length; control++) {
				var control_mc = this.controls_mc["control" + control + "_mc"];
				control_mc.onShow();
			}
		}
		panel_mc.onHide = function () {
			for (var control=0; control<this.controls.length; control++) {
				var control_mc = this.controls_mc["control" + control + "_mc"];
				control_mc.onHide();
			}
		}
	}
	var arbitrary = zone.arbitrary;
	for (var item=0; item<arbitrary.length; item++) {
		var item_mc = arbitrary_mc.createEmptyMovieClip("item" + item + "_mc", item);
		switch (arbitrary[item].type) {
			case "label":
				item_mc.createTextField("label_txt", 0, arbitrary[item].x, arbitrary[item].y, 1, 1);
				item_mc.label = arbitrary[item].label;
				
				var label_tf = new TextFormat();
				if (arbitrary[item].fontColour != undefined) {
					label_tf.color = arbitrary[item].fontColour;
				} else {
					label_tf.color = 0xFFFFFF;
				}
				if (arbitrary[item].fontSize != undefined) {
					label_tf.size = arbitrary[item].fontSize;
				} else {
					label_tf.size = 12;
				}
				label_tf.bold = true;
				label_tf.font = "globalFont";
				
				item_mc.label_txt.embedFonts = true;
				item_mc.label_txt.selectable = false;
				item_mc.label_txt.autoSize = true;
				item_mc.label_txt.setNewTextFormat(label_tf);
				item_mc.label_txt.text = arbitrary[item].label;
				item_mc.arbitraryObj = arbitrary[item];
				
				if (arbitrary[item].key != undefined) {
					item_mc.update = function (key, state, value) {
						var txt = this.label;
						if (state != undefined) {
							txt = txt.split("%state%").join(state);
						} else {
							txt = txt.split("%state%").join(this.arbitraryObj.defaultState);
						}
						if (value != undefined) {
							txt = txt.split("%value%").join(value);
						} else {
							txt = txt.split("%value%").join(this.arbitraryObj.defaultValue);
						}
						this.label_txt.text = txt;
					}
					subscribe(arbitrary[item].key, item_mc);
					item_mc.update();
				}
				break;
			case "icon": case "button":
				var icon_mc = item_mc.attachMovie("Icon", "icon_mc", 0);
				item_mc.key = arbitrary[item].key;
				if (arbitrary[item].icon != undefined) {
					item_mc.icon = arbitrary[item].icon;
					icon_mc.showIcon(item_mc.icon);
				} else {
					item_mc.icons = arbitrary[item].icons.split(",");
					icon_mc.showIcon(item_mc.icons[0]);
					item_mc.commands = arbitrary[item].commands.split(",");
				}
				item_mc.extra = arbitrary[item].extra;
				item_mc.arrayPos = 0;
				icon_mc._xscale = icon_mc._yscale = 50;
				item_mc._x = Math.round(arbitrary[item].x - (item_mc._width / 2));
				item_mc._y = Math.round(arbitrary[item].y - (item_mc._height / 2));
				
				if (arbitrary[item].label != undefined) {
					item_mc.label = arbitrary[item].label;
					item_mc.createTextField("label_txt", 10, 0, 20, 24, 15);

					var label_tf = new TextFormat();
					label_tf.color = 0xFFFFFF;
					label_tf.size = 11;
					label_tf.bold = true;
					label_tf.align = "center";
					label_tf.font = "globalFont";
					
					item_mc.label_txt.embedFonts = true;
					item_mc.label_txt.selectable = false;
					item_mc.label_txt.setNewTextFormat(label_tf);
				}
				
				if (arbitrary[item].key != undefined) {
					item_mc.update = function (key, state, value) {
						if (this.commands[0] == state) {
							this.icon_mc.showIcon(this.icons[1]);
							this.arrayPos = 1;
						} else if (this.commands[1] == state) {
							this.icon_mc.showIcon(this.icons[0]);
							this.arrayPos = 0;
						}
						if (this.label_txt != undefined && value != undefined) {
							this.label_txt.text = value;
						}
					}
					subscribe(arbitrary[item].key, item_mc);
				}
				if (arbitrary[item].type == "button") {
					item_mc.onPress2 = function () {
						updateKey(this.key, this.commands[this.arrayPos], this.extra);
					}
				}
		}
	}
}

createScrollBar = function (mc, height, func) {
	mc.func = func;
	mc.createEmptyMovieClip("bg_mc", 0);
	mc.bg_mc.beginFill(0x4E75B5);
	mc.bg_mc.drawRect(0, 0, 34, height, 5);
	mc.bg_mc.endFill();
	mc.bg_mc.onPress2 = function () {
		var p = this._parent._parent;
		p.startRow = Math.floor((this._ymouse / this._height) * (p.maxItems - p.itemsPerPage + 1));
		p[this._parent.func]();
	}
	
	var scrollUp_mc = mc.attachMovie("Button", "scrollUp_mc", 10, {width:34, height:34, icon:"up-arrow"});
	scrollUp_mc.repeatRate = 200;
	scrollUp_mc.buttonDown = function () {
		this.repeatID = setInterval(this, "action", this.repeatRate);
		this.action();
	}
	scrollUp_mc.buttonUp = function () {
		clearInterval(this.repeatID);
	}
	scrollUp_mc.action = function () {
		var p = this._parent._parent;
		
		if (p.startRow > 0) {
			p.startRow--;
			p[this._parent.func]();
		} else {
			clearInterval(this.repeatID);
		}
	}	

	var scrollDown_mc = mc.attachMovie("Button", "scrollDown_mc", 20, {width:34, height:34, icon:"down-arrow"});
	scrollDown_mc._y = height - 34;
	
	scrollDown_mc.repeatRate = 200;
	scrollDown_mc.buttonDown = function () {
		this.repeatID = setInterval(this, "action", this.repeatRate);
		this.action();
	}
	scrollDown_mc.buttonUp = function () {
		clearInterval(this.repeatID);
	}
	scrollDown_mc.action = function () {
		var p = this._parent._parent;
		if (p.startRow + p.itemsPerPage < p.maxItems) {
			p.startRow++;
			p[this._parent.func]();
		} else {
			clearInterval(this.repeatID);
		}
	}
}

openStatusWindow = function (statusObj) {
	showWindow(400, 415, "Status: " + statusObj.name, statusObj.icon);

	window_mc.content_mc.statusObj = statusObj;
	window_mc.content_mc.startRow = 0;
	
	window_mc.content_mc.update = function () {
		var statusObj = this.statusObj;
		
		var labels_mc = this.createEmptyMovieClip("labels_mc", 10);
		
		var label_tf = new TextFormat();
		label_tf.color = 0xFFFFFF;
		label_tf.size = 16;
		label_tf.bold = true;
		label_tf.font = "globalFont";

		var controls = new Array();
		for (var i=0; i<statusObj.controls.length; i++) {
			if (_global.controls[statusObj.controls[i].key].storedStates["state"] == statusObj.show) {
				controls.push(_global.controls[statusObj.controls[i].key]);
			}
		}
		this.maxItems = controls.length;
		this.itemsPerPage = 10;
		if (this.maxItems == 0) {
			this._parent.close();
		} else if (controls.length > this.itemsPerPage) {
			this.scrollBar_mc._visible = true;
			this.scrollBar_mc.scrollUp_mc.setEnabled(this.startRow > 0);
			this.scrollBar_mc.scrollDown_mc.setEnabled(this.startRow + this.itemsPerPage < this.maxItems);
			var labelWidth = 340;
		} else {
			var labelWidth = 380;
			this.scrollBar_mc._visible = false;
		}

		var counter = 0;
		while (counter < this.itemsPerPage && this.startRow + counter < this.maxItems) {
			var control = controls[this.startRow + counter];
			var label_mc = this.labels_mc.createEmptyMovieClip("label" + counter + "_mc", counter);
			label_mc._y = counter * 35;
			label_mc.key = control.key;
						
			label_mc.createTextField("label" + counter + "_txt", 20, 3, 3, labelWidth - 30, 20);
			var label_txt = label_mc["label" + counter + "_txt"];
			label_txt.embedFonts = true;
			label_txt.selectable = false;
			label_txt.setNewTextFormat(label_tf);
			label_txt.text = control.room + ": " + control.name;

			var bg_mc = label_mc.createEmptyMovieClip("bg_mc", 0);
			bg_mc.beginFill(0x4E75B5);
			bg_mc.drawRect(0, 0, labelWidth, 30, 5);
			bg_mc.endFill();

			bg_mc.onPress2 = function () {
				var content_mc = this._parent._parent._parent;
				if (content_mc.startRow > 0) content_mc.startRow--;
				updateKey(this._parent.key, "off");
			}

			counter++;
		}
	}
	
	var scrollBar_mc = window_mc.content_mc.createEmptyMovieClip("scrollBar_mc", 20);
	createScrollBar(scrollBar_mc, 345, "update");
	scrollBar_mc._x = 346;
	
	window_mc.onClose = function () {
		unsubscribe(this.content_mc.keys, this.content_mc);
	}
	
	var controls = statusObj.controls;
	window_mc.content_mc.keys = new Array();
	for (var control=0; control<controls.length; control++) {
		window_mc.content_mc.keys.push(controls[control].key);
	}
	subscribe(window_mc.content_mc.keys, window_mc.content_mc);
	window_mc.content_mc.update();
}

openRoomControl = function (room, roomPoly) {
	showWindow(400, 400, room.name);
	roomPoly._alpha = 0;
	
	var tabs_mc = window_mc.content_mc;
	
	var groups = room.groups;
	window_mc.content_mc.groups = room.groups;
	
	tabs_mc._visible = false;
	var tabCount = 0;
	for (var group=0; group<groups.length; group++) {
		if (groups[group].canSee == undefined || isAuthenticated(groups[group].canSee)) {
			var tab_mc = tabs_mc.createEmptyMovieClip("tab" + tabCount + "_mc", tabCount + 50);
			
			var tabContent_mc = tab_mc.createEmptyMovieClip("tabContent_mc", 30);
			tabContent_mc._x = 60;
			tabContent_mc._y = 12;
			var lastY = 0;
			var controls = groups[group].controls;
			for (var control=0; control<controls.length; control++) {
				if (controls[control].canSee == undefined || isAuthenticated(controls[control].canSee)) {
					var control_mc = tabContent_mc.createEmptyMovieClip("control" + control + "_mc", control);
					renderControl(controls[control], control_mc, 308);
					subscribe(controls[control].key, control_mc);
					control_mc._y = lastY;
					lastY += control_mc._height + 8;
				}
			}
			var tabIcon_mc = tab_mc.createEmptyMovieClip("tabIcon_mc", 10);
			
			icon_mc = tabIcon_mc.attachMovie("Icon", "icon_mc", 5);
			icon_mc._xscale = icon_mc._yscale = 70;
			icon_mc.showIcon(groups[group].icon)
			icon_mc._x = icon_mc._y = 7;
			
			var bg_mc = tabIcon_mc.createEmptyMovieClip("bg_mc", 0);
			bg_mc.beginFill(0x4E75B5);
			bg_mc.drawRect(0, 0, 47, 47, {tl:8,tr:0,bl:8,br:0});
			bg_mc.endFill();
		
			tabIcon_mc._y = tabCount * (tabIcon_mc._height + 3) + 8;
			tab_mc.id = tabCount;
			tab_mc.title = groups[group].name;
			tab_mc.controls = controls;
	
			tab_mc.active = false;
			tabIcon_mc.bg_mc._alpha = 50;	
			tabIcon_mc.useHandCursor = true;
			tabContent_mc._visible = false;
			
			tab_mc.setActive = function (active) {
				this.active = active;
				if (active) {
					this.tabIcon_mc.bg_mc._alpha = 100;
					this.tabIcon_mc.useHandCursor = false;
					this.tabContent_mc._visible = true;
				} else {
					this.tabIcon_mc.bg_mc._alpha = 50;	
					this.tabIcon_mc.useHandCursor = true;
					this.tabContent_mc._visible = false;
				}
				var controls = this.controls;
				for (var control=0; control<controls.length; control++) {
					var control_mc = this.tabContent_mc["control" + control + "_mc"];
					if (active) {
						control_mc.onShow();
					} else {
						control_mc.onHide();
					}
				}
			}
			
			tabIcon_mc.onPress2 = function () {
				var tab = this._parent;
				var tabs = this._parent._parent;
				if (!tab.active) {
					tabs.changeTab(tab.id);
				}
			}
			tabCount++;
		}
	}
	tabs_mc.originalTitle = room.name;
	tabs_mc.changeTab = function (id) {
		var oldTab = this["tab" + this.oldTabId + "_mc"];
		var newTab = this["tab" + id + "_mc"];
		if (this.oldTabId != undefined) oldTab.setActive(false);
		newTab.setActive(true);
		this.oldTabId = id;
		this._parent.setTitle(this.originalTitle + ": " + newTab.title)
	}
	
	tabs_mc.changeTab(0);
	
	var tabBg_mc = tabs_mc.createEmptyMovieClip("tabBg_mc", 10);
	tabBg_mc._x = 47;
	tabBg_mc.beginFill(0x4E75B5);
	tabBg_mc.drawRect(0, 0, 330, 330, 8);
	tabBg_mc.endFill();
	
	tabs_mc._visible = true;
	
	window_mc.onClose = function () {
		var groups = this.content_mc.groups;
		for (var group=0; group<this.content_mc.groups.length; group++) {
			var controls = groups[group].controls;
			for (var control=0; control<controls.length; control++) {
				unsubscribe(controls[control].key, this.content_mc["tab" + group + "_mc"].tabContent_mc["control" + control + "_mc"]);
				this.content_mc["tab" + group + "_mc"].tabContent_mc["control" + control + "_mc"].onClose();
			}
		}
	}
}

openAbout = function () {
	if (_global.windows["openAbout"] == "open") {
		window_mc.close();
	} else {
		showWindow(600, 500, "About eLife", "home");
		var content_mc = window_mc.content_mc;
		
		var about_tf = new TextFormat();
		about_tf.color = 0xFFFFFF;
		about_tf.size = 14;
		about_tf.bold = true;
		about_tf.font = "globalFont";
		
		content_mc.createTextField("about_txt", 10, 0, 0, content_mc.width, 20);
		var about_txt = content_mc.about_txt;
		about_txt.embedFonts = true;
		about_txt.selectable = false;
		about_txt.wordWrap = true;
		about_txt.multiline = true;
		about_txt.autoSize = true;
		about_txt.setNewTextFormat(about_tf);
		about_txt.text = _global.settings.systemInformation.split("\\n").join("\n");
		
		mdm.browser_load("2", Math.round((window_mc._x + content_mc._x) / _global.screenRatio), Math.round((window_mc._y + content_mc._y + about_txt._height + 5) / _global.screenRatio), Math.round(content_mc.width / _global.screenRatio), Math.round((content_mc.height - about_txt._height - 18) / _global.screenRatio), _global.settings.integratorHtml, "false");

		var version_tf = new TextFormat();
		version_tf.color = 0xFFFFFF;
		version_tf.size = 11;
		version_tf.bold = true;
		version_tf.font = "globalFont";
		
		content_mc.createTextField("ver_txt", 20, 0, content_mc.height - 12, content_mc.width, 20);
		var ver_txt = content_mc.ver_txt;
		ver_txt.embedFonts = true;
		ver_txt.selectable = false;
		ver_txt.wordWrap = true;
		ver_txt.multiline = true;
		ver_txt.autoSize = true;
		ver_txt.setNewTextFormat(version_tf);
		ver_txt.text = "Client: v" + _global.clientVersion + "  Server: v" + _global.serverVersion;

		_global.windows["openAbout"] = "open";
		window_mc.onClose = function () {
			mdm.browser_close("2");
			delete _global.windows["openAbout"];
		}
	}
}

openTV = function (setTo) {
	if (setTo != undefined) {
		tvStatus = setTo;
	} else if (tvStatus == "off") {
		tvStatus = "inset";
	} else if (tvStatus == "inset") {
		tvStatus = "fullscreen";
	} else if (tvStatus == "fullscreen") {
		tvStatus = "off";
	}
	if (tvStatus == "inset") {
		updateKey(_global.tv.inset.key, _global.tv.inset.command, _global.tv.inset.extra, true);
		var width = _global.tv.controlGrid.width;
		var height = _global.tv.controlGrid.height;
		var x = _global.tv.controlGrid.x;
		var y = _global.tv.controlGrid.y;
	} else if (tvStatus == "fullscreen") {
		updateKey(_global.tv.fullscreen.key, _global.tv.fullscreen.command, _global.tv.fullscreen.extra, true);
		var width = Stage.width;
		var height = Stage.height;
		var x = 0;
		var y = 0;
	} else if (tvStatus == "off") {
		appsBar_mc.openTV_mc.hideHighlight();
		updateKey(_global.tv.close.key, _global.tv.close.command, _global.tv.close.extra, true);
	}
	if (tvStatus == "inset" || tvStatus == "fullscreen") {
		tv_mc._visible = true;
		var depth = 0;
		var rows = _global.tv.controlGrid.rows;
		var cellHeight = Math.round(height / rows.length);
		for (var row=0; row<rows.length; row++) {
			var cells = rows[row];
			var cellWidth = Math.round(width / cells.length);
			for (var cell=0; cell<cells.length; cell++) {
				var cell_mc = tv_mc.createEmptyMovieClip("cell" + depth + "_mc", depth++);
				cell_mc.beginFill(_global.tv.controlGrid.bgColour, 90);
				cell_mc.lineTo(cellWidth, 0);
				cell_mc.lineTo(cellWidth, cellHeight);
				cell_mc.lineTo(0, cellHeight);
				cell_mc.lineTo(0, 0);
				cell_mc.endFill();
				cell_mc._x = cell * cellWidth;
				cell_mc._y = row * cellHeight;
				cell_mc.control_obj = cells[cell];
				cell_mc.onPress2 = function () {
					updateKey(this.control_obj.key, this.control_obj.command, this.control_obj.extra, true);
				}
			}
		}
		tv_mc._x = x;
		tv_mc._y = y;
	} else {
		tv_mc._visible = false;
	}
}

/*
openTV = function () {
	if (_global.windows["openTV"] == "open") {
		window_mc.close();
	} else if (_global.windows["openTV"] == "mini") {
		showWindow("full", "map", "Television: Channel 7", "tv", true, false, true);
		mdm.mp_size("0", window_mc._x + window_mc.content_mc._x, window_mc._y + window_mc.content_mc._y, window_mc.content_mc.width, window_mc.content_mc.height); 
		_global.windows["openTV"] = "open";
		window_mc.onClose = function () {
			appsBar_mc.openTV_mc.hideHighlight();
			mdm.mp_close("0");
			delete _global.windows["openTV"];
		}
	} else {
		_global.windows["openTV"] = "mini";
		appsBar_mc.openTV_mc.showHighlight();
		mdm.mp_load("0", _global.settings.applicationWidth - 445, _global.settings.applicationHeight - 245, 320, 240, _global.settings.sampleVideo); 
		mdm.mp_nomenu("0");
	}		
}
*/

openBrowser = function () {
	if (_global.windows["openBrowser"] == "open") {
		window_mc.close();
	} else {
		showWindow("full", "map", "Browser", "atom", true, false, true);
		appsBar_mc.openBrowser_mc.showHighlight();
		_global.windows["openBrowser"] = "open";
		window_mc.onClose = function () {
			appsBar_mc.openBrowser_mc.hideHighlight();
			mdm.browser_close("0");
			delete _global.windows["openBrowser"];
		}
		
		window_mc.content_mc.attachMovie("Button", "back_btn", 50, {width:48, height:48, icon:"left-arrow"});
		window_mc.content_mc.back_btn.buttonDown = function () {
			mdm.browser_back("0");
		}
		window_mc.content_mc.attachMovie("Button", "fwd_btn", 51, {width:48, height:48, icon:"right-arrow"});
		window_mc.content_mc.fwd_btn._x = 50;
		window_mc.content_mc.fwd_btn.buttonDown = function () {
			mdm.browser_forward("0");
		}
		window_mc.content_mc.attachMovie("Button", "stop_btn", 52, {width:48, height:48, icon:"stop"});
		window_mc.content_mc.stop_btn._x = 100;
		window_mc.content_mc.stop_btn.buttonDown = function () {
			mdm.browser_stop("0");
		}
		window_mc.content_mc.attachMovie("Button", "refresh_btn", 53, {width:48, height:48, icon:"refresh"});
		window_mc.content_mc.refresh_btn._x = 150;
		window_mc.content_mc.refresh_btn.buttonDown = function () {
			mdm.browser_refresh("0");
		}

		window_mc.content_mc.attachMovie("Button", "home_btn", 54, {width:48, height:48, icon:"home"});
		window_mc.content_mc.home_btn._x = 200;
		window_mc.content_mc.home_btn.buttonDown = function () {
			mdm.browser_goto("0", _global.settings.defaultBrowserURL);
		}
		
		window_mc.content_mc.attachMovie("Button", "keyboard_btn", 55, {width:48, height:48, icon:"keyboard-key"});
		window_mc.content_mc.keyboard_btn._x = 250;
		window_mc.content_mc.keyboard_btn.buttonDown = function () {
			mdm.browser_hide("0");
			this.goto = function (url, caller) {
				mdm.browser_show("0");
				if (url.length) {
					mdm.browser_goto("0", url);					
				}
			}
			showKeyboard(50, this.goto, this._parent, "http://", false, "", "web");
		}
		
		window_mc.content_mc.attachMovie("Button", "find_btn", 56, {width:48, height:48, icon:"find"});
		window_mc.content_mc.find_btn._x = 300;
		window_mc.content_mc.find_btn.buttonDown = function () {
			mdm.browser_hide("0");
			this.search = function (query, caller) {
				mdm.browser_show("0");
				if (query.length) {
					mdm.browser_goto("0", "http://www.google.com/search?&q=" + query);
				}
			}
			showKeyboard(20, this.search);			
		}
		
		window_mc.content_mc.showBusy = function () {
			this.onEnterFrame = function () {
				this.browserBusy = function (busy) {
					if (busy == "false") {
						window_mc.content_mc.stop_btn.setEnabled(false);
						delete window_mc.content_mc.onEnterFrame;
					}
				}
				mdm.browser_isbusy("0", this.browserBusy);
			}
		}
		mdm.browser_load("0", Math.round((window_mc._x + window_mc.content_mc._x) / _global.screenRatio), Math.round((window_mc._y + window_mc.content_mc._y + 50) / _global.screenRatio), Math.round(window_mc.content_mc.width / _global.screenRatio), Math.round((window_mc.content_mc.height - 54) / _global.screenRatio), _global.settings.defaultBrowserURL, "false");
	}
}

openAuthentication = function () {
	appsBar_mc.openAuthentication_mc.hideHighlight();
	if (!isAuthenticated("superuser")) {
		openPinPad(authenticateUser);
	} else if (_global.settings.adminPin) {
		setAuthenticated(false);
	}	
}

openControlPanel = function () {
	if (_global.windows["openControlPanel"] == "open") {
		window_mc.close();
	} else {
		showWindow("full", "map", "Control Panel", "gears", true, false);
		appsBar_mc.openControlPanel_mc.showHighlight();		
		_global.windows["openControlPanel"] = "open";
		window_mc.onClose = function () {
			delete _global.windows["openControlPanel"];
			appsBar_mc.openControlPanel_mc.hideHighlight();
			for (var i=0; i<this.content_mc.numTabs; i++) {
				this.content_mc["tab" + i + "_mc"].onClose();
			}
		}
		
		var tabBg_mc = window_mc.content_mc.createEmptyMovieClip("tabBg_mc", 10);
		tabBg_mc._x = 47;
		tabBg_mc.beginFill(0x4E75B5);
		tabBg_mc.drawRect(0, 0, window_mc.content_mc.width - tabBg_mc._x, window_mc.content_mc.height - tabBg_mc._y, 8);
		tabBg_mc.endFill();
		
		var tabs_mc = window_mc.content_mc;
		var tabs_array = [{name:"Macros", icon:"atom", func:"createMacroAdmin"}, {name:"Scripts", icon:"notepad", func:"createScriptsAdmin"}, {name:"Volume Control", icon:"speaker", func:"createVolumeControl"}, {name:"Clean Screen", icon:"spanner", func:"createCleanScreen"}, {name:"External Applications", icon:"red-pin", func:"createAppsPanel"}];
		window_mc.content_mc.numTabs = tabs_array.length;

		for (var i=0; i<tabs_array.length; i++) {
			var tab_mc = tabs_mc.createEmptyMovieClip("tab" + i + "_mc", i + 50);
			
			var tabContent_mc = tab_mc.createEmptyMovieClip("tabContent_mc", 30);
			tabContent_mc._x = 60;
			tabContent_mc._y = 12;
			tabContent_mc.width = tabBg_mc._width - 24;
			tabContent_mc.height = tabBg_mc._height - 24;
			_root[tabs_array[i].func](tabContent_mc);
			
			var tabIcon_mc = tab_mc.createEmptyMovieClip("tabIcon_mc", 10);
			
			icon_mc = tabIcon_mc.attachMovie("Icon", "icon_mc", 5);
			icon_mc._xscale = icon_mc._yscale = 70;
			icon_mc.showIcon(tabs_array[i].icon)
			icon_mc._x = icon_mc._y = 7;
			
			var bg_mc = tabIcon_mc.createEmptyMovieClip("bg_mc", 0);
			bg_mc.beginFill(0x4E75B5);
			bg_mc.drawRect(0, 0, 47, 47, {tl:8,tr:0,bl:8,br:0});
			bg_mc.endFill();
		
			tabIcon_mc._y = i * (tabIcon_mc._height + 3) + 8;
			tab_mc.id = i;
			tab_mc.title = tabs_array[i].name;
			
			tab_mc.setActive = function (active) {
				this.active = active;
				if (active) {
					this.tabIcon_mc.bg_mc._alpha = 100;
					this.tabIcon_mc.useHandCursor = false;
					this.tabContent_mc._visible = true;
				} else {
					this.tabIcon_mc.bg_mc._alpha = 50;	
					this.tabIcon_mc.useHandCursor = true;
					this.tabContent_mc._visible = false;
				}
			}
			
			tabIcon_mc.onPress2 = function () {
				var tab = this._parent;
				var tabs = this._parent._parent;
				if (!tab.active) {
					tabs.changeTab(tab.id);
				}
			}
			
			tab_mc.setActive(false);
		}
		
		tabs_mc.originalTitle = "Admin";
		tabs_mc.changeTab = function (id) {
			var oldTab = this["tab" + this.oldTabId + "_mc"];
			var newTab = this["tab" + id + "_mc"];
			if (this.oldTabId != undefined) oldTab.setActive(false);
			newTab.setActive(true);
			this.oldTabId = id;
			this._parent.setTitle(this.originalTitle + ": " + newTab.title)
		}
		
		tabs_mc.changeTab(0);
	}
}

openLogs = function () {
	if (_global.windows["openLogs"] == "open") {
		window_mc.close();
	} else {
		showWindow("full", "map", "logs", "notepad", true, false);
		appsBar_mc.openLogs_mc.showHighlight();
		_global.windows["openLogs"] = "open";
		window_mc.onClose = function () {
			appsBar_mc.openLogs_mc.hideHighlight();
			delete _global.windows["openLogs"];
			this.content_mc["tab" + this.content_mc.oldTabId + "_mc"].tabContent_mc.onHide();
		}
		
		var tabBg_mc = window_mc.content_mc.createEmptyMovieClip("tabBg_mc", 10);
		tabBg_mc._x = 47;
		tabBg_mc.beginFill(0x4E75B5);
		tabBg_mc.drawRect(0, 0, window_mc.content_mc.width - tabBg_mc._x, window_mc.content_mc.height - tabBg_mc._y, 8);
		tabBg_mc.endFill();
		
		var tabs_mc = window_mc.content_mc;
		window_mc.content_mc.numTabs = _global.logging.length;

		for (var i=0; i<_global.logging.length; i++) {
			var tab_mc = tabs_mc.createEmptyMovieClip("tab" + i + "_mc", i + 50);
			
			var tabContent_mc = tab_mc.createEmptyMovieClip("tabContent_mc", 30);
			tabContent_mc._x = 60;
			tabContent_mc._y = 12;
			tabContent_mc.width = tabBg_mc._width - 24;
			tabContent_mc.height = tabBg_mc._height - 24;
			createLogContent(_global.logging[i], tabContent_mc)
		
			var tabIcon_mc = tab_mc.createEmptyMovieClip("tabIcon_mc", 10);
			
			icon_mc = tabIcon_mc.attachMovie("Icon", "icon_mc", 5);
			icon_mc._xscale = icon_mc._yscale = 70;
			icon_mc.showIcon(_global.logging[i].icon)
			icon_mc._x = icon_mc._y = 7;
			
			var bg_mc = tabIcon_mc.createEmptyMovieClip("bg_mc", 0);
			bg_mc.beginFill(0x4E75B5);
			bg_mc.drawRect(0, 0, 47, 47, {tl:8,tr:0,bl:8,br:0});
			bg_mc.endFill();
		
			tabIcon_mc._y = i * (tabIcon_mc._height + 3) + 8;
			tab_mc.id = i;
			tab_mc.title = _global.logging[i].name;
			
			tab_mc.setActive = function (active) {
				this.active = active;
				if (active) {
					this.tabIcon_mc.bg_mc._alpha = 100;
					this.tabIcon_mc.useHandCursor = false;
					this.tabContent_mc._visible = true;
				} else {
					this.tabIcon_mc.bg_mc._alpha = 50;	
					this.tabIcon_mc.useHandCursor = true;
					this.tabContent_mc._visible = false;
				}
			}
			
			tabIcon_mc.onPress2 = function () {
				var tab = this._parent;
				var tabs = this._parent._parent;
				if (!tab.active) {
					tabs.changeTab(tab.id);
				}
			}
			
			tab_mc.setActive(false);
		}
		
		tabs_mc.originalTitle = "Logging";
		tabs_mc.changeTab = function (id) {
			var oldTab = this["tab" + this.oldTabId + "_mc"];
			var newTab = this["tab" + id + "_mc"];
			if (this.oldTabId != undefined) oldTab.setActive(false);
			newTab.setActive(true);
			this.oldTabId = id;
			oldTab.tabContent_mc.onHide();
			newTab.tabContent_mc.onShow();
			this._parent.setTitle(this.originalTitle + ": " + newTab.title)
		}
		
		tabs_mc.changeTab(0);
	}
}

createLogContent = function (logObj, content_mc) {

	content_mc.logObj = logObj;
	content_mc.startRow = 0;
	
	content_mc.update = function () {
		if (!this._visible) return;
		var logObj = this.logObj;
		
		var labels_mc = this.createEmptyMovieClip("labels_mc", 10);
		
		var label_tf = new TextFormat();
		label_tf.color = 0xFFFFFF;
		label_tf.size = 16;
		label_tf.bold = true;
		label_tf.font = "globalFont";

		var log = logObj.log;
		
		if (logObj.type == "tally") {
			this.maxItems = logObj.controls.length;
			this.itemsPerPage = 11;
			if (this.maxItems > this.itemsPerPage) {
				this.scrollBar_mc._visible = true;
				this.scrollBar_mc.scrollUp_mc.setEnabled(this.startRow > 0);
				this.scrollBar_mc.scrollDown_mc.setEnabled(this.startRow + this.itemsPerPage < this.maxItems);
				var labelWidth = this.width - this.scrollBar_mc._width - 5;
			} else {
				var labelWidth = this.width;
				this.scrollBar_mc._visible = false;
			}
			var counter = 0;
			for (var control=this.startRow; control<logObj.controls.length; control++) {
				if (logObj.controls[control].counter >= 0) {
					var key = logObj.controls[control].key;
					var controlObj = _global.controls[key];
					
					var txt = logObj.label;
					if (controlObj.room != undefined) txt = txt.split("%room%").join(controlObj.room);
					if (controlObj.name != undefined) txt = txt.split("%name%").join(controlObj.name);
							
					var label_mc = this.labels_mc.createEmptyMovieClip("label" + control + "_mc", control);
					label_mc._y = counter * 52;
					label_mc.controlObj = logObj.controls[control];
					label_mc.logObj = logObj;
				
					label_mc.createTextField("title_txt", 10, 3, 3, labelWidth - 3, 22);
					var title_txt = label_mc["title_txt"];
					title_txt.embedFonts = true;
					title_txt.selectable = false;
					title_txt.setNewTextFormat(label_tf);
					title_txt.text = txt + " [" + logObj.controls[control].counter + "]";

					if (logObj.controls[control].lastUpdated != undefined) {
						label_mc.createTextField("timestamp_txt", 20, 3, 22, labelWidth - 3, 22);
						var timestamp_txt = label_mc["timestamp_txt"];
						timestamp_txt.embedFonts = true;
						timestamp_txt.selectable = false;
						timestamp_txt.setNewTextFormat(label_tf);
						timestamp_txt.text = "Last updated: " + logObj.controls[control].lastUpdated.dateTimeFormat(logObj.timeformat);
					}
					
					var bg_mc = label_mc.createEmptyMovieClip("bg_mc", 0);
					bg_mc.beginFill(0x7298D6);
					bg_mc.drawRect(0, 0, labelWidth, 50, 5);
					bg_mc.endFill();

					counter++;
					if (counter >= this.itemsPerPage || this.startRow + counter > this.maxItems) break;
				}
			}
			if (count == 0) this._parent.close();
		} else if (logObj.type == "log") {
			this.maxItems = log.length;
			this.itemsPerPage = 17;
			if (this.maxItems > this.itemsPerPage) {
				this.scrollBar_mc._visible = true;
				this.scrollBar_mc.scrollUp_mc.setEnabled(this.startRow > 0);
				this.scrollBar_mc.scrollDown_mc.setEnabled(this.startRow + this.itemsPerPage < this.maxItems);
				var labelWidth = this.width - this.scrollBar_mc._width - 5;
			} else {
				var labelWidth = this.width;
				this.scrollBar_mc._visible = false;
			}
			var counter = 0;
			while (counter < this.itemsPerPage && this.startRow + counter < this.maxItems) {
				var label_mc = this.attachMovie("Label", "label" + counter + "_mc", counter, {width:labelWidth, height:30, label:log[counter + this.startRow].msg})
				label_mc._y = counter * 34;
				label_mc.logObj = logObj;
				label_mc.event = counter + this.startRow;
				counter++;
			}
		} else if (logObj.type == "web") {
			this.scrollBar_mc._visible = false;
	
			var bg_mc = this.createEmptyMovieClip("bg_mc", 0);
			bg_mc.beginFill(0x4E75B5);
			bg_mc.drawRect(0, 0, this.width, this.height);
			bg_mc.endFill();

			var point = {x:bg_mc._x, y:bg_mc._y};
			bg_mc.localToGlobal(point);
			this.browserSettings = {x:point.x, y:point.y, w:this.width, h:Number(this.height), url:logObj.url};
			this.onShow = function () {
				mdm.browser_load("1", Math.round(this.browserSettings.x / _global.screenRatio), Math.round(this.browserSettings.y / _global.screenRatio), Math.round(this.browserSettings.w / _global.screenRatio), Math.round(this.browserSettings.h / _global.screenRatio), this.browserSettings.url, "false");
			}
			this.onHide = function () {
				mdm.browser_close("1");
			}
		}
	}

	var scrollBar_mc = content_mc.createEmptyMovieClip("scrollBar_mc", 20);
	createScrollBar(scrollBar_mc, content_mc.height, "update");
	scrollBar_mc._x = content_mc.width - scrollBar_mc._width;
	
	content_mc.onClose = function () {
		unsubscribe(this.content_mc.keys, this.content_mc);
	}
	
	var controls = logObj.controls;
	content_mc.keys = new Array();
	for (var control=0; control<controls.length; control++) {
		content_mc.keys.push(controls[control].key);
	}
	subscribe(content_mc.keys, content_mc);
	content_mc.update();
}

createUsasgeGraphs = function (content_mc) {
	var graphs_array = ["Power", "Water", "Gas"];
	for (var i=0; i<graphs_array.length; i++) {
		var graph_mc = content_mc.createEmptyMovieClip("graph" + i + "_mc", i);
		graph_mc._y = i * 160;
		
		var label_tf = new TextFormat();
		label_tf.color = 0xFFFFFF;
		label_tf.size = 16;
		label_tf.bold = true;
		label_tf.font = "globalFont";		

		graph_mc.createTextField("label" + i + "_txt", 20, 0, 0, 350, 20);
		var label_txt = graph_mc["label" + i + "_txt"];
		label_txt.embedFonts = true;
		label_txt.selectable = false;
		label_txt.setNewTextFormat(label_tf);
		label_txt.text = graphs_array[i] + " usage over past 24 hours:";

		label_tf.align = "right";
		graph_mc.createTextField("cost" + i + "_txt", 25, 238, 0, 350, 20);
		var label_txt = graph_mc["cost" + i + "_txt"];
		label_txt.embedFonts = true;
		label_txt.selectable = false;
		label_txt.setNewTextFormat(label_tf);
		label_txt.text = "Cost: $" + Math.round(Math.random() * 9 + 1) + "." + Math.round(Math.random() * 9) + "0";
		
		var bg_mc = graph_mc.createEmptyMovieClip("bg_mc", 0);
		bg_mc.beginFill(0x829ECB);
		bg_mc.drawRect(0, 0, 538, 120, 8);
		bg_mc.endFill();
		bg_mc._x = 55;
		bg_mc._y = 25;
		
		var bars_mc = bg_mc.createEmptyMovieClip("bars_mc", 1);
		bars_mc._x = 5;
		bars_mc._y = bg_mc._height - 5;
		for (var w=0; w<48; w++) {
			var bar_mc = bars_mc.createEmptyMovieClip("bar" + w + "_mc", w);
			bar_mc.beginFill(0xB8C8E1);
			bar_mc.drawRect(0, 0, 10, -Math.round(Math.random() * 80 + 10), 0);
			bar_mc.endFill();
			bar_mc._x = w * (bar_mc._width + 1);
		}
	}
}

openCalendar = function () {
	if (_global.windows["openCalendar"] == "open") {
		window_mc.close();
	} else {
		showWindow("full", "map", "Calendar", "calendar", true, false);
		appsBar_mc.openCalendar_mc.showHighlight();
		_global.windows["openCalendar"] = "open";
		window_mc.onClose = function () {
			appsBar_mc.openCalendar_mc.hideHighlight();
			delete _global.windows["openCalendar"];
		}
		
		var calendar_ec = window_mc.content_mc.attachMovie("Calendar", "calendar_ec", 10, {});
	
		calendar_ec.onDisplayEvent = function (eventsData, dateObj) {
			this._parent.showDay(dateObj, eventsData);
		}
		
		// onSelectDate is called when a day with no events is clicked
		calendar_ec.onSelectDate = function (dateObj) {
			this._parent.showDay(dateObj);
		}
	
		calendar_ec.onHideEvent = function () {
			this._parent.currentDay_mc.removeMovieClip();
			this._parent.eventDetails_mc.removeMovieClip();
		}
		
		window_mc.content_mc.showDay = function (dateObj, eventsData) {
			this.currentDateObj = dateObj;
			var currentDay_mc = this.createEmptyMovieClip("currentDay_mc", 20);
			this.eventDetails_mc.removeMovieClip();
			currentDay_mc.dateObj = dateObj;
			currentDay_mc.eventsData = eventsData;
			currentDay_mc._y = 360;
			currentDay_mc.createTextField("day_txt", 50, 0, 0, this.calendar_ec.width, 30);
			var day_txt = currentDay_mc.day_txt;
			var label_tf = new TextFormat();
			label_tf.color = 0xFFFFFF;
			label_tf.size = 18;
			label_tf.bold = true;
			label_tf.font = "globalFont";
			label_tf.align = "center";
			day_txt.embedFonts = true;
			day_txt.selectable = false;
			day_txt.setNewTextFormat(label_tf);
			day_txt.text = dateObj.dateTimeFormat("dddd, d mmmm yyyy");
			currentDay_mc.refresh = function () {
				var events_mc = this.createEmptyMovieClip("events_mc", 10);
				events_mc._y = 30;
				for (var event=0; event<this.eventsData.length; event++) {
					var d = this.eventsData[event];
					var event_mc = events_mc.attachMovie("Label", "event" + event + "_mc", event, {width:this._parent.calendar_ec.width, height:30, label:d.title, colour:0x7F9BC9});
					event_mc._y = event * 35;
					event_mc.event = this.eventsData[event];
					event_mc.buttonDown = function () {
						var eventObj = new Object();
						eventObj.eventType = this.event.eventType;
						eventObj.title = this.event.title;
						eventObj.memo = this.event.memo;
						eventObj.time = this.event.time;
						eventObj.macroName = this.event.macroName;
						eventObj.startDate = this.event.startDate;
						eventObj.endDate = this.event.endDate;
						eventObj.pattern = new Object();
						for (var i in this.event.pattern) {
							eventObj.pattern[i] = this.event.pattern[i];
						}

						this._parent._parent._parent.showEvent(eventObj);
					}
				}
				if (isAuthenticated(_global.settitngs.calendarCanEdit)) {
					var newEvent_mc = events_mc.attachMovie("Label", "newEvent_mc", event, {width:this._parent.calendar_ec.width, height:30, label:"Create New Event...", colour:0x7F9BC9});
					newEvent_mc._y = event * 35;			
					newEvent_mc.buttonDown = function () {
						var now = new Date();
						var eventObj = new Object();
						eventObj.isNew = true;
						eventObj.eventType = "once";
						eventObj.title = "Untitled";
						eventObj.memo = "";
						eventObj.macroName = "";
						eventObj.time = now.dateTimeFormat(_global.settings.longTimeFormat);
						eventObj.startDate = this._parent._parent.dateObj;
						eventObj.endDate = new Date(now.getFullYear() + 1, now.getMonth(), now.getDate(), now.getHours(), now.getMinutes(), now.getSeconds())
						eventObj.pattern = new Object();
						this._parent._parent._parent.showEvent(eventObj);
					}
				}
			}
			currentDay_mc.refresh();
		}
	
		window_mc.content_mc.showEvent = function (eventObj) {
			var eventDetails_mc = this.createEmptyMovieClip("eventDetails_mc", 30);
			eventDetails_mc._x = this.calendar_ec.width + 20;
			eventDetails_mc.eventObj = eventObj;
			eventDetails_mc.refresh = function () {
				this._parent.showEvent(this.eventObj)
			}
			
			var buttonCount = 0;
			
			var eventTitle_mc = eventDetails_mc.attachMovie("Label", "eventTitle_mc", buttonCount, {width:350, height:30, label:eventObj.title, colour:0x7F9BC9});
			eventTitle_mc._y = buttonCount * 35;
			if (isAuthenticated(_global.settitngs.calendarCanEdit)) {
				eventTitle_mc.buttonDown = function () {
					this.updateTitle = function (title, caller) {
						if (title.length) {
							caller.eventObj.title = title;
							caller.eventTitle_mc.setLabel(title);
						}
					}
					if (this._parent.eventObj.title == "Untitled") this._parent.eventObj.title = "";
					showKeyboard(20, this.updateTitle, this._parent, this._parent.eventObj.title);
				}
			}
			
			var timePicker_mc = eventDetails_mc.createEmptyMovieClip("timePicker_mc", ++buttonCount);
			timePicker_mc._y = buttonCount * 35;
			var eventTimeLabel_mc = timePicker_mc.attachMovie("Label", "eventTimeLabel_mc", 1, {width:100, height:30, label:"At: ", colour:0x7F9BC9});
			var eventTimeHour_mc = timePicker_mc.attachMovie("Label", "eventTimeHour_mc", 2, {width:50, height:30, label:((eventObj.time.split(":")[0] > 12) ? eventObj.time.split(":")[0] - 12 : eventObj.time.split(":")[0]), colour:0x7F9BC9});
			eventTimeHour_mc._x = 100;
			var eventTimeColon_mc = timePicker_mc.attachMovie("Label", "eventTimeColon_mc", 3, {width:25, height:30, label:":", colour:0x7F9BC9});
			eventTimeColon_mc._x = 125;
			var eventTimeMinute_mc = timePicker_mc.attachMovie("Label", "eventTimeMinute_mc", 4, {width:50, height:30, label:eventObj.time.split(":")[1], colour:0x7F9BC9});
			eventTimeMinute_mc._x = 150;
			var eventTimeAMPM_mc = timePicker_mc.attachMovie("Label", "eventTimeAMPM_mc", 5, {width:50, height:30, label:((eventObj.time.split(":")[0] > 12) ? "PM" : "AM"), colour:0x7F9BC9});
			eventTimeAMPM_mc._x = 200;
			if (isAuthenticated(_global.settitngs.calendarCanEdit)) {
				timePicker_mc.setTime = function () {
					var hour = this.eventTimeHour_mc.label;
					var minute = this.eventTimeMinute_mc.label;
					var ampm = this.eventTimeAMPM_mc.label;
					if (ampm == "PM") hour += 12;
					this._parent.eventObj.time = hour + ":" + minute + ":" + "00";
				}
				eventTimeHour_mc.buttonDown = function () {
					var hour = Number(this.label);
					if (hour < 12) {
						hour++;
					} else {
						hour = 1;
					}
					this.setLabel(hour);
					this._parent.setTime();
				}
				eventTimeMinute_mc.buttonDown = function () {
					var minute = Number(this.label);
					if (minute < 58) {
						minute++;
					} else {
						minute = 0;
					}
					if (minute < 10) minute = "0" + minute;
					this.setLabel(minute);
					this._parent.setTime();
				}
				eventTimeAMPM_mc.buttonDown = function () {
					if (this.label == "AM") {
						this.setLabel("PM");
					} else {
						this.setLabel("AM");
					}
					this._parent.setTime();
				}
			}
			
			var eventMacro_mc = eventDetails_mc.attachMovie("Label", "eventMacro_mc", ++buttonCount, {width:350, height:30, colour:0x7F9BC9});
			eventMacro_mc._y = buttonCount * 35;
			if (eventObj.macroName.length) {
				for (var i=0; i<_global.macros.length; i++) {
					if (_global.macros[i].name == eventObj.macroName) break;
				}
				eventMacro_mc.macroIndex = i;
				eventMacro_mc.setLabel("Run '" + eventObj.macroName + "' macro");
			} else {
				eventMacro_mc.macroIndex = -1;
				eventMacro_mc.setLabel("Run nothing");
			}
			if (isAuthenticated(_global.settitngs.calendarCanEdit)) {
				eventMacro_mc.buttonDown = function () {
					this.macroIndex++;
					if (this.macroIndex == _global.macros.length) this.macroIndex = -1;
					if (this.macroIndex > -1) {
						this.setLabel("Run '" + _global.macros[this.macroIndex].name + "' macro");
						this._parent.eventObj.macroName = _global.macros[this.macroIndex].name;
					} else {
						this.setLabel("Run nothing");
						this._parent.eventObj.macroName = "";
					}
				}
			}
			
			var eventMemo_mc = eventDetails_mc.attachMovie("Label", "eventMemo_mc", ++buttonCount, {width:350, height:30, label:"Display: " + eventObj.memo.substr(0, 10) + "...", colour:0x7F9BC9});
			eventMemo_mc._y = buttonCount * 35;
			if (eventObj.memo == "") eventMemo_mc.setLabel("Display no message");
			if (isAuthenticated(_global.settitngs.calendarCanEdit)) {
				eventMemo_mc.buttonDown = function () {
					this.updateMemo = function (memo, caller) {
						caller.eventObj.memo = memo;
						if (memo.length) {
							caller.eventMemo_mc.setLabel("Display: " + memo.substr(0, 10) + "...");
						} else {
							eventMemo_mc.setLabel("Display no message");
						}
					}
					showKeyboard(255, this.updateMemo, this._parent, this._parent.eventObj.memo);
				}
			}
			
			var eventType_mc = eventDetails_mc.attachMovie("Label", "eventType_mc", ++buttonCount, {width:350, height:30, label:"Happens " + eventObj.eventType, colour:0x7F9BC9});
			eventType_mc._y = buttonCount * 35;
			eventType_mc.typeArray = ["once","hourly","daily","weekly","monthly","yearly"];
			for (var i=0; i<eventType_mc.typeArray.length; i++) {
				if (eventType_mc.typeArray[i] == eventObj.eventType) break;
			}
			if (isAuthenticated(_global.settitngs.calendarCanEdit)) {
				eventType_mc.typeIndex = i;
				eventType_mc.buttonDown = function () {
					this.typeIndex++;
					if (this.typeIndex == this.typeArray.length) this.typeIndex = 0;
					this.setLabel("Happens " + this.typeArray[this.typeIndex]);
					this._parent.eventObj.eventType = this.typeArray[this.typeIndex];
					if (this.typeArray[this.typeIndex] != "once") {
						this._parent.eventObj.pattern = new Object();
					}
					this._parent.refresh();
				}
			}

			if (eventObj.eventType == "hourly") {
				var recur_mc = eventDetails_mc.attachMovie("Label", "recur_mc", ++buttonCount, {width:350, height:30, colour:0x7F9BC9});
				recur_mc._y = buttonCount * 35;
				if (eventObj.pattern.recur != undefined) {
					recur_mc.recur = eventObj.pattern.recur;
				} else {
					recur_mc.recur = 1;
				}
				if (recur_mc.recur == 1) {
					recur_mc.setLabel("Every " + recur_mc.recur + " hour");
				} else {
					recur_mc.setLabel("Every " + recur_mc.recur + " hours");
				}
				if (isAuthenticated(_global.settitngs.calendarCanEdit)) {
					recur_mc.buttonDown = function () {
						this.recur++;
						if (this.recur == 24) this.recur = 1;
						if (this.recur == 1) {
							this.setLabel("Every " + this.recur + " hour");
						} else {
							this.setLabel("Every " + this.recur + " hours");
						}
						this._parent.eventObj.pattern.recur = this.recur;
					}
				}
			}
			
			if (eventObj.eventType == "daily") {
				var recur_mc = eventDetails_mc.attachMovie("Label", "recur_mc", ++buttonCount, {width:350, height:30, colour:0x7F9BC9});
				recur_mc._y = buttonCount * 35;
				recur_mc.recurArray = [{id:1,l:"odd days"},{id:2,l:"even days"},{id:3,l:"Mondays"},{id:4,l:"Tuesdays"},{id:4,l:"Wednesdays"},{id:4,l:"Thursdays"},{id:4,l:"Fridays"},{id:4,l:"Saturdays"},{id:4,l:"Sundays"},{id:4,l:"Weekdays"},{id:4,l:"Weekends"}];
				if (eventObj.pattern.recur != undefined) {
					for (var i=0; i<recur_mc.recurArray.length; i++) {
						if (recur_mc.recurArray[i].id == eventObj.pattern.recur) break;
					}
					recur_mc.recurIndex = i;
				} else {
					recur_mc.recurIndex = 0;
				}
				recur_mc.setLabel("On " + recur_mc.recurArray[recur_mc.recurIndex].l);
				if (isAuthenticated(_global.settitngs.calendarCanEdit)) {
					recur_mc.buttonDown = function () {
						this.recurIndex++;
						if (this.recurIndex == this.recurArray.length) this.recurIndex = 0;
						this.setLabel("On " + this.recurArray[this.recurIndex].l);
						this._parent.eventObj.pattern.recur = this.recurArray[this.recurIndex].id;
					}
				}
			}
			
			if (eventObj.eventType == "weekly") {
				var recur_mc = eventDetails_mc.attachMovie("Label", "recur_mc", ++buttonCount, {width:350, height:30, colour:0x7F9BC9});
				recur_mc._y = buttonCount * 35;
				recur_mc.recurArray = [{id:1,l:"week"},{id:2,l:"fortnight"},{id:3,l:"3 weeks"},{id:4,l:"4 weeks"}];
				if (eventObj.pattern.recur != undefined) {
					for (var i=0; i<recur_mc.recurArray.length; i++) {
						if (recur_mc.recurArray[i].id == eventObj.pattern.recur) break;
					}
					recur_mc.recurIndex = i;
				} else {
					recur_mc.recurIndex = 0;
				}
				recur_mc.setLabel("Every " + recur_mc.recurArray[recur_mc.recurIndex].l);
				if (isAuthenticated(_global.settitngs.calendarCanEdit)) {
					recur_mc.buttonDown = function () {
						this.recurIndex++;
						if (this.recurIndex == this.recurArray.length) this.recurIndex = 0;
						this.setLabel("Every " + this.recurArray[this.recurIndex].l);
						this._parent.eventObj.pattern.recur = this.recurArray[this.recurIndex].id;
					}
				}
				
				var day_mc = eventDetails_mc.attachMovie("Label", "day_mc", ++buttonCount, {width:350, height:30, colour:0x7F9BC9});
				day_mc._y = buttonCount * 35;
				day_mc.dayArray = [{id:"mon",l:"Monday"},{id:"tue",l:"Tuesday"},{id:"wed",l:"Wednesday"},{id:"thu",l:"Thursday"},{id:"fri",l:"Friday"},{id:"sat",l:"Saturday"},{id:"sun",l:"Sunday"}];
				for (var i=0; i<day_mc.dayArray.length; i++) {
					if (eventObj.pattern[day_mc.dayArray[i].id]) break;
				}
				day_mc.dayIndex = 0;
				day_mc.setLabel("On " + day_mc.dayArray[day_mc.dayIndex].l);
				if (isAuthenticated(_global.settitngs.calendarCanEdit)) {
					day_mc.buttonDown = function () {
						this.dayIndex++;
						if (this.dayIndex == this.dayArray.length) this.dayIndex = 0;
						this.setLabel("On " + this.dayArray[this.dayIndex].l);
						var days = ["mon","tue","wed","thu","fri","sat","sun","sun"]
						for (var day in days) {
							this._parent.eventObj.pattern[days[day]] = (this.dayArray[this.dayIndex].id == days[day]) ? 1 : 0;
						}
					}
				}
			}

			if (eventObj.eventType == "monthly") {
				var recur_mc = eventDetails_mc.attachMovie("Label", "recur_mc", ++buttonCount, {width:350, height:30, colour:0x7F9BC9});
				recur_mc._y = buttonCount * 35;
				recur_mc.recurArray = [{id:1,l:"month"},{id:2,l:"2 months"},{id:3,l:"3 months"},{id:4,l:"4 months"}];
				if (eventObj.pattern.recur != undefined) {
					for (var i=0; i<recur_mc.recurArray.length; i++) {
						if (recur_mc.recurArray[i].id == eventObj.pattern.recur) break;
					}
					recur_mc.recurIndex = i;
				} else {
					recur_mc.recurIndex = 0;
				}
				recur_mc.setLabel("Every " + recur_mc.recurArray[recur_mc.recurIndex].l);
				if (isAuthenticated(_global.settitngs.calendarCanEdit)) {
					recur_mc.buttonDown = function () {
						this.recurIndex++;
						if (this.recurIndex == this.recurArray.length) this.recurIndex = 0;
						this.setLabel("Every " + this.recurArray[this.recurIndex].l);
						this._parent.eventObj.pattern.recur = this.recurArray[this.recurIndex].id;
					}
				}
				
				var day_mc = eventDetails_mc.attachMovie("Label", "day_mc", ++buttonCount, {width:350, height:30, colour:0x7F9BC9});
				day_mc._y = buttonCount * 35;
				day_mc.dayArray = [{id:"mon",l:"Monday"},{id:"tue",l:"Tuesday"},{id:"wed",l:"Wednesday"},{id:"thu",l:"Thursday"},{id:"fri",l:"Friday"},{id:"sat",l:"Saturday"},{id:"sun",l:"Sunday"}];
				if (eventObj.pattern.day != undefined) {
					for (var i=0; i<day_mc.dayArray.length; i++) {
						if (day_mc.dayArray[i].id == eventObj.pattern.day) break;
					}
					day_mc.dayIndex = i;
				} else {
					day_mc.dayIndex = 0;
				}
				day_mc.setLabel("On " + day_mc.dayArray[day_mc.dayIndex].l);
				if (isAuthenticated(_global.settitngs.calendarCanEdit)) {
					day_mc.buttonDown = function () {
						this.dayIndex++;
						if (this.dayIndex == this.dayArray.length) this.dayIndex = 0;
						this.setLabel("On " + this.dayArray[this.dayIndex].l);
						this._parent.eventObj.pattern.day = this.dayArray[this.dayIndex].id;
					}
				}
				
				var week_mc = eventDetails_mc.attachMovie("Label", "week_mc", ++buttonCount, {width:350, height:30, colour:0x7F9BC9});
				week_mc._y = buttonCount * 35;
				week_mc.weekArray = [{id:1,l:"1st week of month"},{id:2,l:"2nd week of month"},{id:3,l:"3rd week of month"},{id:4,l:"4th week of month"},{id:5,l:"Last week of month"}];
				if (eventObj.pattern.week != undefined) {
					for (var i=0; i<week_mc.weekArray.length; i++) {
						if (week_mc.weekArray[i].id == eventObj.pattern.week) break;
					}
					week_mc.weekIndex = i;
				} else {
					week_mc.weekIndex = 0;
				}
				week_mc.setLabel(week_mc.weekArray[week_mc.weekIndex].l);
				if (isAuthenticated(_global.settitngs.calendarCanEdit)) {
					week_mc.buttonDown = function () {
						this.weekIndex++;
						if (this.weekIndex == this.weekArray.length) this.weekIndex = 0;
						this.setLabel(this.weekArray[this.weekIndex].l);
						this._parent.eventObj.pattern.week = this.weekArray[this.weekIndex].id;
					}
				}
			}
			
			if (eventObj.eventType == "yearly") {
				var recur_mc = eventDetails_mc.attachMovie("Label", "recur_mc", ++buttonCount, {width:350, height:30, colour:0x7F9BC9});
				recur_mc._y = buttonCount * 35;
				recur_mc.recurArray = [{id:1,l:"year"},{id:2,l:"2 years"},{id:3,l:"3 years"},{id:4,l:"4 years"}];
				if (eventObj.pattern.recur != undefined) {
					for (var i=0; i<recur_mc.recurArray.length; i++) {
						if (recur_mc.recurArray[i].id == eventObj.pattern.recur) break;
					}
					recur_mc.recurIndex = i;
				} else {
					recur_mc.recurIndex = 0;
				}
				recur_mc.setLabel("Every " + recur_mc.recurArray[recur_mc.recurIndex].l);
				if (isAuthenticated(_global.settitngs.calendarCanEdit)) {
					recur_mc.buttonDown = function () {
						this.recurIndex++;
						if (this.recurIndex == this.recurArray.length) this.recurIndex = 0;
						this.setLabel("Every " + this.recurArray[this.recurIndex].l);
						this._parent.eventObj.pattern.recur = this.recurArray[this.recurIndex].id;
					}
				}
				
				var date_mc = eventDetails_mc.attachMovie("Label", "day_mc", ++buttonCount, {width:350, height:30, colour:0x7F9BC9});
				date_mc._y = buttonCount * 35;
				date_mc.dateArray = [{id:1,l:"1st"},{id:2,l:"2nd"},{id:3,l:"3rd"},{id:4,l:"4th"},{id:5,l:"5th"},{id:6,l:"6th"},{id:7,l:"7th"},{id:8,l:"8th"},{id:9,l:"9th"},{id:10,l:"10th"},{id:11,l:"11th"},{id:12,l:"12th"},{id:13,l:"13th"},{id:14,l:"14th"},{id:15,l:"15th"},{id:16,l:"16th"},{id:17,l:"17th"},{id:18,l:"18th"},{id:19,l:"19th"},{id:20,l:"20th"},{id:21,l:"21st"},{id:22,l:"22nd"},{id:23,l:"23rd"},{id:24,l:"24th"},{id:25,l:"25th"},{id:26,l:"26th"},{id:27,l:"27th"},{id:28,l:"28th"},{id:29,l:"29th"},{id:30,l:"30th"},{id:31,l:"31st"}];
				if (eventObj.pattern.date != undefined) {
					for (var i=0; i<date_mc.dateArray.length; i++) {
						if (date_mc.dateArray[i].id == eventObj.pattern.date) break;
					}
					date_mc.dateIndex = i;
				} else {
					date_mc.dateIndex = 0;
				}
				date_mc.setLabel("On the " + date_mc.dateArray[date_mc.dateIndex].l);
				if (isAuthenticated(_global.settitngs.calendarCanEdit)) {
					date_mc.buttonDown = function () {
						this.dateIndex++;
						if (this.dateIndex == this.dateArray.length) this.dateIndex = 0;
						this.setLabel("On the " + this.dateArray[this.dateIndex].l);
						this._parent.eventObj.pattern.date = this.dateArray[this.dateIndex].id;
					}
				}
				
				var month_mc = eventDetails_mc.attachMovie("Label", "week_mc", ++buttonCount, {width:350, height:30, colour:0x7F9BC9});
				month_mc._y = buttonCount * 35;
				month_mc.monthArray = [{id:0,l:"January"},{id:1,l:"February"},{id:2,l:"March"},{id:3,l:"April"},{id:4,l:"May"},{id:5,l:"June"},{id:6,l:"July"},{id:7,l:"August"},{id:8,l:"September"},{id:9,l:"October"},{id:10,l:"November"},{id:11,l:"December"}];
				if (eventObj.pattern.month != undefined) {
					for (var i=0; i<month_mc.monthArray.length; i++) {
						if (month_mc.monthArray[i].id == eventObj.pattern.month) break;
					}
					month_mc.monthIndex = i;
				} else {
					month_mc.monthIndex = 0;
				}
				month_mc.setLabel("Of " + month_mc.monthArray[month_mc.monthIndex].l);
				if (isAuthenticated(_global.settitngs.calendarCanEdit)) {
					month_mc.buttonDown = function () {
						this.monthIndex++;
						if (this.monthIndex == this.monthArray.length) this.monthIndex = 0;
						this.setLabel("Of " + this.monthArray[this.monthIndex].l);
						this._parent.eventObj.pattern.month = this.monthArray[this.monthIndex].id;
					}
				}
			}

			if (isAuthenticated(_global.settitngs.calendarCanEdit)) {
				var save_btn = eventDetails_mc.attachMovie("Button", "save_btn", buttonCount + 1, {width:174, height:30, label:"Save"});
				save_btn._y = (buttonCount + 1) * 35 + 5;
				save_btn.buttonDown = function () {
					saveEvent(this._parent.eventObj);
					this._parent.removeMovieClip();
				}
				if (eventObj.isNew) {
					var cancel_btn = eventDetails_mc.attachMovie("Button", "cancel_btn", buttonCount + 2, {width:174, height:30, label:"Cancel"});
					cancel_btn._x = 176;
					cancel_btn._y = (buttonCount + 1) * 35 + 5;
					cancel_btn.buttonDown = function () {
						this._parent.removeMovieClip();
					}		
				} else {
					var delete_btn = eventDetails_mc.attachMovie("Button", "delete_btn", buttonCount + 2, {width:174, height:30, label:"Delete"});
					delete_btn._x = 176;
					delete_btn._y = (buttonCount + 1) * 35 + 5;
					delete_btn.buttonDown = function () {
						deleteEvent(this._parent.eventObj);
						this._parent.removeMovieClip();
					}		
				}
			} else {
				var close_btn = eventDetails_mc.attachMovie("Button", "close_btn", buttonCount + 1, {width:350, height:30, label:"Close"});
				close_btn._y = (buttonCount + 1) * 35 + 5;
				close_btn.buttonDown = function () {
					this._parent.removeMovieClip();
				}
			}
		}
		
		window_mc.content_mc.update = function () {
			this.calendar_ec.setDataProvider(_global.calendarData);
			this.calendar_ec.getDayByDate(this.currentDateObj.getDate()).onRelease();
		}
		subscribe("events", window_mc.content_mc);
		
		calendar_ec.setDisplayRange({begin:new Date(2000, 0),end:new Date(2010, 11)});
		calendar_ec.setDataProvider(_global.calendarData);
		calendar_ec.getDayByDate(new Date().getDate()).onRelease();
	}
}

createAppsPanel = function (content_mc) {
	var btns_mc = content_mc.createEmptyMovieClip("btns_mc", 10);
	for (var app=0; app<_global.controlPanelApps.length; app++) {
		var btn = btns_mc.attachMovie("Button", "clean_btn", app, {width:180, height:30, label:_global.controlPanelApps[app].label, fontSize:12});
		btn.buttonDown = function () {
			mdm.exec(this.program);
		}
		btn.program = _global.controlPanelApps[app].program;
		btn._y = app * 35;
	}
	btns_mc._x = Math.round((content_mc.width / 2) - (btns_mc._width / 2));
	btns_mc._y = Math.round((content_mc.height / 2) - (btns_mc._height / 2));	
}

createCleanScreen = function (content_mc) {
	var clean_btn = content_mc.attachMovie("Button", "clean_btn", 10, {width:200, height:50, label:"Clean Screen", fontSize:14});
	clean_btn._x = Math.round((content_mc.width / 2) - (clean_btn._width / 2));
	clean_btn._y = Math.round((content_mc.height / 2) - (clean_btn._height / 2));
	clean_btn.buttonDown = function () {
		showMessageWindow({title:"Clean Screen", height:200, content:"Go ahead... Clean my screen.\n\nScreen locked for the next %t%.", icon:"spanner", hideClose:true, autoClose:20});
	}
}

createVolumeControl = function (content_mc) {
	var volumeControls_mc = content_mc.createEmptyMovieClip("volumeControls_mc", 10);

	var volumeSlider_mc = volumeControls_mc.createEmptyMovieClip("volumeSlider_mc", 15);
	volumeSlider_mc.icons = ["speaker","speaker"];
	createSlider(volumeSlider_mc, {w:300, h:50});
	volumeSlider_mc.update = function () {
		this.setVolume = function (vol) {
			systemVolume = vol;
		}
		mdm.getmastervolume(this.setVolume);
		this.onEnterFrame = function () {
			this.setPercent(Math.round(systemVolume / 65535 * 100));
			delete this.onEnterFrame;
		}
	}
	volumeSlider_mc.bg_mc.onPress2 = function () {
		var value = Math.floor(this._xmouse / (this._width - (this._width * .1)) * 10) * 10;
		if (value >= 0 && value <= 100) {
			mdm.setmastervolume(Math.round(65535 * (value / 100)));
			this._parent.update();
		}
	}
				
	volumeControls_mc._x = Math.round((content_mc.width / 2) - (volumeControls_mc._width / 2));
	volumeControls_mc._y = Math.round((content_mc.height / 2) - (volumeControls_mc._height / 2));
	
	volumeSlider_mc.update();
}

createMacroAdmin = function (content_mc) {
	var label_tf = new TextFormat();
	label_tf.color = 0xFFFFFF;
	label_tf.size = 16;
	label_tf.bold = true;
	label_tf.font = "globalFont";
		
	content_mc.createTextField("label1_txt", 1, 3, 3, 350, 20);
	var label_txt = content_mc["label1_txt"];
	label_txt.embedFonts = true;
	label_txt.selectable = false;
	label_txt.setNewTextFormat(label_tf);
	label_txt.text = "Create Macro:";
	
	var createMacroBtn_mc = content_mc.attachMovie("Button", "createMacroBtn_mc", 2, {width:380, height:30, label:"", fontSize:12});
	createMacroBtn_mc.updateRecordingState = function () {
		if (recordingMacro) {
			this.setLabel("Stop Recording")
		} else {
			this.setLabel("Record New Macro")
		}
	}
	createMacroBtn_mc.updateRecordingState();
	createMacroBtn_mc._y = 25;
	createMacroBtn_mc.onPress2 = function () {
		recordingMacro = !recordingMacro;
		this.updateRecordingState();
		if (recordingMacro) {
			newMacroArray = new Array();
			window_mc.close();
				overlay_mc.status_txt.text = "** MACRO RECORDING **";
				overlay_mc.startStatusBlink();
		} else {
			overlay_mc.status_txt.text = "";
			overlay_mc.stopStatusBlink();
			this.saveMacro = function (title, caller) {
				if (!title.length) var title = "untitled";
				
				_global.macros.splice(0, 0, {name:title, controls:newMacroArray});
				saveMacro(title, newMacroArray);
				renderMacroList();
				caller.listMacros();
			}
			showKeyboard(20, this.saveMacro, this._parent)
		}
	}
	
	content_mc.createTextField("label2_txt", 5, 3, 60, 490, 20);
	var label_txt = content_mc["label2_txt"];
	label_txt.embedFonts = true;
	label_txt.selectable = false;
	label_txt.setNewTextFormat(label_tf);
	label_txt.text = "Current Macros:";
	
	content_mc.startRow = 0;

	content_mc.update = function () {
		var macroList_mc = this.createEmptyMovieClip("macroList_mc", 0)
		macroList_mc._y = 85;
		var label_tf = new TextFormat();
		label_tf.color = 0xFFFFFF;
		label_tf.size = 16;
		label_tf.bold = true;
		label_tf.font = "globalFont";

		this.maxItems = _global.macros.length;
		this.itemsPerPage = 14;
		if (this.maxItems > this.itemsPerPage) {
			this.scrollBar_mc._visible = true;
			this.scrollBar_mc.scrollUp_mc.setEnabled(this.startRow > 0);
			this.scrollBar_mc.scrollDown_mc.setEnabled(this.startRow + this.itemsPerPage < this.maxItems);
			var labelWidth = 520;
		} else {
			var labelWidth = 560;
			this.scrollBar_mc._visible = false;
		}

		var counter = 0;
		while (counter < this.itemsPerPage && this.startRow + counter < this.maxItems) {
			var macro_mc = macroList_mc.createEmptyMovieClip("macro" + counter + "_mc", counter);
			macro_mc._y = counter * 35;
			var macroNum = macro_mc.macroNum = this.startRow + counter;
			var macro = macro_mc.macro = _global.macros[macroNum];
			var buttonNum = 0;

			var moveUpBtn_mc = macro_mc.attachMovie("Button", "moveUpBtn_mc", 30 + (buttonNum++), {width:50, height:28, icon:"up-arrow"});
			moveUpBtn_mc._x = labelWidth - (buttonNum * 52);
			moveUpBtn_mc._y = 1;
			moveUpBtn_mc.buttonDown = function () {
				reorderMacros("moveUp", this._parent.macroNum);
			}
			if (counter == 0) moveUpBtn_mc.setEnabled(false);
			
			var moveDownBtn_mc = macro_mc.attachMovie("Button", "moveDownBtn_mc", 30 + (buttonNum++), {width:50, height:28, icon:"down-arrow"});
			moveDownBtn_mc._x = labelWidth - (buttonNum * 52);
			moveDownBtn_mc._y = 1;
			moveDownBtn_mc.buttonDown = function () {
				reorderMacros("moveDown", this._parent.macroNum);
			}
			if (counter == this.itemsPerPage - 1 || counter == this.maxItems - 1) moveDownBtn_mc.setEnabled(false);
				
			if (macro.running) {
				macro_mc.attachMovie("spinner", "spinner_mc", 5);
				macro_mc.spinner_mc._x = 15;
				macro_mc.spinner_mc._y = 15;
				macro_mc.createTextField("label_txt", 20, 28, 4, labelWidth - 235, 24);
			
				var stopBtn_mc = macro_mc.attachMovie("Button", "stopBtn_mc", 30 + (buttonNum++), {width:50, height:28, icon:"media-stop"});
				stopBtn_mc._x = labelWidth - (buttonNum * 52);
				stopBtn_mc._y = 1;
				stopBtn_mc.buttonDown = function () {
					sendCmd("MACRO", "abort", this._parent.macro.name);
				}
				
				var finishBtn_mc = macro_mc.attachMovie("Button", "finishBtn_mc", 30 + (buttonNum++), {width:50, height:28, icon:"media-fwd"});
				finishBtn_mc._x = labelWidth - (buttonNum * 52);
				finishBtn_mc._y = 1;
				finishBtn_mc.buttonDown = function () {
					sendCmd("MACRO", "complete", this._parent.macro.name);
				}
			} else {
				macro_mc.createTextField("label_txt", 20, 3, 4, labelWidth - 160, 26);
				
				var playBtn_mc = macro_mc.attachMovie("Button", "playBtn_mc", 30 + (buttonNum++), {width:50, height:28, icon:"media-play"});
				playBtn_mc._x = labelWidth - (buttonNum * 52);
				playBtn_mc._y = 1;
				playBtn_mc.buttonDown = function () {
					sendCmd("MACRO", "run", this._parent.macro.name);
				}
			}
				
			var label_txt = macro_mc["label_txt"];
			label_txt.embedFonts = true;
			label_txt.selectable = false;
			label_txt.setNewTextFormat(label_tf);
			label_txt.text = macro.name;
	
			var bg_mc = macro_mc.createEmptyMovieClip("bg_mc", 0);
			bg_mc.beginFill(0x829ECB);
			bg_mc.drawRect(0, 0, labelWidth, 30, 5);
			bg_mc.endFill();
			
			if (!_global.macros[macroNum].status.noEdit) {
				var editBtn_mc = macro_mc.attachMovie("Button", "editBtn_mc", 30 + (buttonNum++), {width:50, height:28, icon:"spanner"});
				editBtn_mc._x = labelWidth - (buttonNum * 52);
				editBtn_mc._y = 1;
				editBtn_mc.buttonDown = function () {
					openMacroEdit(this._parent.macroNum);
				}
			}
			if (!_global.macros[macroNum].status.noDelete) {
				var deleteBtn_mc = macro_mc.attachMovie("Button", "deleteBtn_mc", 10 + (buttonNum++), {width:50, height:28, icon:"delete2"});
				deleteBtn_mc._x = labelWidth - (buttonNum * 52);
				deleteBtn_mc._y = 1;
				deleteBtn_mc.buttonDown = function () {
					this.deleteMacro = function () {
						deleteMacro(this._parent.macro.name);
						//_global.macros.splice(this._parent.macroNum, 1);
						//this._parent._parent._parent.update();
						//renderMacroList()
					}
					confirm("Are you sure you want to delete '" + this._parent.macro.name + "'?", this, "deleteMacro");
				}
			}
			
			if (!_global.macros[macroNum].status.noToolbar) {
				var visibleBtn_mc = macro_mc.attachMovie("Button", "visibleBtn_mc", 30 + (buttonNum++), {width:50, height:28, icon:"led-green"});
			} else {
				var visibleBtn_mc = macro_mc.attachMovie("Button", "visibleBtn_mc", 30 + (buttonNum++), {width:50, height:28, icon:"led-red"});
			}
			visibleBtn_mc._x = labelWidth - (buttonNum * 52);
			visibleBtn_mc._y = 1;
			visibleBtn_mc.buttonDown = function () {
				var macroObj = _global.macros[this._parent.macroNum];
				if (macroObj.status.noToolbar) {
					delete macroObj.status.noToolbar;
				} else {
					macroObj.status.noToolbar = true;
				}
				saveMacro(macroObj.name, macroObj.controls)
			}
			
			if (_global.macros[macroNum].status.isSecure) {
				var secureBtn_mc = macro_mc.attachMovie("Button", "secureBtn_mc", 30 + (buttonNum++), {width:50, height:28, icon:"locked"});
			} else {
				var secureBtn_mc = macro_mc.attachMovie("Button", "secureBtn_mc", 30 + (buttonNum++), {width:50, height:28, icon:"unlocked"});
			}
			secureBtn_mc._x = labelWidth - (buttonNum * 52);
			secureBtn_mc._y = 1;
			secureBtn_mc.buttonDown = function () {
				var macroObj = _global.macros[this._parent.macroNum];
				if (macroObj.status.isSecure) {
					delete macroObj.status.isSecure;
				} else {
					macroObj.status.isSecure = true;
				}
				saveMacro(macroObj.name, macroObj.controls)
			}
			counter++;
		}
	}
	
	var scrollBar_mc = content_mc.createEmptyMovieClip("scrollBar_mc", 20);
	createScrollBar(scrollBar_mc, 485, "update");
	scrollBar_mc._y = 85;
	scrollBar_mc._x = 525;

	subscribe("MACRO", content_mc);

	content_mc._parent.onClose = function () {
		unsubscribe("MACRO", this.tabContent_mc);
	}
	
	content_mc.update();
}

createScriptsAdmin = function (content_mc) {
	var label_tf = new TextFormat();
	label_tf.color = 0xFFFFFF;
	label_tf.size = 16;
	label_tf.bold = true;
	label_tf.font = "globalFont";
		
	content_mc.createTextField("label1_txt", 1, 3, 3, 350, 20);
	var label_txt = content_mc["label1_txt"];
	label_txt.embedFonts = true;
	label_txt.selectable = false;
	label_txt.setNewTextFormat(label_tf);
	label_txt.text = "Current Scripts:";
	
	content_mc.startRow = 0;

	content_mc.update = function () {
		var scriptsList_mc = this.createEmptyMovieClip("scriptsList_mc", 0)
		scriptsList_mc._y = 25;
		var label_tf = new TextFormat();
		label_tf.color = 0xFFFFFF;
		label_tf.size = 16;
		label_tf.bold = true;
		label_tf.font = "globalFont";

		this.maxItems = _global.scripts.length;
		this.itemsPerPage = 14;
		if (this.maxItems > this.itemsPerPage) {
			this.scrollBar_mc._visible = true;
			this.scrollBar_mc.scrollUp_mc.setEnabled(this.startRow > 0);
			this.scrollBar_mc.scrollDown_mc.setEnabled(this.startRow + this.itemsPerPage < this.maxItems);
			var labelWidth = 340;
		} else {
			var labelWidth = 380;
			this.scrollBar_mc._visible = false;
		}

		var counter = 0;
		while (counter < this.itemsPerPage && this.startRow + counter < this.maxItems) {
			var item_mc = scriptsList_mc.createEmptyMovieClip("item" + counter + "_mc", counter);
			item_mc._y = counter * 35;
			var itemNum = item_mc.itemNum = this.startRow + counter;
			var script = item_mc.script = _global.scripts[itemNum];

			if (script.running) {
				item_mc.attachMovie("spinner", "spinner_mc", 5);
				item_mc.spinner_mc._x = 15;
				item_mc.spinner_mc._y = 15;
				item_mc.createTextField("label_txt", 20, 28, 4, labelWidth - 235, 24);
				
				if (script.stoppable) {
					var stopBtn_mc = item_mc.attachMovie("Button", "stopBtn_mc", 10, {width:50, height:28, icon:"media-stop"});
					stopBtn_mc._x = labelWidth - 102;
					stopBtn_mc._y = 1;
					stopBtn_mc.buttonDown = function () {
						sendCmd("SCRIPT", "abort", this._parent.script.name);
					}
				}
			} else {
				item_mc.createTextField("label_txt", 20, 3, 4, labelWidth - 160, 26);
				
				var playBtn_mc = item_mc.attachMovie("Button", "playBtn_mc", 10, {width:50, height:28, icon:"media-play"});
				playBtn_mc._x = labelWidth - 102;
				playBtn_mc._y = 1;
				playBtn_mc.buttonDown = function () {
					sendCmd("SCRIPT", "run", this._parent.script.name);
				}
			}
				
			var label_txt = item_mc["label_txt"];
			label_txt.embedFonts = true;
			label_txt.selectable = false;
			label_txt.setNewTextFormat(label_tf);
			label_txt.text = script.name;
	
			var bg_mc = item_mc.createEmptyMovieClip("bg_mc", 0);
			bg_mc.beginFill(0x829ECB);
			bg_mc.drawRect(0, 0, labelWidth, 30, 5);
			bg_mc.endFill();
			
			if (_global.scripts[itemNum].enabled == "disabled") {
				var toggleBtn_mc = item_mc.attachMovie("Button", "toggleBtn_mc", 30, {width:50, height:28, icon:"power-red"});
			} else {
				var toggleBtn_mc = item_mc.attachMovie("Button", "toggleBtn_mc", 30, {width:50, height:28, icon:"power-green"});
			}
			toggleBtn_mc._x = labelWidth - 51;
			toggleBtn_mc._y = 1;
			toggleBtn_mc.buttonDown = function () {
				var scriptObj = _global.scripts[this._parent.itemNum];
				if (scriptObj.enabled == "enabled") {
					scriptObj.enabled = "disabled";
				} else {
					scriptObj.enabled = "enabled";
				}
				setScriptEnabled(scriptObj.name)
			}
			counter++;
		}
	}
	
	var scrollBar_mc = content_mc.createEmptyMovieClip("scrollBar_mc", 20);
	createScrollBar(scrollBar_mc, 480, "update");
	scrollBar_mc._y = 85;
	scrollBar_mc._x = 346;

	subscribe("SCRIPT", content_mc);

	content_mc._parent.onClose = function () {
		unsubscribe("SCRIPT", this.tabContent_mc);
	}
	
	content_mc.update();
}

openMacroEdit = function (macro) {
	var macroObj = _global.macros[macro];

	showWindow(400, 465, "Edit Macro: " + macroObj.name, "gears", true, true);
	
	window_mc.content_mc.macroObj = macroObj;
	window_mc.content_mc.macroName = macroObj.name;
	window_mc.content_mc.macroControls = new Array();
	window_mc.content_mc.startRow = 0;
	for (var i=0; i<macroObj.controls.length; i++) {
		var objCopy = new Object();
		for (var q in macroObj.controls[i]) {
			objCopy[q] = macroObj.controls[i][q];
		}
		window_mc.content_mc.macroControls.push(objCopy);
	}

	window_mc.content_mc.update = function () {
		var content_mc = this.createEmptyMovieClip("content_mc", 0);
		var macroControls = this.macroControls;
		
		var label_tf = new TextFormat();
		label_tf.color = 0xFFFFFF;
		label_tf.size = 16;
		label_tf.bold = true;
		label_tf.font = "globalFont";
		label_tf.align = "center";

		this.maxItems = macroControls.length;
		this.itemsPerPage = 9;
		if (this.maxItems > this.itemsPerPage) {
			this.scrollBar_mc._visible = true;
			this.scrollBar_mc.scrollUp_mc.setEnabled(this.startRow > 0);
			this.scrollBar_mc.scrollDown_mc.setEnabled(this.startRow + this.itemsPerPage < this.maxItems);
			var labelWidth = 340;
		} else {
			var labelWidth = 380;
			this.scrollBar_mc._visible = false;
		}

		var counter = 0;
		while (counter < this.itemsPerPage && this.startRow + counter < this.maxItems) {
			var control = this.startRow + counter;
			var controlObj = macroControls[control];
			var control_mc = content_mc.createEmptyMovieClip("control" + control + "_mc", control);
			control_mc._y = counter * 40;
			control_mc.controlObj = controlObj;
			control_mc.control = control;
			
			var bg_mc = control_mc.createEmptyMovieClip("bg_mc", 0);
			bg_mc.beginFill(0x4E75B5);
			bg_mc.drawRect(0, 0, labelWidth, 30, 5);
			bg_mc.endFill();
	
			control_mc.createTextField("label_txt", 20, 0, 3, labelWidth, 20);
			var label_txt = control_mc["label_txt"];
			label_txt.embedFonts = true;
			label_txt.selectable = false;
			label_txt.setNewTextFormat(label_tf);
				
			if (controlObj.key == "" && controlObj.command == "pause") {
				controlObj.extra = Number(controlObj.extra);
				
				control_mc.updateLabel = function () {
					this.label_txt.text = "Pause: ";
					if (this.controlObj.extra >= 60) {
						this.label_txt.text += Math.floor(this.controlObj.extra / 60) + " minute";
					} else {
						this.label_txt.text += this.controlObj.extra + " second";
					}
					if (this.controlObj.extra != 1 && this.controlObj.extra != 60) this.label_txt.text += "s"
				}
				control_mc.updateLabel()
				
				var downArrow_mc = control_mc.attachMovie("Button", "downArrow_mc", 1, {width:50, height:28, icon:"down-arrow"});
				downArrow_mc._x = 1;
				downArrow_mc._y = 1;
				downArrow_mc.repeatRate = 70;
				downArrow_mc.buttonDown = function () {
					this.action();
					this.startRepeatID = setInterval(this, "startRepeat", 400);
				}
				downArrow_mc.startRepeat = function () {
					clearInterval(this.startRepeatID);
					this.repeatID = setInterval(this, "action", this.repeatRate);
				}
				downArrow_mc.buttonUp = function () {
					clearInterval(this.startRepeatID);
					clearInterval(this.repeatID);
				}
				downArrow_mc.action = function () {
					if (this._parent.controlObj.extra > 0) {
						if (this._parent.controlObj.extra > 60) {
							this._parent.controlObj.extra -= 60;
						} else {
							this._parent.controlObj.extra--;
						}
						this._parent.updateLabel();
					}
				}	
	
				var upArrow_mc = control_mc.attachMovie("Button", "upArrow_mc", 2, {width:50, height:28, icon:"up-arrow"});
				upArrow_mc._x = labelWidth - 51;
				upArrow_mc._y = 1;
				upArrow_mc.repeatRate = 70;
				upArrow_mc.buttonDown = function () {
					this.action();
					this.startRepeatID = setInterval(this, "startRepeat", 400);
				}
				upArrow_mc.startRepeat = function () {
					clearInterval(this.startRepeatID);
					this.repeatID = setInterval(this, "action", this.repeatRate);
				}
				upArrow_mc.buttonUp = function () {
					clearInterval(this.startRepeatID);
					clearInterval(this.repeatID);
				}
				upArrow_mc.action = function () {
					if (this._parent.controlObj.extra < 60) {
						this._parent.controlObj.extra++;
					} else {
						this._parent.controlObj.extra += 60;
					}
					this._parent.updateLabel();
				}				
			} else {				
				label_txt.text = controlObj.key + " [" + controlObj.command;
				if (controlObj.extra != "") label_txt.text += " : " + controlObj.extra;
				label_txt.text += "]";				

				var deleteBtn_mc = control_mc.attachMovie("Button", "upArrow_mc", 2, {width:50, height:28, icon:"delete2"});
				deleteBtn_mc._x = labelWidth - 51;
				deleteBtn_mc._y = 1;
				deleteBtn_mc.buttonDown = function () {
					window_mc.content_mc.macroControls.splice(this._parent.control, 2);
					window_mc.content_mc.update();
				}
			}
			counter++;
		}
	}
	var scrollBar_mc = window_mc.content_mc.createEmptyMovieClip("scrollBar_mc", 20);
	createScrollBar(scrollBar_mc, 350, "update");
	scrollBar_mc._y = 0;
	scrollBar_mc._x = 346;

	window_mc.content_mc.update();

	var buttons_mc = window_mc.content_mc.createEmptyMovieClip("buttons_mc", 500);
	var save_mc = buttons_mc.attachMovie("Button", "save_mc", 5, {width:80, height:35, label:"Save", fontSize:14});
	save_mc.buttonDown = function () {
		this._parent._parent.macroObj.controls = this._parent._parent.macroControls;
		saveMacro(this._parent._parent.macroName, this._parent._parent.macroControls);
		openControlPanel();
	}
	var cancel_mc = buttons_mc.attachMovie("Button", "cancel_mc", 10, {width:80, height:35, label:"Cancel", fontSize:14});
	cancel_mc._x = 90;
	cancel_mc.buttonDown = function () {
		window_mc.close();
		openControlPanel();
	}
	buttons_mc._x = Math.round((window_mc.content_mc.width / 2) - (buttons_mc._width / 2));
	buttons_mc._y = 360;
}

screenUnlock = function (pin) {
	if (pin == _global.settings.screenLockPin) {
		screenLocked = false;
		_root.pinOpen = false;
	} else if (pin.length) {
		showMessageWindow({title:"Invalid Password", height:100, content:"The password you entered was incorrect.", icon:"warning", hideClose:false, autoClose:10});
		window_mc.onClose = function () {
			_root.pinOpen = false;
		}
	} else {
		_root.pinOpen = false;
	}
}

authenticateUser = function (pin) {
	if (pin == _global.settings.adminPin) {
		_global.adminLastVerified = getTimer();
		setAuthenticated(true);
		if (_root.onUnlock != undefined) _root[_root.onUnlock]();
		_root.pinOpen = false;
	} else if (pin.length) {
		showMessageWindow({title:"Invalid Password", height:100, content:"The password you entered was incorrect.", icon:"warning", hideClose:false, autoClose:10});
		window_mc.onClose = function () {
			_root.pinOpen = false;
		}
	} else {
		_root.pinOpen = false;
	}
	delete _root.onUnlock;
}

openPinPad = function (func, onUnlock) {
	if (_global.windows["openBrowser"] == "open" || _global.windows["openAbout"] == "open" || _global.windows["openTV"] == "open") {
		window_mc.close();
	} else if (_global.windows["openTV"] == "mini") {
		mdm.mp_close("0");
	}
	if (pinOpen || commsError) return;
	_root.onUnlock = onUnlock;
	_root.pinOpen = true;
	showKeyboard(15, func, this, "", true, "Enter Pin", "pin");
}

showCommsError = function () {
	showMessageWindow({title:"Server Disconnected", content:"The connection with the server has been lost.\n\nPlease wait while the connection is restablished.", icon:"warning", hideClose:true})
}

#include "renderControl.as"

openKeyboard = function () {
	keyboard_mc._visible = true;	
}

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
	var iconOn_mc = handle_mc.attachMovie("Icon", "iconOn_mc", 10, {icon:item_mc.icons[1], height:settings.h - (padding * 2)});
	var iconOff_mc = handle_mc.attachMovie("Icon", "iconOff_mc", 0, {icon:item_mc.icons[0], height:settings.h - (padding * 2)});
	
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

createVideoViewer = function (item_mc, settings) {
	var bg_mc = item_mc.createEmptyMovieClip("bg_mc", 0);
	bg_mc.beginFill(0x829ECB);
	bg_mc.drawRect(0, 0, settings.w, settings.videoHeight + 7, 4);
	bg_mc.endFill();
	
	var video_mc = item_mc.createEmptyMovieClip("video_mc", 10);
	video_mc.beginFill(0x555555);
	video_mc.drawRect(0, 0, settings.videoWidth + 2, settings.videoHeight + 2);
	video_mc.endFill();
	
	video_mc._x = Math.round((settings.w / 2) - (settings.videoWidth / 2));
	video_mc._y = 3;
	
	var videoImage_mc = video_mc.createEmptyMovieClip("videoImage_mc", 10);
	videoImage_mc._x = videoImage_mc._y = 1;

	if (settings.format == "jpg") {
		var videoImage2_mc = video_mc.createEmptyMovieClip("videoImage2_mc", 20);
		videoImage2_mc._x = videoImage2_mc._y = 1;
	
		video_mc.src = settings.src;
		video_mc.videoWidth = settings.videoWidth;
		video_mc.videoHeight = settings.videoHeight;
		video_mc.refreshRate = settings.refreshRate;
		video_mc.loadJPG = function () {
			if (!isNaN(this.videoWidth)) {
				this.onEnterFrame = function () {
					if (this.newLoader._width > 3) {
						this.oldLoader._visible = false;
						this.newLoader._visible = true;
						this.newLoader._width = this.videoWidth;
						this.newLoader._height = this.videoHeight;
						delete this.onEnterFrame;
					}
				}
			}
			var tmp = this.oldLoader;
			this.oldLoader = this.newLoader;
			this.newLoader = tmp;
			this.newLoader.loadMovie(this.src);
			clearInterval(this.refreshID);
			this.refreshID = setInterval(this, "loadJPG", this.refreshRate);
		}
		video_mc.oldLoader = videoImage2_mc;
		video_mc.newLoader = videoImage_mc;
		video_mc.loadJPG();
	} else if (settings.format == "swf") {
		videoImage_mc.loadMovie(settings.src);
	} else if (settings.format == "flv") {
		flvContainer_mc = video_mc.attachMovie("flvContainer", "flvContainer_mc", 10);
		flvContainer_mc.src = settings.src;
		flvContainer_mc.videoWidth = settings.videoWidth;
		flvContainer_mc.videoHeight = settings.videoHeight;
		flvContainer_mc.loadFLV = function () {
			this.video._width = this.videoWidth;
			this.video._height = this.videoHeight;
			this.netConn = new NetConnection();
			this.netConn.connect(null);
			this.stream = new NetStream(this.netConn);
			this.stream.onStatus = function (info) {
				if (info.code == "NetStream.Play.Stop") {
					this.seek(0);
					this.play();
				}
			}
			this.stream.setBufferTime(5);
			this.video.attachVideo(this.stream);
			this.stream.play(this.src);		
		}
		flvContainer_mc.loadFLV();
	}
}

createButton = function (item_mc, settings) {
	item_mc.enabled = true;
	
	var bg_mc = item_mc.createEmptyMovieClip("bg_mc", 0);
	bg_mc.beginFill(0x829ECB);
	bg_mc.drawRect(0, 0, settings.w, settings.h, 5);
	bg_mc.endFill();
	
	var inset_mc = item_mc.createEmptyMovieClip("inset_mc", 1);
	inset_mc.beginFill(0xB8C8E1);
	inset_mc.drawRect(2, 2, settings.w - 4, settings.h - 4, 4);
	inset_mc.endFill();
	
	var outline_mc = item_mc.createEmptyMovieClip("outline_mc", 3);
	outline_mc.lineStyle(2, 0xFFCC00, 100);
	outline_mc.drawRect(0, 0, settings.w, settings.h, 5);
	outline_mc._alpha = 0;
	
	item_mc.setEnabled = function (enabled) {
		this.enabled = enabled;
		this._alpha = (enabled) ? 100 : 30;
		if (!this.enabled && this.outline_mc._alpha) {
			if (!this.showOn) this.hideHighlight();
		}
	}
	
	item_mc.showHighlight = function () {
		this.outline_mc._alpha = 100;
	}
	item_mc.hideHighlight = function () {
		this.outline_mc.onEnterFrame = function () {
			this._alpha -= 20;
			if (this._alpha <= 0) delete this.onEnterFrame;
		}		
	}
	item_mc.onRelease = item_mc.onReleaseOutside = function () {
		if (!this.showOn) this.hideHighlight();
		this.buttonUp();
	}
	item_mc.onPress2 = function () {
		if (this.enabled) {
			this.showHighlight();
			this.buttonDown();
		}
	}
	if (settings.label != undefined) { 
		if (settings.fontSize != undefined) {
			var fontSize = settings.fontSize;
		} else {
			var fontSize = _global.settings.controlButtonLabelFontSize;
		}
		
		var label_tf = new TextFormat();
		label_tf.color = _global.settings.controlButtonLabelColour;
		label_tf.size = fontSize;
		label_tf.bold = true;
		label_tf.font = "globalFont";

		item_mc.createTextField("label_txt", 20, 0, 0, 1, 1);
	
		var label_txt = item_mc.label_txt;
		label_txt.embedFonts = true;
		label_txt.selectable = false;
		label_txt.autoSize = true;
		label_tf.align = "center";
		label_txt.setNewTextFormat(label_tf);
		label_txt.text = settings.label;
		while (label_txt.textWidth > settings.w - 4) {
			label_tf.size--;
			label_txt.setTextFormat(label_tf);
		}
		label_txt._x = Math.round((settings.w/2) - (label_txt._width/2));
		label_txt._y = Math.round((settings.h/2) - (label_txt._height/2));
	
		item_mc.setLabel = function (label) {
			this.label_txt.text = label;
		}
	} else {
		item_mc.setIcon = function (icon) {
			var icon_mc = this.attachMovie("Icon", "icon_mc", 10, {icon:icon, height:this.bg_mc._height - 10});
			icon_mc._x = Math.round((this.bg_mc._width / 2) - ((this.bg_mc._width - 10) / 2));
			icon_mc._y = Math.round((this.bg_mc._height / 2) - ((this.bg_mc._height - 10) / 2));
		}
		item_mc.setIcon(settings.icon)
	}
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
		sendCmd(key, state, value, valueRest);
		broadcastChange(key);
	}
}

screenLock = function () {
	screenLocked = true;
	setAuthenticated(false);
}

layout = function () {
	_root.createEmptyMovieClip("logging_mc", -100);
	_root.createEmptyMovieClip("bg_mc", 0);
	_root.createEmptyMovieClip("zones_mc", 100);
	_root.createEmptyMovieClip("zoneLabels_mc", 200);
	_root.createEmptyMovieClip("modal_mc", 300);
	_root.createEmptyMovieClip("overlay_mc", 400);
	_root.createEmptyMovieClip("statusBar_mc", 500);
	_root.createEmptyMovieClip("appsBar_mc", 600);
	_root.createEmptyMovieClip("megaModal_mc", 1000);
	_root.createEmptyMovieClip("window_mc", 1100);
	_root.createEmptyMovieClip("confirm_mc", 1500);
	_root.createEmptyMovieClip("keyboard_mc", 2000);
	_root.createEmptyMovieClip("tv_mc", 3000);
	
	createObjects();
	
	bg_mc.lineStyle(0, _global.settings.applicationBg, 0);
	bg_mc.beginFill(_global.settings.applicationBg);
	bg_mc.drawRect(0, 0, _global.settings.applicationWidth, _global.settings.applicationHeight);
	bg_mc.endFill();
	
	zones_mc._x = _global.settings.zonesX;
	zones_mc._y = _global.settings.zonesY;
	
	zoneLabels_mc._x = _global.settings.zoneLabelsX;
	zoneLabels_mc._y = _global.settings.applicationHeight - _global.settings.zoneLabelsY - _global.settings.zoneBtnHeight;

	overlay_mc.attachMovie("overlay","bg_mc", 0);
	overlay_mc.bg_mc._x = _global.settings.applicationWidth - overlay_mc.bg_mc._width;
	overlay_mc.attachMovie("elife-logo","logo_mc", 5);
	overlay_mc.logo_mc._x = _global.settings.applicationWidth - 60 - Math.round(overlay_mc.logo_mc._width / 2);
	overlay_mc.logo_mc._y = 46;
	overlay_mc.logo_mc.onPress2 = function () {
		openAbout();
	}
	overlay_mc.createTextField("title_txt", 10, _global.settings.titleX, _global.settings.titleY, 300, 30);
	overlay_mc.createTextField("status_txt", 20, _global.settings.applicationWidth / 2, _global.settings.dateY, 1, 1);
	overlay_mc.createTextField("date_txt", 30, _global.settings.applicationWidth - _global.settings.dateX, _global.settings.dateY, 1, 1);

	var label_tf = new TextFormat();
	label_tf.color = _global.settings.titleFontColour;
	label_tf.size = _global.settings.titleFontSize;
	label_tf.bold = true;
	label_tf.align = "left";
	label_tf.font = "globalFont";
	overlay_mc.title_txt.embedFonts = true;
	overlay_mc.title_txt.selectable = false;
	overlay_mc.title_txt.setNewTextFormat(label_tf);

	label_tf.color = _global.settings.dateFontColour;
	label_tf.size = _global.settings.dateFontSize;
	label_tf.align = "center";
	overlay_mc.status_txt.embedFonts = true;
	overlay_mc.status_txt.selectable = false;
	overlay_mc.status_txt.setNewTextFormat(label_tf);
	overlay_mc.status_txt.autoSize = "center";
	overlay_mc.status_txt.text = "";
	
	overlay_mc.startStatusBlink = function () {
		this.showStatus();
	}
	overlay_mc.stopStatusBlink = function () {
		clearInterval(this.showIntervalID);
		clearInterval(this.hideIntervalID);
		this.status_txt._visible = true;
	}
	overlay_mc.showStatus = function () {
		this.status_txt._visible = true;
		clearInterval(this.showIntervalID);
		this.hideIntervalID = setInterval(this, "hideStatus", 500);
	}
	overlay_mc.hideStatus = function () {
		this.status_txt._visible = false;
		clearInterval(this.hideIntervalID);
		this.showIntervalID = setInterval(this, "showStatus", 500);
	}
	
	label_tf.color = _global.settings.dateFontColour;
	label_tf.size = _global.settings.dateFontSize;
	label_tf.align = "right";
	overlay_mc.date_txt.embedFonts = true;
	overlay_mc.date_txt.selectable = false;
	overlay_mc.date_txt.setNewTextFormat(label_tf);
	overlay_mc.date_txt.autoSize = "right";
	overlay_mc.updateClock = function () {
		var now = new Date();
		this.date_txt.text = now.dateTimeFormat(_global.settings.clockFormat);
	}
	overlay_mc.updateClock();
	setInterval(overlay_mc, "updateClock", 20000);
	
	statusBar_mc._x = _global.settings.statusBarX;
	statusBar_mc._y = _global.settings.statusBarY;
	
	appsBar_mc._x = _global.settings.applicationWidth - _global.settings.appsBarX - 120 - ((_global.settings.appsBarBtnWidth + _global.settings.appsBarBtnSpacing) * _global.appsBar.length);
	appsBar_mc._y = _global.settings.appsBarY;

	// setup timer to start screenlock on no mouse movement
	if (_global.settings.screenLockTimeout > 0) {
		_root.onMouseMove = _root.onMouseDown = function () {
			clearInterval(screenLockID);
			if (screenLocked) {
				openPinPad(screenUnlock)
			} else {
				screenLockID = setInterval(screenLock, _global.settings.screenLockTimeout * 1000)
			}
		}
		screenLockID = setInterval(screenLock, _global.settings.screenLockTimeout * 1000)
	}
	
	// hide mouse if set in config
	if (_global.settings.hideMouseCursor == "true") Mouse.hide();
	
	tv_mc.update = function (key, state, value) {
		openTV(state);
	}
	subscribe("TV", tv_mc);
	tvStatus = "off";
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

unsubscribe = function (keys, movieClip) {
	if (typeof(keys) == "string") keys = keys.split(",");
	for (var q=0; q<keys.length; q++) {
		var key = keys[q];
		var subscribers = _global.controls[key].subscribers;
		var i = subscribers.length;
		while (i--) {
			if (subscribers[i] == movieClip) {
				subscribers.splice(i, 1);
				break;
			}
		}
	}
	/*
	var counter = 0;
	for (var i in _global.controls) {
		if (_global.controls[i].subscribers.length) counter++;
	}
	trace("subscribers: " + counter);
	*/
}

broadcastChange = function (key) {
	//debug("broadcasting for " + key + ":")
	var control = _global.controls[key];
	for (var subscriber=0; subscriber<control.subscribers.length; subscriber++) {
		eval(control.subscribers[subscriber]).update(key, control.state, control.value);
		//debug(" - " + control.subscribers[subscriber])
	}
}

application_xml = new XML();
application_xml.onLoad = function () {
	var lastUpdated = this.firstChild.attributes.lastUpdated;
	var top = this.firstChild.childNodes;
	for (var i in top) {
		switch (top[i].nodeName) {
			case ("settings") :
				defineSettings(top[i].childNodes)
				break;
			case ("statusBar") :
				defineStatusBar(top[i].childNodes)
				break;
			case ("logging") :
				defineLogging(top[i].childNodes)
				break;
			case ("appsBar") :
				defineAppsBar(top[i].childNodes)
				break;
			case ("controlPanelApps") :
				defineControlPanelApps(top[i].childNodes);
				break;
			case ("sounds") :
				defineSounds(top[i].childNodes)
				break;
			case ("property") :
				defineZones(top[i].childNodes)
				break;
			case ("controlTypes") :
				defineControlTypes(top[i].childNodes)
				break;
			case ("tv") :
				defineTV(top[i].childNodes)
				break;
		}
	}
	layout();
	renderStatusBar();
	renderAppsBar();
	renderZones();
	setUpLogging();
	serverSetup();
	setAuthenticated(isAuthenticated("superuser"));
	if (_global.settings.iconMode == "external") loadIcons();
	if (Stage.width != _global.settings.width) {
		_global.screenRatio = Stage.width / _global.settings.width;
	} else {
		_global.screenRatio = 1;
	}
}

loadIcons = function () {
	var iconLib_mc = _root.createEmptyMovieClip("iconLib_mc", 3000);
	iconLib_mc._visible = false;
	for (var i=0; i<_global.icons.length; i++) {
		var icon_mc = iconLib_mc.createEmptyMovieClip(_global.icons[i], i);
		icon_mc._visible = false;
		icon_mc.loadMovie(_global.settings.libLocation + "icons/" + _global.icons[i] + ".swf");
	}
}

init = function () {
	this._visible = true;
	application_xml.load(_global.settings.applicationXML);
}

checkCoreUpdate = function () {
	if (mdm != undefined && _global.settings.checkVersion == "true") {
		_global.settings.appDirectory = appDir;
		serverCoreVersion_lv.load(_global.settings.latestVersionURL);
	} else {
		init()
	}
}

serverCoreVersion_lv = new LoadVars();
serverCoreVersion_lv.onData = function (ver) {
	if (ver != undefined) {
		if (_global.clientVersion < ver || _global.settings.forceUpdate == "true") {
			_level0.downloadCoreVersion(ver)
		} else {
			init()
		}
	} else {
		init()
	}
}

setUpDebug();
checkCoreUpdate();