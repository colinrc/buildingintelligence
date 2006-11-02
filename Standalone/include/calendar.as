﻿import bi.util.DateFunction;

_global.daysOfWeek = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];

openCalendar = function () {
	if (_global.windows["openCalendar"] == "open") {
		window_mc.close();
	} else {
		var window_mc = showWindow({width:"full", height:"full", title:"Calendar", iconName:"calendar"});
		appsBar_mc.openCalendar_mc.showHighlight();
		_global.windows["openCalendar"] = "open";
		window_mc.onClose = function () {
			appsBar_mc.openCalendar_mc.hideHighlight();
			delete _global.windows["openCalendar"];
			for (var i=0; i<this.contentClip.tabs_mc.contentClips.length; i++) {
				this.contentClip.tabs_mc.contentClips[i].onClose();
			}
		}
		
		var tabs_mc = window_mc.contentClip.attachMovie("bi.ui.Tabs", "tabs_mc", 0, {settings:{width:window_mc.contentClip.width, height:window_mc.contentClip.height}});
		
		var tabData = new Array();
		for (var q=0; q<_global.calendar.length; q++) {
			tabData.push({name:_global.calendar[q].label, iconName:_global.calendar[q].icon});
		}
		
		tabs_mc.tabData = tabData;
		
		for (var i=0; i<tabs_mc.tabData.length; i++) {
			_root[tabs_mc.tabData[i].func](tabs_mc.contentClips[i]);
		}
		
		tabs_mc.originalTitle = "Calendar";
		tabs_mc.changeTab = function (eventObj) {
			// set window title
			this._parent._parent.title = this.originalTitle + ": " + eventObj.name;
			eventObj.newTab.update();
		}
		tabs_mc.addEventListener("changeTab", tabs_mc);
		tabs_mc.activeTab = 0;

		///////////////////
		// render views //
		//////////////////
		
		var columnBreak = 490;
		
		/////////////////////////////////////////
		// render watering and automation view //
		/////////////////////////////////////////
		
		for (var q=0; q<_global.calendar.length; q++) {
		
			var content_mc = tabs_mc.contentClips[q];
			content_mc.tabNum = q;
			
			switch (_global.calendar[q].view) {
				case "today":
					content_mc.createEmptyMovieClip("line1_mc", 100);
					content_mc.line1_mc.lineStyle(1, 0xFFFFFF, 40);
					content_mc.line1_mc.lineTo(0,  content_mc.height);
					content_mc.line1_mc._x = columnBreak;
					
					var calendar_ec = content_mc.attachMovie("bi.ui.Calendar", "calendar_ec", 10, {});
					calendar_ec._x = 15;
				
					calendar_ec.onDisplayEvent = function (eventsData, dateObj) {
						showDay(dateObj, eventsData, this._parent);
					}
					
					// onSelectDate is called when a day with no events is clicked
					calendar_ec.onSelectDate = function (dateObj) {
						showDay(dateObj, null, this._parent);
					}
				
					calendar_ec.onHideEvent = function () {
						currentDay_mc.removeMovieClip();
						standardEvents_mc.removeAll();
						this._parent.day_lb.text = "";
						macroEvents_mc.removeAll();
					}
					
					showDay = function (dateObj, eventsData, context) {
						context.dateObj = dateObj;
						var currentDay_mc = context.createEmptyMovieClip("currentDay_mc", 20);
						context.standardEvents_mc.removeAll();
						context.day_lb.text = dateObj.dateTimeFormat("dddd, d mmmm yyyy:");
						context.macroEvents_mc.removeAll();
						eventsData.sortOn("time");
						for (var i=0; i<eventsData.length; i++) {
							// only render active (enabled) events
							if (eventsData[i].active) {
								var eventObj = new Object();
								eventObj.eventType = eventsData[i].eventType;
								eventObj.id = eventsData[i].id;
								eventObj.title = eventsData[i].title;
								eventObj.alarm = eventsData[i].alarm;
								eventObj.memo = eventsData[i].memo;
								eventObj.iconName = eventsData[i].iconName;
								eventObj.category = eventsData[i].category;
								eventObj.time = eventsData[i].time;
								eventObj.macroName = eventsData[i].macroName;
								eventObj.extra = eventsData[i].extra;
								eventObj.extra2 = eventsData[i].extra2;
								eventObj.startDate = eventsData[i].startDate;
								eventObj.endDate = eventsData[i].endDate;
								eventObj.filter = eventsData[i].filter;
								eventObj.skip = eventsData[i].skip;
								eventObj.pattern = new Object();
								for (var q in eventsData[i].pattern) {
									eventObj.pattern[q] = eventsData[i].pattern[q];
								}
	
								var title = "";
								
								if (eventObj.extra.length) {
									var zone = _global.calendarZoneLabels[eventObj.extra];
									if (eventObj.title.length) {
										title = eventObj.title + " (" + zone + ")";
									} else {
										title = "(" + zone + ")";
									}
								} else if (eventObj.macroName.length) {
									if (eventObj.title.length) {
										title = eventObj.title + " (" + eventObj.macroName + ")";
									} else {
										title = "(" + eventObj.macroName + ")";
									}								
								} else {
									title = eventObj.title;
								}
								
								title = eventObj.time.dateTimeFormat(_global.settings.shortTimeFormat)  +"\t" + title;
								
								if (eventObj.eventType == "hourly") {
									if (eventObj.pattern.recur == 1) {
										title += " [Every hour]";
									} else {
										title += " [Every " + eventObj.pattern.recur + " hours]";
									}
								}
														
								if (eventObj.macroName.length) {					
									for (var d=0; d<_global.calendar.length; d++) {
										if (eventObj.macroName == _global.calendar[d].macro || _global.calendar[d].macro == "*") {
											var iconName = _global.calendar[d].icon;
											break;
										}
									}
									var skip = false;
									var skipData = eventObj.skip;
									for (var p=0; p<skipData.length; p++) {
										if (dateObj.getTime() == skipData[p]) {
											skip = true;
											break;
										} else if (dateObj.getTime() < skipData[0] || dateObj.getTime() > skipData[skipData.length - 1]) {
											break;
										}
									}
									macroEvents_mc.addItem({label:title, value:eventObj, iconName:iconName, strikeThrough:skip});
								} else {
									standardEvents_mc.addItem({label:title, value:eventObj, iconName:eventObj.iconName});
								}
							}
						}
					}
				
					content_mc.update = function () {
						if (!this._visible) return;
						this.calendar_ec.setDataProvider(_global.calendarData);
						this.calendar_ec.getDayByDate(this.dateObj.getDate()).onRelease();
					}
					subscribe("events", content_mc);
					content_mc.onClose = function () {
						unsubscribe("events", this);
					}
							
					content_mc.attachMovie("bi.ui.Label", "day_lb", 25, {settings:{width:content_mc.width - columnBreak - 10, align:"center", _x:columnBreak + 10, _y:0, fontSize:18}});
			
					var standardEvents_mc = content_mc.attachMovie("bi.ui.List", "standardEvents_mc", 30, {settings:{width:content_mc.width - columnBreak - 10, height:content_mc.height / 2 - 30}});
					standardEvents_mc._x = columnBreak + 10;
					standardEvents_mc._y = 30;
					standardEvents_mc.addEventListener("change", standardEvents_mc);
					standardEvents_mc.change = function (eventObj) {
						editCalendarEvent(eventObj.target.selectedItem.value, this._parent.dateObj);
						this.selectedIndex = null;
					}
			
					content_mc.attachMovie("bi.ui.Label", "events_lb", 40, {settings:{text:"Scheduled events:", width:content_mc.width - columnBreak - 10, align:"center", _x:columnBreak + 10, _y:Math.round(content_mc.height / 2), fontSize:18}});
					
					var macroEvents_mc = content_mc.attachMovie("bi.ui.List", "macroEvents_mc", 50, {settings:{width:content_mc.width - columnBreak - 10, height:content_mc.height / 2 - 30}});
					macroEvents_mc._x = columnBreak + 10;
					macroEvents_mc._y = content_mc.height / 2 + 30;
					macroEvents_mc.addEventListener("change", macroEvents_mc);
					macroEvents_mc.change = function (eventObj) {
						skipCalendarEvent(eventObj.target.selectedItem.value, this._parent.dateObj);
						this.selectedIndex = null
					}
					
					var buttons_mc = content_mc.createEmptyMovieClip("buttons_mc", 60);
					buttons_mc.attachMovie("bi.ui.Button", "newEvent_btn", 10, {settings:{width:calendar_ec._width, height: 30, label:"Create new..."}});
					buttons_mc.newEvent_btn.press = function () {
						newCalendarEvent(null, this._parent._parent.dateObj);
					}
					buttons_mc.newEvent_btn.addEventListener("press", buttons_mc.newEvent_btn);
					buttons_mc.attachMovie("bi.ui.Button", "today_btn", 20, {settings:{width:calendar_ec._width, height: 30, label:"Go to today"}});
					buttons_mc.today_btn.press = function () {
						calendar_ec.setDate(new Date());
						calendar_ec.getDayByDate(new Date().getDate()).onRelease();
					}
					buttons_mc.today_btn.addEventListener("press", buttons_mc.today_btn);
					buttons_mc.today_btn._y = 40;
					
					buttons_mc._x = calendar_ec._x;
					buttons_mc._y = calendar_ec._y + calendar_ec._height + 70;
							
					calendar_ec.setDisplayRange({begin:new Date(2000, 0),end:new Date(2010, 11)});
					calendar_ec.setDataProvider(_global.calendarData);
					calendar_ec.getDayByDate(new Date().getDate()).onRelease();
					break;
				case "filtered":
				case "macros":				
					var arrows_mc = content_mc.createEmptyMovieClip("arrows_mc",10);
					var leftArrow_mc = arrows_mc.attachMovie("bi.ui.Button", "leftArrow_mc", 10, {settings:{width:60, height:30, iconName:"left-arrow"}});
					leftArrow_mc.press = function () {
						var base = this._parent._parent;
						base.currentWeekStarting.setDate(base.currentWeekStarting.getDate() - 7);
						base.update();
					}
					leftArrow_mc.addEventListener("press", leftArrow_mc);
					
					var week_txt = arrows_mc.attachMovie("bi.ui.Label", "week_txt", 50, {settings:{width:250, fontSize:18, align:"center", _x:leftArrow_mc._width, _y:3}});
			
					var rightArrow_mc = arrows_mc.attachMovie("bi.ui.Button", "rightArrow_mc", 20, {settings:{width:60, height:30, iconName:"right-arrow"}});
					rightArrow_mc._x = leftArrow_mc._width + week_txt._width;
					rightArrow_mc.press = function () {
						var base = this._parent._parent;
						base.currentWeekStarting.setDate(base.currentWeekStarting.getDate() + 7);
						base.update();
					}
					rightArrow_mc.addEventListener("press", rightArrow_mc);
					
					arrows_mc._x = Math.round((content_mc.width / 2) - (arrows_mc._width / 2));
									
					var lines_mc = content_mc.createEmptyMovieClip("lines_mc", 100);
					var daysOfWeek_mc = content_mc.createEmptyMovieClip("daysOfWeek_mc", 20);
					daysOfWeek_mc._y = 50;
					lines_mc._alpha = 40;
					lines_mc.lineStyle(1, 0xFFFFFF);
					var colStart = 150;
					var colWidth = Math.round((content_mc.width - 40 - colStart) / 7);
					for (var i=0; i<7; i++) {
						lines_mc.moveTo(i * colWidth + colStart, daysOfWeek_mc._y + 20);
						lines_mc.lineTo(i * colWidth + colStart,  content_mc.height - 40);
						
						daysOfWeek_mc.attachMovie("bi.ui.Label", "day" + i + "_txt", i, {settings:{width:colWidth, text:_global.daysOfWeek[i], fontSize:14, align:"center", _x:i * colWidth + colStart}});
					}
					
					var rowsMask_mc = content_mc.createEmptyMovieClip("rowsMask_mc", 55);
					rowsMask_mc._y = daysOfWeek_mc._y + 30;
					rowsMask_mc.beginFill(0xFFCC00, 20);
					rowsMask_mc.lineTo(content_mc.width - 40, 0);
					rowsMask_mc.lineTo(content_mc.width - 40, content_mc.height - 40 - rowsMask_mc._y);
					rowsMask_mc.lineTo(0, content_mc.height - 40 - rowsMask_mc._y);
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
					
					var scrollUp_mc = scrollBar_mc.attachMovie("bi.ui.Button", "scrollUp_mc", 10, {settings:{width:34, height:34, iconName:"up-arrow"}});
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
						var p = this._parent._parent.rows_mc;
						if (p._y < this._parent._y) {
							p._y += 42;
						} else {
							clearInterval(this.repeatID);
						}
					}	
				
					var scrollDown_mc = scrollBar_mc.attachMovie("bi.ui.Button", "scrollDown_mc", 20, {settings:{width:34, height:34, iconName:"down-arrow"}});
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
						var p = this._parent._parent.rows_mc;
						if (p._y + p._height > this._parent._y + this._parent._height) {
							p._y -= 42;
						} else {
							clearInterval(this.repeatID);
						}
					}
	
					// add new event button
					var add_btn = content_mc.attachMovie("bi.ui.Button", "label_txt", 80, {settings:{width:colStart - 8, label:"Add", fontSize:14, _x:4, _y:content_mc.height - 30}});
					add_btn.press = function (eventObj) {
						var base = this._parent;
						createRecurringEvent(base.tabNum, base.currentWeekStarting);
					}
					add_btn.addEventListener("press", add_btn);
							
					content_mc.calendarTab = _global.calendar[q];
					var now = new Date();
					now.setDate(now.getDate() - now.getDay());
					now.setHours(0);
					now.setMinutes(0);
					now.setSeconds(0);
					now.setMilliseconds(0);
					content_mc.currentWeekStarting = now;
					content_mc.tabNum = q;
					content_mc.update = function (key, id) {
						if (!this._visible) return;											
						//trace("redrawing " + this);

						switch (_global.calendar[this.tabNum].view) {
							case "filtered":
								var listData = [];
								for (var i=0; i<_global.calendarData.length; i++) {
									if (_global.calendarData[i].macroName == this.calendarTab.macro) {
										var eventObj = new Object();
										for (var d=0; d<_global.calendar[this.tabNum].zones.length; d++) {
											if (_global.calendar[this.tabNum].zones[d].key == _global.calendarData[i].extra) {
												eventObj.label = _global.calendarData[i].title + " (" + _global.calendar[this.tabNum].zones[d].label + ")";
												break;
											}
										}
										eventObj.time = _global.calendarData[i].time.dateTimeFormat(_global.settings.shortTimeFormat);
										eventObj.runTime = Math.ceil(Number(_global.calendarData[i].extra2 / 60)) + " mins\n";
										eventObj.skip = _global.calendarData[i].skip;
										eventObj.calendarObj = _global.calendarData[i];
										listData.push(eventObj);
									}
								}
								break;
							case "macros":
								var listData = [];
								for (var i=0; i<_global.calendarData.length; i++) {
									if (_global.calendarData[i].macroName != "" && _global.calendarData[i].extra2 == "") {
										var eventObj = new Object();
										eventObj.label = _global.calendarData[i].title + " (" + _global.calendarData[i].macroName + ")";
										eventObj.time = _global.calendarData[i].time.dateTimeFormat(_global.settings.shortTimeFormat);
										eventObj.runTime = "";
										eventObj.skip = _global.calendarData[i].skip;
										eventObj.calendarObj = _global.calendarData[i];
										listData.push(eventObj);
									}
								}
								break;
						}
						
						if (id == undefined) {
							this.arrows_mc.week_txt.text = "Week: " + this.currentWeekStarting.dateTimeFormat("d mmmm yyyy");
							
							var rows_mc = this.createEmptyMovieClip("rows_mc", 50);
							rows_mc.setMask(this.rowsMask_mc);
							rows_mc._y = daysOfWeek_mc._y + 30;
							for (var i=0; i<listData.length; i++) {
								// render row
								if (id == undefined || listData[i].id == id) {
									var row_mc = rows_mc.createEmptyMovieClip("row" + i + "_mc", i);
									renderRow(listData[i], row_mc, this.width - 40, colWidth, colStart, i % 2, this.currentWeekStarting);
									row_mc._y = (row_mc._height + 2) * i;
								}
							}
						} else {
							for (var i=0; i<listData.length; i++) {
								// update row
								if (listData[i].calendarObj.id == id) {
									var row_mc = this.rows_mc.createEmptyMovieClip("row" + i + "_mc", i);
									trace(this.currentWeekStarting);
									renderRow(listData[i], row_mc, this.width - 40, colWidth, colStart, i % 2, this.currentWeekStarting);
									row_mc._y = (row_mc._height + 2) * i;
									break;
								}
							}
						}
					}
					//content_mc.update();
					subscribe("events", content_mc);
					content_mc.onClose = function () {
						unsubscribe("events", this);
					}
					break;
			}
		}
	}
}

