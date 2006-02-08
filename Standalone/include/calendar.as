openCalendar = function () {
	if (_global.windows["openCalendar"] == "open") {
		window_mc.close();
	} else {
		showWindow({width:"full", height:"map", title:"Calendar", iconName:"calendar", modal:true});
		appsBar_mc.openCalendar_mc.showHighlight();
		_global.windows["openCalendar"] = "open";
		window_mc.onClose = function () {
			appsBar_mc.openCalendar_mc.hideHighlight();
			delete _global.windows["openCalendar"];
		}
		
		var tabs_mc = window_mc.contentClip.attachMovie("bi.ui.Tabs", "tabs_mc", 0, {settings:{width:window_mc.contentClip.width, height:window_mc.contentClip.height}});
		tabs_mc.tabData = [{name:"Today", iconName:"calendar"}, {name:"Watering", iconName:"sprinkler"}, {name:"Macros", iconName:"atom"}];
		
		for (var i=0; i<tabs_mc.tabData.length; i++) {
			_root[tabs_mc.tabData[i].func](tabs_mc.contentClips[i]);
		}
		
		tabs_mc.originalTitle = "Calendar";
		tabs_mc.changeTab = function (eventObj) {
			// set window title
			this._parent._parent.title = this.originalTitle + ": " + eventObj.name;
		}
		tabs_mc.addEventListener("changeTab", tabs_mc);
		tabs_mc.activeTab = 0;

		////////////////////
		// render today view
		////////////////////
		
		var content_mc = tabs_mc.contentClips[0];

		var columnBreak = 490;
		
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
				var eventObj = new Object();
				eventObj.eventType = eventsData[i].eventType;
				eventObj.title = eventsData[i].title;
				eventObj.memo = eventsData[i].memo;
				eventObj.time = eventsData[i].time;
				eventObj.macroName = eventsData[i].macroName;
				eventObj.startDate = eventsData[i].startDate;
				eventObj.endDate = eventsData[i].endDate;
				eventObj.filter = eventsData[i].filter;
				eventObj.pattern = new Object();
				for (var q in eventsData[i].pattern) {
					eventObj.pattern[q] = eventsData[i].pattern[q];
				}
				if (eventObj.macroName.length) {
					macroEvents_mc.addItem({label:eventObj.time.dateTimeFormat(_global.settings.shortTimeFormat)  +"\t" + eventObj.title, value:eventObj});
				} else {
					standardEvents_mc.addItem({label:eventObj.time.dateTimeFormat(_global.settings.shortTimeFormat) +"\t" + eventObj.title, value:eventObj});
				}
			}
			/*
			currentDay_mc.refresh = function () {
				var events_mc = this.createEmptyMovieClip("events_mc", 10);
				events_mc._y = 30;
				for (var event=0; event<this.eventsData.length; event++) {
					var d = this.eventsData[event];
					var event_mc = events_mc.attachMovie("bi.ui.Label", "event" + event + "_mc", event, {width:this._parent.calendar_ec.width, height:30, label:d.title, colour:0x7F9BC9});
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
					var newEvent_mc = events_mc.attachMovie("bi.ui.Label", "newEvent_mc", event, {width:this._parent.calendar_ec.width, height:30, label:"Create New Event...", colour:0x7F9BC9});
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
			*/
		}
	
		/*
		content_mc.showEvent = function (eventObj) {
			var eventDetails_mc = this.createEmptyMovieClip("eventDetails_mc", 30);
			eventDetails_mc._x = this.calendar_ec.width + 20;
			eventDetails_mc.eventObj = eventObj;
			eventDetails_mc.refresh = function () {
				this._parent.showEvent(this.eventObj)
			}
			
			var buttonCount = 0;
			
			var eventTitle_mc = eventDetails_mc.attachMovie("bi.ui.Label", "eventTitle_mc", buttonCount, {width:350, height:30, label:eventObj.title, colour:0x7F9BC9});
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
			var eventTimeLabel_mc = timePicker_mc.attachMovie("bi.ui.Label", "eventTimeLabel_mc", 1, {width:100, height:30, label:"At: ", colour:0x7F9BC9});
			var eventTimeHour_mc = timePicker_mc.attachMovie("bi.ui.Label", "eventTimeHour_mc", 2, {width:50, height:30, label:((eventObj.time.split(":")[0] > 12) ? eventObj.time.split(":")[0] - 12 : eventObj.time.split(":")[0]), colour:0x7F9BC9});
			eventTimeHour_mc._x = 100;
			var eventTimeColon_mc = timePicker_mc.attachMovie("bi.ui.Label", "eventTimeColon_mc", 3, {width:25, height:30, label:":", colour:0x7F9BC9});
			eventTimeColon_mc._x = 125;
			var eventTimeMinute_mc = timePicker_mc.attachMovie("bi.ui.Label", "eventTimeMinute_mc", 4, {width:50, height:30, label:eventObj.time.split(":")[1], colour:0x7F9BC9});
			eventTimeMinute_mc._x = 150;
			var eventTimeAMPM_mc = timePicker_mc.attachMovie("bi.ui.Label", "eventTimeAMPM_mc", 5, {width:50, height:30, label:((eventObj.time.split(":")[0] > 12) ? "PM" : "AM"), colour:0x7F9BC9});
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
			
			var eventMacro_mc = eventDetails_mc.attachMovie("bi.ui.Label", "eventMacro_mc", ++buttonCount, {width:350, height:30, colour:0x7F9BC9});
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
			
			var eventMemo_mc = eventDetails_mc.attachMovie("bi.ui.Label", "eventMemo_mc", ++buttonCount, {width:350, height:30, label:"Display: " + eventObj.memo.substr(0, 10) + "...", colour:0x7F9BC9});
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
			
			var eventType_mc = eventDetails_mc.attachMovie("bi.ui.Label", "eventType_mc", ++buttonCount, {width:350, height:30, label:"Happens " + eventObj.eventType, colour:0x7F9BC9});
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
				var recur_mc = eventDetails_mc.attachMovie("bi.ui.Label", "recur_mc", ++buttonCount, {width:350, height:30, colour:0x7F9BC9});
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
				var recur_mc = eventDetails_mc.attachMovie("bi.ui.Label", "recur_mc", ++buttonCount, {width:350, height:30, colour:0x7F9BC9});
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
				var recur_mc = eventDetails_mc.attachMovie("bi.ui.Label", "recur_mc", ++buttonCount, {width:350, height:30, colour:0x7F9BC9});
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
				
				var day_mc = eventDetails_mc.attachMovie("bi.ui.Label", "day_mc", ++buttonCount, {width:350, height:30, colour:0x7F9BC9});
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
				var recur_mc = eventDetails_mc.attachMovie("bi.ui.Label", "recur_mc", ++buttonCount, {width:350, height:30, colour:0x7F9BC9});
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
				
				var day_mc = eventDetails_mc.attachMovie("bi.ui.Label", "day_mc", ++buttonCount, {width:350, height:30, colour:0x7F9BC9});
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
				
				var week_mc = eventDetails_mc.attachMovie("bi.ui.Label", "week_mc", ++buttonCount, {width:350, height:30, colour:0x7F9BC9});
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
				var recur_mc = eventDetails_mc.attachMovie("bi.ui.Label", "recur_mc", ++buttonCount, {width:350, height:30, colour:0x7F9BC9});
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
				
				var date_mc = eventDetails_mc.attachMovie("bi.ui.Label", "day_mc", ++buttonCount, {width:350, height:30, colour:0x7F9BC9});
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
				
				var month_mc = eventDetails_mc.attachMovie("bi.ui.Label", "week_mc", ++buttonCount, {width:350, height:30, colour:0x7F9BC9});
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
				var save_btn = eventDetails_mc.attachMovie("bi.ui.Button", "save_btn", buttonCount + 1, {width:174, height:30, label:"Save"});
				save_btn._y = (buttonCount + 1) * 35 + 5;
				save_btn.press = function () {
					saveEvent(this._parent.eventObj);
					this._parent.removeMovieClip();
				}
				save_btn.addEventListener("press", save_btn);
				
				if (eventObj.isNew) {
					var cancel_btn = eventDetails_mc.attachMovie("bi.ui.Button", "cancel_btn", buttonCount + 2, {width:174, height:30, label:"Cancel"});
					cancel_btn._x = 176;
					cancel_btn._y = (buttonCount + 1) * 35 + 5;
					cancel_btn.press = function () {
						this._parent.removeMovieClip();
					}
					cancel_btn.addEventListener("press", cancel_btn);
				} else {
					var delete_btn = eventDetails_mc.attachMovie("bi.ui.Button", "delete_btn", buttonCount + 2, {width:174, height:30, label:"Delete"});
					delete_btn._x = 176;
					delete_btn._y = (buttonCount + 1) * 35 + 5;
					delete_btn.press = function () {
						deleteEvent(this._parent.eventObj);
						this._parent.removeMovieClip();
					}
					delete_btn.addEventListener("press", delete_btn);
				}
			} else {
				var close_btn = eventDetails_mc.attachMovie("bi.ui.Button", "close_btn", buttonCount + 1, {width:350, height:30, label:"Close"});
				close_btn._y = (buttonCount + 1) * 35 + 5;
				close_btn.press = function () {
					this._parent.removeMovieClip();
				}
				close_btn.addEventListener("press", close_btn);
			}
		}
		*/
		
		content_mc.update = function () {
			this.calendar_ec.setDataProvider(_global.calendarData);
			this.calendar_ec.getDayByDate(this.currentDateObj.getDate()).onRelease();
		}
		subscribe("events", content_mc);
				
		content_mc.attachMovie("bi.ui.Label", "day_lb", 25, {settings:{width:content_mc.width - columnBreak - 10, align:"center", _x:columnBreak + 10, _y:0, fontSize:18}});

		var standardEvents_mc = content_mc.attachMovie("bi.ui.List", "standardEvents_mc", 30, {settings:{width:content_mc.width - columnBreak - 10, height:content_mc.height / 2 - 30}});
		standardEvents_mc._x = columnBreak + 10;
		standardEvents_mc._y = 30;
		standardEvents_mc.addEventListener("change", standardEvents_mc);
		standardEvents_mc.change = function (eventObj) {
			editCalendarEvent(eventObj.target.selectedItem.value, this._parent.dateObj);
		}

		content_mc.attachMovie("bi.ui.Label", "events_lb", 40, {settings:{text:"Scheduled macros:", width:content_mc.width - columnBreak - 10, align:"center", _x:columnBreak + 10, _y:Math.round(content_mc.height / 2), fontSize:18}});
		
		var macroEvents_mc = content_mc.attachMovie("bi.ui.List", "macroEvents_mc", 50, {settings:{width:content_mc.width - columnBreak - 10, height:content_mc.height / 2 - 30}});
		macroEvents_mc._x = columnBreak + 10;
		macroEvents_mc._y = content_mc.height / 2 + 30;
		macroEvents_mc.addEventListener("change", macroEvents_mc);
		macroEvents_mc.change = function (eventObj) {
			skipCalendarEvent(eventObj.target.selectedItem.value);
		}		
		
		var buttons_mc = content_mc.createEmptyMovieClip("buttons_mc", 60);
		buttons_mc.attachMovie("bi.ui.Button", "newEvent_btn", 10, {settings:{width:calendar_ec._width, height: 30, label:"Create new event"}});
		buttons_mc.newEvent_btn.press = function () {
			trace(dateObj);
			newCalendarEvent(null, this._parent._parent.dateObj);
		}
		buttons_mc.newEvent_btn.addEventListener("press", buttons_mc.newEvent_btn);
		buttons_mc.attachMovie("bi.ui.Button", "today_btn", 20, {settings:{width:calendar_ec._width, height: 30, label:"Go to today"}});
		buttons_mc.today_btn.press = function () {
			calendar_ec.setDate(new Date());
			calendar_ec.getDayByDate(new Date().getDate()).onRelease();
		}
		buttons_mc.today_btn.addEventListener("press", buttons_mc.today_btn);
		buttons_mc.today_btn._y = 35;
		
		buttons_mc._x = calendar_ec._x;
		buttons_mc._y = calendar_ec._y + calendar_ec._height + 70;
				
		calendar_ec.setDisplayRange({begin:new Date(2000, 0),end:new Date(2010, 11)});
		calendar_ec.setDataProvider(_global.calendarData);
		calendar_ec.getDayByDate(new Date().getDate()).onRelease();
		
		/////////////////////////////////////////
		// render watering and automation view //
		/////////////////////////////////////////
		
		for (var q=0; q<2; q++) {
		
			var content_mc = tabs_mc.contentClips[1 + q];
			var currentWeekStarting = new Date(2006, 0, 23);
			
			var arrows_mc = content_mc.createEmptyMovieClip("arrows_mc",10);
			var leftArrow_mc = arrows_mc.attachMovie("bi.ui.Button", "leftArrow_mc", 10, {settings:{width:60, height:30, iconName:"left-arrow"}});
			leftArrow_mc.press = function () {
			}
			leftArrow_mc.addEventListener("press", leftArrow_mc);
			
			arrows_mc.createTextField("week_txt", 50, 0, 3, 250, 15);
			var week_txt = arrows_mc.week_txt;
			week_txt._x = leftArrow_mc._width;
			var label_tf = new TextFormat();
			label_tf.color = 0xFFFFFF;
			label_tf.size = 18;
			label_tf.bold = true;
			label_tf.font = "bi.ui.globalFont";
			label_tf.align = "center";
			week_txt.embedFonts = true;
			week_txt.selectable = false;
			week_txt.setNewTextFormat(label_tf);
			week_txt.text = "Week: " + currentWeekStarting.dateTimeFormat("d mmmm yyyy");
	
			var rightArrow_mc = arrows_mc.attachMovie("bi.ui.Button", "rightArrow_mc", 20, {settings:{width:60, height:30, iconName:"right-arrow"}});
			rightArrow_mc._x = leftArrow_mc._width + week_txt._width;
			rightArrow_mc.press = function () {
			}
			rightArrow_mc.addEventListener("press", rightArrow_mc);
			
			arrows_mc._x = Math.round((content_mc.width / 2) - (arrows_mc._width / 2));
			
			var daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
			
			var lines_mc = content_mc.createEmptyMovieClip("lines_mc", 100);
			var daysOfWeek_mc = content_mc.createEmptyMovieClip("daysOfWeek_mc", 20);
			daysOfWeek_mc._y = 50;
			lines_mc._alpha = 40;
			lines_mc.lineStyle(1, 0xFFFFFF);
			var colStart = 150;
			var colWidth = Math.round((content_mc.width - colStart) / 7);
			for (var i=0; i<7; i++) {
				lines_mc.moveTo(i * colWidth + colStart, daysOfWeek_mc._y + 20);
				lines_mc.lineTo(i * colWidth + colStart,  content_mc.height);
				
				daysOfWeek_mc.createTextField("day" + i + "_txt", i, 0, 0, colWidth, 30);
				var day_txt = daysOfWeek_mc["day" + i + "_txt"];
				var label_tf = new TextFormat();
				label_tf.color = 0xFFFFFF;
				label_tf.size = 16;
				label_tf.bold = true;
				label_tf.font = "bi.ui.globalFont";
				label_tf.align = "center";
				day_txt.embedFonts = true;
				day_txt.selectable = false;
				day_txt.setNewTextFormat(label_tf);
				day_txt.text = daysOfWeek[i];
				
				day_txt._x = i * colWidth + colStart;
			}
			
			if (q == 0) {
				var listData = [{label:"Front lawn"}, {label:"Back lawn"}, {label:"Back garden"}, {label:"Front lawn(2)"}];
			} else {
				var listData = [];
				for (var i=0; i<_global.calendarData.length; i++) {
					if (_global.calendarData[i].macroName.length && _global.calendarData[i].startDate < new Date(currentWeekStarting.getTime() + 604800000) && _global.calendarData[i].endDate > currentWeekStarting) {
						listData.push({label:_global.calendarData[i].title, time:_global.calendarData[i].time.split(":").slice(0, 2).join(":"), runTime:Number(_global.calendarData[i].runTime.split(":")[0]) * 60 + Number(_global.calendarData[i].runTime.split(":")[1]), pattern:_global.calendarData[i].pattern, skip:_global.calendarData[i].skip});
					}
				}
			}
			var rows_mc = content_mc.createEmptyMovieClip("rows_mc", 50);
			rows_mc._y = daysOfWeek_mc._y + 30;
			for (var i=0; i<listData.length; i++) {
				var row_mc = rows_mc.createEmptyMovieClip("row" + i + "_mc", i);
				
				var bg_mc = row_mc.createEmptyMovieClip("bg_mc", 0);
				if (i % 2) {
					bg_mc.beginFill(0x043B96, 30);				
				} else {
					bg_mc.beginFill(0xFFFFFF, 25);
				}
				bg_mc.drawRect(0, 0, content_mc.width, 40, 6);
				bg_mc.endFill();
				
				row_mc._y = (row_mc._height + 2) * i;
				
				row_mc.createTextField("label_txt", 10, 4, 0, colStart, 0);
				var label_txt = row_mc.label_txt;
				var label_tf = new TextFormat();
				label_tf.color = 0xFFFFFF;
				label_tf.size = 14;
				label_tf.font = "bi.ui.globalFont";
				label_txt.embedFonts = true;
				label_txt.selectable = false;
				label_txt.setNewTextFormat(label_tf);
				label_txt.autoSize = true;
				label_txt.text = listData[i].label;
				label_txt._y = Math.round((bg_mc._height / 2) - (label_txt._height / 2));
								
				for (var z=0; z<7; z++) {
					var currentDate = new Date(currentWeekStarting.getTime() + (z * 86400000));
					currentDate = currentDate.dateTimeFormat("yyyy-mm-dd");

					// check if current day fits into defined pattern
					if (listData[i].pattern[daysOfWeek[z].toLowerCase().substr(0, 3)] == 1) {			
						var cell_mc = row_mc.createEmptyMovieClip("cell" + z + "_mc", z + 20);
						cell_mc._x = z * colWidth + colStart;
						
						var hitArea_mc = cell_mc.createEmptyMovieClip("hitArea_mc", 0);
						hitArea_mc.beginFill(0xFFCC00);
						hitArea_mc.drawRect(0, 0, colWidth, bg_mc._height);
						cell_mc.hitArea = hitArea_mc;
						hitArea_mc._visible = false;
						
						var holder_mc = cell_mc.createEmptyMovieClip("holder_mc", 10);
						
						holder_mc.attachMovie("bi.ui.Icon", "icon_mc", 10, {settings:{iconName: "check", size: 25}});
						
						holder_mc.createTextField("label_txt", 20, 0, 0, colWidth - holder_mc.icon_mc._width - 8, 0);
						var label_txt = holder_mc.label_txt;
						label_txt._x = holder_mc.icon_mc._width + 4;
						var label_tf = new TextFormat();
						label_tf.color = 0xFFFFFF;
						label_tf.size = 10;
						label_tf.font = "bi.ui.globalFont";
						label_txt.autoSize = true;
						label_txt.embedFonts = true;
						label_txt.selectable = false;
						label_txt.setNewTextFormat(label_tf);
						label_txt.text = listData[i].runTime + " mins\n@ " + listData[i].time;
						
						holder_mc._x = Math.round((hitArea_mc._width / 2) - (holder_mc._width / 2));
						holder_mc._y = Math.round((hitArea_mc._height / 2) - (holder_mc._height / 2));
		
						cell_mc.onRelease = function () {
							trace("bing");
						}
						
						var skip = false;
						var skipData = listData[i].skip.split(",");
						for (var p=0; p<skipData.length; p++) {
							if (skipData[p] == currentDate) {
								skip = true;
								break;
							}
						}
						
						if (skip) {
							cell_mc.enabled = false;
							holder_mc._alpha = 70;
							var myColorMatrix_filter = new ColorMatrixFilter([0.3, 0.59, 0.11, 0, 0, 0.3, 0.59, 0.11, 0, 0, 0.3, 0.59, 0.11, 0, 0, 0, 0, 0, 1, 0]);
							holder_mc.filters = [myColorMatrix_filter];
						}
					}
				}
			}
		}
	}
}

