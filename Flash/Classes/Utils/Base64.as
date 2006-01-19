class Utils.Base64 {
	public var str:String;
	function Base64(opString:String) {
		str = opString;
	}
	//
	function set string(_str:String) {
		str = _str;
	}
	//
	function get string() {
		return str;
	}
	//
	function encode(opString:String):String {
		opString != undefined ? str=opString : str=str;
		var Base64s:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
		var bits, dual, i:Number = 0, encOut = '';
		while (str.length>=i+3) {
			bits = (str.charCodeAt(i++) & 0xff) << 16 | (str.charCodeAt(i++) & 0xff) << 8 | str.charCodeAt(i++) & 0xff;
			encOut += Base64s.charAt((bits & 0x00fc0000) >> 18)+Base64s.charAt((bits & 0x0003f000) >> 12)+Base64s.charAt((bits & 0x00000fc0) >> 6)+Base64s.charAt((bits & 0x0000003f));
		}
		if (str.length-i>0 && str.length-i<3) {
			dual = Boolean(str.length-i-1);
			bits = ((str.charCodeAt(i++) & 0xff) << 16) | (dual ? (str.charCodeAt(i) & 0xff) << 8 : 0);
			encOut += Base64s.charAt((bits & 0x00fc0000) >> 18)+Base64s.charAt((bits & 0x0003f000) >> 12)+(dual ? Base64s.charAt((bits & 0x00000fc0) >> 6) : '=')+'=';
		}
		return encOut;
	}
	//
	function decode(opString:String):String {
		opString != undefined ? str=opString : str=str;
		var Base64s:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
		var bits, decOut = '', i:Number = 0;
		for (i=0; i<str.length; i += 4) {
			bits = (Base64s.indexOf(str.charAt(i)) & 0xff) << 18 | (Base64s.indexOf(str.charAt(i+1)) & 0xff) << 12 | (Base64s.indexOf(str.charAt(i+2)) & 0xff) << 6 | Base64s.indexOf(str.charAt(i+3)) & 0xff;
			decOut += String.fromCharCode((bits & 0xff0000) >> 16, (bits & 0xff00) >> 8, bits & 0xff);
		}
		if (str.charCodeAt(i-2) == 61) {
			return decOut.substring(0, decOut.length-2);
		} else if (str.charCodeAt(i-1) == 61) {
			return decOut.substring(0, decOut.length-1);
		} else {
			return decOut.substring(0, decOut.length);
		}
	}
}