renderRow = function (rowData, row_mc, rowWidth, colWidth, colStart, odd, currentWeekStarting) {	
	var bg_mc = row_mc.createEmptyMovieClip("bg_mc", 0);
	if (odd) {
		bg_mc.beginFill(0x043B96, 30);				
	} else {
		bg_mc.beginFill(0xFFFFFF, 25);
	}
	bg_mc.drawRect(0, 0, rowWidth, 40, 6);
	bg_mc.endFill();
	
	bg_mc.calendarObj = rowData.calendarObj;
	bg_mc.onPress = function () {
		editRecurringEvent(this.calendarObj);
	}
	
	var label_txt = row_mc.attachMovie("bi.ui.Label", "label_txt", 10, {settings:{width:colStart, text:rowData.label, fontSize:14, _x:4}});
	label_txt._y = Math.round((bg_mc._height / 2) - (label_txt._height / 2));
	if (!rowData.calendarObj.active) {
		label_txt._alpha = 60;
	}
	
	var calendarObj = rowData.calendarObj;
	var dayObj = {sun:0, mon:1, tue:2, wed:3, thu:4, fri:5, sat:6};
	
	if (calendarObj != undefined) {
		for (var z=0; z<7; z++) {
			var currentDate = DateFunction.dateAdd("d", currentWeekStarting, z);

			// check if day is within start/end range
			if (currentDate >= calendarObj.startDate && currentDate <= calendarObj.endDate) {									
				// check if current day fits into defined pattern
				if (
					(calendarObj.eventType == "once" && calendarObj.startDate.getTime() == currentDate.getTime())
					|| (calendarObj.eventType == "hourly")
					|| (calendarObj.eventType == "daily" && ((calendarObj.filter == "" && DateFunction.dateDiff("d", calendarObj.startDate, currentDate) % calendarObj.pattern.recur == 0) || (calendarObj.filter == "odd" && z % 2 == 0) || (calendarObj.filter == "even" && z % 2 == 1)))
					|| (calendarObj.eventType == "weekly" && calendarObj.pattern[_global.daysOfWeek[z].toLowerCase().substr(0, 3)] == 1 && DateFunction.dateDiff("w",  currentWeekStarting, calendarObj.startDate) % calendarObj.pattern.recur == 0)
					|| (calendarObj.eventType == "monthly" && calendarObj.pattern.date == currentDate.getDate() && DateFunction.dateDiff("m", currentDate, calendarObj.startDate) % calendarObj.pattern.recur == 0)
					|| (calendarObj.eventType == "monthly" && dayObj[calendarObj.pattern.day] == currentDate.getDay() && DateFunction.getFloatingDate(dayObj[calendarObj.pattern.day], currentDate.getMonth(), currentDate.getFullYear(), calendarObj.pattern.week).getTime() == currentDate.getTime() && DateFunction.dateDiff("m", currentDate, calendarObj.startDate) % calendarObj.pattern.recur == 0)
					|| (calendarObj.eventType == "yearly" && calendarObj.pattern.month == currentDate.getMonth() + 1 && calendarObj.pattern.date == currentDate.getDate() && DateFunction.dateDiff("y", currentDate, calendarObj.startDate) % calendarObj.pattern.recur == 0)
					){
										
					var cell_mc = row_mc.createEmptyMovieClip("cell" + z + "_mc", z + 20);
					cell_mc.calendarObj = calendarObj;
					cell_mc.dateObj = currentDate;
					cell_mc._x = z * colWidth + colStart;
					cell_mc.skip = false;
					
					var hitArea_mc = cell_mc.createEmptyMovieClip("hitArea_mc", 0);
					hitArea_mc.beginFill(0xFFCC00);
					hitArea_mc.drawRect(0, 0, colWidth, bg_mc._height);
					cell_mc.hitArea = hitArea_mc;
					hitArea_mc._visible = false;
					
					var holder_mc = cell_mc.createEmptyMovieClip("holder_mc", 10);
					
					holder_mc.attachMovie("bi.ui.Icon", "icon_mc", 10, {settings:{iconName:"check", size:25, _y:2}});								
					holder_mc.attachMovie("bi.ui.Label", "label_txt", 20, {settings:{width:colWidth - holder_mc.icon_mc._width - 20, fontSize:10, text:rowData.runTime + "@ " + rowData.time, _x:holder_mc.icon_mc._width + 4}});
					
					holder_mc.label_txt._y = (holder_mc.icon_mc._height / 2) - (holder_mc.label_txt._height / 2);
					
					holder_mc._x = Math.round((hitArea_mc._width / 2) - (holder_mc._width / 2));
					holder_mc._y = Math.round((hitArea_mc._height / 2) - (holder_mc._height / 2));
	
					cell_mc.onPress = function () {
						this.pressTime = getTimer();
						this.onEnterFrame = function () {
							if (getTimer() > this.pressTime + 500) {
								skipCalendarEvent(this.calendarObj, this.dateObj);
								delete this.onEnterFrame;
							}
						}
					}
					cell_mc.onRelease = function () {
						if (getTimer() < this.pressTime + 500) {
							updateEventSkip(this.calendarObj, !this.skip, new Date(this.dateObj.getTime()), new Date(this.dateObj.getTime()));
							delete this.onEnterFrame;
						}
					}
					
					var skip = false;
					var skipData = rowData.skip;
					for (var p=0; p<skipData.length; p++) {
						if (currentDate.getTime() == skipData[p]) {
							skip = true;
							break;
						} else if (currentDate.getTime() < skipData[0] || currentDate.getTime() > skipData[skipData.length - 1]) {
							break;
						}
					}
					
					if (skip) {
						//cell_mc.enabled = false;
						cell_mc.skip = true;
						holder_mc._alpha = 70;
						var myColorMatrix_filter = new ColorMatrixFilter([0.3, 0.59, 0.11, 0, 0, 0.3, 0.59, 0.11, 0, 0, 0.3, 0.59, 0.11, 0, 0, 0, 0, 0, 1, 0]);
						holder_mc.filters = [myColorMatrix_filter];
					}
				}
			}
		}
	}
}

