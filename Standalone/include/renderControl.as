renderControl = function (control, control_mc, totalWidth) {
	var a = getTimer();	

	control_mc.controlTypeObj = _global.controlTypes[control.type];
	control_mc.rows = _global.controlTypes[control.type].rows;
	control_mc.update = function (key, state, value, fromClient) {
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
					row_mc["item" + item + "_mc"].update(key, state, value, fromClient);
				}
			}
		}
	}
	control_mc.onShow = function () {
		if (this.controlTypeObj.onShow.key.length > 0 || this.controlTypeObj.onShow.command.length > 0) {
			performAction(this.controlTypeObj.onShow.key, this.controlTypeObj.onShow.command, this.controlTypeObj.onShow.extra);
		}
		for (var row=0; row<this.rows.length; row++) {
			var row_mc = this["row" + row + "_mc"];
			row_mc.onShow();
		}
	}
	control_mc.onHide = function () {
		if (this.controlTypeObj.onHide.key.length > 0 || this.controlTypeObj.onHide.command.length > 0) {
			performAction(this.controlTypeObj.onHide.key, this.controlTypeObj.onHide.command, this.controlTypeObj.onHide.extra);
		}
		for (var row=0; row<this.rows.length; row++) {
			var row_mc = this["row" + row + "_mc"];
			row_mc.onHide();
		}
	}
	control_mc.onClose = function () {
		if (this.controlTypeObj.onClose.key.length > 0 || this.controlTypeObj.onClose.command.length > 0) {
			performAction(this.controlTypeObj.onClose.key, this.controlTypeObj.onClose.command, this.controlTypeObj.onClose.extra);
		}
		for (var row=0; row<this.rows.length; row++) {
			var row_mc = this["row" + row + "_mc"];
			row_mc.onClose();
		}
	}
	
	var spacing = _global.settings.controlButtonSpacing;
	var count = 0;
	var rows = _global.controlTypes[control.type].rows;
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
			switch (type) {
				case "label":
					var item_mc = row_mc.createEmptyMovieClip("item" + item + "_mc", item);
					item_mc.name = control.name;
					item_mc.defaultState = items[item].defaultState;
					item_mc.defaultValue = items[item].defaultValue;
					item_mc.states = items[item].states.split(",");
					item_mc.format = items[item].format;
					item_mc.formats = items[item].formats.split(",");
					//createLabel(item_mc, {w:width, label:control.name});
					item_mc.attachMovie("bi.ui.Label", "label_lb", 0, {settings:{width:width, label:control.name}});
										
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
						} else if (this.format.length) {
							var label = this.format;
							for (var i in _global.controls[key].storedStates) {
								label = label.split("%" + i + "%").join(_global.controls[key].storedStates[i]);
							}
						} else {
							var label = "%name% ";
							if (state != undefined) label += "(%state%)"; 
						}
	
						label = label.split("%name%").join(this.name);
						label = label.split("%state%").join(state.toUpperCase());
						label = label.split("%value%").join(value);
						label = label.split("%src%").join(src);
						
						this.label_lb.text = label;
					}
					break;
				case "picker":
					var item_mc = row_mc.createEmptyMovieClip("item" + item + "_mc", item);
					item_mc.value = 50;
					var upButton_mc = item_mc.attachMovie("bi.ui.Button", "upButton_mc", 10, {settings:{width:50, height:height, iconName:"up-arrow"}});
					var label_mc = item_mc.attachMovie("bi.ui.Button", "label_mc", 20, {settings:{width:width - 104, height:height, label:""}});
					label_mc._x = 52;
					label_mc.key = control.key;
					label_mc.command = items[item].command;
					label_mc.valueFormat = items[item].valueFormat;
					label_mc.press = function () {
						if (this.valueFormat != undefined) {
							var extra = this.valueFormat.split("%value%").join(this._parent.value);
							updateKey(this.key, this.command, extra);
						} else {
							updateKey(this.key, this.command, this._parent.value);
						}
					}
					label_mc.addEventListener("press", label_mc);
					label_mc.labelFormat = items[item].label;
					label_mc.setValue = function (value) {
						this.label = this.labelFormat.split("%value%").join(value);
					}
					label_mc.setValue(item_mc.value);
					var downButton_mc = item_mc.attachMovie("bi.ui.Button", "downButton_mc", 30, {settings:{width:50, height:height, iconName:"down-arrow"}});
					downButton_mc._x = label_mc._x + label_mc._width + 2;
					upButton_mc.repeatRate = downButton_mc.repeatRate = items[item].repeatRate;
					upButton_mc.step = downButton_mc.step = Number(items[item].step);
					upButton_mc.press = downButton_mc.press = function () {
						if (this.repeatRate) this.repeatID = setInterval(this, "action", this.repeatRate)
						this.action();
					}
					upButton_mc.release = downButton_mc.release = function () {
						if (this.repeatRate) clearInterval(this.repeatID);
					}
					upButton_mc.addEventListener("press", upButton_mc);
					upButton_mc.addEventListener("release", upButton_mc);
					downButton_mc.addEventListener("press", downButton_mc);
					downButton_mc.addEventListener("release", downButton_mc);
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
					break;
				case "slider":
					var item_mc = row_mc.createEmptyMovieClip("item" + item + "_mc", item);
					item_mc.key = control.key;
					item_mc.icons = control.icons.split(",");
					if (items[item].command != undefined) {
						item_mc.command = items[item].command;
					} else {
						item_mc.command = "on";
					}
					item_mc.extras = items[item].extras.split(",");
					createSlider(item_mc, {w:width, h:height});
					item_mc.update = function (key, state) {
						// if state/value are undefined then get the current value of the key for its desired state
						if (state == undefined) var state = _global.controls[key].storedStates["state"];
				
						if (state == this.command) {
							var value = _global.controls[key].storedStates[this.command];
							if (this.extras.length) {
								value = Math.round(value / (this.extras[1] - this.extras[0]) * 100);
							}
							this.slider_mc.handle_mc.iconOn_mc._alpha = value;
							this.slider_mc.handle_mc._x = Math.round((this.slider_mc.width - this.slider_mc.handle_mc._width) * (value / 100));
						} else {
							this.slider_mc.handle_mc.iconOn_mc._alpha = 0;
							this.slider_mc.handle_mc._x = 0;
						}
					}
					break;
				case "button":
				case "toggle":
					if (type == "toggle") {
						items[item].mode = "toggle";
					}
					var item_mc = attachButton(row_mc, control, items[item], "item" + item + "_mc", item, width, height);
					if (buttonObj.macro != undefined) {
						item_mc.onShow = function () {
							subscribe("MACRO", this);
						}
						item_mc.onHide = function () {
							unsubscribe("MACRO", this);
						}	
					}
					break;
				case "toggled":
					var buttonObject = {width:width, height:height};
					for (var attr in items[item]) {
						if (attr.substr(0, 6) == "button") {
							if (items[item][attr] == Number(items[item][attr])) {
								buttonObject[attr.substr(6, 1).toLowerCase() + attr.substr(7)] = Number(items[item][attr]);
							} else if (items[item][attr] == "true" || items[item][attr] == "false") {
								buttonObject[attr.substr(6, 1).toLowerCase() + attr.substr(7)] = (items[item][attr] == "true");
							} else {
								buttonObject[attr.substr(6, 1).toLowerCase() + attr.substr(7)] = items[item][attr];
							}
						}
					}
				
					if (control.icons.split(",").length == 2) {
						var icons = control.icons.split(",");
					} else {
						var icons = items[item].icons.split(",");
					}
					var labels = items[item].labels.split(",");
					if (labels.length == 2) {
						buttonObject.label = labels[0];
					} else {
						buttonObject.iconName = icons[0];
					}
				
					var item_mc = row_mc.attachMovie("bi.ui.Button", "item" + item + "_mc", item, buttonObject);
					
					item_mc.icons = icons;
					item_mc.labels = labels;
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

					item_mc.press = function () {
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
					item_mc.addEventListener("press", item_mc);
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
									this.label = this.labels[0];
								} else {
									this.iconName = this.icons[0];
									this.sound = this.sounds[1];
								}
								this.arrayPos = 0;
							} else if (value == this.extras[0]) {
								if (this.labels.length == 2) {
									this.label = this.labels[1];
								} else {
									this.iconName = this.icons[1];
									this.sound = this.sounds[0];
								}
								this.arrayPos = 1;
							}
						}
					}
					break;
				case "video":
					var item_mc = row_mc.createEmptyMovieClip("item" + item + "_mc", item);
					createVideoViewer(item_mc, {w:width, h:height, format:items[item].format, videoWidth:Number(items[item].videoWidth), videoHeight:Number(items[item].videoHeight), src:items[item].src, refreshRate:items[item].refreshRate});
					break;
				case "browser":
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
						//trace("show browser!");
						browser.visible = true;
					}
					item_mc.onHide = function () {
						//trace("hide browser!");
						browser.visible = false;
					}
					item_mc.onClose = function () {
						//trace("close browser!");
						browser.close();
					}
					browser = new mdm.Browser(Math.round(point.x / _global.screenRatio), Math.round(point.y / _global.screenRatio), Math.round(width / _global.screenRatio), Math.round(control.height / _global.screenRatio), control.url, "false");
					browser.visible = false;
					break;
				case "mediaPlayer":
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
					item_mc.onShow = function () {					
						mediaPlayer.visible = true;
					}
					item_mc.onHide = function () {
						mediaPlayer.visible = false;
					}
					item_mc.onClose = function () {
						mediaPlayer.close();
	
					}
					mediaPlayer = new mdm.MediaPlayer6(Math.round((point.x + (width / 2) - (control.srcWidth / 2)) / _global.screenRatio), Math.round(point.y / _global.screenRatio), Math.round(control.srcWidth / _global.screenRatio), Math.round(control.srcHeight / _global.screenRatio), control.src);
					mediaPlayer.visible = false;
					break;
				case "trackDetails":
					var item_mc = row_mc.createEmptyMovieClip("item" + item + "_mc", item);
					
					var detailsBoxBg_mc = item_mc.createEmptyMovieClip("bg_mc", 0);
					detailsBoxBg_mc.beginFill(0x000000, 20);
					if (items[item].art == "cover") {
						var boxHeight = 310;
					} else {
						var boxHeight = 110;
					}
					if (items[item].detailsPosition == "bottom") boxHeight += 100;
					
					detailsBoxBg_mc.drawRect(0, 0, width, boxHeight, 4);
					detailsBoxBg_mc.endFill();
					item_mc.art = items[item].art;
					item_mc.detailsPosition = items[item].detailsPosition;
					
					if (items[item].detailsPosition == "right") {
						var xMod = boxHeight;
						var yMod = 0;
					}  else {
						var xMod = 10;
						if (items[item].art == "cover") {
							var yMod = 310;
						} else {
							var yMod = 110;
						}
					}
					item_mc.attachMovie("bi.ui.Label", "title_lb", 20, {_x:xMod, _y:5 + yMod, settings:{width:width - xMod - 5, text:"Title: %title%"}});
					item_mc.attachMovie("bi.ui.Label", "artist_lb", 30, {_x:xMod, _y:35 + yMod, settings:{width:width - xMod - 5, text:"Artist: %artist%"}});
					item_mc.attachMovie("bi.ui.Label", "album_lb", 40, {_x:xMod, _y:65 + yMod, settings:{width:width - xMod - 5, text:"Album: %album%"}});
					
					item_mc.update = function (key, state, value, fromClient) {
						if (!fromClient && _global.controls[key].track.id != this.lastTrackID) {
							this.title_lb.text = (_global.controls[key].track.title != undefined) ? "Title: " + _global.controls[key].track.title : "";
							this.artist_lb.text = (_global.controls[key].track.artist != undefined) ? "Artist: " + _global.controls[key].track.artist : "";
							this.album_lb.text = (_global.controls[key].track.album != undefined) ? "Album: " + _global.controls[key].track.album : "";
							
							if (_global.controls[key].track.album_id != this.lastAlbumID) {
								this.createEmptyMovieClip("coverArt_mc", 10);
								this.coverArt_mc._y = 5;
								this.coverArt_mc.loadMovie("http://" + _global.settings.squeezeAddress + ":" + _global.settings.squeezePort + "/music/current/" + this.art + ".jpg?playerid=" + _global.controls[key].id + "&r=" + _global.controls[key].track.id);
								//debug("loading:" + "http://" + _global.settings.squeezeAddress + ":" + _global.settings.squeezePort + "/music/current/" + this.art + ".jpg?playerid=" + _global.controls[key].id + "&r=" + _global.controls[key].track.id);
								this.onEnterFrame = function () {
									if (this.coverArt_mc._width > 20) {
										if (this.coverArt_mc._width > 300) {
											this.coverArt_mc._width = 300;
											this.coverArt_mc._yscale = this.coverArt_mc._xscale;
										} else if (this.coverArt_mc._height > 300) {
											this.coverArt_mc._height = 300;
											this.coverArt_mc._xscale = this.coverArt_mc._yscale;
										}
										if (this.detailsPosition == "right") {
											this.coverArt_mc._x = Math.round((this.bg_mc._height / 2) - (this.coverArt_mc._width / 2));
										} else {
											this.coverArt_mc._x = Math.round((this.bg_mc._width / 2) - (this.coverArt_mc._width / 2));
										}
										delete this.onEnterFrame;
									}
								}
							}
							
							this.lastTrackID = _global.controls[key].track.id;
							this.lastAlbumID = _global.controls[key].track.album_id;
						}
					}
					
					break;
				case "space":
					item_mc = null;
					break;
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
	//trace(getTimer() - a + "ms");
}

