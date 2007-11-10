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

createObjects = function () {
	_global.zones = new Array();
	_global.alerts = new Array();
	_global.statusBar = new Array();
	_global.logging = new Object();
	_global.appsBar = new Array();
	_global.macros = new Array();
	_global.macroStatus = new Array();
	_global.scripts = new Array();
	_global.calendar = new Array();
	_global.calendarZoneLabels = new Object();
	_global.controls = new Object();
	_global.controlTypes = new Object();
	_global.calendarData = new Array();
	_global.icons = new Object();
	_global.iconNames = new Array();
	_global.controlPanelApps = new Array();
	_global.tv = new Object();
	_global.windowStack = new Object();
	_global.players = new Object();
}

confirm = function (msg, scope, onYes, onNo, param1) {
	var window_mc = showWindow({id:"confirm", width:300, height:180, title:"Warning:", iconName:"warning", hideClose:msgObj.hideClose, noAutoClose:true});
	
	var content_mc = window_mc.content_mc;
	
	content_mc.createTextField("content_txt", 20, 10, 0, content_mc.width - 10, 10);
	var content_txt = content_mc.content_txt;
	
	var content_tf = new TextFormat();
	content_tf.color = 0xFFFFFF;
	content_tf.size = 16;
	content_tf.bold = true;
	content_tf.font = "bi.ui.Fonts:" + _global.settings.defaultFont;
	content_tf.align = "center";
	
	content_txt.embedFonts = true;
	content_txt.selectable = false;
	content_txt.multiline = true;
	content_txt.wordWrap = true;
	content_txt.autoSize = true;
	content_txt.setNewTextFormat(content_tf);
	content_txt.text = msg;
	content_txt._x = Math.round((content_mc.width / 2) - (content_txt._width / 2));
	content_txt._y = Math.round(((content_mc.height - 40) / 2) - (content_txt.textHeight / 2));
	
	var buttons_mc = content_mc.createEmptyMovieClip("buttons_mc", 30);
	buttons_mc.scope = scope;
	buttons_mc.window_mc = window_mc;
	var yes_mc = buttons_mc.attachMovie("bi.ui.Button", "yes_mc", 5, {settings:{width:60, height:35, label:"Yes", fontSize:14}});
	yes_mc.func = onYes;
	yes_mc.param = param1;
	yes_mc.press = function () {
		this._parent.scope[this.func](this.param);
		_global.windowStack["confirm"].close();
	}
	yes_mc.addEventListener("press", yes_mc);
	var no_mc = buttons_mc.attachMovie("bi.ui.Button", "no_mc", 10, {settings:{width:60, height:35, label:"No", fontSize:14}});
	no_mc._x = 80;
	no_mc.func = onNo;
	no_mc.press = function () {
		this._parent.scope[this.func]();
		_global.windowStack["confirm"].close();
	}
	no_mc.addEventListener("press", no_mc);
	buttons_mc._x = Math.round((content_mc.width / 2) - (buttons_mc._width / 2));
	buttons_mc._y = content_txt._y + content_txt.textHeight + 20;
}
	
showMessageWindow = function (msgObj) {
	var width = (msgObj.width == undefined) ? 450 : msgObj.width;
	var height = (msgObj.height == undefined) ? 300 : msgObj.height;
	var window_mc = showWindow({width:width, height:height, title:msgObj.title, iconName:msgObj.icon, hideClose:msgObj.hideClose, noAutoClose:true, align:"center"});

	if (msgObj.alarm == "Y") {
		_global.sounds["alarm"].start();
	}
	
	if (msgObj.onClose != undefined) {
		window_mc.onClose = msgObj.onClose;
	}
	
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
		content_tf.font = "bi.ui.Fonts:" + _global.settings.defaultFont;
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
	
	return window_mc;
}

showKeyboard = function (limit, onClose, callerObj, initial, password, type) {
	var buttonWidth = buttonHeight = 50;
	var buttonSpacing = 2;
	
	if (type == "pin") {
		var keyboard = "1,2,3;4,5,6;7,8,9;clear,0,ok_small";
		var cols = 3;
		var title = "Pin:";
	} else if (type == "numeric") {
		var keyboard = "1,2,3;4,5,6;7,8,9;clear,0,ok_small";
		var cols = 3;
		var title = "Number:";
	} else if (type == "web") {
		var keyboard = "1,2,3,4,5,6,7,8,9,0,/;q,w,e,r,t,y,u,i,o,p,';http://,a,s,d,f,g,h,j,k,l,:;www.,z,x,c,v,b,n,m,.,clear,del;.com,.au,shift,space,ok";
		var cols = 11;
		var title = "Address:";
	} else if (type == "path") {
		var keyboard = "1,2,3,4,5,6,7,8,9,0,-;q,w,e,r,t,y,u,i,o,p,_;a,s,d,f,g,h,j,k,l,:;\\\\,\\,z,x,c,v,b,n,m,.;clear,del,space,ok";
		var cols = 11;
		var title = "Address:";
	} else {
		var keyboard = "1,2,3,4,5,6,7,8,9,0,!;q,w,e,r,t,y,u,i,o,p,';a,s,d,f,g,h,j,k,l,:;clear,z,x,c,v,b,n,m,.,del;shift,space,ok";
		var cols = 11;
		var title = "Text:";
	}
	var rows = keyboard.split(";").length;

	var keyboard_mc = showWindow({width:10 + (cols * buttonWidth) + ((cols - 1) * buttonSpacing), height:110 + (rows * buttonHeight) + ((rows - 1) * buttonSpacing), title:title, iconName:"keyboard_key", align:"center", hideClose:true});
	
	var keys_mc = keyboard_mc.content_mc.createEmptyMovieClip("keys_mc", 100);


	keys_mc._y = 50;
	
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
				var key_mc = row_mc.attachMovie("bi.ui.Button", "key" + key + "_mc", key, {settings:{width:realWidth, height:buttonHeight, label:keys[key].toUpperCase(), fontSize:15}});
				key_mc.press = function () {
					var inputField_ti = this.keyboard_mc.inputField_ti;
					if (inputField_ti.length < inputField_ti.maxChars) inputField_ti.text += " ";
					inputField_ti.scrollRight();
				}
				key_mc.addEventListener("press", key_mc);
			} else if (keys[key] == "del") {
				var key_mc = row_mc.attachMovie("bi.ui.Button", "key" + key + "_mc", key, {settings:{width:buttonWidth, height:buttonHeight, label:keys[key].toUpperCase(), fontSize:15}});
				key_mc.press = function () {
					var inputField_ti = this.keyboard_mc.inputField_ti;
					inputField_ti.text = inputField_ti.text.substr(0, inputField_ti.length - 1);
					inputField_ti.scrollRight();
				}
				key_mc.addEventListener("press", key_mc);
			} else if (keys[key] == "clear") {
				var key_mc = row_mc.attachMovie("bi.ui.Button", "key" + key + "_mc", key, {settings:{width:buttonWidth, height:buttonHeight, label:keys[key].toUpperCase(), fontSize:15}});
				key_mc.press = function () {
					var inputField_ti = this.keyboard_mc.inputField_ti;
					inputField_ti.text = "";
				}
				key_mc.addEventListener("press", key_mc);
			} else if (keys[key] == "ok" || keys[key] == "ok_small") {
				if (keys[key] == "ok") {
					realWidth = (buttonWidth + buttonSpacing) * 2 - buttonSpacing;
				}
				var key_mc = row_mc.attachMovie("bi.ui.Button", "key" + key + "_mc", key, {settings:{width:realWidth, height:buttonHeight, label:"OK", fontSize:15}});
				key_mc.press = function () {
					var inputField_ti = this.keyboard_mc.inputField_ti;
					this.keyboard_mc.onClose(inputField_ti.text, this.keyboard_mc.callerObj);
					this.keyboard_mc._parent.close();
				}
				key_mc.addEventListener("press", key_mc);
			} else if (keys[key] == "shift") {
				realWidth = (buttonWidth + buttonSpacing)* 2 - buttonSpacing;
				var key_mc = row_mc.attachMovie("bi.ui.Button", "key" + key + "_mc", key, {settings:{width:realWidth, height:buttonHeight, label:keys[key].toUpperCase(), fontSize:15}});
				key_mc.press = function () {
					this.keyboard_mc.useShift = true;
				}
				key_mc.addEventListener("press", key_mc);
			} else {
				var key_mc = row_mc.attachMovie("bi.ui.Button", "key" + key + "_mc", key, {settings:{width:buttonWidth, height:buttonHeight, label:keys[key].toLowerCase(), fontSize:15}});
				key_mc.press = function () {
					var inputField_ti = this.keyboard_mc.inputField_ti;
					if (inputField_ti.maxChars < 3 && inputField_ti.length == inputField_ti.maxChars) inputField_ti.text = "";
					if (inputField_ti.length < inputField_ti.maxChars) {
						if (this.keyboard_mc.useShift) {
							inputField_ti.text += this.label.toUpperCase();
							this.keyboard_mc.useShift = false;
						} else {
							inputField_ti.text += this.label.toLowerCase();
						}
						inputField_ti.scrollRight();
					}
				}
				key_mc.addEventListener("press", key_mc);
			}
			key_mc.keyboard_mc = keyboard_mc.content_mc;
			key_mc._x = currentX;
			key_mc.debounce = 0;
			currentX += realWidth + buttonSpacing;
			key_mc._y = (buttonHeight + buttonSpacing) * row;
		}
		row_mc._x = Math.round((keys_mc._width / 2) - (row_mc._width / 2));
	}
	
	var inputField_ti = keyboard_mc.content_mc.attachMovie("bi.ui.TextInput", "inputField_ti", 200, {settings:{width:keyboard_mc.content_mc.width, wordWrap:false, height:45, fontSize:30, readOnly:true, text:(initial != undefined) ? initial : "", maxChars:limit, password:password}});
	inputField_ti.scrollRight = function () {
		this.text_txt.hscroll = this.text_txt.maxhscroll;
		this.text_txt.background = false;
	}
	inputField_ti.scrollRight();
	
	keyboard_mc.content_mc.onClose = onClose;
	keyboard_mc.content_mc.callerObj = callerObj;
}

showWindow = function (windowObj) {
	//if (windowObj.depth == undefined) {
		//if (window_mc._visible) window_mc.close();
		//delete window_mc.onClose;
	//}
	
	if (windowObj.width == undefined) windowObj.width = _global.settings.windowWidth;
	if (windowObj.height == undefined) windowObj.height = _global.settings.windowHeight;
	
	if (_global.settings.device == "pda") {
		windowObj.width = "full";
		windowObj.height = "full";
	}
	
	if (windowObj.width == "full" || _global.settings.device == "pda") {
		windowObj.width = _global.settings.applicationWidth;
		var x = 0;
	} else if (windowObj.align == "center") {
		var x = Math.round((_global.settings.applicationWidth / 2) - (windowObj.width / 2));
	} else {
		var toolbarWidth = 120;
		var x = Math.round(((_global.settings.applicationWidth - toolbarWidth) / 2) - (windowObj.width / 2));
	}
	
	if (windowObj.height == "full" || _global.settings.device == "pda") {
		windowObj.height = _global.settings.applicationHeight;
		var y = 0;
	} else if (windowObj.align == "center") {
		var y = Math.round((_global.settings.applicationHeight / 2) - (windowObj.height / 2));
	} else {
		var toolbarHeight = _global.settings.statusBarY + _global.settings.statusBarBtnHeight + _global.settings.statusBarBtnSpacing;
		var y = Math.round(((_global.settings.applicationHeight - toolbarHeight) / 2) - (windowObj.height / 2)) + toolbarHeight;
	}
	
	var modal_mc = windows_mc.createEmptyMovieClip("modal_mc", windows_mc.getNextHighestDepth());
	
	if (_global.settings.modalBlur) {
		var blurCopyObj = new BitmapData(Stage.width, Stage.height, true, 0x00FFFFFF);
		blurCopyObj.draw(_root);
		var blur_mc= modal_mc.createEmptyMovieClip("blur_mc", 0);	
		blur_mc.attachBitmap(blurCopyObj, 0, "auto", true);
		blur_mc.filters = [new BlurFilter(2, 2, 4)];
	}
	
	var bg_mc = modal_mc.createEmptyMovieClip("black_mc", 10);
	bg_mc.beginFill(0x000000, 40);
	bg_mc.drawRect(0, 0, 1000 + _global.settings.applicationWidth, 1000 + _global.settings.applicationHeight);
	bg_mc.endFill();
	
	modal_mc.onPress = function () {};
	modal_mc.useHandCursor = false;
	
	var depth = windows_mc.getNextHighestDepth();
	window_mc = windows_mc.attachMovie("bi.ui.Window", "window" + depth + "_mc", depth, {settings:windowObj});
	window_mc.modal_mc = modal_mc;
	
	_global.windowStack[windowObj.id] = window_mc;
	
	window_mc.close = function () {
		var i;
		for (i in _global.windowStack) {
			if (_global.windowStack[i] == this) {
				delete _global.windowStack[i];
				break;
			}
		}
		delete window_mc.onMouseMove;
		this.modal_mc.removeMovieClip();
		clearInterval(this.closeWindowID);
		this.onClose();
		this.removeMovieClip();
	}

	window_mc._x = x;
	window_mc._y = y;
	
	if (!windowObj.noAutoClose) {
		window_mc.onMouseMove = function () {
			clearInterval(this.closeWindowID);
			this.closeWindowID = setInterval(this, "close", _global.settings.windowAutoCloseTime * 1000);
		}
	}
	
	return window_mc;
}