skipCalendarEvent = function (calendarObj, dateObj) {
	var window_mc = showWindow({width:350, height:320, title:"Edit: " + calendarObj.title, iconName:"calendar", align:"center"});
	
	var content_mc = window_mc.content_mc;
	var buttonWidth = content_mc.width;
	
	var from = new Date(dateObj.getTime());
	var to = new Date(dateObj.getTime());
	
	var buttonListener = new Object();
	buttonListener.calendarObj = calendarObj;
	buttonListener.press = function (eventObj) {
		switch (eventObj.target.id) {
			case "editEvent":
				editRecurringEvent(this.calendarObj);
				break;
			case "tomorrow":
				to = dateAdd(to, "d", 1);
				break;
			case "week":
				to = dateAdd(to, "w", 1);
				break;
			case "month":
				to = dateAdd(to, "m", 1);
				break;
			case "neverSkip":
				updateEventSkip(this.calendarObj, false);
				break;
		}
		if (eventObj.target.id != "editEvent" && eventObj.target.id != "neverSkip") {
			updateEventSkip(this.calendarObj, true, from, to);
		}
		eventObj.target._parent._parent.close();
	}
	
	var tmp = new Date(to.getTime());
	
	var buttons = [{label:"Skip until " + _global.daysOfWeek[dateAdd(to, "d", 1).getDay()], id:"today"}, {label:"Skip until " +  _global.daysOfWeek[dateAdd(to, "d", 2).getDay()], id:"tomorrow"}, {label:"Skip for 1 week", id:"week"}, {label:"Skip for 1 month", id:"month"}, {label:"Never skip", id:"neverSkip"}, {label:"Edit event", id:"editEvent"}];
	for (var i=0; i<buttons.length; i++) {
		var btn_mc = content_mc.attachMovie("bi.ui.Button", buttons[i].id + "_btn", i + 10, {settings:{width:buttonWidth, height:35, label:buttons[i].label}, id:buttons[i].id});
		btn_mc._y = i * (btn_mc._height + 8);
		btn_mc.addEventListener("press", buttonListener);
	}
}

updateEventSkip = function (calendarObj, skip, from, to) {
	if (skip) {
		//trace("skip for " + from.dateTimeFormat("yyyy-mm-dd") + " until " + to.dateTimeFormat("yyyy-mm-dd"));
		while (from <= to) {
			calendarObj.skip.push(from.getTime());
			from.setDate(from.getDate() + 1);
		}
		calendarObj.skip.sort();
	} else {
		if (from == undefined || to == undefined) {
			calendarObj.skip = new Array();
		} else {
			//trace("unskip for " + from.dateTimeFormat("yyyy-mm-dd") + " until " + to.dateTimeFormat("yyyy-mm-dd"));
			for (var i=0; i<calendarObj.skip.length; i++) {
				if (calendarObj.skip[i] == from.getTime()) {
					var remove = (from.getTime() == to.getTime()) ? 1 : (to.getTime() - from.getTime()) / 86400000;
					calendarObj.skip.splice(i, remove);
				}
			}
		}
	}
	saveEvent(calendarObj);
}

