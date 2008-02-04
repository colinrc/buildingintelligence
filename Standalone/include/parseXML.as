defineSettings = function (allSettings) {
	for (var i in allSettings) {
		//if (allSettings[i].nodeName == "common" || allSettings[i].attributes.type == _global.settings.deviceType) {
			var settings = allSettings[i].childNodes;
			for (var setting=0; setting<settings.length; setting++) {
				if (settings[setting].attributes.name != "label" && Number(settings[setting].attributes.value) == settings[setting].attributes.value) {
					_global.settings[settings[setting].attributes.name] = Number(settings[setting].attributes.value);
				} else if (settings[setting].attributes.value == "true" || settings[setting].attributes.value == "false") {
					_global.settings[settings[setting].attributes.name] = (settings[setting].attributes.value == "true");
				} else {
					_global.settings[settings[setting].attributes.name] = settings[setting].attributes.value;
				}
			}		
		//}
	}
}

defineStatusBar = function (groups) {
	for (var group=0; group<groups.length; group++) {
		_global.statusBar.push({name:groups[group].attributes.name, icon:groups[group].attributes.icon, controls:[]});
		for (var attrib in groups[group].attributes) {
			_global.statusBar[group][attrib] = groups[group].attributes[attrib];
		}
		var controls = groups[group].childNodes;
		for (var control=0; control<controls.length; control++) {
			_global.statusBar[group].controls[control] = new Object();
			for (var attrib in controls[control].attributes) {
				_global.statusBar[group].controls[control][attrib] = controls[control].attributes[attrib];
			}
		}
	}
}

defineLogging = function (logging) {
	for (var attrib in logging.attributes) {
		_global.logging[attrib] = logging.attributes[attrib];
	}
	var groups = logging.childNodes;
	_global.logging.groups = new Array();
	for (var group=0; group<groups.length; group++) {
		_global.logging.groups.push({name:groups[group].attributes.name, icon:groups[group].attributes.icon, label:groups[group].attributes.label, listenTo:groups[group].attributes.listenTo, type:groups[group].attributes.type, url:groups[group].attributes.url, timeformat:groups[group].attributes.timeformat, controls:[], log:[]});
		var controls = groups[group].childNodes;
		for (var control=0; control<controls.length; control++) {
			_global.logging.groups[group].controls[control] = new Object();
			for (var attrib in controls[control].attributes) {
				_global.logging.groups[group].controls[control][attrib] = controls[control].attributes[attrib];
			}
		}
	}
}

defineAppsBar = function (icons) {
	for (var icon=0; icon<icons.length; icon++) {
		var appObj = new Object();
		for (var attrib in icons[icon].attributes) {
			appObj[attrib] = icons[icon].attributes[attrib];
		}
		_global.appsBar.push(appObj);
	}
}

defineCalendar= function (topLevel) {
	for (var i=0; i<topLevel.length; i++) {
		var q = topLevel[i];
		switch (q.nodeName) {
			case "categories":
				_global.calendarCategories = [{label:"", value:"", icon:""}];
				var categories = q.childNodes;
				for (var category=0; category<categories.length; category++) {
					_global.calendarCategories.push({label:categories[category].attributes.name, value:categories[category].attributes.name.toLowerCase(), icon:categories[category].attributes.icon});
				}
				break;
			case "window":
				var tabs = q.childNodes;
				for (var tab=0; tab<tabs.length; tab++) {
					var tabObj = new Object();
					tabObj.view = tabs[tab].attributes.view;
					tabObj.label = tabs[tab].attributes.label;
					tabObj.macro = tabs[tab].attributes.macro;
					tabObj.icon = tabs[tab].attributes.icon;
					tabObj.zones = new Array();
					for (var zone=0; zone<tabs[tab].childNodes.length; zone++){
						tabObj.zones.push({key:tabs[tab].childNodes[zone].attributes.key, label:tabs[tab].childNodes[zone].attributes.label});
						_global.calendarZoneLabels[tabs[tab].childNodes[zone].attributes.key] = tabs[tab].childNodes[zone].attributes.label;
					}
					_global.calendar.push(tabObj);
				}
				break;
		}
	}
}

