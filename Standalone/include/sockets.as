/*
import com.bnm.fc.f_TEA;
var crypto:f_TEA = new f_TEA();
var cryptoKeys:Array=new Array();
cryptoKeys = [1, 2, 3, 4];
*/

crypto.onEncode = function (encoded) {
	encoded =  '<encrypted><![CDATA[' + encoded + ']]></encrypted>';
	trace("ENCODED DATA:\n" + encoded);
	server.send(encoded + "\n");
}

crypto.onDecode = function (decoded) {
	trace("DECODED DATA:\n" + decoded);
	receiveCmd(new XML(decoded).firstChild, true);
}

var availablePorts = mdm.COMPorts.ports.split(",");
isCOMAvailabe = false;
for (var i=0; i<availablePorts.length; i++) {
	if (Number(availablePorts) == _global.settings.COMPort) {
		isCOMAvailabe = true;
	}
}
if (isCOMAvailabe) {
	mdm.COMPort.open(_global.settings.COMPort, 19200, 8, "N", 1, "OFF");
	mdm.COMPort.useLineMode(true, chr(13));
	mdm.COMPort.onCOMPortData = function (dataObj){
		var data = dataObj.data.substr(0, dataObj.data.length - 1);
		var command = data.split(" ")[0];
		var extra = data.split(" ")[1];
		if (extra == "+") extra = "on";
		if (extra == "-") extra = "off";
		//if (command == "W0") return;
		if (command == "K2" && extra == "off") toggleTV();
		receiveCmd(new XML('<CONTROL KEY="COM_PORT" COMMAND="' + command + '" EXTRA="' + extra + '" />'));
	}
}

serverSetup = function () {
	if (_global.settings.serverAddress.length) {
		if (_global.settings.serverAddress.substr(0, 7) == "http://" || _global.settings.serverAddress.substr(0, 8) == "https://") {
			setInterval(this, "getCachedData", _global.settings.webRefreshRate * 1000);
			getCachedData(true);
		} else {
			server = new XMLSocket();
			server.onConnect = serverOnConnect;
			server.onClose = serverOnClose;
			server.onXML = receiveCmd;
			serverConnect();			
		}
	}
}

getCachedData = function (init) {
	var xml = new XML();
	if (init) {
		xml.load(_global.settings.serverAddress + "/webclient/update?INIT=Y");
	} else {
		xml.load(_global.settings.serverAddress + "/webclient/update");
	}
	xml.onLoad = function (success) {
		if (success) {
			var packet = this.firstChild.childNodes;
			for (var i=0; i<packet.length; i++) {
				//trace("START:\n" + packet[i] + "\nEND");
				receiveCmd(packet[i], true);
			}
		} else {
			// xml didn't load
		}
	}
}

sendAndLoadCachedData = function () {
	
}

serverSend = function (packet) {
	if (_global.settings.debugMode) {
		debug_mc.outgoing_txt.text = packet + "\n" + debug_mc.outgoing_txt.text;
	} else {
		trace("OUTGOING:\n" + packet + "\n--------");
	}
	
	if (_global.settings.serverAddress.substr(0, 7) == "http://" || _global.settings.serverAddress.substr(0, 8) == "https://") {
		var xmlIn:XML = new XML();
		var messageOut:LoadVars = new LoadVars();
		messageOut.MESSAGE = packet;
		messageOut.sendAndLoad(_global.settings.serverAddress + "/webclient/update", xmlIn);
		xmlIn.onLoad = function (success) {
			if (success) {
				/*
				var packet = this.firstChild.childNodes;
				for (var i=0; i<packet.length; i++) {
					receiveCmd(packet[i], true);
				}
				*/
			} else {
				// xml didn't load
			}
		}
	} else {
		if (_global.settings.encryptedData) {
			crypto.encodeString(packet, cryptoKeys[0], cryptoKeys[1], cryptoKeys[2], cryptoKeys[3]);
		} else {
			server.send(packet + "\n");
		}
	}
}