editCalendarEvent = newCalendarEvent = function (calendarObj, dateObj) {
	if (calendarObj != undefined) {
		var mode = "edit";
		var window_mc = showWindow({width:580, height:455, title:"Edit event: " + calendarObj.title, iconName:"calendar", align:"center"});
	} else {
		var mode = "create";
		var calendarObj = new Object();
		calendarObj.isNew = true;
		calendarObj.id = "";
		calendarObj.eventType = "once";
		calendarObj.title = "";
		calendarObj.active = true;
		calendarObj.alarm = false;
		calendarObj.memo = "";
		calendarObj.category = "";
		calendarObj.macroName = "";
		calendarObj.extra = "";
		calendarObj.extra2 = "";
		calendarObj.filter = "";
		calendarObj.time = new Date();
		calendarObj.startDate = dateObj;
		calendarObj.endDate = DateFunction.dateAdd("y", dateObj, 1);
		calendarObj.pattern = new Object();
		var window_mc = showWindow({width:580, height:455, title:"Create new event:", iconName:"calendar", align:"center"});
	}
	
	var content_mc = window_mc.content_mc;
	
	content_mc.attachMovie("bi.ui.Label", "title_lb", 10, {settings:{width:80, text:"Title:"}});
	content_mc.attachMovie("bi.ui.TextInput", "title_ti", 15, {settings:{width:180, text:calendarObj.title, _x:90, maxChars:20}});
	
	content_mc.attachMovie("bi.ui.Label", "time_lb", 20, {settings:{width:80, text:"Time:", _y:35}});
	content_mc.attachMovie("bi.ui.TimePicker", "time_tp", 25, {settings:{width:180, time:calendarObj.time, _x:90, _y:35}});
	
	content_mc.attachMovie("bi.ui.Label", "msg_lb", 40, {settings:{width:80, text:"Message:", _y:70}});
	content_mc.attachMovie("bi.ui.TextInput", "msg_ti", 45, {settings:{width:180, height:175, text:calendarObj.memo, _x:90, _y:70, minChars:0, maxChars:200}});

	content_mc.attachMovie("bi.ui.Label", "alarm_lb", 30, {settings:{width:80, text:"Alarm:", _y:250}});
	content_mc.attachMovie("bi.ui.CheckBox", "alarm_cb", 35, {settings:{_x:90, _y:250, selected:calendarObj.alarm}});
	
	content_mc.attachMovie("bi.ui.Label", "category_lb", 50, {settings:{width:80, text:"Category:", _y:285}});
	content_mc.attachMovie("bi.ui.ItemPicker", "category_ip", 55, {settings:{width:180, items:_global.calendarCategories, _x:90, _y:285}});
	content_mc.category_ip.selectedValue = calendarObj.category;

	content_mc.attachMovie("bi.ui.Label", "active_lb", 60, {settings:{width:80, text:"Active:", _y:320}});
	content_mc.attachMovie("bi.ui.CheckBox", "active_cb", 65, {settings:{_x:90, _y:320, selected:calendarObj.active}});
	
	content_mc.attachMovie("bi.ui.Label", "recurrence_lb", 69, {settings:{width:100, text:"Recurrence:", _x:280}});
	
	content_mc.attachMovie("bi.ui.RadioButton", "once_rb", 70, {settings:{width:110, label:"Once", data:"once", _x:280, _y:35, groupName:"period"}});
	content_mc.attachMovie("bi.ui.RadioButton", "hourly_rb", 71, {settings:{width:110, label:"Hourly", data:"hourly", _x:420, _y:35, groupName:"period"}});
	content_mc.attachMovie("bi.ui.RadioButton", "daily_rb", 72, {settings:{width:110, label:"Daily", data:"daily", _x:280, _y:70, groupName:"period"}});
	content_mc.attachMovie("bi.ui.RadioButton", "weekly_rb", 73, {settings:{width:110, label:"Weekly", data:"weekly", _x:420, _y:70, groupName:"period"}});
	content_mc.attachMovie("bi.ui.RadioButton", "monthly_rb", 74, {settings:{width:110, label:"Monthly", data:"monthly", _x:280, _y:105, groupName:"period"}});
	content_mc.attachMovie("bi.ui.RadioButton", "yearly_rb", 75, {settings:{width:110, label:"Yearly", data:"yearly", _x:420, _y:105, groupName:"period"}});
	content_mc.period.data = calendarObj.eventType;
	
	var periodListener = new Object();
	periodListener.click = function (eventObj) {
		var tabs_mc = eventObj.target.selection._parent.tabs_mc;
		tabs_mc.selectedTab._visible = false;
		tabs_mc.selectedTab = tabs_mc[eventObj.target.data + "_mc"];
		tabs_mc.selectedTab._visible = true;
	}
	content_mc.period.addEventListener("click", periodListener);
	
	var tabs_mc = content_mc.createEmptyMovieClip("tabs_mc", 80);
	tabs_mc._x = 280;
	tabs_mc._y = 150;
	
	// hourly tab
	var tab_mc = tabs_mc.createEmptyMovieClip("hourly_mc", 0);
	tab_mc.attachMovie("bi.ui.Label", "every_lb", 0, {settings:{width:200, text:"Every         hour(s)"}});
	tab_mc.attachMovie("bi.ui.TextInput", "numHours_ti", 5, {settings:{width:30, text:"1", _x:50, minValue:1, maxValue:12, maxChars:2, inputType:"numeric"}});
	if (calendarObj.eventType == "hourly") {
		tab_mc.numHours_ti.text = calendarObj.pattern.recur;
	}
	tab_mc._visible = false;
	
	// daily tab
	var tab_mc = tabs_mc.createEmptyMovieClip("daily_mc", 10);
	tab_mc.attachMovie("bi.ui.RadioButton", "everyXdays_rb", 0, {settings:{width:200, label:"Every         day(s)",  data:"", groupName:"every"}});
	tab_mc.attachMovie("bi.ui.TextInput", "numDays_ti", 5, {settings:{width:30, text:"1", _x:85, minValue:1, maxValue:7, maxChars:1, inputType:"numeric"}});	
	tab_mc.attachMovie("bi.ui.RadioButton", "everyOddDay_rb", 10, {settings:{width:200, label:"Every odd day",  data:"odd", _y:35, groupName:"every"}});
	tab_mc.attachMovie("bi.ui.RadioButton", "everyEvenDay_rb", 20, {settings:{width:200, label:"Every even day",  data:"even", _y:70, groupName:"every"}});
	if (calendarObj.eventType == "daily") {
		if (calendarObj.filter == "odd" || calendarObj.filter == "even") {
			tab_mc.every.data = calendarObj.filter;
		} else {
			tab_mc.every.data = "";
			tab_mc.numDays_ti.text = calendarObj.pattern.recur;
		}
	} else {
		tab_mc.every.data = "";
	}
	tab_mc._visible = false;
	
	// weekly tab
	var tab_mc = tabs_mc.createEmptyMovieClip("weekly_mc", 20);
	tab_mc.attachMovie("bi.ui.Label", "every_lb", 0, {settings:{width:200, text:"Every         week(s) on:"}});
	tab_mc.attachMovie("bi.ui.TextInput", "numWeeks_ti", 5, {settings:{width:30, text:"1", _x:50, minValue:1, maxValue:4, maxChars:1, inputType:"numeric"}});
	tab_mc.attachMovie("bi.ui.RadioButton", "monday_rb", 10, {settings:{width:130, label:"Monday", _y:35}});
	tab_mc.attachMovie("bi.ui.RadioButton", "tuesday_rb", 15, {settings:{width:130, label:"Tuesday", _y:70}});
	tab_mc.attachMovie("bi.ui.RadioButton", "wednesday_rb", 20, {settings:{width:130, label:"Wednesday", _y:105}});
	tab_mc.attachMovie("bi.ui.RadioButton", "thursday_rb", 25, {settings:{width:130, label:"Thursday", _y:140}});
	tab_mc.attachMovie("bi.ui.RadioButton", "friday_rb", 30, {settings:{width:130, label:"Friday", _x:140, _y:35}});
	tab_mc.attachMovie("bi.ui.RadioButton", "saturday_rb", 35, {settings:{width:130, label:"Saturday", _x:140, _y:70}});
	tab_mc.attachMovie("bi.ui.RadioButton", "sunday_rb", 40, {settings:{width:130, label:"Sunday", _x:140, _y:105}});
	if (calendarObj.eventType == "weekly") {
		tab_mc.numWeeks_ti.text = calendarObj.pattern.recur;
		tab_mc.monday_rb.selected = calendarObj.pattern.mon;
		tab_mc.tuesday_rb.selected = calendarObj.pattern.tue;
		tab_mc.wednesday_rb.selected = calendarObj.pattern.wed;
		tab_mc.thursday_rb.selected = calendarObj.pattern.thu;
		tab_mc.friday_rb.selected = calendarObj.pattern.fri;
		tab_mc.saturday_rb.selected = calendarObj.pattern.sat;
		tab_mc.sunday_rb.selected = calendarObj.pattern.sun;	
	} else {
		tab_mc[["sunday","monday","tuesday","wednesday","thursday","friday","saturday"][dateObj.getDay()] + "_rb"].selected = true;
	}
	tab_mc._visible = false;
	
	// monthly tab
	var tab_mc = tabs_mc.createEmptyMovieClip("monthly_mc", 30);
	tab_mc.attachMovie("bi.ui.RadioButton", "date_rb", 0, {settings:{width:200, label:"Day        of every", data:"date", groupName:"every"}});
	tab_mc.attachMovie("bi.ui.TextInput", "date_ti", 5, {settings:{width:30, text:"1", _x:70, maxChars:2, minValue:1, maxValue:31, inputType:"numeric"}});
	tab_mc.attachMovie("bi.ui.TextInput", "numMonths_ti", 10, {settings:{width:30, text:"1", _x:35, _y:35, maxChars:2, minValue:1, maxValue:12, inputType:"numeric"}});
	tab_mc.attachMovie("bi.ui.Label", "every_lb", 15, {settings:{width:100, text:"month(s)", _x:70, _y:35}});
	tab_mc.attachMovie("bi.ui.RadioButton", "day_rb", 20, {settings:{width:200, label:"The", data:"day", groupName:"every", _y:105}});
	tab_mc.attachMovie("bi.ui.ItemPicker", "week_ip", 25, {settings:{width:170, items:[{label:"first", value:1}, {label:"second", value:2}, {label:"third", value:3}, {label:"fourth", value:4}, {label:"last", value:5}], _x:70, _y:105}});
	tab_mc.attachMovie("bi.ui.ItemPicker", "day_ip", 30, {settings:{width:205, items:[{label:"Monday", value:"mon"}, {label:"Tuesday", value:"tue"}, {label:"Wednesday", value:"wed"}, {label:"Thursday", value:"thu"}, {label:"Friday", value:"fri"}, {label:"Saturday", value:"sat"}, {label:"Sunday", value:"sun"}], _x:35, _y:140}});
	tab_mc.attachMovie("bi.ui.Label", "every_lb", 35,{settings:{width:200, text:"of every         month(s)", _x:35, _y:175}});
	tab_mc.attachMovie("bi.ui.TextInput", "numMonths2_ti", 40, {settings:{width:30, text:"1", _x:105, _y:175, minValue:1, maxValue:12, maxChars:1, inputType:"numeric"}});
	if (calendarObj.eventType == "monthly") {
		if (calendarObj.pattern.date != undefined) {
			tab_mc.every.data = "date";
			tab_mc.date_ti.text = calendarObj.pattern.date;
			tab_mc.numMonths_ti.text = calendarObj.pattern.recur;
		} else if (calendarObj.pattern.day != undefined) {
			tab_mc.every.data = "day";
			tab_mc.day_ip.selectedValue = calendarObj.pattern.day;
			tab_mc.week_ip.selectedValue = calendarObj.pattern.week;
			tab_mc.numMonths2_ti.text = calendarObj.pattern.recur;
		}		
	} else {
		tab_mc.every.data = "date";
		tab_mc.date_ti.text = dateObj.getDate();
		tab_mc.day_ip.selectedValue = ["sun","mon","tue","wed","thu","fri","sat"][dateObj.getDay()];
	}
	tab_mc._visible = false;
	
	// yearly tab
	var tab_mc = tabs_mc.createEmptyMovieClip("yearly_mc", 40);
	tab_mc.attachMovie("bi.ui.Label", "every_lb", 0, {settings:{width:200, text:"Every         year(s) on:"}});
	tab_mc.attachMovie("bi.ui.TextInput", "numYears_ti", 5, {settings:{width:30, text:"1", _x:50, maxChars:1, minValue:1, maxValue:3, inputType:"numeric"}});
	tab_mc.attachMovie("bi.ui.ItemPicker", "month_ip", 10, {settings:{width:200, items:[{label:"January", value:0}, {label:"February", value:1}, {label:"March", value:2}, {label:"April", value:3}, {label:"May", value:4}, {label:"June", value:5}, {label:"July", value:6}, {label:"August", value:7}, {label:"September", value:8}, {label:"October", value:9}, {label:"November", value:10}, {label:"December", value:11}], _y:35}});
	tab_mc.attachMovie("bi.ui.NumberPicker", "date_np", 20, {settings:{width:150, minValue:1, maxValue:31, step:1, _y:70}});
	if (calendarObj.eventType == "yearly") {
		tab_mc.numYears_ti.text = calendarObj.pattern.recur;
		tab_mc.month_ip.selectedValue = calendarObj.pattern.month - 1;
		tab_mc.date_np.selectedValue = calendarObj.pattern.date;
	} else {
		tab_mc.month_ip.selectedValue = dateObj.getMonth();
		tab_mc.date_np.selectedValue = dateObj.getDate();
	}
	tab_mc._visible = false;
	
	// set tabs
	tabs_mc.selectedTab = tabs_mc[calendarObj.eventType + "_mc"];
	tabs_mc.selectedTab._visible = true;

	/*
	content_mc.attachMovie("bi.ui.Label", "macro_lb", 90, {settings:{width:100, text:"Macro:", _x:530}});
	
	var macros_mc = content_mc.attachMovie("bi.ui.List", "standardEvents_mc", 100, {settings:{width:155, height:315, _x:530, _y:35}});
	macros_mc.addEventListener("change", macros_mc);
	for (var macro=0; macro<_global.macros.length; macro++) {
		macros_mc.addItem({label:_global.macros[macro].name, value:macro});
	}
	macros_mc.selectedLabel = calendarObj.macroName;
	*/
		
	var buttonListener = new Object();
	buttonListener.press = function (eventObj) {
		switch (eventObj.target._name) {
			case "saveEvent_btn":
			case "createEvent_btn":
				var saveObj = new Object();
				saveObj.id = calendarObj.id;
				saveObj.title = content_mc.title_ti.text;
				saveObj.active = content_mc.active_cb.selected;
				saveObj.alarm = content_mc.alarm_cb.selected;
				saveObj.memo = content_mc.msg_ti.text;
				saveObj.category = content_mc.category_ip.selectedItem.value;
				saveObj.time = content_mc.time_tp.time;
				saveObj.macroName = "";
				saveObj.extra = "";
				saveObj.extra2 = "";
				saveObj.startDate = calendarObj.startDate;
				saveObj.endDate = calendarObj.endDate;
				if (saveObj.startDate.getTime() == saveObj.endDate.getTime()) saveObj.endDate = DateFunction.dateAdd("y", saveObj.startDate, 1);
				saveObj.eventType = content_mc.period.data;
				saveObj.filter = "";
				if (saveObj.eventType != "once") {
					saveObj.pattern = new Object();
					var tab_mc = content_mc.tabs_mc[saveObj.eventType + "_mc"];
					switch (saveObj.eventType) {
						case "hourly":
							saveObj.pattern.recur = tab_mc.numHours_ti.text
							break;
						case "daily":
							saveObj.filter = tab_mc.every.data;
							if (tab_mc.every.data == "") {
								saveObj.pattern.recur = tab_mc.numDays_ti.text;
							}
							break;
						case "weekly":
							saveObj.pattern.recur = tab_mc.numWeeks_ti.text;
							saveObj.pattern.mon = (tab_mc.monday_rb.selected) ? 1 : 0;
							saveObj.pattern.tue = (tab_mc.tuesday_rb.selected) ? 1 : 0;
							saveObj.pattern.wed = (tab_mc.wednesday_rb.selected) ? 1 : 0;
							saveObj.pattern.thu = (tab_mc.thursday_rb.selected) ? 1 : 0;
							saveObj.pattern.fri = (tab_mc.friday_rb.selected) ? 1 : 0;
							saveObj.pattern.sat = (tab_mc.saturday_rb.selected) ? 1 : 0;
							saveObj.pattern.sun = (tab_mc.sunday_rb.selected) ? 1 : 0;
							break;
						case "monthly":
							switch (tab_mc.every.data) {
								case "date":
									saveObj.pattern.recur = tab_mc.numMonths_ti.text;
									saveObj.pattern.date = tab_mc.date_ti.text;
									break;
								case "day":
									saveObj.pattern.recur = tab_mc.numMonths2_ti.text;
									saveObj.pattern.day = tab_mc.day_ip.selectedItem.value;
									saveObj.pattern.week = tab_mc.week_ip.selectedItem.value;
									break;
							}
							
							saveObj.startDate = new Date(saveObj.startDate.getFullYear(), saveObj.startDate.getMonth(), 1, 0, 0, 0);
							saveObj.endDate = DateFunction.dateAdd("y", saveObj.startDate, 1);
							break;
						case "yearly":
							saveObj.pattern.recur = tab_mc.numYears_ti.text;
							saveObj.pattern.month = tab_mc.month_ip.selectedItem.value + 1;
							saveObj.pattern.date = tab_mc.date_np.selectedItem.value;
							
							saveObj.startDate = new Date(saveObj.startDate.getFullYear(), 0, 1, 0, 0, 0);
							saveObj.endDate = DateFunction.dateAdd("y", saveObj.startDate, 5);
							break;
					}
				}
				break;
		}
		switch (eventObj.target._name) {
			case "deleteEvent_btn":
				confirm("Are you sure you want to delete this event?", _root, "deleteEvent", null, calendarObj);
				//deleteEvent(calendarObj);
				break;
			case "saveEvent_btn":
				saveEvent(saveObj);
				break;
			case "createEvent_btn":
				saveObj.isNew = true;
				saveEvent(saveObj);
				break;
			case "cancel_btn":
				trace("cancel");
				break;
		}
		eventObj.target._parent._parent.close();
	}
	
	if (mode == "edit") {
		content_mc.attachMovie("bi.ui.Button", "saveEvent_btn", 200, {settings:{width:150, label:"Save", _x:45, _y:365}});
		content_mc.saveEvent_btn.addEventListener("press", buttonListener);
		content_mc.attachMovie("bi.ui.Button", "deleteEvent_btn", 205, {settings:{width:150, label:"Delete", _x:205, _y:365}});
		content_mc.deleteEvent_btn.addEventListener("press", buttonListener);
		content_mc.attachMovie("bi.ui.Button", "cancel_btn", 210, {settings:{width:150, label:"Cancel", _x:365, _y:365}});
		content_mc.cancel_btn.addEventListener("press", buttonListener);
	} else {
		content_mc.attachMovie("bi.ui.Button", "createEvent_btn", 200, {settings:{width:150, label:"Create", _x:120, _y:365}});
		content_mc.createEvent_btn.addEventListener("press", buttonListener);
		content_mc.attachMovie("bi.ui.Button", "cancel_btn", 205, {settings:{width:150, label:"Cancel", _x:280, _y:365}});
		content_mc.cancel_btn.addEventListener("press", buttonListener);
	}
}

