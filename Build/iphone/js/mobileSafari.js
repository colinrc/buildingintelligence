showDebug = false;

addEventListener("load", function() { setTimeout(hideURLbar, 0) }, false);
function hideURLbar() {
	window.scrollTo(0, 1);
}

/*
var currentWidth = 0;
addEventListener("load", function() { setTimeout(updateLayout, 0) }, false);
function updateLayout() {
	if (window.innerWidth != currentWidth) {
		currentWidth = window.innerWidth;
		var orient = currentWidth == 320 ? "profile" : "landscape";
		document.body.setAttribute("orient", orient);
		setTimeout(function() { window.scrollTo(0, 1) }, 100);
	}
}

setInterval(updateLayout, 400);
*/

debug = function (msg) {
	if (!showDebug) return;
	var debug = document.getElementById("debug");
	debug.innerHTML += msg + "<br>";
	debug.scrollTop = debug.scrollHeight;
}

pollServer = function (init) {
	var xmlhttp = new XMLHttpRequest();
	if (init) {
		debug("HTTPS: " + _global.settings.serverProtocol + "://" + _global.settings.serverAddress  + ":" + _global.settings.serverPort + "/webclient/update?INIT=Y&ID=" + _global.settings.securityID);
		xmlhttp.open("GET", _global.settings.serverProtocol + "://" + _global.settings.serverAddress + ":" + _global.settings.serverPort + "/webclient/update?INIT=Y&ID=" + _global.settings.securityID, false);
	} else {
		debug("HTTPS: " + _global.settings.serverProtocol + "://" + _global.settings.serverAddress  + ":" + _global.settings.serverPort + "/webclient/update?SESSION_ID=" + _global.sessionID);
		xmlhttp.open("GET", _global.settings.serverProtocol + "://" + _global.settings.serverAddress + ":" + _global.settings.serverPort + "/webclient/update?SESSION_ID=" + _global.sessionID, false);
	}
	xmlhttp.send('');
	if (Sarissa.getParseErrorText(xmlhttp.responseXML) == Sarissa.PARSED_OK) {
		var packetXML = xmlhttp.responseXML.firstChild.firstChild;
		if (packetXML) {
			if (init) {
				debug("Connected: v" + packetXML.attributes["version"].value);
				_global.sessionID = packetXML.attributes["session"].value;
			} else {
				switch (packetXML.nodeName) {
					case "CONTROL":
						if (!_global.controls[packetXML.attributes["KEY"].value]) _global.controls[packetXML.attributes["KEY"].value] = new Object();
						_global.controls[packetXML.attributes["KEY"].value].command = packetXML.attributes["COMMAND"].value;
						_global.controls[packetXML.attributes["KEY"].value].extra = packetXML.attributes["EXTRA"].value;
						
						var s = new XMLSerializer().serializeToString(packetXML);
						s = s.replace(/</g, "&lt;");
						s = s.replace(/>/g, "&gt;");
						debug("Incoming packet: " + "\n" + s);
						
						refresh();
						break;
					default:
						// a packet came in which we didn't know what to do with, so dump it to debug
						var s = new XMLSerializer().serializeToString(packetXML);
						s = s.replace(/</g, "&lt;");
						s = s.replace(/>/g, "&gt;");
						debug("Incoming packet: " + "\n" + s);
				}
			}
		}
	} else {
		debug("Error: " + Sarissa.getParseErrorText(xmlhttp.responseXML));
	}
}

xmlToObj = function (node) {
	for (var i=0; i<node.childNodes.length; i++) {
		if (node.childNodes[i].nodeType > 1) continue;
		var nodeObj = new Object();
		for (var q=0; q<node.childNodes[i].attributes.length; q++) {
			var attr = node.childNodes[i].attributes[q];
			if (attr.value == "true" || attr.value == "false") {
				nodeObj[attr.name] = (attr.value == "true");
			} else if (Number(attr.value) == attr.value) {
				nodeObj[attr.name] = Number(attr.value);				
			} else {
				nodeObj[attr.name] = attr.value;
			}
		}
		if (node.childNodes[i].childNodes.length) {
			debug(node.childNodes[i].nodeName);
			nodeObj[node.childNodes[i].nodeName] = new Array();
			nodeObj[node.childNodes[i].nodeName].push(xmlToObj(node.childNodes[i]));
		}
		
		if (node.childNodes[i].nodeName == "zone" && node.childNodes[i].attributes.name) {
			_global.zones.push(nodeObj);
			//debug(node.childNodes[i].childNodes[1].nodeName);
			//debug(nodeObj.rooms.length);
		}
	}
	return nodeObj;
}

