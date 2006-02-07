renderControl = function (control, control_mc, totalWidth) {
	control_mc.rows = _global.controlTypes[control.type];
	control_mc.update = function (key, state, value) {
		var currentY = 0;
		for (var row=0; row<this.rows.length; row++) {
			var row_mc = this["row" + row + "_mc"];
			if (this.rows[row].cases != undefined) {
				row_mc.update(key);
			}
			if (row_mc._visible) {
				row_mc._y = currentY;
				currentY += row_mc.maxHeight + _global.settings.controlButtonSpacing;
				
				var items = this.rows[row].items;
				for (var item=0; item<items.length; item++) {
					row_mc["item" + item + "_mc"].update(key, state, value);
				}
			}
		}
	}
	control_mc.onShow = function () {
		for (var row=0; row<this.rows.length; row++) {
			var row_mc = this["row" + row + "_mc"];
			row_mc.onShow();
		}
	}
	control_mc.onHide = function () {
		for (var row=0; row<this.rows.length; row++) {
			var row_mc = this["row" + row + "_mc"];
			row_mc.onHide();
		}
	}
	control_mc.onClose = function () {
		for (var row=0; row<this.rows.length; row++) {
			var row_mc = this["row" + row + "_mc"];
			row_mc.onClose();
		}
	}
	
	var spacing = _global.settings.controlButtonSpacing;
	var count = 0;
	var rows = _global.controlTypes[control.type];
	for (var row=0; row<rows.length; row++) {
		var row_mc = control_mc.createEmptyMovieClip("row" + row + "_mc", row);
		var currentX = 0;
		var maxHeight = 0;
		var items = row_mc.items = rows[row].items;
		for (var item=0; item<items.length; item++) {
			if (items[item].width != undefined) {
				var width = (totalWidth + spacing) * (items[item].width / 100) - spacing;
			} else {
				var width = Math.round((totalWidth + spacing - currentX) / (items.length - item) - spacing);
			}
			var height = _global.settings.controlButtonHeight;
			var type = items[item].type;
			if (type == "label") {
				var item_mc = row_mc.createEmptyMovieClip("item" + item + "_mc", item);
				item_mc.name = control.name;
				item_mc.defaultState = items[item].defaultState;
				item_mc.defaultValue = items[item].defaultValue;
				item_mc.states = items[item].states.split(",");
				item_mc.formats = items[item].formats.split(",");
				createLabel(item_mc, {w:width, label:control.name});
				
				item_mc.update = function (key) {
					var state = _global.controls[key].storedStates["state"];
					var value = _global.controls[key].storedStates["on"];
					
					if (state == undefined) state = this.defaultState;

					if (value == undefined) value = this.defaultValue;
					
					var src = _global.controls[key].storedStates["src"];
					
					if (this.states.length > 1) {
						if (state == this.states[0]) {
							var label = this.formats[0];
						} else if (state == this.states[1]) {
							var label = this.formats[1];
						} else {
							var label = "%name% ";
						}
					} else {
						var label = "%name% ";
						if (state != undefined) label += "(%state%)"; 
					}

					label = label.split("%name%").join(this.name);
					label = label.split("%state%").join(state.toUpperCase());
					label = label.split("%value%").join(value);
					label = label.split("%src%").join(src);
					
					this.label_txt.text = label;
				}
			} else if (type == "picker") {
				var item_mc = row_mc.createEmptyMovieClip("item" + item + "_mc", item);
				item_mc.value = 50;
				var upButton_mc = item_mc.attachMovie("bi.ui.Button", "upButton_mc", 10, {width:50, height:height, icon:"up-arrow"});
				var label_mc = item_mc.attachMovie("bi.ui.Button", "label_mc", 20, {width:width - 104, height:height, label:""});
				label_mc._x = 52;
				label_mc.key = control.key;
				label_mc.command = items[item].command;
				label_mc.valueFormat = items[item].valueFormat;
				label_mc.buttonDown = function () {
					if (this.valueFormat != undefined) {
						var extra = this.valueFormat.split("%value%").join(this._parent.value);
						updateKey(this.key, this.command, extra);
					} else {
						updateKey(this.key, this.command, this._parent.value);
					}
				}
				label_mc.labelFormat = items[item].label;
				label_mc.setValue = function (value) {
					var label = this.labelFormat.split("%value%").join(value);
					this.setLabel(label);
				}
				label_mc.setValue(item_mc.value);
				var downButton_mc = item_mc.attachMovie("bi.ui.Button", "downButton_mc", 30, {width:50, height:height, icon:"down-arrow"});
				downButton_mc._x = label_mc._x + label_mc._width + 2;
				upButton_mc.repeatRate = downButton_mc.repeatRate = items[item].repeatRate;
				upButton_mc.step = downButton_mc.step = Number(items[item].step);
				upButton_mc.buttonDown = downButton_mc.buttonDown = function () {
					if (this.repeatRate) this.repeatID = setInterval(this, "action", this.repeatRate)
					this.action();
				}
				upButton_mc.buttonUp = downButton_mc.buttonUp = function () {
					if (this.repeatRate) clearInterval(this.repeatID);
				}
				upButton_mc.maxValue = items[item].maxValue;
				upButton_mc.action = function () {
					this._parent.value = Number(this._parent.value) + this.step;
					if (this._parent.value > this.maxValue) this._parent.value = this.maxValue;
					this._parent.label_mc.setValue(this._parent.value);
				}
				downButton_mc.minValue = items[item].minValue;
				downButton_mc.action = function () {
					this._parent.value = Number(this._parent.value) - this.step;
					if (this._parent.value < this.minValue) this._parent.value = this.minValue;
					this._parent.label_mc.setValue(this._parent.value);
				}
			} else if (type == "slider") {
				var item_mc = row_mc.createEmptyMovieClip("item" + item + "_mc", item);
				item_mc.key = control.key;
				item_mc.icons = control.icons.split(",");
				createSlider(item_mc, {w:width, h:height});
				item_mc.update = function (key, state) {
					// if state/value are undefined then get the current value of the key for its desired state
					if (state == undefined) var state = _global.controls[key].storedStates["state"];
			
					if (state == "on") {
						var value = _global.controls[key].storedStates["on"];
						this.slider_mc.handle_mc.iconOn_mc._alpha = value;
						this.slider_mc.handle_mc._x = Math.round((this.slider_mc.width - this.slider_mc.handle_mc._width) * (value / 100));
					} else {
						this.slider_mc.handle_mc.iconOn_mc._alpha = 0;
						this.slider_mc.handle_mc._x = 0;
					}
				}
			} else if (type == "button") {
				var item_mc = row_mc.attachMovie("bi.ui.Button", "item" + item + "_mc", item, {width:width, height:height, label:items[item].label, icon:items[item].icon, showOn:(items[item].showOn == "true")});
				item_mc.sound = items[item].sound;
				if (items[item].macro == undefined) {
					item_mc.showOn = (items[item].showOn == "true");
					if (items[item].key != undefined) {
						item_mc.key = items[item].key;
					} else {
						item_mc.key = control.key;
					}
					item_mc.command = items[item].command;
					item_mc.extra = items[item].extra;
					item_mc.extras = [items[item].extra];
					for (var i=2; i<7; i++) {
						if (items[item]["extra" + i] != undefined) {
							item_mc.extras.push(items[item]["extra" + i]);
						} else {
							break;
						}
					}
					item_mc.repeatRate = items[item].repeatRate;
					item_mc.buttonDown = function () {
						if (this.repeatRate) this.repeatID = setInterval(this, "action", this.repeatRate)
						this.action();
					}
					item_mc.buttonUp = function () {
						if (this.repeatRate) clearInterval(this.repeatID);
					}
					item_mc.action = function () {
						if (this.command.split("_")[0] == "browser" || this.command.split("_")[0] == "mp") {
							mdm[this.command]("1");
						} else {
							updateKey(this.key, this.command, this.extras, true);
						}
					}
					if (item_mc.showOn) {
						item_mc.update = function (key, state, value) {
							// if state/value are undefined then get the current value of the key for its desired state
							if (state == undefined) var state = this.command;
							if (value == undefined) var value = _global.controls[key].storedStates[this.command];
							
							if (state == this.command) {
								if (value == this.extra) {
									this.showHighlight();
								} else {
									this.hideHighlight();
								}
							}
						}
					}
				} else {
					for (var i=0; i<_global.macros.length; i++) {
						if (_global.macros[i].name == items[item].macro) {
							var macroID = i;
							break;
						}
					}
					item_mc.macroID = macroID;
					if (_global.macros[macroID].type == "dual") {
						if (_global.macroStatus[macroID] == 1) {
							item_mc.setLabel(_global.macros[macroID].controls[1].command);
							item_mc.macroName = _global.macros[macroID].controls[1].command;
							item_mc.onChangeID = 0;
						} else {
							item_mc.setLabel(_global.macros[macroID].controls[0].command);
							item_mc.macroName = _global.macros[macroID].controls[0].command;
							item_mc.onChangeID = 1;
						}
						item_mc.buttonDown = function () {
							sendCmd("MACRO", "run", this.macroName);
							_global.macroStatus[this.macroID] = this.onChangeID;
							this.showHighlight();
						}
					} else {
						item_mc.showOn = true;
						if (_global.macros[macroID].running) item_mc.showHighlight();
						
						item_mc.macroName = _global.macros[macroID].name;
						
						item_mc.buttonDown = function () {
							if (_global.macros[this.macroID].running) {
								updateKey("MACRO", "abort", this.macroName, true);
							} else {
								updateKey("MACRO", "run", this.macroName, true);
							}
						}
					}
					item_mc.update = function (key, state, value) {
						if (key == "MACRO") {
							if (_global.macros[this.macroID].running) {
								this.showHighlight();
							} else {
								this.hideHighlight();
							}
						}
					}
					item_mc.onShow = function () {
						subscribe("MACRO", this);
					}
					item_mc.onHide = function () {
						unsubscribe("MACRO", this);
					}
				}
			} else if (type == "toggle") {
				var item_mc = row_mc.attachMovie("bi.ui.Button", "item" + item + "_mc", item, {width:width, height:height});
				item_mc.arrayPos = 0;
				if (items[item].key != undefined) {
					item_mc.key = items[item].key;
				} else {
					item_mc.key = control.key;
				}
				item_mc.command = items[item].command;
				item_mc.commands = items[item].commands.split(",");
				item_mc.sounds = items[item].sounds.split(",");
				item_mc.extras = items[item].extras.split(",");
				if (control.icons.split(",").length == 2) {
					item_mc.icons = control.icons.split(",");
				} else {
					item_mc.icons = items[item].icons.split(",");
				}
				item_mc.labels = items[item].labels.split(",");
				if (item_mc.labels.length == 2) {
					item_mc.setLabel(item_mc.labels[0]);
				} else {
					item_mc.setIcon(item_mc.icons[0]);
				}
				item_mc.buttonDown = function () {
					if (this.command == "state") {
						updateKey(this.key, this.extras[this.arrayPos]);
					} else {
						if (this.commands.length) {
							updateKey(this.key, this.commands[this.arrayPos], this.extras[this.arrayPos]);
						} else {
							updateKey(this.key, this.command, this.extras[this.arrayPos]);							
						}
					}
				}
				item_mc.update = function (key, state, value) {
					if (this.commands.length) {
						if (state == this.commands[0]) {
							var command = this.commands[0];
						} else {
							var command = this.commands[1];
						}
					} else {
						var command = this.command;
					}
					// if state/value are undefined then get the current value of the key for its desired state
					if (state == undefined) var state = command;
					if (value == undefined) var value = _global.controls[key].storedStates[command];

					// fix to make on/off behave like other state/extra command pairs
					if (state == "on" || state == "off") {
						value = state;
						state = "state"; 
					}
					
					if (state == command) {
						if (value == this.extras[1]) {
							if (this.labels.length == 2) {
								this.setLabel(this.labels[0]);
							} else {
								this.setIcon(this.icons[0]);
								this.sound = this.sounds[1];
							}
							this.arrayPos = 0;
						} else if (value == this.extras[0]) {
							if (this.labels.length == 2) {
								this.setLabel(this.labels[1]);
							} else {
								this.setIcon(this.icons[1]);
								this.sound = this.sounds[0];
							}
							this.arrayPos = 1;
						}
					}
				}
			} else if (type == "video") {
				var item_mc = row_mc.createEmptyMovieClip("item" + item + "_mc", item);
				createVideoViewer(item_mc, {w:width, h:height, format:items[item].format, videoWidth:Number(items[item].videoWidth), videoHeight:Number(items[item].videoHeight), src:items[item].src, refreshRate:items[item].refreshRate});
			} else if (type == "webBrowser") {
				var item_mc = row_mc.createEmptyMovieClip("item" + item + "_mc", item);
				var bg_mc = item_mc.createEmptyMovieClip("bg_mc", 0);
				bg_mc.beginFill(0x829ECB);
				bg_mc.drawRect(0, 0, width, Number(control.height), 4);
				bg_mc.endFill();
				if (row_mc._parent["row" + (row - 1) + "_mc"].maxHeight != undefined) {
					var point = {x:item_mc._x, y:item_mc._y + row_mc._parent["row" + (row - 1) + "_mc"].maxHeight + 2};
				} else {
					var point = {x:item_mc._x, y:item_mc._y};
				}
				item_mc.localToGlobal(point);
				item_mc.browserSettings = {x:point.x, y:point.y, w:width, h:Number(control.height), url:control.url};
				item_mc.onShow = function () {
					mdm.browser_load("1", Math.round(this.browserSettings.x / _global.screenRatio), Math.round(this.browserSettings.y / _global.screenRatio), Math.round(this.browserSettings.w / _global.screenRatio), Math.round(this.browserSettings.h / _global.screenRatio), this.browserSettings.url, "false");
				}
				item_mc.onHide = function () {
					mdm.browser_close("1");
				}
				item_mc.onClose = function () {
					mdm.browser_close("1");
				}
			} else if (type == "mediaPlayer") {
				var item_mc = row_mc.createEmptyMovieClip("item" + item + "_mc", item);
				var bg_mc = item_mc.createEmptyMovieClip("bg_mc", 0);
				bg_mc.beginFill(0x829ECB);
				bg_mc.drawRect(0, 0, width, Number(control.srcHeight) + 11, 4);
				bg_mc.endFill();
				if (row_mc._parent["row" + (row - 1) + "_mc"].maxHeight != undefined) {
					var point = {x:item_mc._x, y:item_mc._y + row_mc._parent["row" + (row - 1) + "_mc"].maxHeight + 6};
				} else {
					var point = {x:item_mc._x, y:item_mc._y + 6};
				}
				item_mc.localToGlobal(point);
				item_mc.playerSettings = {x:point.x, y:point.y, w:width, h:height, srcWidth:Number(control.srcWidth), srcHeight:Number(control.srcHeight), src:control.src};
				item_mc.onShow = function () {					
					mdm.mp_load("1", Math.round((this.playerSettings.x + (this.playerSettings.w / 2) - (this.playerSettings.srcWidth / 2)) / _global.screenRatio), Math.round(this.playerSettings.y / _global.screenRatio), Math.round(this.playerSettings.srcWidth / _global.screenRatio), Math.round(this.playerSettings.srcHeight / _global.screenRatio), this.playerSettings.src);
					mdm.mp_nomenu("1");
				}
				item_mc.onHide = function () {
					mdm.mp_close("1");
				}
				item_mc.onClose = function () {
					mdm.mp_close("1");
				}
			} else if (type == "space") {
				item_mc = null;
			}
			item_mc._x = currentX;
			maxHeight = Math.max(maxHeight, item_mc._height);
			currentX += width + spacing;
		}
		row_mc.onShow = function () {
			for (var item=0; item<this.items.length; item++) {
				this["item" + item + "_mc"].onShow();
			}
		}
		row_mc.onHide = function () {
			for (var item=0; item<this.items.length; item++) {
				this["item" + item + "_mc"].onHide();
			}
		}
		row_mc.onClose = function () {
			for (var item=0; item<this.items.length; item++) {
				this["item" + item + "_mc"].onClose();
			}
		}
		
		row_mc.maxHeight = maxHeight;
		
		if (rows[row].cases != undefined) {
			var cases = rows[row].cases.split(",");
			row_mc.cases = new Array();
			for (var i=0; i<cases.length; i++) {
				row_mc.cases.push({extra:cases[i].split(":")[0],values:cases[i].split(":")[1].split("|")});
				row_mc.update = function (key) {
					var show = false;
					for (var i=0; i<this.cases.length; i++) {
						for (var q=0; q<this.cases[i].values.length; q++) {
							if (this.cases[i].values[q].substr(0,1) == "!") {
								if (_global.controls[control.key].storedStates[this.cases[i].extra] == this.cases[i].values[q].substr(1)) show = false;
							} else {
								show = (_global.controls[control.key].storedStates[this.cases[i].extra] == this.cases[i].values[q])
								if (show) break;
							}
						}
						if (!show) break;
					}
					this._visible = show;
				}
			}
		}
	}
	control_mc.update(control.key);
}