createRecurringEvent = function (tabNum, dateObj) {
	var view = _global.calendar[tabNum].view;
	
	if (view == "macros") {
		var window_mc = showWindow({width:350, height:450, title:"Select macro:", iconName:"calendar", align:"center"});
	} else {
		var window_mc = showWindow({width:350, height:450, title:"Select zone:", iconName:"calendar", align:"center"});
	}
	
	var content_mc = window_mc.content_mc;
	
	var list_mc = content_mc.attachMovie("bi.ui.List", "list_mc", 10, {settings:{width:content_mc.width, height:content_mc.height}});
	list_mc.addEventListener("change", list_mc);
	list_mc.change = function (eventObj) {
		newRecurringEvent(null, dateObj, eventObj.target.selectedItem.value, view);
		eventObj.target._parent._parent.close();
	}
	
	if (view == "macros") {
		for (var macro=0; macro<_global.macros.length; macro++) {
			list_mc.addItem({label:_global.macros[macro].name, value:_global.macros[macro].name});
		}
	} else {
		for (var zone=0; zone<_global.calendar[tabNum].zones.length; zone++) {
			list_mc.addItem({label:_global.calendar[tabNum].zones[zone].label, value:_global.calendar[tabNum].macro + "|" + _global.calendar[tabNum].zones[zone].key});
		}
	}
}

