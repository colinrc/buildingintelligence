serverSetup = function () {
	server = new XMLSocket();
	server.onConnect = serverOnConnect;
	server.onClose = serverOnClose;
	server.onXML = receiveCmd;
	serverConnect();
}

serverOnConnect = function (status) {
	clearInterval(serverConnectID);
	clearInterval(serverTimeoutID);
	if (status) {
		//sendCmd("MACRO", "getList", "");
		//sendCmd("SCRIPT", "getList", "");
		//sendCmd("CALENDAR", "getEvents", "");
		//sendCmd("ID", "getList", "");
		if (commsError) {
			window_mc.close();
			delete commsError;
		}
	} else {
		if (!_global.settings.debugMode) {
			showCommsError();
			commsError = true;
		}
		serverConnectID = setInterval(_root, "serverConnect", _global.settings.serverRetryTime * 1000);
	}
}

serverOnClose = function () {
	showCommsError();
	commsError = true;
	serverConnect();
}

serverConnect = function () {
	if (_global.settings.serverAddress.length) {
		trace("Connecting to server: " + _global.settings.serverAddress + ":" + _global.settings.serverPort);
		server.connect(_global.settings.serverAddress, _global.settings.serverPort);
		serverTimeoutID = setInterval(_root, "serverOnConnect", _global.settings.serverConnectTimeout * 1000);
	}
}

receiveCmd = function (xml) {
	var msg = xml.firstChild;

	if (msg.nodeName == "connected") {
		_global.serverVersion = msg.attributes.version;
	} else if (msg.nodeName == "MACROS") {
		defineMacros(msg.childNodes);
		broadcastChange("MACRO");
		renderMacroList();
	} else if (msg.nodeName == "SCRIPT") {
		defineScripts(msg.childNodes);
		broadcastChange("SCRIPT");
	} else if (msg.nodeName == "events") {
		//trace(msg.childNodes);
		defineCalendarData(msg.childNodes);
		broadcastChange("events");
	} else if (msg.nodeName == "MESSAGE") {
		var msgWin = new Object();
		msgWin.title = msg.attributes.TITLE;
		if (msg.attributes.WIDTH != undefined) msgWin.width = Number(msg.attributes.WIDTH);
		if (msg.attributes.HEIGHT != undefined) msgWin.height = Number(msg.attributes.HEIGHT);
		if (msg.attributes.ICON != undefined && msg.attributes.ICON != "") msgWin.icon = msg.attributes.ICON;
		if (msg.attributes.CONTENT != undefined) msgWin.content = msg.attributes.CONTENT;
		if (msg.attributes.HIDECLOSE != undefined) msgWin.hideClose = (msg.attributes.HIDECLOSE.toLowerCase() == "true");
		if (msg.attributes.AUTOCLOSE != undefined && !isNaN(msg.attributes.AUTOCLOSE)) msgWin.autoClose = msg.attributes.AUTOCLOSE;
		if (msg.attributes.VIDEO != undefined) msgWin.video = msg.attributes.VIDEO;
		showMessageWindow(msgWin);
	} else if (msg.nodeName == "CONTROL" && msg.attributes.KEY == "MACRO") {
		for (var i=0; i<_global.macros.length; i++) {
			if (_global.macros[i].name ==  msg.attributes.EXTRA) break; 
		}
		if (msg.attributes.COMMAND == "started") {
			_global.macros[i].running = true;
			_global.macros[i].lastStarted =  new Date();
		} else {
			_global.macros[i].running = false;
			_global.macros[i].lastFinished =  new Date();
		}
		broadcastChange("MACRO");
		renderMacroList();
	} else if (msg.nodeName == "CONTROL" && msg.attributes.KEY == "SCRIPT") {
		for (var i=0; i<_global.scripts.length; i++) {
			if (_global.scripts[i].name ==  msg.attributes.EXTRA) break; 
		}
		if (msg.attributes.COMMAND == "started") {
			_global.scripts[i].running = true;
			_global.scripts[i].lastStarted =  new Date();
		} else {
			_global.scripts[i].running = false;
			_global.scripts[i].lastFinished =  new Date();
		}
		broadcastChange("SCRIPT");
	} else if (msg.nodeName == "CONTROL" && msg.attributes.KEY == "LOCKSCREEN") {
		setAuthenticated(false);
		screenLocked = true;
	} else {
		var control = _global.controls[msg.attributes.KEY];
		if (control != undefined) {
			if (control.state != msg.attributes.COMMAND) {
				control.state = msg.attributes.COMMAND;
				if (msg.attributes.COMMAND == "on" || msg.attributes.COMMAND == "off") {
					control.storedStates["state"] = msg.attributes.COMMAND;
				}
				changed = true;
			}
			
			if (msg.attributes.EXTRA != undefined && control.value != msg.attributes.EXTRA) {
				control.value = msg.attributes.EXTRA;
				control.storedStates[msg.attributes.COMMAND] = msg.attributes.EXTRA;
				changed = true;
			}

			if (changed) broadcastChange(msg.attributes.KEY);
		}
	}
	if (_global.settings.debugMode) {
		debug_mc.incoming_txt.text = msg + "\n" + debug_mc.incoming_txt.text;
	} else {
		trace("INCOMING: " + msg);
	}
}