performAction = function (key, command, extra) {
	if (command.split(".")[0] == "browser") {
		browser[command.split(".")][1]();
	} else if (command.split(".")[0] == "mediaPlayer") {
		mediaPlayer[command.split(".")][1]();
	} else if (command.split(".")[0] == "url") {
		var commands = command.split(".").splice(1).join(".").split(",");
		var loadURL:LoadVars = new LoadVars();
		loadURL.onLoad = function () {
			if (!commands.length) return;
			var c = commands.pop();
			this.load(c);
			trace("URL: " + c);
		}
		loadURL.onLoad();
	} else if (command.split(".")[0] == "func") {
		_root[command.split(".")[1]](key);
	} else {
		updateKey(key, command, extra, true);
	}
}

attachButton = function (attachTo, control, buttonObj, name, depth, w, h) {
	var buttonObject = {width:w, height:h};
	/// parse and set overrides
	for (var attr in buttonObj) {
		if (attr.substr(0, 6) == "button") {
			if (buttonObj[attr] == Number(buttonObj[attr])) {
				buttonObject[attr.substr(6, 1).toLowerCase() + attr.substr(7)] = Number(buttonObj[attr]);
			} else if (buttonObj[attr] == "true" || buttonObj[attr] == "false") {
				buttonObject[attr.substr(6, 1).toLowerCase() + attr.substr(7)] = (buttonObj[attr] == "true");
			} else {
				buttonObject[attr.substr(6, 1).toLowerCase() + attr.substr(7)] = buttonObj[attr];
			}
		}
	}
	
	if (control.icons.split(",").length == 2) {
		var icons = control.icons.split(",");
	} else if (buttonObj.icons.split(",").length == 2) {
		var icons = buttonObj.icons.split(",");
	}
	
	if (control.labels.split(",").length == 2) {
		var labels = control.labels.split(",");
	} else if (buttonObj.labels.split(",").length == 2) {
		var labels = buttonObj.labels.split(",");		
	}

	if (labels.length == 2) {
		buttonObject.labels = labels;
		buttonObject.label = labels[0];
	} else if (buttonObj.label.length) {
		buttonObject.label = buttonObj.label.toString();
	} else if (icons.length == 2) {
		buttonObject.icons = icons;
		buttonObject.iconName = icons[0];
	} else {
		buttonObject.iconName = buttonObj.icon;
	}

	if (buttonObj.sound != undefined) {
		buttonObject.sound = buttonObj.sound;
	} else if (buttonObj.sounds != undefined) {
		buttonObject.sounds = buttonObj.sounds.split(",");
		buttonObject.sound = buttonObject.sounds[0];
	}
	
	var item_mc = attachTo.attachMovie("bi.ui.Button", name, depth, buttonObject);
	item_mc.settings = buttonObject;
	
	item_mc.addEventListener("press", item_mc);
	item_mc.addEventListener("release", item_mc);
	
	if (buttonObj.macro == undefined) {
		if (control.keys) {
			item_mc.key = control.keys[buttonObj.key.substr(4, buttonObj.key.length - 5) - 1];
		} else if (buttonObj.key != undefined) {
			item_mc.key = buttonObj.key;
		} else {
			item_mc.key = control.key;
		}
		item_mc.mode = buttonObj.mode;
		item_mc.command = buttonObj.command;
		item_mc.commands = buttonObj.commands.split(",");
		if (item_mc.mode == "toggle") {
			item_mc.arrayPos = 0;
			item_mc.extras = buttonObj.extras.split(",");
		} else {
			item_mc.extras = buttonObj.extras.split("|");
			item_mc.allExtras = [buttonObj.extra];
			for (var i=2; i<7; i++) {
				if (buttonObj["extra" + i] != undefined) {
					item_mc.allExtras.push(buttonObj["extra" + i]);
				} else {
					break;
				}
			}
			item_mc.repeatRate = buttonObj.repeatRate;
		}

		item_mc.press = function () {
			if (this.repeatRate) this.repeatID = setInterval(this, "action", this.repeatRate);
			if (this.mode == "startStop") {
				updateKey(this.key, this.commands[0], this.extras[0].split(","), true);
			} else {
				this.action();
			}
		}
		item_mc.release = function () {
			if (this.repeatRate) clearInterval(this.repeatID);
			if (this.mode == "startStop") {
				updateKey(this.key, this.commands[1], this.extras[1].split(","), true);
			}
		}
		item_mc.action = function () {
			if (this.mode == "toggle") {
				if (this.command == "state") {
					updateKey(this.key, this.extras[this.arrayPos]);
				} else if (this.commands.length) {
					updateKey(this.key, this.commands[this.arrayPos], this.extras[this.arrayPos]);
				} else {
					updateKey(this.key, this.command, this.extras[this.arrayPos]);							
				}
			} else {
				performAction(this.key, this.command, this.allExtras);
			}
		}
		if (buttonObj.showOn || buttonObj.mode == "toggle") {
			if (buttonObj.showOn) item_mc.toggle = true;
			item_mc.update = function (key, state, value) {
				if (this.mode == "toggle") {
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
								this.label = this.labels[0];
							} else {
								this.iconName = this.icons[0];
								this.sound = this.sounds[1];
							}
							this.arrayPos = 0;
						} else if (value == this.extras[0]) {
							if (this.labels.length == 2) {
								this.label = this.labels[1];
							} else {
								this.iconName = this.icons[1];
								this.sound = this.sounds[0];
							}
							this.arrayPos = 1;
						}
					}
				} else {
					// if state/value are undefined then get the current value of the key for its desired state
					if (state == undefined) var state = this.command;
					if (value == undefined) var value = _global.controls[key].storedStates[this.command];
				
					if (state == this.command) {
						if (value == this.allExtras[0]) {
							this.highlight = true;
						} else {
							this.highlight = false;
						}
					}
				}
			}
		}
	} else {
		// find the macros internal ID
		for (var i=0; i<_global.macros.length; i++) {
			if (_global.macros[i].name == buttonObj.macro) {
				var macroID = i;
				break;
			}
		}
		item_mc.macroID = macroID;
		
		if (_global.macros[macroID].type == "dual") {
			if (_global.macroStatus[macroID] == 1) {
				item_mc.label = _global.macros[macroID].controls[1].command;
				item_mc.macroName = _global.macros[macroID].controls[1].command;
				item_mc.onChangeID = 0;
			} else {
				item_mc.label = _global.macros[macroID].controls[0].command;
				item_mc.macroName = _global.macros[macroID].controls[0].command;
				item_mc.onChangeID = 1;
			}
			item_mc.press = function () {
				sendCmd("MACRO", "run", this.macroName);
				_global.macroStatus[this.macroID] = this.onChangeID;
				this.highlight = true;
			}
		} else {
			item_mc.toggle = true;
			if (_global.macros[macroID].running) item_mc.highlight = true;
			
			if (buttonObj.label != undefined) {
				item_mc.label = buttonObj.label;
			} else {
				item_mc.label = _global.macros[macroID].name;
			}
			item_mc.macroName = _global.macros[macroID].name;
			
			item_mc.press = function () {
				if (_global.macros[this.macroID].running) {
					updateKey("MACRO", "abort", this.macroName, true);
				} else {
					updateKey("MACRO", "run", this.macroName, true);
				}
			}
		}
		item_mc.update = function (key, state, value) {
			if (value == this.macroName) {
				if (_global.macros[macroID].type == "dual") {
					if (_global.macroStatus[this.macroID] == 0) {
						this.label = _global.macros[this.macroID].controls[0].command;
						this.macroName = _global.macros[this.macroID].controls[0].command;
						this.onChangeID = 1;
					} else {
						this.label = _global.macros[this.macroID].controls[1].command;
						this.macroName = _global.macros[this.macroID].controls[1].command;
						this.onChangeID = 0;
					}
				} else {
					if (_global.macros[this.macroID].running) {
						this.highlight = true;
					} else {
						this.highlight = false;
					}
				}
			}
		}
	}
	return item_mc;
}