editRecurringEvent = newRecurringEvent = function (calendarObj, dateObj, macroName) {
	if (calendarObj != null) {
		var mode = "edit";
		var window_mc = showWindow({width:580, height:455, title:"Edit event: " + calendarObj.title + " [" + calendarObj.macroName + "]", iconName:"calendar", align:"center"});
	} else {
		var mode = "create";
		var calendarObj = new Object();
		calendarObj.isNew = true;
		calendarObj.id = "";
		calendarObj.eventType = "weekly";
		calendarObj.title = "";
		calendarObj.active = true;
		calendarObj.alarm = false;
		calendarObj.memo = "";
		calendarObj.category = "";
		if (macroName.split("|").length == 2) {
			calendarObj.macroName = macroName.split("|")[0];
			calendarObj.extra = macroName.split("|")[1];
			calendarObj.extra2 = 1800;
		} else {
			calendarObj.macroName = macroName;
			calendarObj.extra = "";
			calendarObj.extra2 = "";
		}
		calendarObj.filter = "";
		calendarObj.time = new Date();
		calendarObj.startDate = new Date(dateObj.getTime());;
		calendarObj.endDate = DateFunction.dateAdd("y", dateObj, 1);
		calendarObj.pattern = new Object();
		var window_mc = showWindow({width:580, height:455, title:"Create new event:" + " [" + calendarObj.macroName + "]", iconName:"calendar", align:"center"});
	}
	
	var content_mc = window_mc.content_mc;
	
	content_mc.attachMovie("bi.ui.Label", "title_lb", 10, {settings:{width:80, text:"Title:"}});
	content_mc.attachMovie("bi.ui.TextInput", "title_ti", 15, {settings:{width:180, text:calendarObj.title, _x:90, maxChars:20}});
	
	content_mc.attachMovie("bi.ui.Label", "time_lb", 20, {settings:{width:80, text:"Time:", _y:35}});
	content_mc.attachMovie("bi.ui.TimePicker", "time_tp", 25, {settings:{width:180, time:calendarObj.time, _x:90, _y:35}});
	
	if (calendarObj.extra2 != "") {
		content_mc.attachMovie("bi.ui.Label", "runTime_lb", 30, {settings:{width:300, text:"Run for:\t\t\t\t\       mins", _y:70}});
		content_mc.attachMovie("bi.ui.NumberPicker", "runTime_np", 35, {settings:{width:130, minValue:1, maxValue:1440, step:1, _x:90, _y:70}});
		content_mc.runTime_np.selectedValue = Number(calendarObj.extra2) / 60;
		
		content_mc.attachMovie("bi.ui.Label", "msg_lb", 40, {settings:{width:80, text:"Message:", _y:105}});
		content_mc.attachMovie("bi.ui.TextInput", "msg_ti", 45, {settings:{width:180, height:210, text:calendarObj.memo, _x:90, _y:105, maxChars:200}});

		content_mc.attachMovie("bi.ui.Label", "active_lb", 50, {settings:{width:80, text:"Active:", _y:320}});
		content_mc.attachMovie("bi.ui.CheckBox", "active_cb", 55, {settings:{_x:90, _y:320, selected:calendarObj.active}});
	} else {
		content_mc.attachMovie("bi.ui.Label", "msg_lb", 30, {settings:{width:80, text:"Message:", _y:70}});
		content_mc.attachMovie("bi.ui.TextInput", "msg_ti", 35, {settings:{width:180, height:210, text:calendarObj.memo, _x:90, _y:70, maxChars:200}});
	
		content_mc.attachMovie("bi.ui.Label", "alarm_lb", 40, {settings:{width:80, text:"Alarm:", _y:285}});
		content_mc.attachMovie("bi.ui.CheckBox", "alarm_cb", 45, {settings:{_x:90, _y:285, selected:calendarObj.alarm}});

		content_mc.attachMovie("bi.ui.Label", "active_lb", 50, {settings:{width:80, text:"Active:", _y:320}});
		content_mc.attachMovie("bi.ui.CheckBox", "active_cb", 55, {settings:{_x:90, _y:320, selected:calendarObj.active}});
	}
			
	content_mc.attachMovie("bi.ui.Label", "recurrence_lb", 60, {settings:{width:100, text:"Recurrence:", _x:280}});
	
	content_mc.attachMovie("bi.ui.RadioButton", "once_rb", 70, {settings:{width:110, label:"Once", data:"once", _x:280, _y:35, groupName:"period"}});
	content_mc.attachMovie("bi.ui.RadioButton", "hourly_rb", 71, {settings:{width:110, label:"Hourly", data:"hourly", _x:420, _y:35, groupName:"period"}});
	content_mc.attachMovie("bi.ui.RadioButton", "daily_rb", 72, {settings:{width:110, label:"Daily", data:"daily", _x:280, _y:70, groupName:"period"}});
	content_mc.attachMovie("bi.ui.RadioButton", "weekly_rb", 73, {settings:{width:110, label:"Weekly", data:"weekly", _x:420, _y:70, groupName:"period"}});
	content_mc.attachMovie("bi.ui.RadioButton", "monthly_rb", 74, {settings:{width:110, label:"Monthly", data:"monthly", _x:280, _y:105, groupName:"period"}});
	content_mc.attachMovie("bi.ui.RadioButton", "yearly_rb", 75, {settings:{width:110, label:"Yearly", data:"yearly", _x:420, _y:105, groupName:"period"}});
	content_mc.period.data = calendarObj.eventType;
	
	var periodListener = new Object();
	periodListener.click = function (eventObj) {
		var tabs_mc = eventObj.target.selection._parent.tabs_mc;
		tabs_mc.selectedTab._visible = false;
		tabs_mc.selectedTab = tabs_mc[eventObj.target.data + "_mc"];
		tabs_mc.selectedTab._visible = true;
	}
	content_mc.period.addEventListener("click", periodListener);
	
	var tabs_mc = content_mc.createEmptyMovieClip("tabs_mc", 80);
	tabs_mc._x = 280;
	tabs_mc._y = 150;
	
	// once tab
	var tab_mc = tabs_mc.createEmptyMovieClip("once_mc", 0);
	tab_mc.attachMovie("bi.ui.ItemPicker", "month_ip", 10, {settings:{width:200, items:[{label:"January", value:0}, {label:"February", value:1}, {label:"March", value:2}, {label:"April", value:3}, {label:"May", value:4}, {label:"June", value:5}, {label:"July", value:6}, {label:"August", value:7}, {label:"September", value:8}, {label:"October", value:9}, {label:"November", value:10}, {label:"December", value:11}], _y:0}});
	tab_mc.attachMovie("bi.ui.NumberPicker", "date_np", 20, {settings:{width:150, minValue:1, maxValue:31, step:1, _y:35}});
	if (calendarObj.eventType == "once") {
		tab_mc.month_ip.selectedValue = calendarObj.startDate.getMonth();
		tab_mc.date_np.selectedValue = calendarObj.startDate.getDate();
	} else {
		tab_mc.month_ip.selectedValue = dateObj.getMonth();
		tab_mc.date_np.selectedValue = dateObj.getDate();
	}
	tab_mc._visible = false;
	
	// hourly tab
	var tab_mc = tabs_mc.createEmptyMovieClip("hourly_mc", 5);
	tab_mc.attachMovie("bi.ui.Label", "every_lb", 0, {settings:{width:200, text:"Every         hour(s)"}});
	tab_mc.attachMovie("bi.ui.TextInput", "numHours_ti", 5, {settings:{width:30, text:"1", _x:50, maxChars:2, minValue:1, maxValue:12, inputType:"numeric"}});
	if (calendarObj.eventType == "hourly") {
		tab_mc.numHours_ti.text = calendarObj.pattern.recur;
	}
	tab_mc._visible = false;
	
	// daily tab
	var tab_mc = tabs_mc.createEmptyMovieClip("daily_mc", 10);
	tab_mc.attachMovie("bi.ui.RadioButton", "everyXdays_rb", 0, {settings:{width:200, label:"Every         day(s)",  data:"", groupName:"every"}});
	tab_mc.attachMovie("bi.ui.TextInput", "numDays_ti", 5, {settings:{width:30, text:"1", _x:85, maxChars:1, minValue:1, maxValue:7, inputType:"numeric"}});	
	tab_mc.attachMovie("bi.ui.RadioButton", "everyOddDay_rb", 10, {settings:{width:200, label:"Every odd day",  data:"odd", _y:35, groupName:"every"}});
	tab_mc.attachMovie("bi.ui.RadioButton", "everyEvenDay_rb", 20, {settings:{width:200, label:"Every even day",  data:"even", _y:70, groupName:"every"}});
	if (calendarObj.eventType == "daily") {
		if (calendarObj.filter == "odd" || calendarObj.filter == "even") {
			tab_mc.every.data = calendarObj.filter;
		} else {
			tab_mc.every.data = "";
			tab_mc.numDays_ti.text = calendarObj.pattern.recur;
		}
	} else {
		tab_mc.every.data = "";
	}
	tab_mc._visible = false;
	
	// weekly tab
	var tab_mc = tabs_mc.createEmptyMovieClip("weekly_mc", 20);
	tab_mc.attachMovie("bi.ui.Label", "every_lb", 0, {settings:{width:200, text:"Every         week(s) on:"}});
	tab_mc.attachMovie("bi.ui.TextInput", "numWeeks_ti", 5, {settings:{width:30, text:"1", _x:50, maxChars:1, minValue:1, maxValue:4, inputType:"numeric"}});
	tab_mc.attachMovie("bi.ui.RadioButton", "monday_rb", 10, {settings:{width:130, label:"Monday", _y:35}});
	tab_mc.attachMovie("bi.ui.RadioButton", "tuesday_rb", 15, {settings:{width:130, label:"Tuesday", _y:70}});
	tab_mc.attachMovie("bi.ui.RadioButton", "wednesday_rb", 20, {settings:{width:130, label:"Wednesday", _y:105}});
	tab_mc.attachMovie("bi.ui.RadioButton", "thursday_rb", 25, {settings:{width:130, label:"Thursday", _y:140}});
	tab_mc.attachMovie("bi.ui.RadioButton", "friday_rb", 30, {settings:{width:130, label:"Friday", _x:140, _y:35}});
	tab_mc.attachMovie("bi.ui.RadioButton", "saturday_rb", 35, {settings:{width:130, label:"Saturday", _x:140, _y:70}});
	tab_mc.attachMovie("bi.ui.RadioButton", "sunday_rb", 40, {settings:{width:130, label:"Sunday", _x:140, _y:105}});
	if (calendarObj.eventType == "weekly") {
		tab_mc.numWeeks_ti.text = calendarObj.pattern.recur;
		tab_mc.monday_rb.selected = calendarObj.pattern.mon;
		tab_mc.tuesday_rb.selected = calendarObj.pattern.tue;
		tab_mc.wednesday_rb.selected = calendarObj.pattern.wed;
		tab_mc.thursday_rb.selected = calendarObj.pattern.thu;
		tab_mc.friday_rb.selected = calendarObj.pattern.fri;
		tab_mc.saturday_rb.selected = calendarObj.pattern.sat;
		tab_mc.sunday_rb.selected = calendarObj.pattern.sun;	
	} else {
		tab_mc[["sunday","monday","tuesday","wednesday","thursday","friday","saturday"][dateObj.getDay()] + "_rb"].selected = true;
	}
	tab_mc._visible = false;
	
	// monthly tab
	var tab_mc = tabs_mc.createEmptyMovieClip("monthly_mc", 30);
	tab_mc.attachMovie("bi.ui.RadioButton", "date_rb", 0, {settings:{width:200, label:"Day        of every", data:"date", groupName:"every"}});
	tab_mc.attachMovie("bi.ui.TextInput", "date_ti", 5, {settings:{width:30, text:"1", _x:70, maxChars:2, minValue:1, maxValue:31, inputType:"numeric"}});
	tab_mc.attachMovie("bi.ui.TextInput", "numMonths_ti", 10, {settings:{width:30, text:"1", _x:35, _y:35, maxChars:2, minValue:1, maxValue:121, inputType:"numeric"}});
	tab_mc.attachMovie("bi.ui.Label", "every_lb", 15, {settings:{width:100, text:"month(s)", _x:70, _y:35}});
	tab_mc.attachMovie("bi.ui.RadioButton", "day_rb", 20, {settings:{width:200, label:"The", data:"day", groupName:"every", _y:105}});
	tab_mc.attachMovie("bi.ui.ItemPicker", "week_ip", 25, {settings:{width:170, items:[{label:"first", value:1}, {label:"second", value:2}, {label:"third", value:3}, {label:"fourth", value:4}, {label:"last", value:5}], _x:70, _y:105}});
	tab_mc.attachMovie("bi.ui.ItemPicker", "day_ip", 30, {settings:{width:205, items:[{label:"Monday", value:"mon"}, {label:"Tuesday", value:"tue"}, {label:"Wednesday", value:"wed"}, {label:"Thursday", value:"thu"}, {label:"Friday", value:"fri"}, {label:"Saturday", value:"sat"}, {label:"Sunday", value:"sun"}], _x:35, _y:140}});
	tab_mc.attachMovie("bi.ui.Label", "every_lb", 35,{settings:{width:200, text:"of every         month(s)", _x:35, _y:175}});
	tab_mc.attachMovie("bi.ui.TextInput", "numMonths2_ti", 40, {settings:{width:30, text:"1", _x:105, _y:175, maxChars:2, minValue:1, maxValue:12, inputType:"numeric"}});
	if (calendarObj.eventType == "monthly") {
		if (calendarObj.pattern.date != undefined) {
			tab_mc.every.data = "date";
			tab_mc.date_ti.text = calendarObj.pattern.date;
			tab_mc.numMonths_ti.text = calendarObj.pattern.recur;
		} else if (calendarObj.pattern.day != undefined) {
			tab_mc.every.data = "day";
			tab_mc.day_ip.selectedValue = calendarObj.pattern.day;
			tab_mc.week_ip.selectedValue = calendarObj.pattern.week;
			tab_mc.numMonths2_ti.text = calendarObj.pattern.recur;
		}		
	} else {
		tab_mc.every.data = "date";
		tab_mc.date_ti.text = dateObj.getDate();
		tab_mc.day_ip.selectedValue = ["sun","mon","tue","wed","thu","fri","sat"][dateObj.getDay()];
	}
	tab_mc._visible = false;
	
	// yearly tab
	var tab_mc = tabs_mc.createEmptyMovieClip("yearly_mc", 40);
	tab_mc.attachMovie("bi.ui.Label", "every_lb", 0, {settings:{width:200, text:"Every         year(s) on:"}});
	tab_mc.attachMovie("bi.ui.TextInput", "numYears_ti", 5, {settings:{width:30, text:"1", _x:50, maxChars:1, minValue:1, maxValue:3, inputType:"numeric"}});
	tab_mc.attachMovie("bi.ui.ItemPicker", "month_ip", 10, {settings:{width:200, items:[{label:"January", value:0}, {label:"February", value:1}, {label:"March", value:2}, {label:"April", value:3}, {label:"May", value:4}, {label:"June", value:5}, {label:"July", value:6}, {label:"August", value:7}, {label:"September", value:8}, {label:"October", value:9}, {label:"November", value:10}, {label:"December", value:11}], _y:35}});
	tab_mc.attachMovie("bi.ui.NumberPicker", "date_np", 20, {settings:{width:150, minValue:1, maxValue:31, step:1, _y:70}});
	if (calendarObj.eventType == "yearly") {
		tab_mc.numYears_ti.text = calendarObj.pattern.recur;
		tab_mc.month_ip.selectedValue = calendarObj.pattern.month - 1;
		tab_mc.date_np.selectedValue = calendarObj.pattern.date;
	} else {
		tab_mc.month_ip.selectedValue = dateObj.getMonth();
		tab_mc.date_np.selectedValue = dateObj.getDate();
	}
	tab_mc._visible = false;
	
	// set tabs
	tabs_mc.selectedTab = tabs_mc[calendarObj.eventType + "_mc"];
	tabs_mc.selectedTab._visible = true;

	
	/*
	content_mc.attachMovie("bi.ui.Label", "macro_lb", 90, {settings:{width:100, text:"Macro:", _x:530}});
	
	var macros_mc = content_mc.attachMovie("bi.ui.List", "standardEvents_mc", 100, {settings:{width:155, height:315, _x:530, _y:35}});
	macros_mc.addEventListener("change", macros_mc);
	for (var macro=0; macro<_global.macros.length; macro++) {
		macros_mc.addItem({label:_global.macros[macro].name, value:macro});
	}
	macros_mc.selectedLabel = calendarObj.macroName;
	*/
		
	var buttonListener = new Object();
	buttonListener.press = function (eventObj) {
		switch (eventObj.target._name) {
			case "saveEvent_btn":
			case "createEvent_btn":
				var saveObj = new Object();
				saveObj.id = calendarObj.id;
				saveObj.title = content_mc.title_ti.text;
				saveObj.memo = content_mc.msg_ti.text;
				saveObj.category = "";
				saveObj.time = content_mc.time_tp.time;
				saveObj.macroName = calendarObj.macroName;
				saveObj.active = content_mc.active_cb.selected;
				if (content_mc.runTime_np.selectedItem) {
					saveObj.alarm = false;
					saveObj.extra = calendarObj.extra;
					saveObj.extra2 = content_mc.runTime_np.selectedItem.value * 60;
				} else {
					saveObj.alarm = content_mc.alarm_cb.selected;
					saveObj.extra = "";
					saveObj.extra2 = "";
				}
				saveObj.startDate = calendarObj.startDate;
				saveObj.endDate = calendarObj.endDate;
				if (saveObj.startDate.getTime() == saveObj.endDate.getTime()) saveObj.endDate = DateFunction.dateAdd("y", saveObj.startDate, 1);
				saveObj.eventType = content_mc.period.data;
				saveObj.filter = "";

				if (saveObj.eventType != "once") saveObj.pattern = new Object();
				var tab_mc = content_mc.tabs_mc[saveObj.eventType + "_mc"];
				switch (saveObj.eventType) {
					case "once":
						saveObj.startDate.setMonth(tab_mc.month_ip.selectedItem.value);
						saveObj.startDate.setDate(tab_mc.date_np.selectedItem.value)
					case "hourly":
						saveObj.pattern.recur = tab_mc.numHours_ti.text
						break;
					case "daily":
						saveObj.filter = tab_mc.every.data;
						if (tab_mc.every.data == "") {
							saveObj.pattern.recur = tab_mc.numDays_ti.text;
						}
						break;
					case "weekly":
						saveObj.pattern.recur = tab_mc.numWeeks_ti.text;
						saveObj.pattern.mon = (tab_mc.monday_rb.selected) ? 1 : 0;
						saveObj.pattern.tue = (tab_mc.tuesday_rb.selected) ? 1 : 0;
						saveObj.pattern.wed = (tab_mc.wednesday_rb.selected) ? 1 : 0;
						saveObj.pattern.thu = (tab_mc.thursday_rb.selected) ? 1 : 0;
						saveObj.pattern.fri = (tab_mc.friday_rb.selected) ? 1 : 0;
						saveObj.pattern.sat = (tab_mc.saturday_rb.selected) ? 1 : 0;
						saveObj.pattern.sun = (tab_mc.sunday_rb.selected) ? 1 : 0;
						break;
					case "monthly":
						switch (tab_mc.every.data) {
							case "date":
								saveObj.pattern.recur = tab_mc.numMonths_ti.text;
								saveObj.pattern.date = tab_mc.date_ti.text;
								break;
							case "day":
								saveObj.pattern.recur = tab_mc.numMonths2_ti.text;
								saveObj.pattern.day = tab_mc.day_ip.selectedItem.value;
								saveObj.pattern.week = tab_mc.week_ip.selectedItem.value;
								break;
						}
						
						saveObj.startDate = new Date(saveObj.startDate.getFullYear(), saveObj.startDate.getMonth(), 1, 0, 0, 0);
						saveObj.endDate = DateFunction.dateAdd("y", saveObj.startDate, 1);
						break;
					case "yearly":
						saveObj.pattern.recur = tab_mc.numYears_ti.text;
						saveObj.pattern.month = tab_mc.month_ip.selectedItem.value + 1;
						saveObj.pattern.date = tab_mc.date_np.selectedItem.value;
						
						saveObj.startDate = new Date(saveObj.startDate.getFullYear(), 0, 1, 0, 0, 0);
						saveObj.endDate = DateFunction.dateAdd("y", saveObj.startDate, 5);
						break;
				}
				break;
		}
		switch (eventObj.target._name) {
			case "deleteEvent_btn":
				confirm("Are you sure you want to delete this event?", _root, "deleteEvent", null, calendarObj);
				//deleteEvent(calendarObj);
				break;
			case "saveEvent_btn":
				saveEvent(saveObj);
				break;
			case "createEvent_btn":
				saveObj.isNew = true;
				saveEvent(saveObj);
				break;
			case "cancel_btn":
				//trace("cancel");
				break;
		}
		eventObj.target._parent._parent.close();
	}
	
	if (mode == "edit") {
		content_mc.attachMovie("bi.ui.Button", "saveEvent_btn", 200, {settings:{width:150, label:"Save", _x:45, _y:365}});
		content_mc.saveEvent_btn.addEventListener("press", buttonListener);
		content_mc.attachMovie("bi.ui.Button", "deleteEvent_btn", 205, {settings:{width:150, label:"Delete", _x:205, _y:365}});
		content_mc.deleteEvent_btn.addEventListener("press", buttonListener);
		content_mc.attachMovie("bi.ui.Button", "cancel_btn", 210, {settings:{width:150, label:"Cancel", _x:365, _y:365}});
		content_mc.cancel_btn.addEventListener("press", buttonListener);
	} else {
		content_mc.attachMovie("bi.ui.Button", "createEvent_btn", 200, {settings:{width:150, label:"Create", _x:120, _y:365}});
		content_mc.createEvent_btn.addEventListener("press", buttonListener);
		content_mc.attachMovie("bi.ui.Button", "cancel_btn", 205, {settings:{width:150, label:"Cancel", _x:280, _y:365}});
		content_mc.cancel_btn.addEventListener("press", buttonListener);
	}
}

dateAdd = function (dateObj, unit, amount) {
	var newDate = new Date(dateObj.getTime());
	switch (unit) {
		case "d":
			newDate.setDate(newDate.getDate() + amount);
			break;
		case "w":
			newDate.setDate(newDate.getDate() + (amount * 7));
			break;
		case "m":
			newDate.setMonth(newDate.getMonth() + amount);
			break;
		case "y":
			newDate.setMonth(newDate.getMonth() + (amount * 12));
			break;
	}
	return newDate;
}