init = function () {
	debug("Initialising eLife");
	
	_global = new Object();
	_global.settings = new Object();
	_global.controls = new Object();
	_global.currentView = new Object();
	
	var canvas = document.getElementById("canvas");
	
	if (!showDebug) document.getElementById("debug").style.display = "none";
	
	debug("Loading elife.xml");
	var xmlhttp = new XMLHttpRequest();
	xmlhttp.open("GET", "elife.xml", false);
	xmlhttp.send('');
	var settings = xmlhttp.responseXML.firstChild;
	for (var i=0; i<settings.childNodes.length; i++) {
		if (settings.childNodes[i].nodeType > 1) continue;
		//debug("- " + settings.childNodes[i].attributes["name"].value + "=" + settings.childNodes[i].attributes["value"].value);
		_global.settings[settings.childNodes[i].attributes["name"].value] = settings.childNodes[i].attributes["value"].value;
	}
	
	debug("Loading " + _global.settings.serverProtocol + "://" + _global.settings.serverAddress + ":" + _global.settings.serverPort + "/" + _global.settings.applicationXML);
	var xmlhttp = new XMLHttpRequest();
	xmlhttp.open("GET", _global.settings.serverProtocol + "://" + _global.settings.serverAddress + ":" + _global.settings.serverPort + "/" + _global.settings.applicationXML, false);
	xmlhttp.send('');
	if (Sarissa.getParseErrorText(xmlhttp.responseXML) == Sarissa.PARSED_OK) {
		var settings = xmlhttp.responseXML.firstChild.childNodes[1].childNodes[1];
		//debug(settings.childNodes.length);
		for (var i=0; i<settings.childNodes.length; i++) {
			if (settings.childNodes[i].nodeType > 1) continue;
			//debug("- " + settings.childNodes[i].attributes["name"].value + "=" + settings.childNodes[i].attributes["value"].value);
			_global.settings[settings.childNodes[i].attributes["name"].value] = settings.childNodes[i].attributes["value"].value;
		}
		
		for (var i=0; i<xmlhttp.responseXML.firstChild.childNodes.length; i++) {
			switch (xmlhttp.responseXML.firstChild.childNodes[i].nodeName) {
				case "property":
					_global.zones = xmlhttp.responseXML.firstChild.childNodes[i];
					break;
			}
		}
		
		//drawZones();
		drawRoom(1, 0, 0);
	} else {
		debug(Sarissa.getParseErrorText(xmlhttp.responseXML));
	}
	pollServer(true);
	
	setInterval("pollServer()", _global.settings.webRefreshRate * 1000);
}

sendCmd = function (key, command, extra) {
	if (command == undefined) var command = "";
	if (extra == undefined) var extra = "";
	
	if (!_global.controls[key]) _global.controls[key] = new Object();
	_global.controls[key].command = command;
	_global.controls[key].extra = extra;
	
	var controlForm = document.getElementById("controlForm");
	debug('Send: &lt;CONTROL KEY="' + key + '" COMMAND="' + command  + '" EXTRA="' + extra + '" /&gt;');
	
	sendObj = '';
	sendObj += '&MESSAGE=<CONTROL KEY="' + key + '" COMMAND="' + command  + '" EXTRA="' + extra + '" />';
	sendObj += '&SESSION_ID=' + _global.sessionID + "&";
	
	var xmlhttp = new XMLHttpRequest();
	xmlhttp.open("POST", _global.settings.serverProtocol + "://" + _global.settings.serverAddress  + ":" + _global.settings.serverPort + "/webclient/update", false);
	xmlhttp.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
	xmlhttp.send(sendObj);
}