serverOnConnect = function (status) {
	clearInterval(serverConnectID);
	clearInterval(serverTimeoutID);
	if (status) {
		if (commsError) {
			window_mc.close();
			delete commsError;
		}
		serverSend('<clientName value="' + _global.settings.clientName + '" />')
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

receiveCmd = function (xml, ignoreSkip) {
	if (xml.firstChild.nodeName == "encrypted") {
		//var block = "1Ct68ep2;19y8087977;0a02796988;0705Qqf3;099Z86j;1k6b88083;1MEpJ84;1G86zNs;1F778j7B0;0q99L971;0Ad7PYY;0kA8Q084;";
		//var xml = new XML('<?xml version="1.0" encoding="UTF-8"?>\n<encrypted><![CDATA[' + block + ']]></encrypted>');
		crypto.decodeString(xml.firstChild.firstChild.nodeValue, cryptoKeys[0], cryptoKeys[1], cryptoKeys[2], cryptoKeys[3]);
		return;
	} else {
		if (ignoreSkip) {
			var msg = xml;
		} else {
			var msg = xml.firstChild;
		}
	}
	
	if (_global.settings.debugMode) {
		debug_mc.incoming_txt.text = msg + "\n" + debug_mc.incoming_txt.text;
	} else {
		trace("INCOMING:\n" + msg + "\n--------");
	}
	
	if (msg.nodeName == "connected") {
		_global.serverVersion = msg.attributes.version;
		sendCmd("MACRO", "getList", "");
		sendCmd("SCRIPT", "getList", "");
		sendCmd("CALENDAR", "getEvents", "");
		sendCmd("ID", "getList", "");
	} else if (msg.nodeName == "MACROS") {
		var partial = (msg.attributes.COMPLETE == "N");
		var wasNew = defineMacros(msg.childNodes, partial);
		if (partial && !wasNew) {
			broadcastChange("MACRO", msg.firstChild.attributes.EXTRA);
		} else {
			broadcastChange("MACRO", (wasNew) ? "new" : "old");
		}
		renderMacroList();
	} else if (msg.nodeName == "MACRO_CONTENTS") {
		var macroContent = defineMacroContent(msg.firstChild.childNodes);
		broadcastChange("MACRO_CONTENTS");
	} else if (msg.nodeName == "SCRIPT") {
		defineScripts(msg.childNodes);
		broadcastChange("SCRIPT");
	} else if (msg.nodeName == "events") {
		var partial = (msg.attributes.COMPLETE == "N");
		defineCalendarData(msg.childNodes, partial);
		if (partial) {
			broadcastChange("events", msg.firstChild.attributes.id);
		} else {
			broadcastChange("events");
		}
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
		if (msg.attributes.ALARM != undefined) msgWin.alarm = msg.attributes.ALARM;
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
		broadcastChange("MACRO", msg.attributes.EXTRA);
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
}

sendXml = function (xmlMsg) {
	serverSend(xmlMsg);
	receiveCmd(new XML(xmlMsg))
}
	
sendCmd = function (key, command, extra, extras) {
	if (key != "COM_PORT") {
		var xmlMsg = '<CONTROL KEY="' + key + '"';
		if (command != undefined) xmlMsg += ' COMMAND="' + command + '"';
		if (extra != undefined) xmlMsg += ' EXTRA="' + extra + '"';
		if (extras != undefined) {
			for (var i=0; i<extras.length; i++) {
				xmlMsg += ' EXTRA' + (i + 2) + '="' + extras[i] + '"';
			}
		}
		xmlMsg += " />"
		
		serverSend(xmlMsg);
	
		if (recordingMacro) {
			if (newMacroArray[newMacroArray.length - 1].key == key && newMacroArray[newMacroArray.length - 1].command == command) {
				// if previous macro in list was the same key and command as we are about to store, discard it
				newMacroArray.pop();
			} else if (newMacroArray.length || insertMacroObj.contents.length) {
				// pad macros in list with "pause" commands
				newMacroArray.push({key:"", command:"pause", extra:"0", extra2:"", extra3:"", extra4:"", extra5:""})
			}
			var macroObj = new Object();
			macroObj.key = key;
			macroObj.command = command;
			macroObj.extra = (extra != undefined) ? extra : ""; 
			macroObj.extra2 = (extra2 != undefined) ? extra2 : "";
			macroObj.extra3 = (extra3 != undefined) ? extra3 : "";
			macroObj.extra4 = (extra4 != undefined) ? extra4 : "";
			macroObj.extra5 = (extra5 != undefined) ? extra5 : "";
			
			newMacroArray.push(macroObj);
		}
	} else if (isCOMAvailabe) {
		debug_mc.outgoing_txt.text = "COMPORT: " + command + " " + extra + "\n" + debug_mc.outgoing_txt.text;
		mdm.COMPort.send(command + " " + extra + "\n");
	}
}

createMacro = function (macroName, controlArray) {
	var xmlMsg = '<CONTROL KEY="MACRO" COMMAND="save" EXTRA="' + macroName + '" STATUS="" TYPE="">';
	for (var control=0; control<controlArray.length; control++) {
		xmlMsg += '<CONTROL KEY="' + controlArray[control].key + '" COMMAND="' + controlArray[control].command + '" EXTRA="' + controlArray[control].extra + '" EXTRA2="' + controlArray[control].extra2 + '" EXTRA3="' + controlArray[control].extra3 + '" EXTRA4="' + controlArray[control].extra4 + '" EXTRA5="' + controlArray[control].extra5 + '" />';
	}
	xmlMsg += "</CONTROL>";
	serverSend(xmlMsg);
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
		xmlMsg += '<CONTROL KEY="' + controlArray[control].key + '" COMMAND="' + controlArray[control].command + '" EXTRA="' + controlArray[control].extra + '" EXTRA2="' + controlArray[control].extra2 + '" EXTRA3="' + controlArray[control].extra3 + '" EXTRA4="' + controlArray[control].extra4 + '" EXTRA5="' + controlArray[control].extra5 + '" />';
	}
	xmlMsg += "</CONTROL>";
	serverSend(xmlMsg);
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
			xmlMsg += '<CONTROL KEY="' + macroObj.controls[control].key + '" COMMAND="' + macroObj.controls[control].command + '" EXTRA="' + macroObj.controls[control].extra + '" EXTRA2="' + macroObj.controls[control].extra2 + '" EXTRA3="' + macroObj.controls[control].extra3 + '" EXTRA4="' + macroObj.controls[control].extra4 + '" EXTRA5="' + macroObj.controls[control].extra5 + '" />';
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
	serverSend(xmlMsg);
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
	serverSend(xmlMsg);
}

deleteMacro = function (macroName) {
	trace("macroName: " + macroName);
	var xmlMsg = '<CONTROL KEY="MACRO" COMMAND="delete" EXTRA="' + macroName + '" />';
	serverSend(xmlMsg);
}

saveEvent = function (event) {
	var xmlMsg = '<CONTROL KEY="CALENDAR" COMMAND="save" EXTRA="">';
	if (event.eventType == "once") {
		xmlMsg += '<event id="' + event.id + '" title="' + event.title + '" active="' + (event.active?"Y":"N") + '" alarm="' + (event.alarm?"Y":"N") + '" memo="' + event.memo + '" category="' + event.category + '" date="' + event.startDate.dateTimeFormat("yyyy-mm-dd") + '" time="' + event.time.dateTimeFormat("HH:nn:ss") + '" eventType="' + event.eventType + '" macroName="' + event.macroName + '"  extra="' + event.extra + '"  extra2="' + event.extra2 + '" filter="' + event.filter + '" />';
	} else {
		xmlMsg += '<event id="' + event.id + '" title="' + event.title + '" active="' + (event.active?"Y":"N") + '" alarm="' + (event.alarm?"Y":"N") + '" memo="' + event.memo + '" category="' + event.category + '" startDate="' + event.startDate.dateTimeFormat("yyyy-mm-dd") + '" endDate="' + event.endDate.dateTimeFormat("yyyy-mm-dd") + '" time="' + event.time.dateTimeFormat("HH:nn:ss") + '" eventType="' + event.eventType + '"  macroName="' + event.macroName + '"  extra="' + event.extra + '"  extra2="' + event.extra2 + '" filter="' + event.filter + '">';		
		xmlMsg += "<pattern";
		for (var attrib in event.pattern) {
			xmlMsg += " " + attrib + '="' + event.pattern[attrib] + '"';
		}
		xmlMsg += "/>";
		if (event.skip.length == 1) {
			var s = new Date(event.skip[0]);
			var e = new Date(event.skip[0]);
			xmlMsg += '<skip start_date="' + s.dateTimeFormat("yyyy-mm-dd") + '" end_date="' + e.dateTimeFormat("yyyy-mm-dd") + '" />';
		} else if (event.skip.length > 1) {
			var startDate = event.skip[0];
			for (var i=0; i<event.skip.length; i++) {
				if (event.skip[i + 1] > event.skip[i] + 86400000 || i == event.skip.length - 1) {
					var s = new Date(startDate);
					var e = new Date(event.skip[i]);
					xmlMsg += '<skip start_date="' + s.dateTimeFormat("yyyy-mm-dd") + '" end_date="' + e.dateTimeFormat("yyyy-mm-dd") + '" />';
					startDate = event.skip[i + 1];
				}
			}
		}
		xmlMsg += '</event>'
	}
	xmlMsg += "</CONTROL>";
	serverSend(xmlMsg);
}

deleteEvent = function (event) {
	var xmlMsg = '<CONTROL KEY="CALENDAR" COMMAND="delete" EXTRA="' + event.id + '" />';
	serverSend(xmlMsg);
}

setUpLogging = function () {
	for (var group=0; group<_global.logging.groups.length; group++) {
		var log_mc = _root.logging_mc.createEmptyMovieClip("log" + group + "_mc", group);
 		var groupObj = log_mc.groupObj = _global.logging.groups[group];
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
					log.unshift({timestamp:now, msg:msg});
					
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