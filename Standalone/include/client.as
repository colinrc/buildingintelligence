client_xml = new XML();
client_xml.onLoad = function () {
	parseClientXML(this);
}

parseClientXML = function (xml) {
	var settings = xml.firstChild.childNodes;
	for (var setting=0; setting<settings.length; setting++) {
		if (Number(settings[setting].attributes.value) == settings[setting].attributes.value) {
			_global.settings[settings[setting].attributes.name] = Number(settings[setting].attributes.value);
		} else if (settings[setting].attributes.value == "true" || settings[setting].attributes.value == "false") {
			_global.settings[settings[setting].attributes.name] = (settings[setting].attributes.value == "true");
		} else {
			_global.settings[settings[setting].attributes.name] = settings[setting].attributes.value;
		}
	}

	Stage.align = "TL";
	Stage.scaleMode = (_global.settings.scale) ? "showAll" : "noScale";

	if (_global.settings.fullScreen) {
		if (mdm == undefined) {
			fscommand("fullscreen", true);
			fscommand("showmenu", false);
		} else if (_global.settings.device != "pda") {
			mdm.Application.maximize();
		}
	} else {
		if (_global.settings.device != "pda") {
			mdm.Forms.thisForm.width = _global.settings.width;
			mdm.Forms.thisForm.height = _global.settings.height;
		}
	}
	
	// hide mouse if set in config
	if (_global.settings.hideMouseCursor) Mouse.hide();

	if (_global.settings.device == "pda") {
		_global.settings.tabPosition = "right";
		_global.settings.tabWidth = 80;
		_global.settings.tabHeight = 80;
		_global.settings.tabSpacing = 10;
	}

	_root.counter = 0;
	_root.onEnterFrame = function () {
		counter++;
		if (counter == 10) {
			init();
			delete this.onEnterFrame;
			delete counter;
		}
	}
}

parseClient = function (xml_string) {
	parseClientXML(new XML(xml_string));
}

if (!mdm.Forms.Preview.isCreated) {
	client_xml.load("elife.xml");
}