drawZones = function () {
	canvas.innerHTML = "<h1>eLife</h1>";
	var output = "";
	for (var i=0; i<_global.zones.childNodes.length; i++) {
		if (_global.zones.childNodes[i].childNodes.length && _global.zones.childNodes[i].firstChild.nodeName == "rooms" && !_global.zones.childNodes[i].attributes["hideFromList"]) {
			output += '<li><a href="javascript:drawRooms(' + i + ')">' + _global.zones.childNodes[i].attributes["name"].value + '</a></li>';
		}
	}
	canvas.innerHTML += '<ul id="boxList">' + output + '</ul>';
	hideURLbar()
}

drawRooms = function (zone) {
	canvas.innerHTML = "<h1>" + _global.zones.childNodes[zone].attributes["name"].value + "</h1>";
	var output = "";
	for (var q=0; q<_global.zones.childNodes[zone].firstChild.childNodes.length; q++) {
		if (_global.zones.childNodes[zone].firstChild.childNodes[q].firstChild.nodeName == "window") {
			output += '<li><a href="javascript:drawRoom(' + zone + ',' + q + ',0)">' + _global.zones.childNodes[zone].firstChild.childNodes[q].attributes["name"].value + '</a></li>';
		}
	}
	canvas.innerHTML += '<ul id="boxList">' + output + '<li class="backButton"><a href="javascript:drawZones()">< Back</a></li></ul>';
	hideURLbar()
}

drawRoom = function (zone, room, tab) {
	_global.currentView.zone = zone;
	_global.currentView.room = room;
	_global.currentView.tab = tab;
	
	refresh = function () {
		var zone = _global.currentView.zone;
		var room = _global.currentView.room;
		var tab = _global.currentView.tab;
		
		var roomXML = _global.zones.childNodes[zone].firstChild.childNodes[room];
		var tabXML = roomXML.firstChild.childNodes[tab];
		
		canvas.innerHTML = "<h1>" + _global.zones.childNodes[zone].firstChild.childNodes[room].attributes["name"].value + "</h1>";
		var output = "";
		for (var i=0; i<roomXML.firstChild.childNodes.length; i++) {
			if (i == tab) {
				output += '<li class="on">'
			} else {
				output += '<li>'
			}
			output += '<a href="javascript:drawRoom(' + zone + ',' + room + ',' + i + ')">';
			//output += roomXML.firstChild.childNodes[i].attributes["name"].value;
			if (roomXML.firstChild.childNodes[i].attributes["icon"]) {
				output += '<img src="/lib/icons/' + roomXML.firstChild.childNodes[i].attributes["icon"].value + '.png">';
			} else {
				output += '<img src="/lib/icons/null.png">';
			}
			output += '</a></li>';
		}
		canvas.innerHTML += '<ul id="tabList">' + output + '</ul>';
		
		output = "";
		for (var i=0; i<tabXML.childNodes.length; i++) {
			var key = tabXML.childNodes[i].attributes["key"].value;
			if (_global.controls[key]) {
				var command = _global.controls[key].command.toLowerCase();
			} else {
				var command = "";
			}
			
			output += '<label>' + tabXML.childNodes[i].attributes["name"].value + '</label>';
			if (tabXML.childNodes[i].attributes["type"].value == "onOff") {
				output += '<a href="javascript:sendCmd(\'' + key + '\', \'' + (command == "on" ? "off" : "on") + '\');refresh();" class="button"><img src="/lib/icons/';
				if (command == "on") {
					output += tabXML.childNodes[i].attributes["icons"].value.split(",")[1];
				} else {
					output += tabXML.childNodes[i].attributes["icons"].value.split(",")[0];
				}
				output += '.png"></a>';
			} else {
				
			}
		}
		canvas.innerHTML += '<div id="tab">' + output + '</div>';
		
		canvas.innerHTML += '<ul id="boxList"><li class="backButton"><a href="javascript:drawRooms(' + zone + ')">< Back</a></li></ul>';
		hideURLbar()
	}
	refresh();
}

addEventListener("load", init, false);