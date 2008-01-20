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
	//return;
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
	s = new XMLSerializer().serializeToString(xmlhttp.responseXML);
	s = s.replace(/</g, "&lt;");
	s = s.replace(/>/g, "&gt;");
	debug(s);
	if (Sarissa.getParseErrorText(xmlhttp.responseXML) == Sarissa.PARSED_OK) {
		if (init) {
			debug("Connected: v" + xmlhttp.responseXML.firstChild.firstChild.attributes.version.value);
			_global.sessionID = xmlhttp.responseXML.firstChild.firstChild.attributes.session.value;
		} else {
		}
	} else {
		debug(Sarissa.getParseErrorText(xmlhttp.responseXML));
	}
}

serverSend = function () {
	var controlForm = document.getElementById("controlForm");
	debug('Send: &lt;CONTROL KEY="' + controlForm.key.value + '" COMMAND="' + controlForm.command.value  + '" EXTRA="' + controlForm.extra.value + '" /&gt;');
	
	sendObj = '';
	sendObj += '&MESSAGE=<CONTROL KEY="' + controlForm.key.value + '" COMMAND="' + controlForm.command.value  + '" EXTRA="' + controlForm.extra.value + '" />';
	sendObj += '&SESSION_ID=' + _global.sessionID + "&";
	
	var xmlhttp = new XMLHttpRequest();
	xmlhttp.open("POST", _global.settings.serverProtocol + "://" + _global.settings.serverAddress  + ":" + _global.settings.serverPort + "/webclient/update", false);
	xmlhttp.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
	xmlhttp.send(sendObj);
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
	_global.rooms = new Object();
	
	var canvas = document.getElementById("canvas");
	
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
		output += '<label>' + tabXML.childNodes[i].attributes["name"].value + '</label>';
		if (tabXML.childNodes[i].attributes["type"].value == "onOff") {
			output += '<a href="javascript:sendCmd(\'' + tabXML.childNodes[i].attributes["key"].value + '\', \'on\')" class="button"><img src="/lib/icons/' + tabXML.childNodes[i].attributes["icons"].value.split(",")[0] + '.png"></a>';
		} else {
			
		}
	}
	canvas.innerHTML += '<div id="tab">' + output + '</div>';
	
	canvas.innerHTML += '<ul id="boxList"><li class="backButton"><a href="javascript:drawRooms(' + zone + ')">< Back</a></li></ul>';
	hideURLbar()
}

addEventListener("load", init, false);