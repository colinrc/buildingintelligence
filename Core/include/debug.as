setUpDebug = function () {
	if (_global.settings.debugMode) {
		_root.attachMovie("debug", "debug_mc", 9999);
		debug_mc._y = 100;
	}
}

debug = function (msg) {
	if (_global.settings.debugMode) {
		debug_mc.debug_txt.text = msg + "\n" + debug_mc.debug_txt.text;
	}
}