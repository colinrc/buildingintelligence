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
	//alert(new XMLSerializer().serializeToString(xmlhttp.responseXML))
}

init = function () {
	debug("Initialising eLife");
	
	_global = new Object();
	_global.settings = new Object();
	
	debug("Loading elife.xml");
	var xmlhttp = new XMLHttpRequest();
	xmlhttp.open("GET", "elife.xml", false);
	xmlhttp.send('');
	var settings = xmlhttp.responseXML.firstChild;
	for (var i=0; i<settings.childNodes.length; i++) {
		if (settings.childNodes[i].nodeType > 1) continue;
		debug("- " + settings.childNodes[i].attributes["name"].value + "=" + settings.childNodes[i].attributes["value"].value);
		_global.settings[settings.childNodes[i].attributes["name"].value] = settings.childNodes[i].attributes["value"].value;
	}
	
	debug("Loading " + _global.settings.serverProtocol + "://" + _global.settings.serverAddress + ":" + _global.settings.serverPort + "/" + _global.settings.applicationXML);
	var xmlhttp = new XMLHttpRequest();
	xmlhttp.open("GET", _global.settings.serverProtocol + "://" + _global.settings.serverAddress + ":" + _global.settings.serverPort + "/" + _global.settings.applicationXML, false);
	xmlhttp.send('');
	if (Sarissa.getParseErrorText(xmlhttp.responseXML) == Sarissa.PARSED_OK) {
		//alert(new XMLSerializer().serializeToString(xmlhttp.responseXML));  
		var settings = xmlhttp.responseXML.firstChild.childNodes[1].childNodes[1];
		//debug(settings.childNodes.length);
		for (var i=0; i<settings.childNodes.length; i++) {
			if (settings.childNodes[i].nodeType > 1) continue;
			debug("- " + settings.childNodes[i].attributes["name"].value + "=" + settings.childNodes[i].attributes["value"].value);
			_global.settings[settings.childNodes[i].attributes["name"].value] = settings.childNodes[i].attributes["value"].value;
		}
	} else {
		debug(Sarissa.getParseErrorText(xmlhttp.responseXML));
	}
	pollServer(true);
	
	setInterval("pollServer()", _global.settings.webRefreshRate * 1000);
}

addEventListener("load", init, false);