defineMacroContent = function (controlsXml) {
	_global.macroContents = [];
	for (var control=0; control<controlsXml.length; control++){
		var controlXml = controlsXml[control].attributes;
		_global.macroContents.push({key:controlXml.KEY, command:controlXml.COMMAND, extra:controlXml.EXTRA, extra2:controlXml.EXTRA2, extra3:controlXml.EXTRA3, extra4:controlXml.EXTRA4, extra5:controlXml.EXTRA5});
	}
}

defineScripts = function (scripts) {
	_global.scripts = new Array();
	for (var script=0; script<scripts.length; script++) {
		var controlsXml = scripts[script].childNodes;
		var controls = [];
		for (var control=0; control<controlsXml.length; control++){
			var controlXml = controlsXml[control].attributes;
			controls.push({key:controlXml.KEY, command:controlXml.COMMAND, extra:controlXml.EXTRA});
		}
		var status = scripts[script].attributes.STATUS.split(",");
		var statusObj = new Object();
		for (var i=0; i<status.length; i++) {
			statusObj[status[i]] = true;
		}
		_global.scripts.push({name:scripts[script].attributes.EXTRA, controls:controls, status:statusObj, running:scripts[script].attributes.RUNNING==1, enabled:scripts[script].attributes.ENABLED,  stoppable:scripts[script].attributes.STOPPABLE=="Y"});
	}
}

defineZones = function (zones) {
	for (var zone=0; zone<zones.length; zone++) {
		_global.zones.push({name:zones[zone].attributes.name, map:zones[zone].attributes.map, cycle:(zones[zone].attributes.cycle=="true"), skipForPDA:(zones[zone].attributes.skipForPDA=="true"), background:zones[zone].attributes.background, alignment:zones[zone].attributes.alignment, canOpen:zones[zone].attributes.canOpen, hideFromList:(zones[zone].attributes.hideFromList == "true"), rooms:[], panels:[], arbitrary:[]})
		for (var z=0; z<zones[zone].childNodes.length; z++) {
			if (zones[zone].childNodes[z].nodeName == "rooms") {
				var rooms = zones[zone].childNodes[z].childNodes;
				for (var room=0; room<rooms.length; room++) {
					_global.zones[zone].rooms.push({name:rooms[room].attributes.name,poly:rooms[room].attributes.poly, canOpen:rooms[room].attributes.canOpen, switchZone:rooms[room].attributes.switchZone, window:{}, alertGroups:[], doors:[]})
					for (var i=0; i<rooms[room].childNodes.length; i++) {
						switch (rooms[room].childNodes[i].nodeName) {
							case "window":
								defineWindow(rooms[room].childNodes[i], zone, room);
								break;
							case "alerts":
								var alertObj = new Object();
								alertObj.alerts = new Array();
								var alert = rooms[room].childNodes[i];
								alertObj.alertsPos = {x:alert.attributes.x, y:alert.attributes.y, layout:alert.attributes.layout};
								var alerts = alert.childNodes;
								for (var alert=0; alert<alerts.length; alert++) {
									alertObj.alerts.push({name:alerts[alert].attributes.name, keys:alerts[alert].attributes.keys, icon:alerts[alert].attributes.icon, fadeOutTime:alerts[alert].attributes.fadeOutTime});
									var keys = alerts[alert].attributes.keys.split(",");
									for (var key=0; key<keys.length; key++) {
										if (_global.controls[keys[key]] == undefined) {
											_global.controls[keys[key]] = {key:keys[key], name:alerts[alert].attributes.name, icon:alerts[alert].attributes.icon, canSee:alerts[alert].attributes.canSee, zone:zones[zone].attributes.name, room:rooms[room].attributes.name, storedStates:{}};
										}
									}
								}
								_global.zones[zone].rooms[room].alertGroups.push(alertObj);
								break;
							case "doors":
								var doors = rooms[room].childNodes[i].childNodes;
								for (var door=0; door<doors.length; door++) {
									if (doors[door].attributes.thickness == undefined) {
										var pos = doors[door].attributes.pos.split(",");
										for (var p=0; p<pos.length; p++) {
											pos[p] = Number(pos[p]);
										}
										_global.zones[zone].rooms[room].doors.push({name:doors[door].attributes.name, pos:pos, key:doors[door].attributes.key, colour:doors[door].attributes.colour, colours:doors[door].attributes.colours.split(",")});
									} else {
										var pos = doors[door].attributes.pos.split(",");
										for (var p=0; p<pos.length; p++) {
											pos[p] = Number(pos[p]);
										}
										_global.zones[zone].rooms[room].doors.push({name:doors[door].attributes.name, pos:pos, key:doors[door].attributes.key, colour1:doors[door].attributes.colour1, colour2:doors[door].attributes.colour2, thickness:doors[door].attributes.thickness});										
									}
									if (_global.controls[doors[door].attributes.key] == undefined) _global.controls[doors[door].attributes.key] = {key:doors[door].attributes.key, name:doors[door].attributes.name, zone:zones[zone].attributes.name, room:rooms[room].attributes.name};
								}
								break;
						}
					}
				}
			} else if (zones[zone].childNodes[z].nodeName == "panels") {
				var panels = zones[zone].childNodes[z].childNodes;
				for (var panel=0; panel<panels.length; panel++) {
					_global.zones[zone].panels.push({name:panels[panel].attributes.name, x:panels[panel].attributes.x, y:panels[panel].attributes.y, width:panels[panel].attributes.width, height:panels[panel].attributes.height, controls:[]})
					for (var i=0; i<panels[panel].childNodes.length; i++) {
						var control = panels[panel].childNodes[i];
						if (control.key != undefined && _global.controls[control.key] == undefined) _global.controls[control.key] = {key:control.key, zone:zones[zone].attributes.name, name:control.name, storedStates:{}};
						_global.zones[zone].panels[panel].controls[i] = new Object();
						for (var attrib in control.attributes) {
							_global.zones[zone].panels[panel].controls[i][attrib] = control.attributes[attrib];
						}
					}
				}
			} else if (zones[zone].childNodes[z].nodeName == "arbitrary") {
				var items = zones[zone].childNodes[z].childNodes;
				for (var item=0; item<items.length; item++) {
					var control = items[item].attributes;
					if (control.key != undefined) {
						if (_global.controls[control.key] == undefined) {
							_global.controls[control.key] = {key:control.key, zone:zones[zone].attributes.name, name:control.name, storedStates:new Object()};
						} else if (control.name != undefined) {
							_global.controls[control.key].name = control.name;
						}
					}
					_global.zones[zone].arbitrary.push({});
					for (var attrib in control) {
						_global.zones[zone].arbitrary[item][attrib] = control[attrib];
					}
				}
			}
		}
	}
}