renderStatusBar = function () {
	for (var group=0; group<_global.statusBar.length; group++) {
 		var groupObj = _global.statusBar[group];
		var group_mc = statusBar_mc.attachMovie("bi.ui.Button", "group" + group + "_mc", group, {settings:{width:_global.settings.statusBarBtnWidth, height:_global.settings.statusBarBtnHeight, iconName:groupObj.icon}});
		group_mc.groupObj = groupObj;
		
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
		
		group_mc.press = function () {
			if (this.groupObj.canOpen == undefined || isAuthenticated(this.groupObj.canOpen)) openStatusWindow(this.groupObj);
		}
		group_mc.addEventListener("press", group_mc);
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
	if (_global.settings.device == "pda") {
		var icon_array = [{iconName:"atom", action:"showMacros"}, {iconName:"up-arrow", action:"changeZoneUp"}, {iconName:"down-arrow", action:"changeZoneDown"}, {iconName:"delete", action:"exitClient"}];
		for (var icon=0; icon<icon_array.length; icon++) {
			var icon_mc = appsBar_mc.attachMovie("bi.ui.Button", icon_array[icon].action + "_mc", icon, {settings:{width:_global.settings.appsBarBtnWidth, height:_global.settings.appsBarBtnHeight, iconName:icon_array[icon].iconName}});
			if (icon_array[icon].action == "changeZoneUp" || icon_array[icon].action == "changeZoneDown") {
				icon_mc.dir = icon_array[icon].action;
				icon_mc.zoneId = 0;
				icon_mc.press = function () {
					zones_mc.macros_mc._visible = false;
					zones_mc["zone" + zones_mc.currentZone + "_mc"]._visible = false;
					zones_mc["zone" + zones_mc.currentZone + "_mc"].panels_mc.onHide();
					
					if (this.dir == "changeZoneUp") {
						zones_mc.currentZone++;
						if (zones_mc.currentZone == _global.zones.length) zones_mc.currentZone = 0;
					} else {
						zones_mc.currentZone--;
						if (zones_mc.currentZone < 0) zones_mc.currentZone = _global.zones.length - 1; 
					}
					
					zones_mc["zone" + zones_mc.currentZone + "_mc"]._alpha = 100;
					zones_mc["zone" + zones_mc.currentZone + "_mc"]._visible = true;
					zones_mc["zone" + zones_mc.currentZone + "_mc"].panels_mc.onShow();
					overlay_mc.title_txt.text = _global.zones[zones_mc.currentZone].name;
				}
			} else if (icon_array[icon].action == "showMacros") {
				icon_mc.state = "off";
				icon_mc.toggle = true;
				icon_mc.press = function () {
					if (this.state == "off") {
						this.state = "on";
						this.highlight = true;
						zones_mc["zone" + zones_mc.currentZone + "_mc"]._visible = false;
						zones_mc["zone" + zones_mc.currentZone + "_mc"].panels_mc.onHide();
						zones_mc.macros_mc._visible = true;
						overlay_mc.title_txt.text = "Macros";
					} else {
						this.state = "off";
						this.highlight = false;
						zones_mc["zone" + zones_mc.currentZone + "_mc"]._alpha = 100;
						zones_mc["zone" + zones_mc.currentZone + "_mc"]._visible = true;
						zones_mc["zone" + zones_mc.currentZone + "_mc"].panels_mc.onShow();
						zones_mc.macros_mc._visible = false;
						overlay_mc.title_txt.text = _global.zones[zones_mc.currentZone].name;
					}
				}				
			} else if (icon_array[icon].action == "exitClient") {
				icon_mc.press = function () {
					fscommand("mdm.exit");
				}
			}
			icon_mc._x = (_global.settings.appsBarBtnWidth + _global.settings.appsBarBtnSpacing) * icon;
			icon_mc.addEventListener("press", icon_mc);
		}
	} else {
		for (var btn=0; btn<_global.appsBar.length; btn++) {
			var iconObj = _global.appsBar[btn];

			var buttonObject = {width:_global.settings.appsBarBtnWidth, height:_global.settings.appsBarBtnHeight, iconName:iconObj.icon};
			for (var attr in iconObj) {
				if (attr.substr(0, 6) == "button") {
					if (iconObj[attr] == Number(iconObj[attr])) {
						buttonObject[attr.substr(6, 1).toLowerCase() + attr.substr(7)] = Number(iconObj[attr]);
					} else if (iconObj[attr] == "true" || iconObj[attr] == "false") {
						buttonObject[attr.substr(6, 1).toLowerCase() + attr.substr(7)] = (iconObj[attr] == "true");
					} else {
						buttonObject[attr.substr(6, 1).toLowerCase() + attr.substr(7)] = iconObj[attr];
					}
				}
			}
			
			var icon_mc = appsBar_mc.attachMovie("bi.ui.Button", iconObj.func + "_mc", btn, {settings:buttonObject});
			icon_mc.func = iconObj.func;
			icon_mc.program = iconObj.program;
			icon_mc.canOpen = iconObj.canOpen;
			icon_mc.showOn = true;
			
			icon_mc.press = function () {
				if (this.canOpen == "superuser" && !isAuthenticated("superuser")) {
					openPinPad(authenticateUser, this.func);
				} else {
					if (this.func == "runexe") {
						mdm.System.exec(this.program);
					} else if (this.func == "toggleTV") {
						toggleTV();
					} else {
						_root[this.func]();
					}
				}
			}
			icon_mc._x = (_global.settings.appsBarBtnWidth + _global.settings.appsBarBtnSpacing) * btn;
			icon_mc.addEventListener("press", icon_mc);
		}
	}
}

setAuthenticated = function (authenticated) {
	clearInterval(autoExpireLogin);
	if (isLoggedIn != authenticated) {
		isLoggedIn = authenticated;
		if (authenticated) {
			appsBar_mc.openAuthentication_mc.iconName = "unlocked";
			autoExpireLogin = setInterval(this, "setAuthenticated", _global.settings.cachePinTime * 1000);
		} else {
			appsBar_mc.openAuthentication_mc.iconName = "locked";
		}
	}
}

isAuthenticated = function (user) {
	return (user == "" || _global.settings.adminPin == "" || isLoggedIn)
}

renderMacroList = function () {
	if (_global.settings.device == "pda") {
		var wasVisible = zones_mc.macros_mc._visible;
		var macros_mc = zones_mc.createEmptyMovieClip("macros_mc", 100);
		macros_mc._visible = wasVisible;
		var macroCount = 0;
		for (var macro=0; macro<_global.macros.length; macro++) {
			if (!_global.macros[macro].status.noToolbar) {
				var button_mc = macros_mc.attachMovie("bi.ui.Button", "macro" + macroCount + "_btn", macroCount, {settings:{width:200, height:45, label:_global.macros[macro].name}});
				button_mc._y = macroCount * (button_mc._height + 2);
				button_mc.macroID = macro;
				
				if (_global.macros[macro].type == "dual") {
					if (_global.macroStatus[macro] == 1) {
						button_mc.label = _global.macros[macro].controls[1].command;
						button_mc.macroName = _global.macros[macro].controls[1].command;
						button_mc.onChangeID = 0;
					} else {
						button_mc.label = _global.macros[macro].controls[0].command;
						button_mc.macroName = _global.macros[macro].controls[0].command;
						button_mc.onChangeID = 1;
					}
					button_mc.press = function () {
						if (isAuthenticated("superuser") || !_global.macros[this.macroID].status.isSecure) {
							sendCmd("MACRO", "run", this.macroName);
							_global.macroStatus[this.macroID] = this.onChangeID;
							this.showHighlight();
						}
					}
				} else {
					if (_global.macros[macro].running) {
						button_mc.highlight = true;
					}
					button_mc.macroName = _global.macros[macro].name;
					
					button_mc.press = function () {
						if (isAuthenticated("superuser") || !_global.macros[this.macroID].status.isSecure) {
							if (_global.macros[this.macroID].running) {
								sendCmd("MACRO", "abort", this.macroName);
								this.highlight = false;
							} else {
								sendCmd("MACRO", "run", this.macroName);
								this.highlight = true;
							}
						}
					}
				}
				button_mc.addEventListener("press", button_mc);
				macroCount++;
			}
		}
		macros_mc._x = Math.round((_global.settings.applicationWidth / 2) - (macros_mc._width / 2));
		macros_mc._y = Math.round(((_global.settings.applicationHeight - _global.settings.zonesY) / 2) - (macros_mc._height / 2));
	} else {
		var macros_mc = _root.createEmptyMovieClip("macros_mc", 700);
		macros_mc._x = _global.settings.applicationWidth - _global.settings.macroBtnWidth - _global.settings.macroBtnSpacing;
		macros_mc._y = _global.settings.applicationHeight - _global.settings.macroBtnHeight - _global.settings.macroListY;
	
		var counter = 0;
		var macro = _global.macros.length;
		while (macro--) {
			if (!_global.macros[macro].status.noToolbar) {
				var macro_mc = macros_mc.attachMovie("bi.ui.Button", "macro" + counter + "_mc", macro, {settings:{width:_global.settings.macroBtnWidth, height:_global.settings.macroBtnHeight, label:_global.macros[macro].name, fontSize:_global.settings.macroBtnFontSize}});
				macro_mc.macroID = macro;
				if (_global.macros[macro].type == "dual") {
					if (_global.macroStatus[macro] == 1) {
						macro_mc.label = _global.macros[macro].controls[1].command;
						macro_mc.macroName = _global.macros[macro].controls[1].command;
						macro_mc.onChangeID = 0;
					} else {
						macro_mc.label = _global.macros[macro].controls[0].command;
						macro_mc.macroName = _global.macros[macro].controls[0].command;
						macro_mc.onChangeID = 1;
					}
					macro_mc.press = function () {
						if (isAuthenticated("superuser") || !_global.macros[this.macroID].status.isSecure) {
							sendCmd("MACRO", "run", this.macroName);
							_global.macroStatus[this.macroID] = this.onChangeID;
							this.highlight = true;;
						}
					}
					macro_mc.addEventListener("press", macro_mc);
				} else {
					if (_global.macros[macro].running) {
						macro_mc.highlight = true;
					}
					macro_mc.macroName = _global.macros[macro].name;
					
					macro_mc.press = function () {
						if (isAuthenticated("superuser") || !_global.macros[this.macroID].status.isSecure) {
							if (_global.macros[this.macroID].running) {
								sendCmd("MACRO", "abort", this.macroName);
								this.highlight = false;
							} else {
								sendCmd("MACRO", "run", this.macroName);
								this.highlight = true;
							}
						}
					}
					macro_mc.addEventListener("press", macro_mc);
				}
				
				macro_mc._y = -(_global.settings.macroBtnHeight + _global.settings.macroBtnSpacing) * counter;
				counter++;
			}
			if (counter == 14) break;
		}
	}
}

renderZones = function () {
	//var maxZoneWidth = 0;
	//var maxZoneHeight = 0;
	var cycleCount = 0;
	var zoneLabelCount = 0;
	var zoneCount = 0;
	for (var zone=0; zone<_global.zones.length; zone++) {
		if (_global.settings.device != "pda" || !_global.zones[zone].skipForPDA) {
			var zone_mc = zones_mc.createEmptyMovieClip("zone" + zoneCount++ + "_mc", zone);
			renderZone(_global.zones[zone], zone_mc);
			
			if (_global.settings.device == "pda") {
				zone_mc.rooms_mc._x = Math.round((_global.settings.applicationWidth / 2) - (zone_mc.rooms_mc._width / 2));
				zone_mc.rooms_mc._y = Math.round(((_global.settings.applicationHeight - _global.settings.zonesY) / 2) - (zone_mc.rooms_mc._height / 2));			
			} else if (_global.zones[zone].alignment == "center") {
				//if (zone_mc._width > maxZoneWidth) maxZoneWidth = zone_mc._width;
				//if (zone_mc._height > maxZoneHeight) maxZoneHeight = zone_mc._height;
				zone_mc.zoneContainer_mc.onEnterFrame = function () {
					var map_mc = this.map_mc;
					if (!map_mc || map_mc._width > 4) {
						this._x = Math.round(((_global.settings.applicationWidth - 121) / 2) - (this._width / 2));
						this._y = Math.round(((_global.settings.applicationHeight - zones_mc._y) / 2) - (this._height / 2));
						delete this.onEnterFrame;
					}
				}
			}
			
			if (_global.zones[zone].cycle && _global.settings.device != "pda") cycleCount++;
	
			zone_mc.zoneObj = _global.zones[zone];
			zone_mc._visible = false;
			zone_mc.fadeOut = function (fadeRate) {
				this.fadeRate = fadeRate;
				this.onEnterFrame = function () {
					if (this._alpha > 0) {
						this._alpha -= fadeRate;
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
						this._alpha += this.fadeRate;
					} else {
						delete this.onEnterFrame;
					}
				}
			}
			
			if (_global.zones.length > 1 && _global.settings.device != "pda" && !zones[zone].hideFromList) {
				var zoneLabel_mc = zoneLabels_mc.attachMovie("bi.ui.Button", "zoneLabel" + zoneLabelCount + "_mc", zoneLabelCount, {settings:{width:_global.settings.zoneBtnWidth, height:_global.settings.zoneBtnHeight, label:zones[zone].name, fontSize:_global.settings.zoneBtnFontSize}});
				
				zoneLabel_mc._x = (_global.settings.zoneBtnWidth + _global.settings.zoneBtnSpacing) * zoneLabelCount++;
	
				zoneLabel_mc.zoneId = zone;
				zoneLabel_mc.zones_mc = zones_mc;
				zoneLabel_mc.zoneObj = _global.zones[zone]
	
				zoneLabel_mc.press = function () {
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
				zoneLabel_mc.addEventListener("press", zoneLabel_mc);
			}
		}
	}
	
	zones_mc.zone0_mc._visible = true;
	overlay_mc.title_txt.text = _global.zones[0].name;
	zones_mc.numZones = _global.zones.length;
	zones_mc.currentZone = 0;

	if (_global.settings.device == "pda") {
		var macros_mc = zones_mc.createEmptyMovieClip("macros_mc", 100);
		macros_mc._visible = false;
	}
	
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
			if (_global.settings.device == "pda") {
				//zone_mc._x = Math.round((_global.settings.applicationWidth / 2) - (maxZoneWidth / 2));
			} else {
				//zone_mc._x = Math.round(((_global.settings.applicationWidth - 121) / 2) - (maxZoneWidth / 2));
			}
			//zone_mc._y = Math.round(((_global.settings.applicationHeight - zones_mc._y) / 2) - (maxZoneHeight / 2));
		}
	}
}

