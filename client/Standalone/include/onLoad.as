MovieClip.prototype.addOnLoadHandler = function (path, func) {
	if (MovieClip._onLoadHandler_ == undefined) {
		MovieClip._onLoadHandler_ = {};
	}
	MovieClip._onLoadHandler_[path] = func;
}
ASSetPropFlags(MovieClip, ["addOnLoadHandler"], 1);

sol = function (func) { addOnLoadHandler(this, func);};
gol = function () { return MovieClip._onLoadHandler_[this];};

MovieClip.prototype.addProperty("onLoad", gol, sol);