skipCalendarEvent = function (eventObj) {
	var window_mc = showWindow({width:350, height:265, title:"Edit: " + eventObj.title, iconName:"calendar", megaModel:true, depth:1110});
	
	var content_mc = window_mc.content_mc;
	var buttonWidth = content_mc.width;
	
	content_mc.attachMovie("bi.ui.Label", "label_mc", 5, {settings:{width:buttonWidth, height:35, text:"Skip event until:"}});
	
	var buttonListener = new Object();
	buttonListener.press = function (eventObj) {
		eventObj.target._parent._parent.close();
	}
	
	var buttons = [{label:"Next occurrence", id:"nextOccurance"}, {label:"Next day", id:"nextDay"}, {label:"Next week", id:"nextWeek"}, {label:"Next month", id:"nextMonth"}];
	for (var i=0; i<buttons.length; i++) {
		var btn_mc = content_mc.attachMovie("bi.ui.Button", buttons[i].id + "_btn", i + 10, {settings:{width:buttonWidth, height:35, label:buttons[i].label}});
		btn_mc._y = i * (btn_mc._height + 8) + 35;
		btn_mc.addEventListener("press", buttonListener);
	}
}

editCalendarEvent = newCalendarEvent = function (calendarObj, dateObj) {
	if (calendarObj != undefined) {
		var mode = "edit";
		var window_mc = showWindow({width:570, height:425, title:"Edit event: " + eventObj.title, iconName:"calendar", megaModel:true, depth:1110});
	} else {
		var mode = "create";
		var calendarObj = new Object();
		var now = new Date();
		calendarObj.isNew = true;
		calendarObj.eventType = "once";
		calendarObj.title = "Untitled";
		calendarObj.memo = "";
		calendarObj.macroName = "";
		calendarObj.filter = "";
		calendarObj.time = now();
		calendarObj.startDate = dateObj;
		trace(dateObj);
		calendarObj.endDate = new Date(now.getFullYear() + 1, now.getMonth(), now.getDate(), now.getHours(), now.getMinutes(), now.getSeconds())
		calendarObj.pattern = new Object();
		var window_mc = showWindow({width:570, height:425, title:"Create new event:", iconName:"calendar", megaModel:true, depth:1110});
	}
	
	var content_mc = window_mc.content_mc;
	
	content_mc.attachMovie("bi.ui.Label", "title_lb", 10, {settings:{width:80, text:"Title:"}});
	content_mc.attachMovie("bi.ui.TextInput", "title_ti", 15, {settings:{width:180, text:calendarObj.title, _x:90, maxLength:20}});
	
	content_mc.attachMovie("bi.ui.Label", "time_lb", 20, {settings:{width:80, text:"Time:", _y:35}});
	content_mc.attachMovie("bi.ui.TextInput", "time_ti", 25, {settings:{width:180, text:calendarObj.time.dateTimeFormat(_global.settings.shortTimeFormat), _x:90, _y:35, maxLength:5}});
	
	content_mc.attachMovie("bi.ui.Label", "alarm_lb", 30, {settings:{width:80, text:"Alarm:", _y:70}});
	content_mc.attachMovie("bi.ui.CheckBox", "alarm_cb", 35, {settings:{_x:90, _y:70}});

	content_mc.attachMovie("bi.ui.Label", "msg_lb", 40, {settings:{width:80, text:"Message:", _y:105}});
	content_mc.attachMovie("bi.ui.TextInput", "msg_ti", 45, {settings:{width:180, height:215, text:calendarObj.memo, _x:90, _y:105, maxLength:200}});
		
	content_mc.attachMovie("bi.ui.Label", "recurrence_lb", 50, {settings:{width:100, text:"Recurrence:", _x:280}});
	
	content_mc.attachMovie("bi.ui.RadioButton", "once_rb", 55, {settings:{width:110, label:"Once", data:"once", _x:280, _y:35, groupName:"period"}});
	content_mc.attachMovie("bi.ui.RadioButton", "hourly_rb", 56, {settings:{width:110, label:"Hourly", data:"hourly", _x:420, _y:35, groupName:"period"}});
	content_mc.attachMovie("bi.ui.RadioButton", "daily_rb", 57, {settings:{width:110, label:"Daily", data:"daily", _x:280, _y:70, groupName:"period"}});
	content_mc.attachMovie("bi.ui.RadioButton", "weekly_rb", 58, {settings:{width:110, label:"Weekly", data:"weekly", _x:420, _y:70, groupName:"period"}});
	content_mc.attachMovie("bi.ui.RadioButton", "monthly_rb", 59, {settings:{width:110, label:"Monthly", data:"monthly", _x:280, _y:105, groupName:"period"}});
	content_mc.attachMovie("bi.ui.RadioButton", "yearly_rb", 60, {settings:{width:110, label:"Yearly", data:"yearly", _x:420, _y:105, groupName:"period"}});
	content_mc.period.data = calendarObj.eventType;
	
	var periodListener = new Object();
	periodListener.click = function (eventObj) {
		var tabs_mc = eventObj.target.selection._parent.tabs_mc;
		tabs_mc.selectedTab._visible = false;
		tabs_mc.selectedTab = tabs_mc[eventObj.target.data + "_mc"];
		tabs_mc.selectedTab._visible = true;
	}
	content_mc.period.addEventListener("click", periodListener);
	
	var tabs_mc = content_mc.createEmptyMovieClip("tabs_mc", 70);
	tabs_mc._x = 280;
	tabs_mc._y = 150;
	// hourly tab
	var tab_mc = tabs_mc.createEmptyMovieClip("hourly_mc", 0);
	tab_mc.attachMovie("bi.ui.Label", "every_lb", 0, {settings:{width:200, text:"Every         hour(s)"}});
	tab_mc.attachMovie("bi.ui.TextInput", "numHours_ti", 5, {settings:{width:30, text:"1", _x:50, maxLength:1, inputType:"numeric"}});
	if (calendarObj.eventType == "hourly") {
		tab_mc.numHours_ti.text = calendarObj.pattern.recur;
	}
	tab_mc._visible = false;
	// daily tab
	var tab_mc = tabs_mc.createEmptyMovieClip("daily_mc", 10);
	tab_mc.attachMovie("bi.ui.RadioButton", "everyXdays_rb", 0, {settings:{width:200, label:"Every         day(s)",  data:"", groupName:"every"}});
	tab_mc.attachMovie("bi.ui.TextInput", "numDays_ti", 5, {settings:{width:30, text:"1", _x:85, maxLength:1, inputType:"numeric"}});	
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
	tab_mc.attachMovie("bi.ui.TextInput", "numWeeks_ti", 5, {settings:{width:30, text:"1", _x:50, maxLength:1, inputType:"numeric"}});
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
	}
	tab_mc._visible = false;
	// monthly tab
	var tab_mc = tabs_mc.createEmptyMovieClip("monthly_mc", 30);
	tab_mc.attachMovie("bi.ui.RadioButton", "date_rb", 0, {settings:{width:200, label:"Day        of every", data:"date", groupName:"every"}});
	tab_mc.attachMovie("bi.ui.TextInput", "date_ti", 5, {settings:{width:30, text:"1", _x:70, maxLength:2, inputType:"numeric"}});
	tab_mc.attachMovie("bi.ui.TextInput", "numMonths_ti", 10, {settings:{width:30, text:"1", _x:35, _y:35, maxLength:1, inputType:"numeric"}});
	tab_mc.attachMovie("bi.ui.Label", "every_lb", 15, {settings:{width:100, text:"month(s)", _x:70, _y:35}});
	tab_mc.attachMovie("bi.ui.RadioButton", "day_rb", 20, {settings:{width:200, label:"The", data:"day", groupName:"every", _y:105}});
	tab_mc.attachMovie("bi.ui.TextInput", "week_ti", 25, {settings:{width:70, text:"first", _x:70, _y:105, maxLength:6}});
	tab_mc.attachMovie("bi.ui.TextInput", "day_ti", 30, {settings:{width:100, text:"Monday", _x:150, _y:105, maxLength:8}});
	tab_mc.attachMovie("bi.ui.Label", "every_lb", 35,{settings:{width:200, text:"of every         month(s)", _x:35, _y:140}});
	tab_mc.attachMovie("bi.ui.TextInput", "numMonths2_ti", 40, {settings:{width:30, text:"1", _x:105, _y:140, maxLength:1, inputType:"numeric"}});
	if (calendarObj.eventType == "monthly") {
		if (calendarObj.pattern.date != undefined) {
			tab_mc.every.data = "date";
			tab_mc.date_ti.text = calendarObj.pattern.date;
			tab_mc.numMonths_ti.text = calendarObj.pattern.recur;
		} else if (calendarObj.pattern.day != undefined) {
			tab_mc.every.data = "day";
			tab_mc.day_ti = calendarObj.pattern.day;
			tab_mc.week_ti = calendarObj.pattern.week;
			tab_mc.numMonths2_ti.text = calendarObj.pattern.recur;
		}		
	} else {
		tab_mc.every.data = "date";
	}
	
	tab_mc._visible = false;
	// yearly tab
	var tab_mc = tabs_mc.createEmptyMovieClip("yearly_mc", 40);
	
	tabs_mc.selectedTab = tabs_mc[calendarObj.eventType + "_mc"];
	tabs_mc.selectedTab._visible = true;

	var buttonListener = new Object();
	buttonListener.press = function (eventObj) {
		switch (eventObj.target._name) {
			case "saveEvent_btn":
			case "createEvent_btn":
				var saveObj = new Object();
				saveObj.title = content_mc.title_ti.text;
				saveObj.memo = content_mc.msg_ti.text;
				saveObj.time = content_mc.time_ti.text + ":00";
				saveObj.macroName = "";
				saveObj.startDate = calendarObj.startDate;
				saveObj.endDate = calendarObj.endDate;
				saveObj.eventType = content_mc.period.data;
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
									trace(saveObj.pattern.recur);
									saveObj.pattern.date = tab_mc.date_ti.text;
									trace(saveObj.pattern.date);
									break;
								case "day":
									saveObj.pattern.recur = tab_mc.numMonths2_ti.text;
									trace(saveObj.pattern.recur);
									saveObj.pattern.day = tab_mc.day_ti.text.substr(0, 3).toLowerCase();
									trace(saveObj.pattern.day);
									saveObj.pattern.week = tab_mc.week_ti.text;
									trace(saveObj.pattern.week);
									break;
							}
							break;
						case "yearly":
							//saveObj.pattern.recur = tab_mc.numYears_ti.text;
							break;
					}
				}
				break;
		}
		switch (eventObj.target._name) {
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
		content_mc.attachMovie("bi.ui.Button", "saveEvent_btn", 200, {settings:{width:150, label:"Save", _x:120, _y:335}});
		content_mc.saveEvent_btn.addEventListener("press", buttonListener);
	} else {
		content_mc.attachMovie("bi.ui.Button", "createEvent_btn", 200, {settings:{width:150, label:"Create", _x:120, _y:335}});
		content_mc.createEvent_btn.addEventListener("press", buttonListener);
	}
	content_mc.attachMovie("bi.ui.Button", "cancel_btn", 205, {settings:{width:150, label:"Cancel", _x:280, _y:335}});
	content_mc.cancel_btn.addEventListener("press", buttonListener);
}