defineWindow = function (window_xml, zone, room) {
	for (var attrib in window_xml.attributes) {
		if (attrib != "label" && Number(window_xml.attributes[attrib]) == window_xml.attributes[attrib]) {
			_global.zones[zone].rooms[room].window[attrib] = Number(window_xml.attributes[attrib]);
		} else if (window_xml.attributes[attrib] == "true" || window_xml.attributes[attrib] == "false") {
			_global.zones[zone].rooms[room].window[attrib] = (window_xml.attributes[attrib] == "true");
		} else {
			_global.zones[zone].rooms[room].window[attrib] = window_xml.attributes[attrib];
		}
	}
	_global.zones[zone].rooms[room].window.tabs = new Array();
	var tabs = window_xml.childNodes;
	for (var tab=0; tab<tabs.length; tab++) {
		
		var tabObj = new Object();
		tabObj.controls = new Array();
		for (var attrib in tabs[tab].attributes) {
			if (attrib != "label" && Number(tabs[tab].attributes[attrib]) == tabs[tab].attributes[attrib]) {
				tabObj[attrib] = Number(settings[setting].attributes.value);
			} else if (tabs[tab].attributes[attrib] == "true" || tabs[tab].attributes[attrib] == "false") {
				tabObj[attrib] = (tabs[tab].attributes[attrib] == "true");
			} else {
				tabObj[attrib] = tabs[tab].attributes[attrib];
			}
		}
		
		_global.zones[zone].rooms[room].window.tabs.push(tabObj);
		
		var controls = tabs[tab].childNodes;
		for (var control=0; control<controls.length; control++) {
			if (controls[control].attributes.key != undefined && _global.controls[controls[control].attributes.key] == undefined) _global.controls[controls[control].attributes.key] = {key:controls[control].attributes.key, zone:_global.zones[zone].attributes.name, room:_global.zones[zone].rooms[room].name, name:controls[control].attributes.name, storedStates:new Object()};
			//_global.controls[controls[control].attributes.key].storedStates["state"] = "on";
			_global.zones[zone].rooms[room].window.tabs[tab].controls[control] = new Object();
			for (var attrib in controls[control].attributes) {
				_global.zones[zone].rooms[room].window.tabs[tab].controls[control][attrib] = controls[control].attributes[attrib];
			}
		}
	}
}