renderZone = function (zone, clip) {
	if (_global.settings.device == "pda") {
		var rooms_mc = clip.createEmptyMovieClip("rooms_mc", 100);
		var rooms = zone.rooms;
		var col = 0;
		var row = 0;
		var colBreak = (rooms.length > 10) ? Math.floor(rooms.length / 2) : -1;
		for (var room=0; room<rooms.length; room++) {
			var button_mc = rooms_mc.attachMovie("bi.ui.Button", "room" + room + "_btn", room, {settings:{width:200, height:45, label:rooms[room].name}});
	
			button_mc._x = col * (button_mc._width + 4);
			button_mc._y = row * (button_mc._height + 2);
			button_mc.roomObj = rooms[room];
			button_mc.press = function () {
				openRoomControl(this.roomObj, null);
			}
			button_mc.addEventListener("press", button_mc);
			
			if (room == colBreak) {
				col++;
				row = 0;
			} else {
				row++;
			}
		}
	} else {
		var zoneContainer_mc = clip.createEmptyMovieClip("zoneContainer_mc", 100);
		if (zone.background.length && _global.settings.device != "pda") {
			var bg_mc = clip.createEmptyMovieClip("bg_mc", 10);
			var holder_mc = bg_mc.createEmptyMovieClip("holder_mc", 0);
			holder_mc._y -= _global.settings.zonesY;
			holder_mc.loadMovie(_global.settings.libLocation + "backgrounds/" + zone.background);
			bg_mc.onEnterFrame = function () {
				if (this.holder_mc._width > 4) {
					this.holder_mc._width = _global.settings.applicationWidth;
					this.holder_mc._height = _global.settings.applicationHeight;
					delete this.onEnterFrame;
				}
			}
		}
		if (zone.map.length) {
			var shadow_mc = zoneContainer_mc.createEmptyMovieClip("shadow_mc", 99);
			var map_mc = zoneContainer_mc.createEmptyMovieClip("map_mc", 100);
			shadow_mc.loadMovie(_global.settings.libLocation + "maps/" + zone.map);
			shadow_mc._x = shadow_mc._y = 1;
			shadow_mc._alpha = 50;
			new Color(shadow_mc).setRGB(0x000000);
			map_mc.loadMovie(_global.settings.libLocation + "maps/" + zone.map);
		}
		var rooms = zone.rooms;
		if (rooms.length) {
			var rooms_mc = zoneContainer_mc.createEmptyMovieClip("rooms_mc", 50);
			var alerts_mc = zoneContainer_mc.createEmptyMovieClip("alerts_mc", 300);
			var doors_mc = zoneContainer_mc.createEmptyMovieClip("doors_mc", 400);
		}
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
			
			if (rooms[room].window.tabs.length) {
				room_mc.onPress2 = function () {
					if (this.roomObj.canOpen == undefined || isAuthenticated(this.roomObj.canOpen)) {
						this._alpha = 100;
						var timeBeforeFade = new Tween(this, null, Regular.easeInOut, 0, 0, _global.settings.roomHighlightTime, true);
						timeBeforeFade.obj = this;
						timeBeforeFade.onMotionFinished = function () {
							if (_global.settings.roomFadeRate) {
								new Tween(this.obj, "_alpha", Regular.easeInOut, 100, 0, _global.settings.roomFadeRate, true);
							} else {
								this.obj._alpha = 0;
							}
						}
						this.onEnterFrame = function () {
							openRoomControl(this.roomObj, this);
							delete this.onEnterFrame;
						}
					}
				}
			} else if (rooms[room].switchZone.length) {
				room_mc.onPress2 = function () {
					if (this.roomObj.canOpen == undefined || isAuthenticated(this.roomObj.canOpen)) {
						this.counter = 0;
						this._alpha = 100;
						this.onEnterFrame = function () {
							if (this.counter == 3) {
								this._alpha = 0;
								
								zones_mc["zone" + zones_mc.currentZone + "_mc"]._alpha = 0;
								zones_mc["zone" + zones_mc.currentZone + "_mc"]._visible = false;
								zones_mc["zone" + zones_mc.currentZone + "_mc"].panels_mc.onHide();
								
								for (var i=0; i<_global.zones.length; i++) {
									if (_global.zones[i].name == this.roomObj.switchZone) {
										var zoneID = i;
										break;
									}
								}
								zones_mc.currentZone = zoneID;
								
								zones_mc["zone" + zones_mc.currentZone + "_mc"]._alpha = 100;
								zones_mc["zone" + zones_mc.currentZone + "_mc"]._visible = true;
								zones_mc["zone" + zones_mc.currentZone + "_mc"].panels_mc.onShow();
								
								delete this.onEnterFrame;
								delete this.counter;
							} else {
								this.counter++;
							}
						}
					}
				}
			}
			var alertGroups = rooms[room].alertGroups;
			var depth = 1;
			for (var alertGroup=0; alertGroup<alertGroups.length; alertGroup++) {
				var roomAlerts_mc = alerts_mc.createEmptyMovieClip("roomAlerts" + room + "_" + alertGroup + "_mc", alerts_mc.getNextHighestDepth());
				roomAlerts_mc.room_mc = room_mc;
				roomAlerts_mc.alertsObj = alertGroups[alertGroup].alerts;
				roomAlerts_mc.alertsPosObj = alertGroups[alertGroup].alertsPos;
				if (alertGroups[alertGroup].alertsPos.x == undefined) {
					alertGroups[alertGroup].alertsPos.x = room_mc.alertCenterX;
					alertGroups[alertGroup].alertsPos.y = room_mc.alertCenterY;
				}
				var alerts = alertGroups[alertGroup].alerts;
				for (var alert=0; alert<alerts.length; alert++) {
					var alert_mc = roomAlerts_mc.attachMovie("bi.ui.Icon", "alert" + alert + "_mc", alert + 10, {settings:{iconName:alerts[alert].icon, size:24}});
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
		
						this._x = this.alertsPosObj.x - (width / 2);
						this._y = this.alertsPosObj.y - (height / 2);
					}
				}
				roomAlerts_mc.layoutAlerts();
			}
			var doors = rooms[room].doors;
			var room_mc = doors_mc.createEmptyMovieClip("room" + room + "_mc", room);
			for (var door=0; door<doors.length; door++) {
				var door_mc = room_mc.createEmptyMovieClip("door" + door + "_mc", door);
				if (doors[door].thickness == undefined) {
					var pos = doors[door].pos;
					if (doors[door].colour != undefined) {
						door_mc.beginFill(doors[door].colour);
					} else if (doors[door].colours != undefined) {
						door_mc.colours = doors[door].colours;
						door_mc.beginFill(0xFFFFFF);
					} else {
						door_mc.beginFill(_global.settings.zoneDoorColour);
					}
					door_mc.drawRect(pos[0], pos[1], pos[2], pos[3]);
					door_mc.endFill();
				} else {
					var pos = doors[door].pos;
					if (doors[door].colour1 != undefined) {
						door_mc.colours = [doors[door].colour1, doors[door].colour2];
					} else {
						door_mc.colours = [_global.settings.zoneDoorColour, _global.settings.zoneDoorColour];
					}
					door_mc.moveTo(pos[0], pos[1]);
					door_mc.lineStyle(doors[door].thickness, door_mc.colours[0], 100, true, "normal", "none");
					door_mc.lineTo(pos[2], pos[3]);
				}
				door_mc.update = function (key, state, value) {
					if (this.colours.length) {
						if (state == "on") {
							new Color(this).setRGB(this.colours[1]);
						} else {
							new Color(this).setRGB(this.colours[0]);
						}
					} else {
						this._visible = (state == "on");
					}
				}
				subscribe(doors[door].key, door_mc);
				door_mc.update();
			}
		}
		var panels = zone.panels;
		if (panels.length) {
			var panels_mc = zoneContainer_mc.createEmptyMovieClip("panels_mc", 600);

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
			label_tf.font = "bi.ui.Fonts:" + _global.settings.defaultFont;
			
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
		if (arbitrary.length) var arbitrary_mc = zoneContainer_mc.createEmptyMovieClip("arbitrary_mc", 500);
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
					label_tf.font = "bi.ui.Fonts:" + _global.settings.defaultFont;
					
					item_mc.label_txt.embedFonts = true;
					item_mc.label_txt.selectable = false;
					item_mc.label_txt.autoSize = true;
					item_mc.label_txt.setNewTextFormat(label_tf);
					item_mc.label_txt.text = arbitrary[item].label;
					item_mc.arbitraryObj = arbitrary[item];
					
					var dropShadow = new DropShadowFilter(0, 0, 0x000000, 10, 4, 4, 1);
					item_mc.label_txt.filters = [dropShadow];
		
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
				case "object":
					var obj_mc = item_mc.createEmptyMovieClip("obj_mc", 10);
					obj_mc.loadMovie(_global.settings.libLocation + "objects/" + arbitrary[item].src);
					item_mc._x = arbitrary[item].x;
					item_mc._y = arbitrary[item].y;
					item_mc.width = arbitrary[item].width;
					item_mc.height = arbitrary[item].height;
					item_mc._rotation = arbitrary[item].rotation;
					item_mc.onEnterFrame = function () {
						if (this.obj_mc._width > 4) {
							this.obj_mc._width = this.width;
							this.obj_mc._height = this.height;
							delete this.onEnterFrame;
						}
					}
					if (arbitrary[item].key != undefined) {
						item_mc.show = arbitrary[item].show;
						item_mc.hide = arbitrary[item].hide;
						item_mc.update = function (key, state, value) {
							if (this.show == state) {
								this._visible = true;
							} else if (this.hide == state) {
								this._visible = false;
							}
						}
						subscribe(arbitrary[item].key, item_mc);
					}
					break;
				case "icon":
					var icon_mc = item_mc.attachMovie("bi.ui.Icon", "icon_mc", 0);
					item_mc.key = arbitrary[item].key;
					
					if (arbitrary[item].icon != undefined) {
						item_mc.icon = arbitrary[item].icon;
						icon_mc.iconName = item_mc.icon;
					} else if (arbitrary[item].icons != undefined) {
						item_mc.icons = arbitrary[item].icons.split(",");
						icon_mc.iconName = item_mc.icons[0];
						item_mc.commands = arbitrary[item].commands.split(",");
					}

					if (arbitrary[item].commands != undefined) {
						item_mc.commands = arbitrary[item].commands.split(",");
						item_mc.onPress2 = function () {
							updateKey(this.key, this.commands[this.arrayPos], this.extra);
						}
					}
					
					item_mc.extra = arbitrary[item].extra;
					item_mc.arrayPos = 0;
					icon_mc.size = (arbitrary[item].size == undefined) ? 25 : Number(arbitrary[item].size);
					item_mc._x = Math.round(arbitrary[item].x - (icon_mc.size / 2));
					item_mc._y = Math.round(arbitrary[item].y - (icon_mc.size / 2));
					
					if (arbitrary[item].label != undefined || arbitrary[item].labels != undefined) {
						item_mc.createTextField("label_txt", 10, 0, 20, 24, 15);
	
						var label_tf = new TextFormat();
						label_tf.color = 0xFFFFFF;
						label_tf.size = 11;
						label_tf.bold = true;
						label_tf.align = "center";
						label_tf.font = "bi.ui.Fonts:" + _global.settings.defaultFont;
						
						item_mc.label_txt.embedFonts = true;
						item_mc.label_txt.selectable = false;
						item_mc.label_txt.setNewTextFormat(label_tf);
					}
					
					if (arbitrary[item].label != undefined) {
						item_mc.label = arbitrary[item].label;
						item_mc.label_txt = arbitrary[item].label;
					} else if (arbitrary[item].labels != undefined) {
						item_mc.labels = arbitrary[item].labels.split(",");
					}
					
					if (arbitrary[item].key != undefined) {
						item_mc.update = function (key, state, value) {
							if (this.commands[0] == state) {
								if (this.icons.length) this.icon_mc.iconName = this.icons[1];
								if (this.labels.length) this.label_txt.text = this.labels[1];
								this.arrayPos = 1;
							} else if (this.commands[1] == state) {
								if (this.icons.length) this.icon_mc.iconName = this.icons[0];
								if (this.labels.length) this.label_txt.text = this.labels[0];
								this.arrayPos = 0;
							}
							if (this.label_txt != undefined && value != undefined) {
								//this.label_txt.text = value;
							}
						}
						subscribe(arbitrary[item].key, item_mc);
					}
					break;
				case "button":
					item_mc._x = arbitrary[item].x;
					item_mc._y = arbitrary[item].y;
					arbitrary[item].mode = "toggle";
					
					var button_mc = attachButton(item_mc, arbitrary[item].key, arbitrary[item], "button_mc", 0, arbitrary[item].width, arbitrary[item].height);
					if (buttonObj.macro != undefined) {
						subscribe("MACRO", button_mc);
					} else {
						subscribe(arbitrary[item].key, button_mc);
					}
					break;
					/*
					var button_mc = item_mc.attachMovie("bi.ui.Button", "button_mc", 0, {settings:{width:arbitrary[item].width, height:arbitrary[item].height, bgColour:arbitrary[item].bgColour, borderColour:arbitrary[item].borderColour, fontSize:arbitrary[item].fontSize, fontColour:arbitrary[item].fontColour}});
					item_mc.key = arbitrary[item].key;
					
					if (arbitrary[item].icon != undefined) {
						icon_mc.iconName = item_mc.icon;
					} else if (arbitrary[item].icons != undefined) {
						item_mc.icons = arbitrary[item].icons.split(",");
						button_mc.iconName = item_mc.icons[0];
					}
										
					item_mc.mode = arbitrary[item].mode;
					item_mc.command = arbitrary[item].command;
					item_mc.commands = arbitrary[item].commands.split(",");
					item_mc.extra = arbitrary[item].extra;
					item_mc.extras = arbitrary[item].extras.split("|");
					item_mc.allExtras = [arbitrary[item].extra];
					for (var i=2; i<7; i++) {
						if (arbitrary[item]["extra" + i] != undefined) {
							item_mc.allExtras.push(arbitrary[item]["extra" + i]);
						} else {
							break;
						}
					}
					item_mc.repeatRate = items[item].repeatRate;
					item_mc.arrayPos = 0;
					item_mc._x = arbitrary[item].x;
					item_mc._y = arbitrary[item].y;
					
					if (arbitrary[item].label != undefined || arbitrary[item].labels != undefined) {
						item_mc.createTextField("label_txt", 10, 0, 20, 24, 15);
	
						var label_tf = new TextFormat();
						label_tf.color = 0xFFFFFF;
						label_tf.size = 11;
						label_tf.bold = true;
						label_tf.align = "center";
						label_tf.font = "bi.ui.Fonts:" + _global.settings.defaultFont;
						
						item_mc.label_txt.embedFonts = true;
						item_mc.label_txt.selectable = false;
						item_mc.label_txt.setNewTextFormat(label_tf);
					}
					
					if (arbitrary[item].label != undefined) {
						item_mc.button_mc.label = arbitrary[item].label;
					} else if (arbitrary[item].labels != undefined) {
						item_mc.labels = arbitrary[item].labels.split(",");
						item_mc.button_mc.label = item_mc.labels[0];
					}
					
					if (arbitrary[item].key != undefined) {
						item_mc.update = function (key, state, value) {
							if (this.commands[0] == state) {
								if (this.icons.length) this.button_mc.iconName = this.icons[1];
								if (this.labels.length) this.button_mc.label = this.labels[1];
								this.arrayPos = 1;
							} else if (this.commands[1] == state) {
								if (this.icons.length) this.button_mc.iconName = this.icons[0];
								if (this.labels.length) this.button_mc.label = this.labels[0];
								this.arrayPos = 0;
							}
						}
						subscribe(arbitrary[item].key, item_mc);
					}
					button_mc.press = function () {
						performAction(this._parent.key, this._parent.commands[this._parent.arrayPos], this._parent.extra);
					}
					button_mc.addEventListener("press", button_mc);
					break;
					*/
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
	
	var scrollUp_mc = mc.attachMovie("bi.ui.Button", "scrollUp_mc", 10, {settings:{width:34, height:34, iconName:"up-arrow"}});
	scrollUp_mc.repeatRate = 200;
	scrollUp_mc.press = function () {
		this.repeatID = setInterval(this, "action", this.repeatRate);
		this.action();
	}
	scrollUp_mc.release = function () {
		clearInterval(this.repeatID);
	}
	scrollUp_mc.addEventListener("press", scrollUp_mc);
	scrollUp_mc.addEventListener("release", scrollUp_mc);
	scrollUp_mc.action = function () {
		var p = this._parent._parent;
		
		if (p.startRow > 0) {
			p.startRow--;
			p[this._parent.func]();
		} else {
			clearInterval(this.repeatID);
		}
	}	

	var scrollDown_mc = mc.attachMovie("bi.ui.Button", "scrollDown_mc", 20, {settings:{width:34, height:34, iconName:"down-arrow"}});
	scrollDown_mc._y = height - 34;
	
	scrollDown_mc.repeatRate = 200;
	scrollDown_mc.press = function () {
		this.repeatID = setInterval(this, "action", this.repeatRate);
		this.action();
	}
	scrollDown_mc.release = function () {
		clearInterval(this.repeatID);
	}
	scrollDown_mc.addEventListener("press", scrollDown_mc);
	scrollDown_mc.addEventListener("release", scrollDown_mc);
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
	var windowObject = new Object();
	for (var attr in statusObj) {
		if (attr.substr(0, 6) == "window") {
			if (statusObj[attr] == Number(statusObj[attr])) {
				windowObject[attr.substr(6, 1).toLowerCase() + attr.substr(7)] = Number(statusObj[attr]);
			} else if (statusObj[attr] == "true" || statusObj[attr] == "false") {
				windowObject[attr.substr(6, 1).toLowerCase() + attr.substr(7)] = (statusObj[attr] == "true");
			} else {
				windowObject[attr.substr(6, 1).toLowerCase() + attr.substr(7)] = statusObj[attr];
			}
		}
	}
	windowObject.title = "Status: " + statusObj.name;
	windowObject.iconName = statusObj.icon;
	
	var window_mc = showWindow(windowObject);

	window_mc.content_mc.statusObj = statusObj;
	window_mc.content_mc.startRow = 0;
	
	window_mc.content_mc.update = function () {
		var statusObj = this.statusObj;
		
		var labels_mc = this.createEmptyMovieClip("labels_mc", 10);
		
		var label_tf = new TextFormat();
		label_tf.color = 0xFFFFFF;
		label_tf.size = 16;
		label_tf.bold = true;
		label_tf.font = "bi.ui.Fonts:" + _global.settings.defaultFont;

		var controls = new Array();
		for (var i=0; i<statusObj.controls.length; i++) {
			if (_global.controls[statusObj.controls[i].key].storedStates["state"] == statusObj.show) {
				controls.push(_global.controls[statusObj.controls[i].key]);
			}
		}
		this.maxItems = controls.length;
		this.itemsPerPage = Math.floor((this.height + 5) / 35);
		if (this.maxItems == 0) {
			this._parent.close();
		} else if (controls.length > this.itemsPerPage) {
			this.scrollBar_mc._visible = true;
			this.scrollBar_mc.scrollUp_mc.enabled = this.startRow > 0;
			this.scrollBar_mc.scrollDown_mc.enabled = this.startRow + this.itemsPerPage < this.maxItems;
			var labelWidth = this.width - 40;
		} else {
			var labelWidth = this.width;
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
	createScrollBar(scrollBar_mc, window_mc.content_mc.height, "update");
	scrollBar_mc._x = window_mc.content_mc.width - scrollBar_mc._width;
	
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

#include "openRoomControl.as"

openAbout = function () {
	var window_mc = showWindow({width:600, height:500, title:"About eLIFE", iconName:"home"});
	var content_mc = window_mc.content_mc;

	var aboutTxt_mc = content_mc.createEmptyMovieClip("aboutTxt_mc", 50);
	var bg_mc = aboutTxt_mc.createEmptyMovieClip("bg_mc", 0);
	bg_mc.beginFill(0xA6B4C9);
	bg_mc.drawRect(0, 0, content_mc.width, content_mc.height - 40);
	bg_mc.endFill();
	var about_tf = new TextFormat();
	about_tf.color = 0x000000;
	about_tf.size = 12;
	about_tf.bold = true;
	about_tf.font = "bi.ui.Fonts:" + _global.settings.defaultFont;
	var about_txt = aboutTxt_mc.createTextField("about_txt", 10, 10, 10, bg_mc._width - 20, bg_mc._height - 20);
	about_txt.embedFonts = true;
	about_txt.selectable = false;
	about_txt.wordWrap = true;
	about_txt.multiline = true;
	about_txt.html = true;
	about_txt.setNewTextFormat(about_tf);
	about_txt.htmlText = "This is a test. hello world.";
	
	var aboutMask_mc = content_mc.createEmptyMovieClip("aboutMask_mc", 100);
	aboutMask_mc.beginFill(0xFFCC00);
	aboutMask_mc.drawRect(0, 0, bg_mc._width, bg_mc._height);
	aboutMask_mc.endFill();
	
	aboutTxt_mc.setMask(aboutMask_mc);
	
	var loadAboutText = new LoadVars();
	loadAboutText.onData = function (src) {
		about_txt.htmlText = src;
	}
	loadAboutText.load(_global.settings.integratorHtml);
	
	var info_tf = new TextFormat();
	info_tf.color = 0xFFFFFF;
	info_tf.size = 12;
	info_tf.bold = true;
	info_tf.font = "bi.ui.Fonts:" + _global.settings.defaultFont;
	info_tf.align = "center";
	
	var info_txt = content_mc.createTextField("info_txt", 10, 0, 0, content_mc.width, 20);
	info_txt.embedFonts = true;
	info_txt.selectable = false;
	info_txt.wordWrap = true;
	info_txt.multiline = true;
	info_txt.autoSize = true;
	info_txt.setNewTextFormat(info_tf);
	
	var upTime = getTimer() - _global.clientStartTime; 
	upTime = upTime.timeFormat();
	
	info_txt.text = _global.systemInformation + "\nClient: v" + _global.clientVersion + "  Server: v" + _global.serverVersion + " Uptime: " + upTime;
	info_txt._y = content_mc.height - info_txt._height;	
	
	//aboutBrowser = new mdm.Browser(Math.round((window_mc._x + content_mc._x) / _global.screenRatio), Math.round((window_mc._y + content_mc._y) / _global.screenRatio), Math.round(content_mc.width / _global.screenRatio), Math.round((content_mc.height - about_txt._height) / _global.screenRatio), _global.settings.integratorHtml, "false");

	window_mc.onClose = function () {
		//aboutBrowser.close();
	}
}

toggleTV = function () {
	if (tvStatus == "open") {
		_root.tvHolder_mc.removeMovieClip();
		var tmp = mdm.System.execStdOut(_global.settings.vlcClose);
		tvStatus = "closed";
	} else {
		_root.attachMovie("tvHolder", "tvHolder_mc", 6000);
		_root.tvHolder_mc._x = 570;
		_root.tvHolder_mc._y = 510;
		mdm.Process.create("VLC", 0, 0, 0, 0, "", _global.settings.vlcOpen, "c:\\", 2, 4);
		tvStatus = "open";
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
	var window_mc = showWindow({width:"full", height:"full", title:"Browser", iconName:"atom", noAutoClose:true});
	window_mc.onClose = function () {
		webBrowser.close();
		clearInterval(this.content_mc.checkBusyId);
	}
	
	window_mc.content_mc.attachMovie("bi.ui.Button", "back_btn", 50, {settings:{width:48, height:48, iconName:"left-arrow"}});
	window_mc.content_mc.back_btn.press = function () {
		webBrowser.back();
	}
	window_mc.content_mc.back_btn.addEventListener("press", window_mc.content_mc.back_btn);

	window_mc.content_mc.attachMovie("bi.ui.Button", "fwd_btn", 51, {settings:{width:48, height:48, iconName:"right-arrow"}});
	window_mc.content_mc.fwd_btn._x = 50;
	window_mc.content_mc.fwd_btn.press = function () {
		webBrowser.forward();
	}
	window_mc.content_mc.fwd_btn.addEventListener("press", window_mc.content_mc.fwd_btn);
	
	window_mc.content_mc.attachMovie("bi.ui.Button", "stop_btn", 52, {settings:{width:48, height:48, iconName:"stop"}});
	window_mc.content_mc.stop_btn._x = 100;
	window_mc.content_mc.stop_btn.press = function () {
		webBrowser.stop();
	}
	window_mc.content_mc.stop_btn.addEventListener("press", window_mc.content_mc.stop_btn);
	
	window_mc.content_mc.attachMovie("bi.ui.Button", "refresh_btn", 53, {settings:{width:48, height:48, iconName:"refresh"}});
	window_mc.content_mc.refresh_btn._x = 150;
	window_mc.content_mc.refresh_btn.press = function () {
		webBrowser.refresh();
	}
	window_mc.content_mc.refresh_btn.addEventListener("press", window_mc.content_mc.refresh_btn);
	
	window_mc.content_mc.attachMovie("bi.ui.Button", "home_btn", 54, {settings:{width:48, height:48, iconName:"home"}});
	window_mc.content_mc.home_btn._x = 200;
	window_mc.content_mc.home_btn.press = function () {
		webBrowser.goto(_global.settings.defaultBrowserURL);
	}
	window_mc.content_mc.home_btn.addEventListener("press", window_mc.content_mc.home_btn);
	
	window_mc.content_mc.attachMovie("bi.ui.Button", "keyboard_btn", 55, {settings:{width:48, height:48, iconName:"keyboard_key"}});
	window_mc.content_mc.keyboard_btn._x = 250;
	window_mc.content_mc.keyboard_btn.press = function () {
		webBrowser.hide();
		this.goto = function (url, caller) {
			webBrowser.show();
			if (url.length) {
				webBrowser.goto(url);
			}
		}
		showKeyboard(50, this.goto, this._parent, "http://", false, "web");
	}
	window_mc.content_mc.keyboard_btn.addEventListener("press", window_mc.content_mc.keyboard_btn);
	
	window_mc.content_mc.attachMovie("bi.ui.Button", "find_btn", 56, {settings:{width:48, height:48, iconName:"find"}});
	window_mc.content_mc.find_btn._x = 300;
	window_mc.content_mc.find_btn.press = function () {
		webBrowser.hide();
		this.search = function (query, caller) {
			webBrowser.show();
			if (query.length) {
				webBrowser.goto("http://www.google.com/search?&q=" + query);
			}
		}
		showKeyboard(20, this.search);			
	}
	window_mc.content_mc.find_btn.addEventListener("press", window_mc.content_mc.find_btn);

	window_mc.content_mc.checkBusy = function () {
		this.stop_btn._visible = webBrowser.isBusy;
	}
	webBrowser = new mdm.Browser(Math.round((window_mc._x + window_mc.content_mc._x) / _global.screenRatio), Math.round((window_mc._y + window_mc.content_mc._y + 50) / _global.screenRatio), Math.round(window_mc.content_mc.width / _global.screenRatio), Math.round((window_mc.content_mc.height - 54) / _global.screenRatio), _global.settings.defaultBrowserURL, "false");
	window_mc.content_mc.checkBusyId = setInterval(window_mc.content_mc, "checkBusy", 500);
}

openAuthentication = function () {
	if (!isAuthenticated("superuser")) {
		openPinPad(authenticateUser);
	} else if (_global.settings.adminPin) {
		setAuthenticated(false);
	}	
}

openControlPanel = function () {
	var window_mc = showWindow({id:"controlPanel", width:"full", height:"full", title:"Control Panel", iconName:"gears", autoClose:false});
	appsBar_mc.openControlPanel_mc.showHighlight();
	window_mc.onClose = function () {
		for (var i=0; i<this.contentClip.tabs_mc.tabData.length; i++) {
			this.contentClip.tabs_mc.contentClips[i].onClose();
		}
	}
	var tabs_mc = window_mc.contentClip.attachMovie("bi.ui.Tabs", "tabs_mc", 0, {settings:{width:window_mc.contentClip.width, height:window_mc.contentClip.height}});
	tabs_mc.tabData = [{name:"Macros", iconName:"atom", func:"createMacroAdmin"}, {name:"Scripts", iconName:"notepad", func:"createScriptsAdmin"}, {name:"Volume Control", iconName:"speaker", func:"createVolumeControl"}, {name:"Clean Screen", iconName:"spanner", func:"createCleanScreen"}, {name:"Screen Saver", iconName:"power-green", func:"createScreenSaverPanel"}, {name:"External Applications", iconName:"red-pin", func:"createAppsPanel"}, {name:"Users", iconName:"people", func:"createUsersPanel"}];
	
	for (var i=0; i<tabs_mc.tabData.length; i++) {
		_root[tabs_mc.tabData[i].func](tabs_mc.contentClips[i]);
	}
	
	tabs_mc.originalTitle = "Admin";
	tabs_mc.changeTab = function (eventObj) {
		// set window title
		this._parent._parent.title = this.originalTitle + ": " + eventObj.name;
	}
	tabs_mc.addEventListener("changeTab", tabs_mc);
	tabs_mc.activeTab = 0;
}

openLogs = function () {
	var windowObject = {width:"full", height:"full", title:"logs", iconName:"notepad"};
	for (var attr in _global.logging) {
		if (attr.substr(0, 6) == "window") {
			if (_global.logging[attr] == Number(_global.logging[attr])) {
				windowObject[attr.substr(6, 1).toLowerCase() + attr.substr(7)] = Number(_global.logging[attr]);
			} else if (_global.logging[attr] == "true" || _global.logging[attr] == "false") {
				windowObject[attr.substr(6, 1).toLowerCase() + attr.substr(7)] = (_global.logging[attr] == "true");
			} else {
				windowObject[attr.substr(6, 1).toLowerCase() + attr.substr(7)] = _global.logging[attr];
			}
		}
	}
	
	var window_mc = showWindow(windowObject);
	
	appsBar_mc.openLogs_mc.showHighlight();
	window_mc.onClose = function () {
		this.contentClip.tabs_mc.contentClips[this.contentClip.tabs_mc.activeTab].onHide();
	}
	
	var tabs_mc = window_mc.contentClip.attachMovie("bi.ui.Tabs", "tabs_mc", 0, {settings:{width:window_mc.contentClip.width, height:window_mc.contentClip.height}});
	
	var tab_array = new Array();
	for (var i=0; i<_global.logging.groups.length; i++) {
		if (groups[group].canSee == undefined || isAuthenticated(groups[group].canSee)) {
			tab_array.push({name:_global.logging.groups[i].name, iconName:_global.logging.groups[i].icon});
		}
	}
	tabs_mc.tabData = tab_array;

	for (var i=0; i<_global.logging.groups.length; i++) {
		createLogContent(_global.logging.groups[i], tabs_mc.contentClips[i])
	}
	
	tabs_mc.originalTitle = "Logging";
	window_mc.title = room.name + ": " + tabs_mc.tabData[0].name;
	tabs_mc.changeTab = function (eventObj) {
		// set window title
		this._parent._parent.title = this.originalTitle + ": " + eventObj.name;
		// fire onShow event to active tab
		this.contentClips[eventObj.id].onShow();
		// fire onHide event to hidden clip
		this.contentClips[eventObj.oldId].onHide();
	}
	tabs_mc.addEventListener("changeTab", tabs_mc);
	tabs_mc.activeTab = 0;
}

createLogContent = function (logObj, content_mc) {

	content_mc.logObj = logObj;
	content_mc.startRow = 0;

	if (logObj.type != "web") {
		content_mc.update = function (force) {
			if (!this._visible && !force) return;
			var logObj = this.logObj;
			
			var labels_mc = this.createEmptyMovieClip("labels_mc", 10);
			
			var label_tf = new TextFormat();
			label_tf.color = 0xFFFFFF;
			label_tf.size = 16;
			label_tf.bold = true;
			label_tf.font = "bi.ui.Fonts:" + _global.settings.defaultFont;
	
			var log = logObj.log;
			
			if (logObj.type == "tally") {
				this.maxItems = logObj.controls.length;
				this.itemsPerPage = 11;
				if (this.maxItems > this.itemsPerPage) {
					this.scrollBar_mc._visible = true;
					this.scrollBar_mc.scrollUp_mc.enabled = this.startRow > 0;
					this.scrollBar_mc.scrollDown_mc.enabled = this.startRow + this.itemsPerPage < this.maxItems;
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
					this.scrollBar_mc.scrollUp_mc.enabled = this.startRow > 0;
					this.scrollBar_mc.scrollDown_mc.enabled = this.startRow + this.itemsPerPage < this.maxItems;
					var labelWidth = this.width - this.scrollBar_mc._width - 5;
				} else {
					var labelWidth = this.width;
					this.scrollBar_mc._visible = false;
				}
				var counter = 0;
				while (counter < this.itemsPerPage && this.startRow + counter < this.maxItems) {
					var label_mc = this.labels_mc.attachMovie("bi.ui.Button", "label" + counter + "_mc", counter, {settings:{width:labelWidth, height:30, label:log[counter + this.startRow].msg, align:"left"}})
					label_mc._y = counter * 34;
					label_mc.logObj = logObj;
					label_mc.event = counter + this.startRow;
					label_mc.tab = this;

					label_mc.press = function () {
						this.logObj.log.splice(this.event, 1);
						trace(this.tab);
						this.tab.update();
					}
					label_mc.addEventListener("press", label_mc);
					
					counter++;
				}
				var clear_mc = this.labels_mc.attachMovie("bi.ui.Button", "clear_mc", 200, {settings:{width:100, height:30, _y:content_mc.height - 30, label:"Clear"}})
				clear_mc.press = function () {
					this.logObj.log = new Array();
					this.tab.update();
				}
				clear_mc.logObj = logObj;
				clear_mc.tab = this;
				clear_mc.addEventListener("press", clear_mc);
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
		content_mc.update(true);
	} else {
		// for web embedded
		var bg_mc = content_mc.createEmptyMovieClip("bg_mc", 0);
		bg_mc.beginFill(0x4E75B5);
		bg_mc.drawRect(0, 0, content_mc.width, content_mc.height);
		bg_mc.endFill();

		var point = {x:bg_mc._x, y:bg_mc._y};
		bg_mc.localToGlobal(point);
		content_mc.browserSettings = {x:point.x, y:point.y, w:content_mc.width, h:Number(content_mc.height), url:logObj.url};
		content_mc.onShow = function () {
			logContent = new mdm.Browser(Math.round(this.browserSettings.x / _global.screenRatio), Math.round(this.browserSettings.y / _global.screenRatio), Math.round(this.browserSettings.w / _global.screenRatio), Math.round(this.browserSettings.h / _global.screenRatio), this.browserSettings.url, "false");
		}
		content_mc.onHide = function () {
			logContent.close();
		}
	}
}

createUsageGraphs = function (content_mc) {
	var graphs_array = ["Power", "Water", "Gas"];
	for (var i=0; i<graphs_array.length; i++) {
		var graph_mc = content_mc.createEmptyMovieClip("graph" + i + "_mc", i);
		graph_mc._y = i * 160;
		
		var label_tf = new TextFormat();
		label_tf.color = 0xFFFFFF;
		label_tf.size = 16;
		label_tf.bold = true;
		label_tf.font = "bi.ui.Fonts:" + _global.settings.defaultFont;		

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

#include "calendar.as"

#include "musicLibrary.as"

createAppsPanel = function (content_mc) {
	var btns_mc = content_mc.createEmptyMovieClip("btns_mc", 10);
	for (var app=0; app<_global.controlPanelApps.length; app++) {
		var app_btn = btns_mc.attachMovie("bi.ui.Button", "app" + app + "_btn", app, {settings:{width:180, height:30, label:_global.controlPanelApps[app].label, fontSize:12}});
		app_btn.press = function () {
			if (this.program.length) {
				mdm.System.exec(this.program);
			} else {
				sendCmd("COM_PORT", this.command, this.extra);
			}
		}
		app_btn.program = _global.controlPanelApps[app].program;
		app_btn.command = _global.controlPanelApps[app].command;
		app_btn.extra = _global.controlPanelApps[app].extra;
		app_btn._y = app * 35;
		app_btn.addEventListener("press", app_btn);
	}
	btns_mc._x = Math.round((content_mc.width / 2) - (btns_mc._width / 2));
	btns_mc._y = Math.round((content_mc.height / 2) - (btns_mc._height / 2));	
}

createScreenSaverPanel = function (content_mc) {
	content_mc.attachMovie("bi.ui.Label", "enabled_lb", 10, {settings:{width:140, text:"Enable:"}});
	content_mc.attachMovie("bi.ui.CheckBox", "enabled_cb", 15, {settings:{_x:150, selected:_global.settings.screenLockEnabled}});
	
	content_mc.enabled_cb.change = function () {
		this._parent.screensaver_mc._visible = this.selected;
		_global.persistentData.data.settings.screenLockEnabled = _global.settings.screenLockEnabled = this.selected;
		setupScreenSaver();
	}
	content_mc.enabled_cb.addEventListener("change", content_mc.enabled_cb);
	
	var screensaver_mc = content_mc.createEmptyMovieClip("screensaver_mc", 30);
	screensaver_mc._y = 35;
	
	screensaver_mc.attachMovie("bi.ui.Label", "timeout_lb", 10, {settings:{width:140, text:"Time out:"}});
	screensaver_mc.attachMovie("bi.ui.NumberPicker", "timeout_np", 15, {settings:{width:160, minValue:1, maxValue:180, step:1, _x:150}});
	screensaver_mc.timeout_np.selectedValue = _global.settings.screenLockTimeout / 60;
	screensaver_mc.timeout_np.change = function () {
		_global.persistentData.data.settings.screenLockTimeout = _global.settings.screenLockTimeout = this.selectedItem.value * 60;
		_global.persistentData.flush();
	}
	screensaver_mc.timeout_np.addEventListener("change", screensaver_mc.timeout_np);
	screensaver_mc.attachMovie("bi.ui.Label", "minutes_lb", 16, {settings:{width:60, text:"mins", _x:320}});
	
	screensaver_mc.attachMovie("bi.ui.Label", "screensaver_lb", 20, {settings:{width:140, text:"Screen saver:"}, _y:35});
	screensaver_mc.attachMovie("bi.ui.ItemPicker", "screensaver_ip", 25, {settings:{width:300, items:[{label:"Logo", value:"logo"}, {label:"Slideshow", value:"photo"}], _x:150}, _y:35});
	screensaver_mc.screensaver_ip.selectedValue = _global.settings.screenLockDisplay;
	
	var logoSettings_mc = screensaver_mc.createEmptyMovieClip("logoSettings_mc", 30);
	logoSettings_mc._y = 70;
	if (mdm.Application.path != undefined) {
		var tmp = mdm.FileSystem.getFileList(mdm.Application.path + _global.settings.libLocation + "screensaver", "*.jpg");
		var availableBackgrounds = new Array();
		for (var i=0; i<tmp.length; i++) {
			availableBackgrounds.push({label:tmp[i], value:tmp[i]});
		}
	} else {
		var availableBackgrounds = new Array({label:"bg-blue.jpg", value:"bg-blue.jpg"}, {label:"bg-green.jpg", value:"bg-green.jpg"}, {label:"bg-orange.jpg", value:"bg-orange.jpg"});
	}
	logoSettings_mc.attachMovie("bi.ui.Label", "bg_lb", 10, {settings:{width:140, text:"Background:"}});
	logoSettings_mc.attachMovie("bi.ui.ItemPicker", "bg_ip", 15, {settings:{width:300, items:availableBackgrounds, _x:150}});
	logoSettings_mc.bg_ip.selectedValue = _global.settings.screenLockLogoBg;
	logoSettings_mc.bg_ip.change = function () {
		_global.persistentData.data.settings.screenLockLogoBg = _global.settings.screenLockLogoBg = this.selectedItem.value;
		_global.persistentData.flush();
	}
	logoSettings_mc.bg_ip.addEventListener("change", logoSettings_mc.bg_ip);
	
	var photoSettings_mc = screensaver_mc.createEmptyMovieClip("photoSettings_mc", 40);
	photoSettings_mc._y = 70;
	photoSettings_mc.attachMovie("bi.ui.Label", "rotate_lb", 10, {settings:{width:140, text:"Time per photo:"}});
	photoSettings_mc.attachMovie("bi.ui.NumberPicker", "rotate_np", 15, {settings:{width:160, minValue:5, maxValue:60, step:1, _x:150}});
	photoSettings_mc.rotate_np.selectedValue = _global.settings.screenLockPhotoRotate;
	photoSettings_mc.rotate_np.change = function () {
		_global.persistentData.data.settings.screenLockPhotoRotate = _global.settings.screenLockPhotoRotate = this.selectedItem.value;
		_global.persistentData.flush();
	}
	photoSettings_mc.rotate_np.addEventListener("change", photoSettings_mc.rotate_np);
	photoSettings_mc.attachMovie("bi.ui.Label", "seconds_lb", 16, {settings:{width:80, text:"seconds", _x:320}});
	photoSettings_mc.attachMovie("bi.ui.Label", "scale_lb", 20, {settings:{width:140, text:"Scale:", _y:35}});
	photoSettings_mc.attachMovie("bi.ui.ItemPicker", "scale_ip", 25, {settings:{width:300, items:[{label:"No scale", value:"noscale"}, {label:"Scale to fit", value:"fullscreen"}], _x:150, _y:35}});
	photoSettings_mc.scale_ip.selectedValue = _global.settings.screenLockPhotoScale;
	photoSettings_mc.scale_ip.change = function () {
		_global.persistentData.data.settings.screenLockPhotoScale = _global.settings.screenLockPhotoScale = this.selectedItem.value;
		_global.persistentData.flush();
	}
	photoSettings_mc.scale_ip.addEventListener("change", photoSettings_mc.scale_ip);
	photoSettings_mc.attachMovie("bi.ui.Label", "path_lb", 30, {settings:{width:140, text:"Photo path:", _y:70}});
	photoSettings_mc.attachMovie("bi.ui.TextInput", "path_ti", 35, {settings:{width:300, text:_global.settings.screenLockPhotoPath, _x:150, _y:70, maxChars:150, inputType:"path"}});
	photoSettings_mc.path_ti.change = function () {
		_global.persistentData.data.settings.screenLockPhotoPath = _global.settings.screenLockPhotoPath = this.text;
		_global.persistentData.flush();
	}
	photoSettings_mc.path_ti.addEventListener("change", photoSettings_mc.path_ti);
	
	screensaver_mc.screensaver_ip.change = function () {
		this._parent.logoSettings_mc._visible = false;
		this._parent.photoSettings_mc._visible = false;
		if (this.selectedItem.value == "logo") {
			this._parent.logoSettings_mc._visible = true;
		} else if (this.selectedItem.value == "photo") {
			this._parent.photoSettings_mc._visible = true;
		}
		_global.persistentData.data.settings.screenLockDisplay = _global.settings.screenLockDisplay = this.selectedItem.value;
		_global.persistentData.flush();
	}
	screensaver_mc.screensaver_ip.addEventListener("change", screensaver_mc.screensaver_ip);
	
	content_mc.enabled_cb.change();
	screensaver_mc.screensaver_ip.change();
}

createUsersPanel = function (content_mc) {
	
}

createCleanScreen = function (content_mc) {
	var clean_btn = content_mc.attachMovie("bi.ui.Button", "clean_btn", 10, {settings:{width:200, height:50, label:"Clean Screen", fontSize:14}});
	clean_btn._x = Math.round((content_mc.width / 2) - (clean_btn._width / 2));
	clean_btn._y = Math.round((content_mc.height / 2) - (clean_btn._height / 2));
	clean_btn.press = function () {
		showMessageWindow({title:"Clean Screen", height:200, content:"Go ahead... Clean my screen.\n\nScreen locked for the next %t%.", icon:"spanner", hideClose:true, autoClose:20});
	}
	clean_btn.addEventListener("press", clean_btn);
}

createVolumeControl = function (content_mc) {
	var volumeControls_mc = content_mc.createEmptyMovieClip("volumeControls_mc", 10);

	var volumeSlider_mc = volumeControls_mc.createEmptyMovieClip("volumeSlider_mc", 15);
	volumeSlider_mc.icons = ["speaker","speaker"];
	createSlider(volumeSlider_mc, {w:300, h:50});
	volumeSlider_mc.update = function () {
		this.onEnterFrame = function () {
			this.setPercent(Math.round(mdm.System.getMasterVolume() / 65535 * 100));
			delete this.onEnterFrame;
		}
	}
	volumeSlider_mc.bg_mc.onPress2 = function () {
		var value = Math.floor(this._xmouse / (this._width - (this._width * .1)) * 10) * 10;
		if (value >= 0 && value <= 100) {
			mdm.System.setMasterVolume(Math.round(65535 * (value / 100)));
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
	label_tf.font = "bi.ui.Fonts:" + _global.settings.defaultFont;
		
	content_mc.createTextField("label1_txt", 1, 3, 3, 350, 20);
	var label_txt = content_mc["label1_txt"];
	label_txt.embedFonts = true;
	label_txt.selectable = false;
	label_txt.setNewTextFormat(label_tf);
	label_txt.text = "Create Macro:";
	
	var createMacroBtn_mc = content_mc.attachMovie("bi.ui.Button", "createMacroBtn_mc", 2, {width:380, height:30, label:"", fontSize:12});
	createMacroBtn_mc.updateRecordingState = function () {
		if (recordingMacro) {
			this.label = "Stop Recording";
		} else {
			this.label = "Record New Macro";
		}
	}
	createMacroBtn_mc.updateRecordingState();
	createMacroBtn_mc._y = 25;
	createMacroBtn_mc.press = function () {
		recordingMacro = !recordingMacro;
		this.updateRecordingState();
		if (recordingMacro) {
			newMacroArray = new Array();
			_global.windowStack["controlPanel"].close();
			overlay_mc.status_txt.text = "** MACRO RECORDING **";
			overlay_mc.startStatusBlink();
		} else {
			overlay_mc.status_txt.text = "";
			overlay_mc.stopStatusBlink();
			if (insertMacroObj != undefined) {
				var insert = insertMacroObj.pos;
				for (var i=0; i<newMacroArray.length; i++) {
					insertMacroObj.contents.splice(insert++, 0, newMacroArray[i]);
				}
				createMacro(insertMacroObj.name, insertMacroObj.contents);
				for (var i=0; i<_global.macros.length; i++) {
					if (_global.macros[i].name == insertMacroObj.name) {
						var macroNum = i;
						break;
					}
				}
				openMacroEdit(macroNum);
				delete insertMacroObj;
			} else {
				this.saveMacro = function (title, caller) {
					if (!title.length) var title = "untitled";
					createMacro(title, newMacroArray);
					delete newMacroArray
				}
				showKeyboard(20, this.saveMacro, this._parent)
			}
		}
	}
	createMacroBtn_mc.addEventListener("press", createMacroBtn_mc);
	
	content_mc.createTextField("label2_txt", 5, 3, 60, 490, 20);
	var label_txt = content_mc["label2_txt"];
	label_txt.embedFonts = true;
	label_txt.selectable = false;
	label_txt.setNewTextFormat(label_tf);
	label_txt.text = "Current Macros:";
	
	var rowsMask_mc = content_mc.createEmptyMovieClip("rowsMask_mc", 55);
	rowsMask_mc._y = 95;
	rowsMask_mc.beginFill(0xFFCC00, 20);
	rowsMask_mc.lineTo(content_mc.width - 40, 0);
	rowsMask_mc.lineTo(content_mc.width - 40, content_mc.height - rowsMask_mc._y);
	rowsMask_mc.lineTo(0, content_mc.height - rowsMask_mc._y);
	rowsMask_mc.endFill();
	
	// SCROLLBAR
	var scrollBar_mc = content_mc.createEmptyMovieClip("scrollBar_mc", 60);
	scrollBar_mc._x = content_mc.width - 35;
	scrollBar_mc._y = rowsMask_mc._y;
	scrollBar_mc.createEmptyMovieClip("bg_mc", 0);
	scrollBar_mc.bg_mc.beginFill(0x4E75B5);
	scrollBar_mc.bg_mc.drawRect(0, 0, 34, rowsMask_mc._height, 5);
	scrollBar_mc.bg_mc.endFill();
	scrollBar_mc.bg_mc.onPress2 = function () {
		//var p = this._parent._parent;
		//p.startRow = Math.floor((this._ymouse / this._height) * (p.maxItems - p.itemsPerPage + 1));
		//p[this._parent.func]();
	}
	
	var scrollUp_mc = scrollBar_mc.attachMovie("bi.ui.Button", "scrollUp_mc", 10, {width:34, height:34, iconName:"up-arrow"});
	scrollUp_mc.repeatRate = 200;
	scrollUp_mc.press = function () {
		this.repeatID = setInterval(this, "action", this.repeatRate);
		this.action();
	}
	scrollUp_mc.release = function () {
		clearInterval(this.repeatID);
	}
	scrollUp_mc.addEventListener("press", scrollUp_mc);
	scrollUp_mc.addEventListener("release", scrollUp_mc);
	scrollUp_mc.action = function () {
		var p = this._parent._parent.macroList_mc;
		if (p._y < this._parent._y) {
			p._y += 35;
		} else {
			clearInterval(this.repeatID);
		}
	}	

	var scrollDown_mc = scrollBar_mc.attachMovie("bi.ui.Button", "scrollDown_mc", 20, {width:34, height:34, iconName:"down-arrow"});
	scrollDown_mc._y = rowsMask_mc._height - 34;
	
	scrollDown_mc.repeatRate = 200;
	scrollDown_mc.press = function () {
		this.repeatID = setInterval(this, "action", this.repeatRate);
		this.action();
	}
	scrollDown_mc.release = function () {
		clearInterval(this.repeatID);
	}
	scrollDown_mc.addEventListener("press", scrollDown_mc);
	scrollDown_mc.addEventListener("release", scrollDown_mc);
	scrollDown_mc.action = function () {
		var p = this._parent._parent.macroList_mc;
		if (p._y + p._height > this._parent._y + this._parent._height) {
			p._y -= 35;
		} else {
			clearInterval(this.repeatID);
		}
	}
	// END SCROLL BAR
	

	content_mc.update = function (key, name) {
		var a = getTimer();
		if (name.length && name != "new" && name != "old") {
			// partial macro info came in, only update the affected row
			for (var i=0; i<_global.macros.length; i++) {
				if (_global.macros[i].name == name) {
					var macro = _global.macros[i];
					break;
				}
			}
			if (macro != undefined) {
				var row_mc = this.macroList_mc["macro" + i + "_mc"];
				row_mc.visibleBtn_mc.iconName = (macro.status.noToolbar) ? "led-red" : "led-green";
				row_mc.secureBtn_mc.iconName = (macro.status.isSecure) ? "locked" : "unlocked";
				row_mc.editBtn_mc.enabled = (!macro.status.noEdit);
				row_mc.deleteBtn_mc.enabled = (!macro.status.noDelete);
				row_mc.finishBtn_mc.enabled = (macro.running);
				row_mc.stopPlayBtn_mc.iconName = (macro.running) ? "media-stop" : "media-play";
				row_mc.spinner_mc._visible = macro.running;
			}
		} else {
			// redraw the whole list...
			var macroList_mc = this.createEmptyMovieClip("macroList_mc", 0);
			macroList_mc.setMask(this.rowsMask_mc);
			macroList_mc._y = 95;
			var label_tf = new TextFormat();
			label_tf.color = 0xFFFFFF;
			label_tf.size = 16;
			label_tf.bold = true;
			label_tf.font = "bi.ui.Fonts:" + _global.settings.defaultFont;
			var labelWidth = this.width - 40;
			
			var counter = 0;
			for (var i=0; i<_global.macros.length; i++) {
				var macro_mc = macroList_mc.createEmptyMovieClip("macro" + i + "_mc", i);
				macro_mc._y = i * 35;
				var macroNum = macro_mc.macroNum = i;
				var macro = macro_mc.macro = _global.macros[i];
				var buttonNum = 0;
				
				macro_mc.createTextField("label_txt", 20, 3, 4, labelWidth - 235, 24);
	
				var moveUpBtn_mc = macro_mc.attachMovie("bi.ui.Button", "moveUpBtn_mc", 30 + (buttonNum++), {width:50, height:28, iconName:"up-arrow"});
				moveUpBtn_mc._x = labelWidth - (buttonNum * 52);
				moveUpBtn_mc._y = 1;
				moveUpBtn_mc.press = function () {
					reorderMacros("moveUp", this._parent.macroNum);
				}
				moveUpBtn_mc.addEventListener("press", moveUpBtn_mc);
				if (i == 0) moveUpBtn_mc.enabled = false;
				
				var moveDownBtn_mc = macro_mc.attachMovie("bi.ui.Button", "moveDownBtn_mc", 30 + (buttonNum++), {width:50, height:28, iconName:"down-arrow"});
				moveDownBtn_mc._x = labelWidth - (buttonNum * 52);
				moveDownBtn_mc._y = 1;
				moveDownBtn_mc.press = function () {
					reorderMacros("moveDown", this._parent.macroNum);
				}
				moveDownBtn_mc.addEventListener("press", moveDownBtn_mc);
				if (i == _global.macros.length - 1) moveDownBtn_mc.enabled = false;
				
							
				var finishBtn_mc = macro_mc.attachMovie("bi.ui.Button", "finishBtn_mc", 30 + (buttonNum++), {width:50, height:28, iconName:"media-fwd"});
				finishBtn_mc._x = labelWidth - (buttonNum * 52);
				finishBtn_mc._y = 1;
				finishBtn_mc.press = function () {
					sendCmd("MACRO", "complete", this._parent.macro.name);
				}
				finishBtn_mc.addEventListener("press", finishBtn_mc);
				finishBtn_mc.enabled = macro.running;
			
				var stopPlayBtn_mc = macro_mc.attachMovie("bi.ui.Button", "stopPlayBtn_mc", 30 + (buttonNum++), {width:50, height:28, iconName:"media-stop"});
				stopPlayBtn_mc._x = labelWidth - (buttonNum * 52);
				stopPlayBtn_mc._y = 1;
				stopPlayBtn_mc.press = function () {
					if (this.iconName == "media-stop") {
						sendCmd("MACRO", "abort", this._parent.macro.name);
					} else {
						sendCmd("MACRO", "run", this._parent.macro.name);
					}
				}
				stopPlayBtn_mc.addEventListener("press", stopPlayBtn_mc);
								
				if (!macro.running) {
					stopPlayBtn_mc.iconName = "media-play";
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
				
				var editBtn_mc = macro_mc.attachMovie("bi.ui.Button", "editBtn_mc", 30 + (buttonNum++), {width:50, height:28, iconName:"spanner"});
				editBtn_mc._x = labelWidth - (buttonNum * 52);
				editBtn_mc._y = 1;
				editBtn_mc.press = function () {
					openMacroEdit(this._parent.macroNum);
				}
				editBtn_mc.addEventListener("press", editBtn_mc);
				editBtn_mc.enabled = !_global.macros[macroNum].status.noEdit;
				
				var deleteBtn_mc = macro_mc.attachMovie("bi.ui.Button", "deleteBtn_mc", 10 + (buttonNum++), {width:50, height:28, iconName:"delete2"});
				deleteBtn_mc._x = labelWidth - (buttonNum * 52);
				deleteBtn_mc._y = 1;
				deleteBtn_mc.press = function () {
					this.deleteMacro = function () {
						deleteMacro(this._parent.macro.name);
					}
					confirm("Are you sure you want to delete '" + this._parent.macro.name + "'?", this, "deleteMacro");
				}
				deleteBtn_mc.addEventListener("press", deleteBtn_mc);
				deleteBtn_mc.enabled = !_global.macros[macroNum].status.noDelete;
				
				if (!_global.macros[macroNum].status.noToolbar) {
					var visibleBtn_mc = macro_mc.attachMovie("bi.ui.Button", "visibleBtn_mc", 30 + (buttonNum++), {width:50, height:28, iconName:"led-green"});
				} else {
					var visibleBtn_mc = macro_mc.attachMovie("bi.ui.Button", "visibleBtn_mc", 30 + (buttonNum++), {width:50, height:28, iconName:"led-red"});
				}
				visibleBtn_mc._x = labelWidth - (buttonNum * 52);
				visibleBtn_mc._y = 1;
				visibleBtn_mc.press = function () {
					var macroObj = _global.macros[this._parent.macroNum];
					if (macroObj.status.noToolbar) {
						delete macroObj.status.noToolbar;
					} else {
						macroObj.status.noToolbar = true;
					}
					saveMacro(macroObj.name, macroObj.controls)
				}
				visibleBtn_mc.addEventListener("press", visibleBtn_mc);
				
				if (_global.macros[macroNum].status.isSecure) {
					var secureBtn_mc = macro_mc.attachMovie("bi.ui.Button", "secureBtn_mc", 30 + (buttonNum++), {width:50, height:28, iconName:"locked"});
				} else {
					var secureBtn_mc = macro_mc.attachMovie("bi.ui.Button", "secureBtn_mc", 30 + (buttonNum++), {width:50, height:28, iconName:"unlocked"});
				}
				secureBtn_mc._x = labelWidth - (buttonNum * 52);
				secureBtn_mc._y = 1;
				secureBtn_mc.press = function () {
					var macroObj = _global.macros[this._parent.macroNum];
					if (macroObj.status.isSecure) {
						delete macroObj.status.isSecure;
					} else {
						macroObj.status.isSecure = true;
					}
					saveMacro(macroObj.name, macroObj.controls)
				}
				secureBtn_mc.addEventListener("press", secureBtn_mc);
				
				macro_mc.attachMovie("spinner", "spinner_mc", 30 + (buttonNum++));
				macro_mc.spinner_mc._x = labelWidth - (buttonNum * 52) + 25;
				macro_mc.spinner_mc._y = 15;
				macro_mc.spinner_mc._visible = macro.running;
			}
			if (name == "new") {
				var scrollBar_mc = this.scrollBar_mc;
				if (macroList_mc._height > scrollBar_mc._height) {
					macroList_mc._y = scrollBar_mc._y - macroList_mc._height + scrollBar_mc._height;
				}
			}
		}
		//trace("macro list rendered in " + this._parent + ":" + (getTimer() - a) + " ms");
	}
	
	subscribe("MACRO", content_mc);

	content_mc.onClose = function () {
		unsubscribe("MACRO", this);
	}
	
	content_mc.update();
}

createScriptsAdmin = function (content_mc) {
	var label_tf = new TextFormat();
	label_tf.color = 0xFFFFFF;
	label_tf.size = 16;
	label_tf.bold = true;
	label_tf.font = "bi.ui.Fonts:" + _global.settings.defaultFont;
		
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
		label_tf.font = "bi.ui.Fonts:" + _global.settings.defaultFont;

		this.maxItems = _global.scripts.length;
		this.itemsPerPage = 14;
		if (this.maxItems > this.itemsPerPage) {
			this.scrollBar_mc._visible = true;
			this.scrollBar_mc.scrollUp_mc.enabled = this.startRow > 0;
			this.scrollBar_mc.scrollDown_mc.enabled = this.startRow + this.itemsPerPage < this.maxItems;
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
					var stopBtn_mc = item_mc.attachMovie("bi.ui.Button", "stopBtn_mc", 10, {settings:{width:50, height:28, iconName:"media-stop"}});
					stopBtn_mc._x = labelWidth - 102;
					stopBtn_mc._y = 1;
					stopBtn_mc.press = function () {
						sendCmd("SCRIPT", "abort", this._parent.script.name);
					}
					stopBtn_mc.addEventListener("press", stopBtn_mc);
				}
			} else {
				item_mc.createTextField("label_txt", 20, 3, 4, labelWidth - 160, 26);
				
				var playBtn_mc = item_mc.attachMovie("bi.ui.Button", "playBtn_mc", 10, {settings:{width:50, height:28, iconName:"media-play"}});
				playBtn_mc._x = labelWidth - 102;
				playBtn_mc._y = 1;
				playBtn_mc.press = function () {
					sendCmd("SCRIPT", "run", this._parent.script.name);
				}
				playBtn_mc.addEventListener("press", playBtn_mc);
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
				var toggleBtn_mc = item_mc.attachMovie("bi.ui.Button", "toggleBtn_mc", 30, {settings:{width:50, height:28, iconName:"power-red"}});
			} else {
				var toggleBtn_mc = item_mc.attachMovie("bi.ui.Button", "toggleBtn_mc", 30, {settings:{width:50, height:28, iconName:"power-green"}});
			}
			toggleBtn_mc._x = labelWidth - 51;
			toggleBtn_mc._y = 1;
			toggleBtn_mc.press = function () {
				var scriptObj = _global.scripts[this._parent.itemNum];
				if (scriptObj.enabled == "enabled") {
					scriptObj.enabled = "disabled";
				} else {
					scriptObj.enabled = "enabled";
				}
				setScriptEnabled(scriptObj.name)
			}
			toggleBtn_mc.addEventListener("press", toggleBtn_mc);
			counter++;
		}
	}
	
	var scrollBar_mc = content_mc.createEmptyMovieClip("scrollBar_mc", 20);
	createScrollBar(scrollBar_mc, 480, "update");
	scrollBar_mc._y = 85;
	scrollBar_mc._x = 346;

	subscribe("SCRIPT", content_mc);

	content_mc.onClose = function () {
		unsubscribe("SCRIPT", this);
	}
	
	content_mc.update();
}

openMacroEdit = function (macro) {
	var macroObj = _global.macros[macro];

	var window_mc = showWindow({id:"macroEdit", width:500, height:470, title:"Edit Macro: " + macroObj.name, iconName:"gears", hideClose:true});
	
	window_mc.content_mc.macroName = macroObj.name;
	window_mc.content_mc.startRow = 0;

	window_mc.content_mc.update = function () {
		var content_mc = this.createEmptyMovieClip("content_mc", 0);
		var macroControls = this.macroControls = _global.macroContents;
		
		var label_tf = new TextFormat();
		label_tf.color = 0xFFFFFF;
		label_tf.size = 16;
		label_tf.bold = true;
		label_tf.font = "bi.ui.Fonts:" + _global.settings.defaultFont;
		label_tf.align = "center";

		this.maxItems = macroControls.length;
		this.itemsPerPage = 9;
		if (this.maxItems > this.itemsPerPage) {
			this.scrollBar_mc._visible = true;
			this.scrollBar_mc.scrollUp_mc.enabled = this.startRow > 0;
			this.scrollBar_mc.scrollDown_mc.enabled = this.startRow + this.itemsPerPage < this.maxItems;
			var labelWidth = this.width - this.scrollBar_mc._width - 5;
		} else {
			var labelWidth = this.width;
			this.scrollBar_mc._visible = false;
		}
		
		if (this.insertMode) labelWidth -= 35;

		var counter = 0;
		while (counter < this.itemsPerPage && this.startRow + counter < this.maxItems) {
			var control = this.startRow + counter;
			var controlObj = macroControls[control];
			var control_mc = content_mc.createEmptyMovieClip("control" + control + "_mc", control * 10);
			if (this.insertMode) control_mc._x = 35;
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
				
				control_mc.onPress = function () {
					var window_mc = showWindow({id:"macroPause", width:173, height:165, title:"Pause:", iconName:"media-pause", hideClose:true});
					window_mc.content_mc.parentObj = this;
					var pause_np = window_mc.content_mc.attachMovie("bi.ui.NumberPicker", "pause_np", 10, {settings:{width:160, minValue:0, maxValue:100, step:1}});
					var unit_ip = window_mc.content_mc.attachMovie("bi.ui.ItemPicker", "unit_ip", 20, {settings:{width:160, items:[{label:"secs", value:"secs"}, {label:"mins", value:"mins"}, {label:"hours", value:"hours"}], _y:35}});
					if (this.controlObj.extra < 60) {
						pause_np.selectedValue = this.controlObj.extra;
						unit_ip.selectedValue = "secs";
					} else if (this.controlObj.extra < 3600) {
						pause_np.selectedValue = this.controlObj.extra / 60;
						unit_ip.selectedValue = "mins";
					} else {
						pause_np.selectedValue = this.controlObj.extra / 3600;
						unit_ip.selectedValue = "hours";
					}
					var set_btn = window_mc.content_mc.attachMovie("bi.ui.Button", "set_btn", 30, {settings:{width:160, label:"Set", _y:70}});
					set_btn.addEventListener("press", set_btn);
					set_btn.press = function () {
						if (this._parent.unit_ip.selectedItem.value == "secs")  {
							var pause = this._parent.pause_np.selectedItem.value;
						} else if (this._parent.unit_ip.selectedItem.value == "mins") {
							var pause = this._parent.pause_np.selectedItem.value * 60;							
						} else {
							var pause = this._parent.pause_np.selectedItem.value * 3600;
						}
						this._parent.parentObj.controlObj.extra = pause;
						this._parent.parentObj.updateLabel();
						_global.windowStack["macroPause"].close();
					}
				}
				/*
				var downArrow_mc = control_mc.attachMovie("bi.ui.Button", "downArrow_mc", 1, {settings:{width:50, height:28, iconName:"down-arrow"}});
				downArrow_mc._x = 1;
				downArrow_mc._y = 1;
				downArrow_mc.repeatRate = 70;
				downArrow_mc.press = function () {
					this.action();
					this.startRepeatID = setInterval(this, "startRepeat", 400);
				}
				downArrow_mc.startRepeat = function () {
					clearInterval(this.startRepeatID);
					this.repeatID = setInterval(this, "action", this.repeatRate);
				}
				downArrow_mc.release = function () {
					clearInterval(this.startRepeatID);
					clearInterval(this.repeatID);
				}
				downArrow_mc.addEventListener("press", downArrow_mc);
				downArrow_mc.addEventListener("release", downArrow_mc);
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
	
				var upArrow_mc = control_mc.attachMovie("bi.ui.Button", "upArrow_mc", 2, {settings:{width:50, height:28, iconName:"up-arrow"}});
				upArrow_mc._x = labelWidth - 51;
				upArrow_mc._y = 1;
				upArrow_mc.repeatRate = 70;
				upArrow_mc.press = function () {
					this.action();
					this.startRepeatID = setInterval(this, "startRepeat", 400);
				}
				upArrow_mc.startRepeat = function () {
					clearInterval(this.startRepeatID);
					this.repeatID = setInterval(this, "action", this.repeatRate);
				}
				upArrow_mc.release = function () {
					clearInterval(this.startRepeatID);
					clearInterval(this.repeatID);
				}
				upArrow_mc.addEventListener("press", upArrow_mc);
				upArrow_mc.addEventListener("release", upArrow_mc);
				upArrow_mc.action = function () {
					if (this._parent.controlObj.extra < 60) {
						this._parent.controlObj.extra++;
					} else {
						this._parent.controlObj.extra += 60;
					}
					this._parent.updateLabel();
				}			
				*/
			} else {
				control_mc.updateLabel = function () {
					this.label_txt.text = this.controlObj.key + " [" + this.controlObj.command;
					if (controlObj.extra != "") this.label_txt.text += " : " + this.controlObj.extra;
					this.label_txt.text += "]";
				}
				control_mc.updateLabel();
				
				if (controlObj.extra == Number(controlObj.extra) && controlObj.extra >= 0 && controlObj.extra <= 100) {
					bg_mc.onPress = function () {
						var window_mc = showWindow({id:"macroExtraChange", width:173, height:130, title:"Edit:", iconName:"atom", hideClose:true});
						window_mc.content_mc.parentObj = this._parent;
						var extra_np = window_mc.content_mc.attachMovie("bi.ui.NumberPicker", "extra_np", 10, {settings:{width:160, minValue:0, maxValue:2000, step:1}});
						extra_np.selectedValue = this._parent.controlObj.extra;
						
						var set_btn = window_mc.content_mc.attachMovie("bi.ui.Button", "set_btn", 30, {settings:{width:160, label:"Set", _y:35}});
						set_btn.addEventListener("press", set_btn);
						set_btn.press = function () {
							this._parent.parentObj.controlObj.extra = this._parent.extra_np.selectedItem.value;
							this._parent.parentObj.updateLabel();
							_global.windowStack["macroExtraChange"].close();
						}
					}
				}

				var deleteBtn_mc = control_mc.attachMovie("bi.ui.Button", "upArrow_mc", 2, {settings:{width:50, height:28, iconName:"delete2"}});
				deleteBtn_mc._x = labelWidth - 51;
				deleteBtn_mc._y = 1;
				deleteBtn_mc.press = function () {
					if (this._parent.control) {
						window_mc.content_mc.macroControls.splice(this._parent.control - 1, 2);
					} else {
						window_mc.content_mc.macroControls.splice(this._parent.control, 2);
					}
					window_mc.content_mc.update();
				}
				deleteBtn_mc.addEventListener("press", deleteBtn_mc);
			}
			if (this.insertMode && ((controlObj.command != "pause") || control == this.maxItems - 1)) {
				var insert_btn = content_mc.attachMovie("bi.ui.Icon", "insert_" + control + "_mc", control * 10 + 5, {settings:{iconName:"right-arrow", size:35, _y:counter * 40 + 20}});
				insert_btn.index = control;
				insert_btn.onPress = function () {
					recordingMacro = true;
					newMacroArray = new Array();
					insertMacroObj = {name:this._parent._parent.macroName, contents:_global.macroContents, pos:this.index + 1};
					_global.windowStack["macroEdit"].close();
					_global.windowStack["controlPanel"].close();
					overlay_mc.status_txt.text = "** MACRO RECORDING **";
					overlay_mc.startStatusBlink();
				}
			}
			counter++;
		}
	}
	var scrollBar_mc = window_mc.content_mc.createEmptyMovieClip("scrollBar_mc", 20);
	createScrollBar(scrollBar_mc, 350, "update");
	scrollBar_mc._y = 0;
	scrollBar_mc._x = window_mc.content_mc.width - scrollBar_mc._width;

	sendCmd("MACRO", "getContents", macroObj.name);
	subscribe("MACRO_CONTENTS", window_mc.content_mc);
	
	window_mc.onClose = function () {
		unsubscribe("MACRO_CONTENTS", this.content_mc);
	}

	var buttons_mc = window_mc.content_mc.createEmptyMovieClip("buttons_mc", 500);
	var save_mc = buttons_mc.attachMovie("bi.ui.Button", "save_mc", 5, {settings:{width:80, height:35, label:"Save", fontSize:14}});
	save_mc.press = function () {
		saveMacro(this._parent._parent.macroName, this._parent._parent.macroControls);
		_global.windowStack["macroEdit"].close();
	}
	save_mc.addEventListener("press", save_mc);
	var insert_btn = buttons_mc.attachMovie("bi.ui.Button", "insert_btn", 10, {settings:{width:80, height:35, label:"Insert Mode", fontSize:14}, _x:85});
	insert_btn.press = function () {
		this._parent._parent.insertMode = !this._parent._parent.insertMode;
		this._parent._parent.update();
	}
	insert_btn.addEventListener("press", insert_btn);
	var cancel_mc = buttons_mc.attachMovie("bi.ui.Button", "cancel_mc", 15, {settings:{width:80, height:35, label:"Cancel", fontSize:14}, _x:170});
	cancel_mc.press = function () {
		_global.windowStack["macroEdit"].close();
	}
	cancel_mc.addEventListener("press", cancel_mc);
	buttons_mc._x = Math.round((window_mc.content_mc.width / 2) - (buttons_mc._width / 2));
	buttons_mc._y = 370;
}

screenUnlock = function (pin) {
	if (pin == _global.settings.screenLockPin) {
		screenLocked = false;
		_root.pinPadOpen = false;
	} else if (pin.length) {
		showMessageWindow({title:"Invalid Password", height:100, content:"The password you entered was incorrect.", icon:"warning", hideClose:false, autoClose:10, onClose:function () {_root.pinPadOpen = false;}});
	} else {
		_root.pinPadOpen = false;
	}
}

authenticateUser = function (pin) {
	if (pin == _global.settings.adminPin) {
		_global.adminLastVerified = getTimer();
		setAuthenticated(true);
		if (_root.onUnlock != undefined) _root[_root.onUnlock]();
	} else if (pin.length) {
		showMessageWindow({title:"Invalid Password", height:100, content:"The password you entered was incorrect.", icon:"warning", hideClose:false, autoClose:10});
	}
	_root.pinPadOpen = false;
	delete _root.onUnlock;
}

openPinPad = function (func, onUnlock) {
	if (_root.pinPadOpen || commsError) return;
	_root.pinPadOpen = true;
	_root.onUnlock = onUnlock;
	showKeyboard(15, func, this, "", true, "pin");
}

showCommsError = function () {
	if (window_mc.title != "Server Disconnected") {
		showMessageWindow({title:"Server Disconnected", content:"The connection with the server has been lost.\n\nPlease wait while the connection is restablished.", icon:"warning", hideClose:true})
	}
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
	label_tf.font = "bi.ui.Fonts:" + _global.settings.defaultFont;
	
	item_mc.createTextField("label_txt", 10, 0, 0, settings.w, 20);
	var label_txt = item_mc.label_txt;
	label_txt.embedFonts = true;
	label_txt.selectable = false;
	label_txt.setNewTextFormat(label_tf);
	label_txt.text = settings.label;
	
	var dropShadow = new DropShadowFilter(0, 0, 0x000000, 10, 4, 4, 1);
	label_txt.filters = [dropShadow];
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
		if (this._xmouse < 25) {
			var value = 0;
		} else if (this._xmouse > this._width - 25) {
			var value = 100;
		} else {
			var value = Math.floor((this._xmouse - 25) / (this._width - 50) * 11) * 10;
		}
		if (this._parent.extras.length) {
			value = Math.round((this._parent.extras[1] - this._parent.extras[0]) * (value / 100));
		}
		updateKey(this._parent.key, this._parent.command, value);
	}
	
	item_mc.setPercent = function (value) {
		this.slider_mc.handle_mc._x = Math.round((this.slider_mc.width - this.slider_mc.handle_mc._width) * (value / 100));	
	}
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
					if (this.newLoader._width > 6) {
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
			var url = this.src;
			if (this.src.substr(this.src.length - 1, 1) == "?" || this.src.substr(this.src.length - 1, 1) == "&") {
				url += new Date().getTime();
			} else if (this.src.split("?").length > 1) {
				url += "&r=" + new Date().getTime();
			} else {
				url += "?r=" + new Date().getTime();
			}
			this.newLoader.loadMovie(url);
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
		broadcastChange(key, null, true);
	}
}

screenLock = function () {
	if (_global.settings.screenLockDisplay != "") {
		screenSaver("start");
	}
	clearInterval(screenLockID);
	screenLocked = true;
	setAuthenticated(false);
}

screenSaver = function (mode) {
	if (mode == "start" && !screensaver_mc._visible) {
		// start
		screensaver_mc._visible = true;
		if (_global.settings.screenLockDisplay == "photo") {
			var holder1_mc = screensaver_mc.createEmptyMovieClip("holder1_mc", 0);
			var holder2_mc = screensaver_mc.createEmptyMovieClip("holder2_mc", 1);
			holder1_mc._visible = holder2_mc._visible = false;
			screensaver_mc.currentHolder = holder1_mc;
			screensaver_mc.currentImage = 0;
			screensaver_mc.loadPicture = function () {
				this.onEnterFrame = function () {
					clearInterval(this.loaderId);
					
					if (this.currentHolder == this.holder1_mc) {
						this.holder1_mc._visible = true;
						new Tween(this.holder1_mc, "_alpha", Regular.easeInOut, 0, 100, 2, true);
						var fadeOut = new Tween(this.holder2_mc, "_alpha", Regular.easeInOut, 100, 0, 2, true);
						fadeOut.onMotionFinished = function () {
							this.holder2_mc._visible = false;
						}
					} else {
						this.holder2_mc._visible = true;
						new Tween(this.holder2_mc, "_alpha", Regular.easeInOut, 0, 100, 2, true);
						var fadeOut = new Tween(this.holder1_mc, "_alpha", Regular.easeInOut, 100, 0, 2, true);
						fadeOut.onMotionFinished = function () {
							this.holder1_mc._visible = false;
						}
	
					}
					
					var target_mc = this.currentHolder;
					if (target_mc._width > 4) {
						if (_global.settings.screenLockPhotoScale == "fullscreen") {
							if (target_mc._width > target_mc._height) {
								target_mc._width = _global.settings.applicationWidth;
								target_mc._yscale = target_mc._xscale;
							} else {
								target_mc._height = _global.settings.applicationHeight;
								target_mc._yscale = target_mc._xscale;			
							}
						}
						target_mc._x = Math.round((_global.settings.applicationWidth / 2) - (target_mc._width / 2));
						target_mc._y = Math.round((_global.settings.applicationHeight / 2) - (target_mc._height / 2));
						
						this.currentHolder = (this.currentHolder == this.holder1_mc) ? this.holder2_mc : this.holder1_mc;
						this.loaderId = setInterval(this, "loadPicture", _global.settings.screenLockPhotoRotate * 1000);
						
						delete this.onEnterFrame;
					}
				}
				this.currentHolder.loadMovie(_global.settings.screenLockPhotoPath + screensaver_mc.imageArray[this.currentImage++]);
				if (this.currentImage == this.imageArray.length) this.currentImage = 0;
			}
			screensaver_mc.loadPicture();
		} else if (_global.settings.screenLockDisplay == "logo") {
			var bg_mc = screensaver_mc.createEmptyMovieClip("bg_mc", 0);
			bg_mc.loadMovie(_global.settings.libLocation + "screensaver/" + _global.settings.screenLockLogoBg);
			
			var logo_mc = screensaver_mc.attachMovie("elife-logo-large", "logo_mc", 10);

			logo_mc._x = Math.round(Math.random() * (_global.settings.applicationWidth - logo_mc._width));
			logo_mc._y = Math.round(Math.random() * (_global.settings.applicationHeight - logo_mc._height));
		
			var $dirX = 1;
			var $dirY = 1;
			
			var $r = random(360) * (Math.PI / 180);
			var $s = 3 + random(8);
			
			logo_mc.onEnterFrame = function() {
				this._x += Math.round(Math.cos($r) * $s * $dirX);
				this._y += Math.round(Math.sin($r) * $s * $dirY);
				
				if (this._x < 0 || this._x > (_global.settings.applicationWidth - this._width)) {
					this._x = Math.round((this._x < 0) ? 0 : _global.settings.applicationWidth - this._width);
					$dirX *= -1;
					$r = (20 + random(40)) * (Math.PI / 180);
					$s = 3 + random(6);	
				}
				if (this._y < 0 || this._y > (_global.settings.applicationHeight - this._height)) {
					this._y =  Math.round((this._y < 0) ? 0 : _global.settings.applicationHeight - this._height);
					$dirY *= -1;
					$r = (20 + random(40)) * (Math.PI / 180);
					$s = 3 + random(6);	
				}
			}
		}
	} else {
		// stop
		screensaver_mc._visible = false;
		if (_global.settings.screenLockDisplay == "photo") clearInterval(this.loaderId);
	}
}

layout = function () {
	_root.createEmptyMovieClip("logging_mc", -100);
	_root.createEmptyMovieClip("bg_mc", 0);
	_root.createEmptyMovieClip("bg2_mc", 10);
	_root.createEmptyMovieClip("zones_mc", 100);
	_root.createEmptyMovieClip("zoneLabels_mc", 200);
	_root.createEmptyMovieClip("overlay_mc", 400);
	_root.createEmptyMovieClip("statusBar_mc", 500);
	_root.createEmptyMovieClip("appsBar_mc", 600);
	_root.createEmptyMovieClip("windows_mc", 1100);
	_root.createEmptyMovieClip("confirm_mc", 1500);
	_root.createEmptyMovieClip("keyboard_mc", 2000);
	_root.createEmptyMovieClip("screensaver_mc", 5000);
	//_root.createEmptyMovieClip("tv_mc", 3000);
		
	bg_mc.beginFill(_global.settings.applicationBg);
	bg_mc.drawRect(0, 0, _global.settings.applicationWidth, _global.settings.applicationHeight);
	bg_mc.endFill();
	
	screensaver_mc.beginFill(0x000000);
	screensaver_mc.drawRect(0, 0, _global.settings.applicationWidth, _global.settings.applicationHeight);
	screensaver_mc.endFill();
	screensaver_mc.useHandCursor = false;
	screensaver_mc.onPress = function () {
		screenSaver("stop");
	}
	screensaver_mc._visible = false;
	
	if (_global.settings.screenLockDisplay == "photo") {
		screensaver_mc.imageArray = mdm.FileSystem.getFileList(_global.settings.screenLockPhotoPath, "*.jpg");
	}
	
	//if (_global.settings.device != "pda") bg2_mc.loadMovie(_global.settings.libLocation + "backgrounds/bg.png");
		
	zones_mc._x = _global.settings.zonesX;
	zones_mc._y = _global.settings.zonesY;
	
	zoneLabels_mc._x = _global.settings.zoneLabelsX;
	zoneLabels_mc._y = _global.settings.applicationHeight - _global.settings.zoneLabelsY - _global.settings.zoneBtnHeight;

	if (_global.settings.device == "pda") {
		var bg_mc = overlay_mc.createEmptyMovieClip("bg_mc", 0);
		bg_mc.beginFill(0x000000, 50);
		bg_mc.lineTo(_global.settings.applicationWidth, 0);
		bg_mc.lineTo(_global.settings.applicationWidth, _global.settings.statusBarY - _global.settings.statusBarBtnSpacing);
		bg_mc.lineTo(0, _global.settings.statusBarY - _global.settings.statusBarBtnSpacing);
		bg_mc.endFill();
		bg_mc.beginFill(0xFFFFFF, 80);
		bg_mc.moveTo(0, _global.settings.statusBarY - _global.settings.statusBarBtnSpacing);
		bg_mc.lineTo(_global.settings.applicationWidth, _global.settings.statusBarY - _global.settings.statusBarBtnSpacing);
		bg_mc.lineTo(_global.settings.applicationWidth, _global.settings.statusBarY + _global.settings.statusBarBtnHeight + _global.settings.statusBarBtnSpacing);
		bg_mc.lineTo(0, _global.settings.statusBarY + _global.settings.statusBarBtnHeight + _global.settings.statusBarBtnSpacing);
		bg_mc.endFill();		
	} else {
		overlay_mc.attachMovie("overlay", "bg_mc", 0);
		overlay_mc.bg_mc._x = _global.settings.applicationWidth - overlay_mc.bg_mc._width;
		overlay_mc.attachMovie("elife-logo-small", "logo_mc", 5);
		overlay_mc.logo_mc._x = _global.settings.applicationWidth - 60 - Math.round(overlay_mc.logo_mc._width / 2);
		overlay_mc.logo_mc._y = 46;
		overlay_mc.logo_mc.onPress2 = function () {
			openAbout();
		}
	}
	overlay_mc.createTextField("title_txt", 10, _global.settings.titleX, _global.settings.titleY, 300, 30);
	overlay_mc.createTextField("status_txt", 20, _global.settings.applicationWidth / 2, _global.settings.dateY, 1, 1);
	overlay_mc.createTextField("date_txt", 30, _global.settings.applicationWidth - _global.settings.dateX, _global.settings.dateY, 1, 1);

	var label_tf = new TextFormat();
	label_tf.font = "bi.ui.Fonts:" + _global.settings.titleFont;
	label_tf.color = _global.settings.titleFontColour;
	label_tf.size = _global.settings.titleFontSize;
	label_tf.bold = true;
	label_tf.align = "left";
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
	clearInterval(clockUpdateID);
	clockUpdateID = setInterval(overlay_mc, "updateClock", 20000);
	
	statusBar_mc._x = _global.settings.statusBarX;
	statusBar_mc._y = _global.settings.statusBarY;
	
	if (_global.settings.device == "pda") {
		appsBar_mc._x = _global.settings.applicationWidth - _global.settings.appsBarX - ((_global.settings.appsBarBtnWidth + _global.settings.appsBarBtnSpacing) * 4);
	} else {
		appsBar_mc._x = _global.settings.applicationWidth - _global.settings.appsBarX - 120 - ((_global.settings.appsBarBtnWidth + _global.settings.appsBarBtnSpacing) * _global.appsBar.length);
	}
	appsBar_mc._y = _global.settings.appsBarY;

	setupScreenSaver();
	
	tv_mc.update = function (key, state, value) {
		openTV(state);
	}
	subscribe("TV", tv_mc);
	tvStatus = "off";
}

setupScreenSaver = function () {
	// setup timer to start screenlock on no mouse movement
	if (_global.settings.screenLockTimeout > 0 && _global.settings.screenLockEnabled) {
		_root.onMouseMove = _root.onMouseDown = function () {
			clearInterval(screenLockID);
			screenLockID = setInterval(screenLock, _global.settings.screenLockTimeout * 1000)
			if (screenLocked) {
				if (_global.settings.screenLockPin.length) {
					openPinPad(screenUnlock);
				}
			}
		}
		clearInterval(screenLockID);
		screenLockID = setInterval(screenLock, _global.settings.screenLockTimeout * 1000);
		screenSaver("stop");
	} else {
		clearInterval(screenLockID);
		_root.onMouseMove = _root.onMouseDown = null;
	}
}

subscribe = function (keys, movieClip, sendCurrentState) {
	//debug("Subscribe: " + keys + ":" + movieClip);
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
		var alreadySubscribed = false;
		while (i--) {
			if (subscribers[i] == movieClip) {
				alreadySubscribed = true;
				break;
			}
		}
		if (!alreadySubscribed) subscribers.push(movieClip);
	}
	if (sendCurrentState) movieClip.update(key, _global.controls[key].state, _global.controls[key].value);
}

unsubscribe = function (keys, movieClip) {
	//debug("Unsubscribe: " + keys + ":" + movieClip);
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
	var counter = 0;
	for (var i in _global.controls) {
		if (_global.controls[i].subscribers.length) counter++;
	}
	//trace("subscribers: " + counter);
}

broadcastChange = function (key, id, fromClient) {
	//debug("broadcasting for " + key + ":")
	var control = _global.controls[key];
	for (var subscriber=0; subscriber<control.subscribers.length; subscriber++) {
		if (id > 0) {
			eval(control.subscribers[subscriber]).update(key, id);
		} else if (typeof(id) == "string") {
			// for music player, so we can send through what dataset we've just received and stored
			eval(control.subscribers[subscriber]).update(key, id);
		} else {
			eval(control.subscribers[subscriber]).update(key, control.state, control.value, fromClient);
		}
		//debug(" - " + control.subscribers[subscriber])
	}
}

loadPersistent = function () {
	var dataObj = _global.persistentData = SharedObject.getLocal("elife_client", "/");
	if (!dataObj.data.settings || _global.settings.clearPersistentData) {
		dataObj.data.settings = new Object()
	} else {
		for (var i in dataObj.data.settings) {
			//trace("persistent: " + i + " = " + dataObj.data.settings[i]);
			_global.settings[i] = dataObj.data.settings[i];
		}
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
				defineLogging(top[i])
				break;
			case ("appsBar") :
				defineAppsBar(top[i].childNodes)
				break;
			case ("calendar") :
				defineCalendar(top[i].childNodes)
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
	loadPersistent();
	layout();
	renderStatusBar();
	renderAppsBar();
	renderZones();
	setUpLogging();
	comPortSetup();
	serverSetup();
	setAuthenticated(isAuthenticated("superuser"));
	if (Stage.width != _global.settings.width) {
		_global.screenRatio = Stage.width / _global.settings.width;
	} else {
		_global.screenRatio = 1;
	}
}

loadIcons = function () {
	if (_global.settings.device == "pda" || _global.flashMajorVersion < 8) {
		application_xml.load(_global.settings.applicationXML);
	} else {
		var st = getTimer();
		var iconLoader_mc = _root.createEmptyMovieClip("iconLoader_mc", -9999);
		loader = new MovieClipLoader();
		loader.addListener(loader);
		loader.onLoadInit  = function (mc) {
			_global.icons[mc._name] = new BitmapData(mc._width, mc._height, true, 0x00FFFFFF);
			_global.icons[mc._name].draw(mc);
			mc.removeMovieClip();
			this.loadCounter--;
			if (this.loadCounter == 0) {
				//trace("time to load " + _global.iconNames.length + " icons: " + (getTimer() - st) + "ms");
				iconLoader_mc.removeMovieClip();
				application_xml.load(_global.settings.applicationXML);
			}
		}
		loader.loadPointer = 0;
		loader.loadCounter = 0;
		loader.loadNext = function () {
			var name = _global.iconNames[this.loadPointer];
			var loadClip_mc = iconLoader_mc.createEmptyMovieClip(name.split(".")[0], this.loadPointer);
			this.loadClip(_global.settings.libLocation + "icons/" + name, loadClip_mc);
			this.loadPointer++;
			this.loadCounter++;
			if (this.loadPointer < _global.iconNames.length) {
				this.loadNext();
			}
		}
		
		// load the list of icons and store them into the icon objects
		if (mdm.Application.path != undefined) {
			_global.iconNames = mdm.FileSystem.getFileList(mdm.Application.path + _global.settings.libLocation + "icons", "*.png");
			
			if (iconNames.length) {
				loader.loadNext();
			} else {
				iconLoader_mc.removeMovieClip();
				application_xml.load(_global.settings.applicationXML);
			}
		} else {
			var loadIconList = new LoadVars();
			//trace(_global.settings.libLocation);
			loadIconList.load(_global.settings.libLocation + "icons/_icons.txt");
			loadIconList.onData = function (src) {
				_global.iconNames = src.split(chr(13) + chr(10));
				loader.loadNext();
			}
		}
	}
}

init = function () {
	createObjects();
	if (_global.settings.device == "pda") {
		_global.settings.applicationWidth = _global.settings.width;
		_global.settings.applicationHeight = _global.settings.height;
	} else {
		_global.settings.applicationWidth = Stage.width;
		_global.settings.applicationHeight = Stage.height;		
	}
	setUpDebug();
	loadIcons();
}