sendXml = function (xmlMsg) {
	server.send(xmlMsg);
	receiveCmd(new XML(xmlMsg))
	if (_global.settings.debugMode) {
		debug_mc.outgoing_txt.text = xmlMsg + "\n" + debug_mc.outgoing_txt.text;
	} else {
		trace("OUTGOING: " + msg);
	}
}
	
sendCmd = function (key, command, extra, extras) {
	var xmlMsg = '<CONTROL KEY="' + key + '"';
	if (command != undefined) xmlMsg += ' COMMAND="' + command + '"';
	if (extra != undefined) xmlMsg += ' EXTRA="' + extra + '"';
	if (extras != undefined) {
		for (var i=0; i<extras.length; i++) {
			xmlMsg += ' EXTRA' + (i + 2) + '="' + extras[i] + '"';
		}
	}
	xmlMsg += " />"
	
	server.send(xmlMsg);

	if (_global.settings.debugMode) {
		debug_mc.outgoing_txt.text = xmlMsg + "\n" + debug_mc.outgoing_txt.text;
	} else {
		trace("OUTGOING: " + xmlMsg);
	}
	
	if (recordingMacro) {
		if (newMacroArray[newMacroArray.length - 1].key == key && newMacroArray[newMacroArray.length - 1].command == command) {
			// if previous macro in list was the same key and command as we are about to store, discard it
			newMacroArray.pop();
		} else if (newMacroArray.length) {
			// pad macros in list with "pause" commands
			newMacroArray.push({key:"", command:"pause", extra:"0"})
		}
		var macroObj = new Object();
		macroObj.key = key;
		macroObj.command = command;
		macroObj.extra = (extra != undefined) ? extra : ""; 
		
		newMacroArray.push(macroObj);
	}
}

saveMacro = function (macroName, controlArray) {
	for (var i=0; i<_global.macros.length; i++) {
		if (_global.macros[i].name == macroName) break;
	}
	var macroObj = _global.macros[i];
	var statusList = [];
	for (var i in macroObj.status) {
		statusList.push(i); 
	}
	var xmlMsg = '<CONTROL KEY="MACRO" COMMAND="save" EXTRA="' + macroObj.name + '" STATUS="'+ statusList.join(",") + '" TYPE="' +  macroObj.type + '">';
	for (var control=0; control<controlArray.length; control++) {
		xmlMsg += '<CONTROL KEY="' + controlArray[control].key + '" COMMAND="' + controlArray[control].command + '" EXTRA="' + controlArray[control].extra + '" />';
	}
	xmlMsg += "</CONTROL>"
	server.send(xmlMsg);
	trace("OUTGOING: " + xmlMsg);
}

reorderMacros = function (dir, id) {
	var xmlMsg = '<MACROS>';
	for (var i=0; i<_global.macros.length; i++) {
		var macroObj = _global.macros[i];
		var statusList = [];
		for (var q in macroObj.status) {
			statusList.push(q); 
		}
		xmlMsg += '<CONTROL KEY="MACRO" COMMAND="save" EXTRA="' + macroObj.name + '" STATUS="'+ statusList.join(",") + '" TYPE="' + macroObj.type + '">';
		for (var control=0; control<macroObj.controls.length; control++) {
			xmlMsg += '<CONTROL KEY="' + macroObj.controls[control].key + '" COMMAND="' + macroObj.controls[control].command + '" EXTRA="' + macroObj.controls[control].extra + '" />';
		}
		xmlMsg += "</CONTROL>"
	}
	xmlMsg += "</MACROS>"
	var tmpXml = new XML(xmlMsg);
	if (dir == "moveUp") {
		var currentNode = tmpXml.firstChild.childNodes[id];
	} else {
		var currentNode = tmpXml.firstChild.childNodes[id + 1];
	}
	tmpXml.firstChild.insertBefore(currentNode.cloneNode(true), currentNode.previousSibling);	
	currentNode.removeNode();
	xmlMsg = tmpXml.toString();
	debug(xmlMsg);
	server.send(xmlMsg);
	if (_global.settings.debugMode) debug_mc.outgoing_txt.text = xmlMsg + "\n" + debug_mc.outgoing_txt.text;
}