defineControlTypes = function (controlTypes) {
	for (var controlType=0; controlType<controlTypes.length; controlType++) {
		var type = controlTypes[controlType].attributes.type;
		_global.controlTypes[type] = {rows:[]};
		var rows = controlTypes[controlType].childNodes;
		for (var row=0; row<rows.length; row++) {
			if (rows[row].nodeName != "row") {
				_global.controlTypes[type][rows[row].nodeName] = {command:rows[row].attributes.command, key:rows[row].attributes.key, extra:rows[row].attributes.extra}
			} else {
				var rowObj = _global.controlTypes[type].rows[row] = {items:[]};
				for (var attrib in rows[row].attributes) {
					rowObj[attrib] = rows[row].attributes[attrib];
				}
				
				var items = rows[row].childNodes;
				for (var item=0; item<items.length; item++) {
					rowObj.items[item] = new Object();
					for (var attrib in items[item].attributes) {		
						if (attrib != "label" && attrib != "extra" && Number(items[item].attributes[attrib]) == items[item].attributes[attrib]) {
							rowObj.items[item][attrib] = Number(items[item].attributes[attrib]);
						} else if (items[item].attributes[attrib] == "true" || items[item].attributes[attrib] == "false") {
							rowObj.items[item][attrib] = (items[item].attributes[attrib] == "true");
						} else {
							rowObj.items[item][attrib] = items[item].attributes[attrib];
						}
					}
				}
			}
		}
	}
}

defineMacros = function (macros, partial) {
	if (!partial) _global.macros = new Array();
	var wasNew = false;
	
	for (var macro=0; macro<macros.length; macro++) {
		var controlsXml = macros[macro].childNodes;
		var controls = [];
		for (var control=0; control<controlsXml.length; control++){
			var controlXml = controlsXml[control].attributes;
			controls.push({key:controlXml.KEY, command:controlXml.COMMAND, extra:controlXml.EXTRA, extra2:controlXml.EXTRA2, extra3:controlXml.EXTRA3, extra4:controlXml.EXTRA4, extra5:controlXml.EXTRA5});
		}
		var status = macros[macro].attributes.STATUS.split(",");
		var statusObj = new Object();
		for (var i=0; i<status.length; i++) {
			statusObj[status[i]] = true;
		}
		var macroObj = {name:macros[macro].attributes.EXTRA, controls:controls, status:statusObj, running:macros[macro].attributes.RUNNING == 1, type:macros[macro].attributes.TYPE};

		if (partial) {
			var found = false;
			for (var i=0; i<_global.macros.length; i++) {
				if (_global.macros[i].name == macroObj.name) {
					var found = true;
					_global.macros[i] = macroObj;
					break;
				}
			}
			if (!found) {
				_global.macros.push(macroObj);
				wasNew = true;
			}
		} else {
			_global.macros.push(macroObj);
		}
	}
	return wasNew;
}

