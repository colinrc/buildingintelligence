_global.settings = new Object();

client_xml = new XML();
client_xml.onLoad = function () {
	var settings = this.firstChild.childNodes;
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
		} else {
			mdm.maximize();
		}
	} else {
		mdm.size(_global.settings.width, _global.settings.height, "true");
	}
	
	// hide mouse if set in config
	if (_global.settings.hideMouseCursor) Mouse.hide();

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

client_xml.load("elife.xml");