setScriptEnabled = function (scriptName) {
	for (var i=0; i<_global.scripts.length; i++) {
		if (_global.scripts[i].name == scriptName) break;
	}
	var scriptObj = _global.scripts[i];
	/*
	var statusList = [];
	for (var i in scriptObj.status) {
		statusList.push(i); 
	}
	*/
	var xmlMsg = '<CONTROL KEY="SCRIPT" COMMAND="save" EXTRA="' + scriptObj.name + '" EXTRA2="'+ scriptObj.enabled + '"/>';
	server.send(xmlMsg);
	debug(xmlMsg);
}

deleteMacro = function (macroName) {
	trace("macroName: " + macroName);
	var xmlMsg = '<CONTROL KEY="MACRO" COMMAND="delete" EXTRA="' + macroName + '" />';
	server.send(xmlMsg);
	debug(xmlMsg);
}

saveEvent = function (event) {
	var xmlMsg = '<CONTROL KEY="CALENDAR" COMMAND="save" EXTRA="">';
	if (event.eventType == "once") {
		xmlMsg += '<event id="' + event.id + '" title="' + event.title + '" alarm="' + (event.alarm?"Y":"N") + '" memo="' + event.memo + '" category="' + event.category + '" date="' + event.startDate.dateTimeFormat("yyyy-mm-dd") + '" time="' + event.time + '" eventType="' + event.eventType + '" macroName="' + event.macroName + '" />';
	} else {
		xmlMsg += '<event id="' + event.id + '" title="' + event.title + '" alarm="' + (event.alarm?"Y":"N") + '" memo="' + event.memo + '" category="' + event.category + '" startDate="' + event.startDate.dateTimeFormat("yyyy-mm-dd") + '" endDate="' + event.endDate.dateTimeFormat("yyyy-mm-dd") + '" time="' + event.time + '" eventType="' + event.eventType + '"  macroName="' + event.macroName + '" filter="' + event.filter + '">';		
		xmlMsg += "<pattern";
		for (var attrib in event.pattern) {
			xmlMsg += " " + attrib + '="' + event.pattern[attrib] + '"';
		}
		xmlMsg += "/>";		
		xmlMsg += '</event>'
	}
	xmlMsg += "</CONTROL>";
	server.send(xmlMsg);
	debug(xmlMsg);
}

deleteEvent = function (event) {
	var xmlMsg = '<CONTROL KEY="CALENDAR" COMMAND="delete" EXTRA="' + event.id + '" />';
	server.send(xmlMsg);
	if (_global.settings.debugMode) debug_mc.outgoing_txt.text = xmlMsg + "\n" + debug_mc.outgoing_txt.text;
}

setUpLogging = function () {
	for (var group=0; group<_global.logging.length; group++) {
		var log_mc = _root.logging_mc.createEmptyMovieClip("log" + group + "_mc", group);
 		var groupObj = log_mc.groupObj = _global.logging[group];
		log_mc.update = function (key, state, value) {
			for (var control=0; control<this.groupObj.controls.length; control++) {
				if (this.groupObj.controls[control].key == key) break;
			}
			var showState = false;
			var listenToArray = this.groupObj.listenTo.split(",");
			for (var i=0; i<listenToArray.length; i++) {
				if (state == listenToArray[i]) {
					showState = true;
					break;
				}
			}
			if (showState) {
				var now = new Date();
				if (this.groupObj.type == "scripts") {
					for (var i=0; i<_global.scripts.length; i++) {
						if (_global.scripts[i].name == value) break; 
					}
					if (state == "started") {
						_global.scripts[i].running = true;
						_global.scripts[i].lastStarted = now;
					} else {
						_global.scripts[i].running = false;
						_global.scripts[i].lastFinished = now;
					}
				} else {
					var log = this.groupObj.log;
					var controlObj = _global.controls[key];
					
					if (this.groupObj.label.split(",").length > 1) {
						if (state == this.groupObj.listenTo.split(",")[0]) {
							var msg = this.groupObj.label.split(",")[0];
						} else {
							var msg = this.groupObj.label.split(",")[1];
						}
					} else {
						var msg = this.groupObj.label;
					}
					msg += " ";
					msg = msg.split("%timestamp%").join(now.dateTimeFormat(this.groupObj.timeformat));
					//msg = msg.split("%datestamp%").join(now.dateTimeFormat(this.groupObj.dateFormat));
					msg = msg.split("%room%").join(controlObj.room);
					msg = msg.split("%name%").join(controlObj.name);
					msg = msg.split("%state%").join(state);
					msg = msg.split("%extra%").join(value);
							
					log.unshift({timestamp:now, msg:msg})
					
					if (log.length > 30) log.pop();
					
					this.groupObj.controls[control].counter++;
					this.groupObj.counter++;
					this.groupObj.controls[control].lastUpdated = new Date();
				}
			}
		}
		var keys = new Array();
		for (var control=0; control<groupObj.controls.length; control++) {
			keys.push(groupObj.controls[control].key);
			groupObj.controls[control].counter = 0;
		}
		subscribe(keys, log_mc);
		groupObj.counter = 0;
	}
}