defineCalendarData = function (events, partial) {
	if (!partial) _global.calendarData = new Array();
	for (var event=0; event<events.length; event++) {
		var d = events[event].attributes;
		
		var debug = "EventObj: ";
		for (var q in d) {
			debug += q + "=" + d[q] + "; ";
		}
		//trace(debug);

		for (var i=0; i<_global.calendarCategories.length; i++) {
			if (d.category == _global.calendarCategories[i].value) {
				d.iconName = _global.calendarCategories[i].icon;
				break;
			}
		}
		
		var t = d.time.split(":");
		d.time = new Date(1976, 8, 27, t[0], t[1], t[2]);
		if (d.eventType == "once") {
			var calendarObj = {id:d.id, title:d.title, active:d.active == "Y", alarm:d.alarm == "Y", memo:d.memo, iconName:d.iconName, category:d.category, startDate:d.date.parseDate(), endDate:d.date.parseDate(), time:d.time, runTime:d.runTime, eventType:"once", macroName:d.macroName, extra:d.extra, extra2:d.extra2, filter:d.filter};
		} else {
			var skip = new Array();
			for (var i in events[event].childNodes) {
				var node = events[event].childNodes[i];
				switch (node.nodeName) {
					case "skip":
						var from = node.attributes.start_date.parseDate();
						var to = node.attributes.end_date.parseDate();
						while (from <= to) {
							skip.push(from.getTime());
							from.setDate(from.getDate() + 1);
						}
						skip.sort();
						break;
					case "pattern":
						var pattern = new Object();
						for (var attrib in node.attributes) {
							if (Number(node.attributes[attrib]) == node.attributes[attrib]) {
								pattern[attrib] = Number(node.attributes[attrib]);
							} else {
								pattern[attrib] = node.attributes[attrib];
							}
							//trace("-- pattern: " + attrib + ":" + node.attributes[attrib]);
						}
						break;
				}
			}
			var calendarObj = {id:d.id, title:d.title, active:d.active == "Y", alarm:d.alarm == "Y", memo:d.memo, iconName:d.iconName, category:d.category, startDate:d.startDate.parseDate(), endDate:d.endDate.parseDate(), time:d.time, runTime:d.extra2, skip:skip, eventType:d.eventType, macroName:d.macroName, extra:d.extra, extra2:d.extra2, filter:d.filter, pattern:pattern};
		}
		if (partial) {
			var found = false;
			for (var i=0; i<_global.calendarData.length; i++) {
				if (_global.calendarData[i].id == calendarObj.id) {
					var found = true;
					_global.calendarData[i] = calendarObj;
					break;
				}
			}
			if (!found) {
				_global.calendarData.push(calendarObj);
			}
		} else {
			_global.calendarData.push(calendarObj);
		}
	}
}

defineSounds = function (sounds) {
	for (var snd=0; snd<sounds.length; snd++) {
		var s = _global.sounds[sounds[snd].attributes.name] = new Sound();
		s.loadSound(_global.settings.libLocation + sounds[snd].attributes.file);
		s.setVolume(sounds[snd].attributes.volume)
	}
}

defineControlPanelApps = function (apps) {
	for (var app=0; app<apps.length; app++) {
		var appObj = new Object();
		for (var attrib in apps[app].attributes) {
			appObj[attrib] = apps[app].attributes[attrib];
		}
		_global.controlPanelApps.push(appObj);
	}
}

defineTV = function (nodes) {
	_global.tv = {key:"TV", name:"TV", icon:"tv", rows:[]};
	
	for (var i=0; i<nodes.length; i++) {
		switch (nodes[i].nodeName) {
			case "open":
				_global.tv.open = nodes[i].attributes.command;
				break;
			case "close":
				_global.tv.close = nodes[i].attributes.command;
				break;
			case "control":
				var rowsData = new Array();
				var rows = nodes[i].childNodes;
				
				for (var row=0; row<rows.length; row++) {
					var rowObj = _global.tv.rows[row] = {items:[]};
					for (var attrib in rows[row].attributes) {
						rowObj[attrib] = rows[row].attributes[attrib];
					}
					
					var items = rows[row].childNodes;
					for (var item=0; item<items.length; item++) {
						rowObj.items[item] = new Object();
						for (var attrib in items[item].attributes) {		
							if (attrib != "label" && attrib != "extra" && Number(items[item].attributes[attrib]) == items[item].attributes[attrib]) {
								rowObj.items[item][attrib] = Number(items[item].attributes[attrib]);
							} else if (items[item].attributes[attrib] == "true" || items[item].attributes[attrib] == "false") {
								rowObj.items[item][attrib] = (items[item].attributes[attrib] == "true");
							} else {
								rowObj.items[item][attrib] = items[item].attributes[attrib];
							}
						}
					}
				}
				break;
		}
	}
}